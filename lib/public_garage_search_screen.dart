import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'models/car_item.dart';
import 'repositories/car_image_repository.dart';
import 'repositories/follow_repository.dart';
import 'repositories/like_repository.dart';
import 'repositories/profile_repository.dart';
import 'services/error_logger.dart';
import 'utils/date_formatter.dart';
import 'widgets/car_image_gallery.dart';
import 'widgets/car_thumbnail.dart';
import 'widgets/labeled_car_grid_item.dart';
import 'widgets/return_to_garage_button.dart';

class PublicGarageSearchScreen extends StatefulWidget {
  const PublicGarageSearchScreen({super.key});

  @override
  State<PublicGarageSearchScreen> createState() =>
      _PublicGarageSearchScreenState();
}

class _PublicGarageSearchScreenState extends State<PublicGarageSearchScreen> {
  static const _profilesTable = 'profiles';
  final _searchController = TextEditingController();
  final List<_PublicProfile> _profiles = [];
  Timer? _searchDebounce;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _searchProfiles();
    });
  }

  Future<void> _searchProfiles() async {
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _profiles.clear();
        _errorMessage = null;
      });
      return;
    }

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = Supabase.instance.client
          .from(_profilesTable)
          .select('id, login, garage_name')
          .eq('is_public', true)
          .or('login.ilike.%$query%,garage_name.ilike.%$query%');
      final data = await (currentUserId == null
          ? request.order('login', ascending: true)
          : request.neq('id', currentUserId).order('login', ascending: true));

      final profiles = (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((row) => _PublicProfile.fromMap(row))
          .where((profile) => profile.login.isNotEmpty)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _profiles
          ..clear()
          ..addAll(profiles);
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'searchProfiles');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.publicGaragesLoadFailed;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openGarage(_PublicProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicGarageDetailScreen(
          userId: profile.id,
          login: profile.login,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.publicGaragesTitle),
        actions: const [
          ReturnToGarageButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchProfiles(),
            onChanged: (value) {
              setState(() {
                _errorMessage = null;
              });
              _onQueryChanged(value);
            },
            decoration: InputDecoration(
              labelText: l10n.publicSearchLabel,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: l10n.publicSearchTooltip,
                onPressed: _isLoading ? null : _searchProfiles,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_searchController.text.trim().length < 2)
            Text(l10n.publicSearchHint),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          if (!_isLoading &&
              _searchController.text.trim().length >= 2 &&
              _profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l10n.publicSearchNoResults),
            ),
          if (_profiles.isNotEmpty)
            ..._profiles.map(
              (profile) => Card(
                child: ListTile(
                  onTap: () => _openGarage(profile),
                  title: Text(profile.login),
                  subtitle: Text(
                    profile.garageName?.trim().isNotEmpty == true
                        ? profile.garageName!
                        : l10n.publicGarageSubtitle,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PublicGarageDetailScreen extends StatefulWidget {
  const PublicGarageDetailScreen({
    super.key,
    required this.userId,
    required this.login,
  });

  final String userId;
  final String login;

  @override
  State<PublicGarageDetailScreen> createState() =>
      _PublicGarageDetailScreenState();
}

class _PublicGarageDetailScreenState extends State<PublicGarageDetailScreen> {
  static const _carsTable = 'garage_cars';
  final _profileRepository = ProfileRepository();
  final _followRepository = FollowRepository();
  final _likeRepository = LikeRepository();
  final List<CarItem> _cars = [];
  ProfileData? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFollowing = false;
  int _followersCount = 0;
  bool _isTogglingFollow = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    try {
      final profileFuture = _profileRepository.loadPublicProfile(widget.userId);
      final carsFuture = Supabase.instance.client
          .from(_carsTable)
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);
      final followersCountFuture = _followRepository.getFollowersCount(widget.userId);
      final isFollowingFuture = currentUserId != null
          ? _followRepository.isFollowing(currentUserId, widget.userId)
          : Future.value(false);

      final profile = await profileFuture;
      final carsData = await carsFuture;
      final followersCount = await followersCountFuture;
      final isFollowing = await isFollowingFuture;

      var items = (carsData as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(CarItem.fromMap)
          .toList();

      // Load likes data for all cars
      if (items.isNotEmpty) {
        final carIds = items
            .map((car) => car.id)
            .whereType<String>()
            .toList();

        if (carIds.isNotEmpty) {
          final likesCountsFuture = _likeRepository.getLikesCountForCars(carIds);
          final likedIdsFuture = currentUserId != null
              ? _likeRepository.getLikedCarIds(currentUserId, carIds)
              : Future.value(<String>{});

          final likesCounts = await likesCountsFuture;
          final likedIds = await likedIdsFuture;

          items = items.map((car) {
            final carId = car.id;
            if (carId == null) return car;
            return car.copyWith(
              likesCount: likesCounts[carId] ?? 0,
              isLiked: likedIds.contains(carId),
            );
          }).toList();
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = profile;
        _cars
          ..clear()
          ..addAll(items);
        _followersCount = followersCount;
        _isFollowing = isFollowing;
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'loadGarage');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.publicGarageCarsLoadFailed;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null || _isTogglingFollow) {
      return;
    }

    setState(() {
      _isTogglingFollow = true;
    });

    try {
      if (_isFollowing) {
        await _followRepository.unfollow(currentUserId, widget.userId);
        if (!mounted) return;
        setState(() {
          _isFollowing = false;
          _followersCount = (_followersCount - 1).clamp(0, double.maxFinite.toInt());
        });
      } else {
        await _followRepository.follow(currentUserId, widget.userId);
        if (!mounted) return;
        setState(() {
          _isFollowing = true;
          _followersCount++;
        });
      }
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'toggleFollow');
      // Silently ignore errors (don't show to user)
    } finally {
      if (!mounted) return;
      setState(() {
        _isTogglingFollow = false;
      });
    }
  }

  void _openCarDetails(CarItem car) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PublicCarDetailScreen(car: car),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
        title: Text('@${widget.login}'),
        actions: const [
          ReturnToGarageButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: CustomScrollView(
                    slivers: [
                      // Profile Header
                      SliverToBoxAdapter(
                        child: _ProfileHeader(
                          profile: _profile,
                          login: widget.login,
                          carsCount: _cars.length,
                          followersCount: _followersCount,
                          isFollowing: _isFollowing,
                          isTogglingFollow: _isTogglingFollow,
                          onToggleFollow: _toggleFollow,
                        ),
                      ),
                      // Divider
                      const SliverToBoxAdapter(
                        child: Divider(height: 1),
                      ),
                      // Cars Grid or Empty State
                      if (_cars.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.directions_car_outlined,
                                    size: 64,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.publicGarageEmpty,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(2),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final car = _cars[index];
                                return LabeledCarGridItem(
                                  car: car,
                                  onTap: () => _openCarDetails(car),
                                );
                              },
                              childCount: _cars.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.login,
    required this.carsCount,
    required this.followersCount,
    required this.isFollowing,
    required this.isTogglingFollow,
    required this.onToggleFollow,
  });

  final ProfileData? profile;
  final String login;
  final int carsCount;
  final int followersCount;
  final bool isFollowing;
  final bool isTogglingFollow;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final garageName = profile?.garageName.trim();
    final bio = profile?.bio.trim();
    final avatarUrl = profile?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CarThumbnail(
                    url: avatarUrl?.isNotEmpty == true ? avatarUrl : null,
                    size: 86,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(
                      value: carsCount.toString(),
                      label: l10n.carsCount(carsCount),
                    ),
                    _StatColumn(
                      value: followersCount.toString(),
                      label: l10n.followersCount(followersCount),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Garage name
          if (garageName?.isNotEmpty == true) ...[
            Text(
              garageName!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
          ],
          // Username
          Text(
            '@$login',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Bio
          if (bio?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              bio!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          // Follow button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: isFollowing
                ? OutlinedButton.icon(
                    onPressed: isTogglingFollow ? null : onToggleFollow,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.following),
                  )
                : FilledButton.icon(
                    onPressed: isTogglingFollow ? null : onToggleFollow,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.follow),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PublicCarDetailScreen extends StatefulWidget {
  const _PublicCarDetailScreen({required this.car});

  final CarItem car;

  @override
  State<_PublicCarDetailScreen> createState() => _PublicCarDetailScreenState();
}

class _PublicCarDetailScreenState extends State<_PublicCarDetailScreen> {
  final _imageRepository = CarImageRepository();
  final _likeRepository = LikeRepository();
  List<String> _galleryUrls = [];
  bool _isLoadingImages = true;
  bool _isLiked = false;
  int _likesCount = 0;
  bool _isTogglingLike = false;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
    _loadLikeStatus();
  }

  Future<void> _loadGalleryImages() async {
    final carId = widget.car.id;
    if (carId == null) {
      setState(() {
        _isLoadingImages = false;
        _galleryUrls = widget.car.allImageUrls;
      });
      return;
    }

    try {
      final urls = await _imageRepository.getImageUrlsForCar(carId);
      if (!mounted) return;

      setState(() {
        _galleryUrls = urls.isNotEmpty ? urls : widget.car.allImageUrls;
        _isLoadingImages = false;
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'loadGalleryImages');
      if (!mounted) return;
      setState(() {
        _galleryUrls = widget.car.allImageUrls;
        _isLoadingImages = false;
      });
    }
  }

  Future<void> _loadLikeStatus() async {
    final carId = widget.car.id;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (carId == null) return;

    try {
      final countFuture = _likeRepository.getLikesCount(carId);
      final isLikedFuture = userId != null
          ? _likeRepository.isLiked(carId, userId)
          : Future.value(false);

      final count = await countFuture;
      final isLiked = await isLikedFuture;

      if (!mounted) return;
      setState(() {
        _likesCount = count;
        _isLiked = isLiked;
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'loadLikeData');
      // Silently ignore (don't show to user)
    }
  }

  Future<void> _toggleLike() async {
    final carId = widget.car.id;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (carId == null || userId == null || _isTogglingLike) return;

    setState(() {
      _isTogglingLike = true;
    });

    try {
      if (_isLiked) {
        await _likeRepository.unlike(carId, userId);
        if (!mounted) return;
        setState(() {
          _isLiked = false;
          _likesCount = (_likesCount - 1).clamp(0, double.maxFinite.toInt());
        });
      } else {
        await _likeRepository.like(carId, userId);
        if (!mounted) return;
        setState(() {
          _isLiked = true;
          _likesCount++;
        });
      }
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'toggleLike');
      // Silently ignore (don't show to user)
    } finally {
      if (!mounted) return;
      setState(() {
        _isTogglingLike = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.carDetailsTitle),
        actions: const [
          ReturnToGarageButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            if (_isLoadingImages)
              const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              CarImageGallery(
                imageUrls: _galleryUrls,
                height: 220,
                heroTagPrefix: 'public_car_${widget.car.id}',
                onTap: _galleryUrls.isNotEmpty
                    ? () => FullScreenImageGallery.show(
                          context,
                          imageUrls: _galleryUrls,
                          heroTagPrefix: 'public_car_${widget.car.id}',
                        )
                    : null,
              ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.car.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _LikeButton(
                  isLiked: _isLiked,
                  likesCount: _likesCount,
                  isLoading: _isTogglingLike,
                  onTap: _toggleLike,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.car.description?.trim().isNotEmpty == true
                  ? widget.car.description!
                  : l10n.noDescription,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (widget.car.createdAt != null) ...[
              Text(
                l10n.addedAtLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(DateFormatter.formatDateTime(widget.car.createdAt!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PublicProfile {
  const _PublicProfile({
    required this.id,
    required this.login,
    this.garageName,
  });

  final String id;
  final String login;
  final String? garageName;

  factory _PublicProfile.fromMap(Map<String, dynamic> map) {
    return _PublicProfile(
      id: map['id']?.toString() ?? '',
      login: map['login'] as String? ?? '',
      garageName: map['garage_name'] as String?,
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.isLiked,
    required this.likesCount,
    required this.isLoading,
    required this.onTap,
  });

  final bool isLiked;
  final int likesCount;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isLiked),
                  color: isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
              if (likesCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '$likesCount',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
