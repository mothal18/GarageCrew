import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'models/car_item.dart';
import 'models/garage_statistics.dart';
import 'repositories/car_repository.dart';
import 'repositories/follow_repository.dart';
import 'repositories/like_repository.dart';
import 'widgets/car_thumbnail.dart';
import 'widgets/return_to_garage_button.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _carRepository = CarRepository();
  final _followRepository = FollowRepository();
  final _likeRepository = LikeRepository();

  GarageStatistics? _statistics;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No user signed in';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parallel loading of all data
      final results = await Future.wait([
        _carRepository.loadCars(user.id),
        _followRepository.getFollowersCount(user.id),
        _followRepository.getFollowingCount(user.id),
        _carRepository.getRecentCars(user.id, days: 7),
        _carRepository.getRecentCars(user.id, days: 30),
        _carRepository.getFirstCarDate(user.id),
      ]);

      final allCars = results[0] as List<CarItem>;
      final followersCount = results[1] as int;
      final followingCount = results[2] as int;
      final carsThisWeek = (results[3] as List<CarItem>).length;
      final carsThisMonth = (results[4] as List<CarItem>).length;
      final firstCarDate = results[5] as DateTime?;

      // Get likes for all cars
      final carIds = allCars.map((car) => car.id!).toList();
      var carsWithLikes = allCars;

      if (carIds.isNotEmpty) {
        final likesData = await _likeRepository.getLikesCountForCars(carIds);
        carsWithLikes = allCars.map((car) {
          final likesCount = likesData[car.id] ?? 0;
          final isLiked = false; // Not needed for stats
          return car.copyWith(likesCount: likesCount, isLiked: isLiked);
        }).toList();
      }

      // Calculate statistics
      final totalLikes = carsWithLikes.fold<int>(
        0,
        (sum, car) => sum + car.likesCount,
      );

      final mostLikedCar = carsWithLikes.isEmpty
          ? null
          : carsWithLikes.reduce(
              (a, b) => a.likesCount > b.likesCount ? a : b,
            );

      final averageLikes = carsWithLikes.isEmpty
          ? 0.0
          : totalLikes / carsWithLikes.length;

      // Group by Toy Number prefix
      final carsByPrefix = <String, int>{};
      for (final car in carsWithLikes) {
        if (car.toyNumberPrefix.isNotEmpty) {
          carsByPrefix[car.toyNumberPrefix] =
              (carsByPrefix[car.toyNumberPrefix] ?? 0) + 1;
        }
      }

      final carsWithImages =
          carsWithLikes.where((car) => car.hasImages).length;
      final carsWithoutImages = carsWithLikes.length - carsWithImages;

      final stats = GarageStatistics(
        totalCars: carsWithLikes.length,
        totalLikes: totalLikes,
        followersCount: followersCount,
        followingCount: followingCount,
        mostLikedCar: mostLikedCar,
        averageLikesPerCar: averageLikes,
        carsByToyNumberPrefix: carsByPrefix,
        carsWithImages: carsWithImages,
        carsWithoutImages: carsWithoutImages,
        carsAddedThisWeek: carsThisWeek,
        carsAddedThisMonth: carsThisMonth,
        firstCarDate: firstCarDate,
      );

      if (mounted) {
        setState(() {
          _statistics = stats;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      }
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
        title: Text(l10n.statisticsTitle),
        actions: const [
          ReturnToGarageButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.statisticsLoadFailed,
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadStatistics,
                          child: Text(l10n.splashRetry),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: _statistics == null
                      ? Center(child: Text(l10n.garageEmpty))
                      : _buildStatisticsContent(_statistics!),
                ),
    );
  }

  Widget _buildStatisticsContent(GarageStatistics stats) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Overview Section
        _StatCard(
          title: l10n.overviewSection,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.directions_car,
                      label: l10n.totalCars,
                      value: '${stats.totalCars}',
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.favorite,
                      label: l10n.totalLikes,
                      value: '${stats.totalLikes}',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.people,
                      label: l10n.followers,
                      value: '${stats.followersCount}',
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.person_add,
                      label: l10n.followingCount,
                      value: '${stats.followingCount}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Popularity Section
        _StatCard(
          title: l10n.popularitySection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (stats.mostLikedCar != null) ...[
                Text(
                  l10n.mostLikedCar,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _MostLikedCarWidget(car: stats.mostLikedCar!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.favorite_outline,
                      label: l10n.averageLikes,
                      value: stats.averageLikesPerCar.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Collection Section
        _StatCard(
          title: l10n.collectionSection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.image,
                      label: l10n.carsWithImages,
                      value: '${stats.carsWithImages}',
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.confirmation_number,
                      label: l10n.carsByToyNumber,
                      value: '${stats.totalUniqueSeries}',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              if (stats.carsByToyNumberPrefix.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  '${l10n.toyNumberPrefixFilter}:',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...stats.carsByToyNumberPrefix.entries
                    .toList()
                    .take(5)
                    .map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Activity Section
        _StatCard(
          title: l10n.activitySection,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.today,
                      label: l10n.carsAddedThisWeek,
                      value: '${stats.carsAddedThisWeek}',
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.calendar_month,
                      label: l10n.carsAddedThisMonth,
                      value: '${stats.carsAddedThisMonth}',
                    ),
                  ),
                ],
              ),
              if (stats.firstCarDate != null) ...[
                const SizedBox(height: 16),
                _StatColumn(
                  icon: Icons.access_time,
                  label: l10n.collectionAge,
                  value: l10n.collectionAgeDays(stats.collectionAgeDays),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color ?? theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color ?? theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MostLikedCarWidget extends StatelessWidget {
  const _MostLikedCarWidget({required this.car});

  final CarItem car;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CarThumbnail(
              url: car.primaryImageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (car.toyNumber.isNotEmpty)
                  Text(
                    car.toyNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${car.likesCount}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
