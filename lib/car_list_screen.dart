import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'add_car_screen.dart';
import 'car_detail_screen.dart';
import 'models/car_item.dart';
import 'notifications_screen.dart';
import 'public_garage_search_screen.dart';
import 'repositories/car_image_repository.dart';
import 'repositories/car_repository.dart';
import 'repositories/like_repository.dart';
import 'services/realtime_notification_service.dart';
import 'services/storage_service.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'services/error_logger.dart';
import 'widgets/labeled_car_grid_item.dart';
import 'widgets/shimmer_loading.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final _repository = CarRepository();
  final _imageRepository = CarImageRepository();
  final _likeRepository = LikeRepository();
  final _storageService = StorageService();
  final List<CarItem> _cars = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String _searchQuery = '';
  _SortMode _sortMode = _SortMode.newest;
  int _unreadNotificationCount = 0;
  StreamSubscription<int>? _unreadCountSubscription;
  int _rebuildKey = 0;

  // Advanced filters
  String? _toyNumberPrefixFilter;
  bool? _hasImagesFilter;
  RangeValues _likesRangeFilter = const RangeValues(0, 50);
  _DateRangeFilter _dateRangeFilter = _DateRangeFilter.allTime;

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'signOut');
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.carListSignOutFailed,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCars();
    _subscribeToUnreadCount();
  }

  @override
  void dispose() {
    _unreadCountSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToUnreadCount() {
    _unreadCountSubscription = RealtimeNotificationService
        .instance
        .unreadCountStream
        .listen((count) {
      if (!mounted) return;
      setState(() {
        _unreadNotificationCount = count;
      });
    });
  }

  Future<void> _loadCars() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var items = await _repository.loadCars(user.id);

      // Load likes data for all cars
      if (items.isNotEmpty) {
        final carIds = items
            .map((car) => car.id)
            .whereType<String>()
            .toList();

        if (carIds.isNotEmpty) {
          final likesCounts = await _likeRepository.getLikesCountForCars(carIds);

          items = items.map((car) {
            final carId = car.id;
            if (carId == null) return car;
            return car.copyWith(
              likesCount: likesCounts[carId] ?? 0,
            );
          }).toList();
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _cars
          ..clear()
          ..addAll(items);
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'loadCars');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.carListLoadFailed),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddCar() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Check car limit before opening add screen
    try {
      final canAdd = await _repository.canAddCar(user.id);
      if (!canAdd) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.carLimitReached(CarRepository.maxCarsPerUser))),
        );
        return;
      }
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'canAddCar check');
      // If check fails, let user try anyway (will fail later with proper error)
    }

    if (!mounted) return;

    final result = await Navigator.of(
      context,
    ).push<AddCarResult>(MaterialPageRoute(builder: (_) => const AddCarScreen()));

    if (result == null || !mounted) {
      return;
    }

    await _addCarWithImages(result);
  }

  Future<void> _openEditCar(CarItem car) async {
    final result = await Navigator.of(context).push<AddCarResult>(
      MaterialPageRoute(builder: (_) => AddCarScreen(initialCar: car)),
    );

    if (result == null || car.id == null) {
      return;
    }

    await _updateCarWithImages(result, car.id!);
  }

  Future<void> _openCarDetails(CarItem car) async {
    final result = await Navigator.of(context).push<CarItem>(
      MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)),
    );

    // Force rebuild after navigation completes to clear image rendering issues on Windows
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _rebuildKey++; // Force widget recreation with new keys
        });
      }
    });

    if (result == null) {
      return;
    }
    await _updateCar(result);
  }

  Future<void> _addCarWithImages(AddCarResult result) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // First save the car to get its ID
      final savedCar = await _repository.addCar(result.car, user.id);
      final carId = savedCar.id;

      if (carId == null) {
        throw Exception('Failed to get car ID');
      }

      // Upload pending files and collect all image URLs
      final allImageUrls = <String>[...result.car.galleryUrls];

      for (final file in result.pendingFiles) {
        final uploadedUrl = await _storageService.uploadCarImage(
          file,
          user.id,
          carId,
        );
        if (uploadedUrl != null) {
          allImageUrls.add(uploadedUrl);
        }
      }

      // Add all images to car_images table
      for (final url in allImageUrls) {
        await _imageRepository.addImage(carId, user.id, url);
      }

      // Update local car with gallery URLs
      final carWithGallery = savedCar.copyWith(galleryUrls: allImageUrls);

      if (!mounted) {
        return;
      }
      setState(() {
        _cars.insert(0, carWithGallery);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      String message;
      if (error is CarLimitExceededException) {
        message = l10n.carLimitReached(error.maxCars);
      } else {
        message = l10n.carListSaveCarFailed;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _updateCarWithImages(AddCarResult result, String carId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update the car data
      final updated = await _repository.updateCar(result.car, user.id);

      // Upload pending files and collect all image URLs
      final allImageUrls = <String>[...result.car.galleryUrls];

      for (final file in result.pendingFiles) {
        final uploadedUrl = await _storageService.uploadCarImage(
          file,
          user.id,
          carId,
        );
        if (uploadedUrl != null) {
          allImageUrls.add(uploadedUrl);
        }
      }

      // Delete existing images and add new ones
      await _imageRepository.deleteAllImagesForCar(carId);
      for (final url in allImageUrls) {
        await _imageRepository.addImage(carId, user.id, url);
      }

      // Update local car with gallery URLs
      final carWithGallery = updated.copyWith(galleryUrls: allImageUrls);

      if (!mounted) {
        return;
      }
      setState(() {
        final index = _cars.indexWhere((item) => item.id == carWithGallery.id);
        if (index != -1) {
          _cars[index] = carWithGallery;
        }
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'updateCarWithImages');
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.carListSaveChangesFailed),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _updateCar(CarItem car) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || car.id == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = await _repository.updateCar(car, user.id);

      if (!mounted) {
        return;
      }
      setState(() {
        final index = _cars.indexWhere((item) => item.id == updated.id);
        if (index != -1) {
          _cars[index] = updated;
        }
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'updateCar');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.carListSaveChangesFailed),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _confirmDelete(CarItem car) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.carDeleteTitle),
        content: Text(AppLocalizations.of(context)!.carDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteCar(car);
    }
  }

  Future<void> _deleteCar(CarItem car) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || car.id == null) {
      return;
    }

    try {
      await _repository.deleteCar(car.id!, user.id);

      if (!mounted) {
        return;
      }
      setState(() {
        _cars.removeWhere((item) => item.id == car.id);
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'deleteCar');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.carListDeleteFailed),
        ),
      );
    }
  }

  List<CarItem> _applySearchAndSort() {
    // Step 1: Search filter (text query)
    final query = _searchQuery.trim().toLowerCase();
    var filtered = query.isEmpty
        ? List<CarItem>.from(_cars)
        : _cars.where((car) {
            final title = car.title.toLowerCase();
            final description = car.description?.toLowerCase() ?? '';
            return title.contains(query) || description.contains(query);
          }).toList();

    // Step 2: Toy Number prefix filter
    if (_toyNumberPrefixFilter != null && _toyNumberPrefixFilter!.isNotEmpty) {
      filtered = filtered.where((car) {
        return car.toyNumberPrefix == _toyNumberPrefixFilter;
      }).toList();
    }

    // Step 3: Has images filter
    if (_hasImagesFilter != null) {
      filtered = filtered.where((car) {
        return car.hasImages == _hasImagesFilter;
      }).toList();
    }

    // Step 4: Likes range filter
    filtered = filtered.where((car) {
      return car.likesCount >= _likesRangeFilter.start.round() &&
          car.likesCount <= _likesRangeFilter.end.round();
    }).toList();

    // Step 5: Date range filter
    if (_dateRangeFilter != _DateRangeFilter.allTime) {
      final now = DateTime.now();
      DateTime? cutoffDate;

      switch (_dateRangeFilter) {
        case _DateRangeFilter.last7Days:
          cutoffDate = now.subtract(const Duration(days: 7));
          break;
        case _DateRangeFilter.last30Days:
          cutoffDate = now.subtract(const Duration(days: 30));
          break;
        case _DateRangeFilter.last90Days:
          cutoffDate = now.subtract(const Duration(days: 90));
          break;
        case _DateRangeFilter.allTime:
          break;
      }

      if (cutoffDate != null) {
        filtered = filtered.where((car) {
          return car.createdAt != null && car.createdAt!.isAfter(cutoffDate!);
        }).toList();
      }
    }

    // Step 6: Sort
    int compareByTitle(CarItem a, CarItem b, {required bool asc}) {
      final value = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      return asc ? value : -value;
    }

    int compareByDate(CarItem a, CarItem b, {required bool asc}) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final value = aDate.compareTo(bDate);
      return asc ? value : -value;
    }

    switch (_sortMode) {
      case _SortMode.newest:
        filtered.sort((a, b) => compareByDate(a, b, asc: false));
        break;
      case _SortMode.oldest:
        filtered.sort((a, b) => compareByDate(a, b, asc: true));
        break;
      case _SortMode.az:
        filtered.sort((a, b) => compareByTitle(a, b, asc: true));
        break;
      case _SortMode.za:
        filtered.sort((a, b) => compareByTitle(a, b, asc: false));
        break;
    }

    return filtered;
  }

  /// Get unique Toy Number prefixes from all cars
  List<String> _getToyNumberPrefixes() {
    final prefixes = <String>{};
    for (final car in _cars) {
      if (car.toyNumberPrefix.isNotEmpty) {
        prefixes.add(car.toyNumberPrefix);
      }
    }
    final sorted = prefixes.toList()..sort();
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final visibleCars = _applySearchAndSort();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6A00), // Hot Wheels Orange
                Color(0xFFFF8533), // Lighter Orange
              ],
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PublicGarageSearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.explore, size: 20),
            label: Text(l10n.exploreGarages),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
        leadingWidth: 110,
        actions: [
          IconButton(
            tooltip: l10n.notificationBellTooltip,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
              RealtimeNotificationService.instance.notifyUnreadCountChanged();
            },
            icon: Badge(
              isLabelVisible: _unreadNotificationCount > 0,
              label: Text(
                _unreadNotificationCount > 9
                    ? '9+'
                    : _unreadNotificationCount.toString(),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            tooltip: l10n.statisticsTooltip,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            tooltip: l10n.settingsTooltip,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            tooltip: l10n.logoutTooltip,
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: _cars.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _isSaving ? null : _openAddCar,
              child: const Icon(Icons.add),
            ),
      body: _isLoading
          ? const ShimmerCarGrid()
          : _cars.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.garageEmpty,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _openAddCar,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addCar),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final padding = isWide ? 24.0 : 20.0;

                return RefreshIndicator(
                  onRefresh: _loadCars,
                  child: CustomScrollView(
                    slivers: [
                      // Controls section
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(padding, padding, padding, 12),
                        sliver: SliverToBoxAdapter(
                          child: _GarageControls(
                            searchQuery: _searchQuery,
                            sortMode: _sortMode,
                            onSearchChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            onSortChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _sortMode = value;
                              });
                            },
                            toyNumberPrefixes: _getToyNumberPrefixes(),
                            toyNumberPrefixFilter: _toyNumberPrefixFilter,
                            onToyNumberPrefixChanged: (value) {
                              setState(() {
                                _toyNumberPrefixFilter = value;
                              });
                            },
                            hasImagesFilter: _hasImagesFilter,
                            onHasImagesChanged: (value) {
                              setState(() {
                                _hasImagesFilter = value;
                              });
                            },
                            likesRangeFilter: _likesRangeFilter,
                            onLikesRangeChanged: (value) {
                              setState(() {
                                _likesRangeFilter = value;
                              });
                            },
                            dateRangeFilter: _dateRangeFilter,
                            onDateRangeChanged: (value) {
                              setState(() {
                                _dateRangeFilter = value;
                              });
                            },
                            onClearFilters: () {
                              setState(() {
                                _toyNumberPrefixFilter = null;
                                _hasImagesFilter = null;
                                _likesRangeFilter = const RangeValues(0, 50);
                                _dateRangeFilter = _DateRangeFilter.allTime;
                              });
                            },
                            totalCars: _cars.length,
                            filteredCars: visibleCars.length,
                          ),
                        ),
                      ),
                      // Empty state or car grid (Instagram style)
                      if (visibleCars.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(l10n.searchNoResults),
                          ),
                        )
                      else
                        // Instagram-style 3-column grid
                        SliverPadding(
                          padding: const EdgeInsets.all(2),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 4 : 3,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final car = visibleCars[index];
                                return LabeledCarGridItem(
                                  key: ValueKey('${car.id}_$_rebuildKey'),
                                  car: car,
                                  onTap: () => _openCarDetails(car),
                                  showLabel: true,
                                  showEditActions: true,
                                  onEdit: _isSaving ? null : () => _openEditCar(car),
                                  onDelete: _isSaving ? null : () => _confirmDelete(car),
                                );
                              },
                              childCount: visibleCars.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _GarageControls extends StatelessWidget {
  const _GarageControls({
    required this.searchQuery,
    required this.sortMode,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.toyNumberPrefixes,
    required this.toyNumberPrefixFilter,
    required this.onToyNumberPrefixChanged,
    required this.hasImagesFilter,
    required this.onHasImagesChanged,
    required this.likesRangeFilter,
    required this.onLikesRangeChanged,
    required this.dateRangeFilter,
    required this.onDateRangeChanged,
    required this.onClearFilters,
    required this.totalCars,
    required this.filteredCars,
  });

  final String searchQuery;
  final _SortMode sortMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_SortMode?> onSortChanged;
  final List<String> toyNumberPrefixes;
  final String? toyNumberPrefixFilter;
  final ValueChanged<String?> onToyNumberPrefixChanged;
  final bool? hasImagesFilter;
  final ValueChanged<bool?> onHasImagesChanged;
  final RangeValues likesRangeFilter;
  final ValueChanged<RangeValues> onLikesRangeChanged;
  final _DateRangeFilter dateRangeFilter;
  final ValueChanged<_DateRangeFilter> onDateRangeChanged;
  final VoidCallback onClearFilters;
  final int totalCars;
  final int filteredCars;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Check if any filters are active
    final hasActiveFilters = toyNumberPrefixFilter != null ||
        hasImagesFilter != null ||
        likesRangeFilter.start > 0 ||
        likesRangeFilter.end < 50 ||
        dateRangeFilter != _DateRangeFilter.allTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            labelText: l10n.searchGarageLabel,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<_SortMode>(
          initialValue: sortMode,
          onChanged: onSortChanged,
          decoration: InputDecoration(labelText: l10n.sortLabel),
          items: [
            DropdownMenuItem(
              value: _SortMode.newest,
              child: Text(l10n.sortNewest),
            ),
            DropdownMenuItem(
              value: _SortMode.oldest,
              child: Text(l10n.sortOldest),
            ),
            DropdownMenuItem(value: _SortMode.az, child: Text(l10n.sortAz)),
            DropdownMenuItem(value: _SortMode.za, child: Text(l10n.sortZa)),
          ],
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: Row(
            children: [
              Text(l10n.advancedFilters),
              if (hasActiveFilters) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '✓',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Toy Number Prefix Filter
                  if (toyNumberPrefixes.isNotEmpty) ...[
                    DropdownButtonFormField<String?>(
                      initialValue: toyNumberPrefixFilter,
                      onChanged: onToyNumberPrefixChanged,
                      decoration: InputDecoration(
                        labelText: l10n.toyNumberPrefixFilter,
                        prefixIcon: const Icon(Icons.confirmation_number_outlined),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.toyNumberPrefixAll),
                        ),
                        ...toyNumberPrefixes.map(
                          (prefix) => DropdownMenuItem<String?>(
                            value: prefix,
                            child: Text(prefix),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Has Images Filter
                  DropdownButtonFormField<bool?>(
                    initialValue: hasImagesFilter,
                    onChanged: onHasImagesChanged,
                    decoration: InputDecoration(
                      labelText: l10n.hasImagesFilter,
                      prefixIcon: const Icon(Icons.image_outlined),
                    ),
                    items: [
                      DropdownMenuItem<bool?>(
                        value: null,
                        child: Text(l10n.hasImagesAll),
                      ),
                      DropdownMenuItem<bool?>(
                        value: true,
                        child: Text(l10n.hasImagesYes),
                      ),
                      DropdownMenuItem<bool?>(
                        value: false,
                        child: Text(l10n.hasImagesNo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Likes Range Filter
                  Text(
                    '${l10n.likesRangeFilter}: ${likesRangeFilter.start.round()}-${likesRangeFilter.end.round()}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  RangeSlider(
                    values: likesRangeFilter,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: onLikesRangeChanged,
                  ),
                  const SizedBox(height: 16),
                  // Date Range Filter
                  DropdownButtonFormField<_DateRangeFilter>(
                    initialValue: dateRangeFilter,
                    onChanged: (value) {
                      if (value != null) onDateRangeChanged(value);
                    },
                    decoration: InputDecoration(
                      labelText: l10n.dateRangeFilter,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: _DateRangeFilter.allTime,
                        child: Text(l10n.dateRangeAllTime),
                      ),
                      DropdownMenuItem(
                        value: _DateRangeFilter.last7Days,
                        child: Text(l10n.dateRangeLast7Days),
                      ),
                      DropdownMenuItem(
                        value: _DateRangeFilter.last30Days,
                        child: Text(l10n.dateRangeLast30Days),
                      ),
                      DropdownMenuItem(
                        value: _DateRangeFilter.last90Days,
                        child: Text(l10n.dateRangeLast90Days),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Clear Filters Button
                  if (hasActiveFilters)
                    TextButton.icon(
                      onPressed: onClearFilters,
                      icon: const Icon(Icons.clear),
                      label: Text(l10n.clearFilters),
                    ),
                ],
              ),
            ),
          ],
        ),
        // Results count
        if (filteredCars != totalCars) ...[
          const SizedBox(height: 8),
          Text(
            l10n.showingXofYCars(filteredCars, totalCars),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

enum _SortMode { newest, oldest, az, za }

enum _DateRangeFilter {
  last7Days,
  last30Days,
  last90Days,
  allTime,
}
