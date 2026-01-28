import 'car_item.dart';

/// Statistics data for a user's garage collection
class GarageStatistics {
  const GarageStatistics({
    required this.totalCars,
    required this.totalLikes,
    required this.followersCount,
    required this.followingCount,
    this.mostLikedCar,
    required this.averageLikesPerCar,
    required this.carsByToyNumberPrefix,
    required this.carsWithImages,
    required this.carsWithoutImages,
    required this.carsAddedThisWeek,
    required this.carsAddedThisMonth,
    this.firstCarDate,
  });

  final int totalCars;
  final int totalLikes;
  final int followersCount;
  final int followingCount;
  final CarItem? mostLikedCar;
  final double averageLikesPerCar;
  final Map<String, int> carsByToyNumberPrefix;
  final int carsWithImages;
  final int carsWithoutImages;
  final int carsAddedThisWeek;
  final int carsAddedThisMonth;
  final DateTime? firstCarDate;

  /// Collection age in days
  int get collectionAgeDays {
    if (firstCarDate == null) return 0;
    return DateTime.now().difference(firstCarDate!).inDays;
  }

  /// Total unique Toy Number series
  int get totalUniqueSeries => carsByToyNumberPrefix.length;

  /// Cars without Toy Number
  int get carsWithoutToyNumber =>
      totalCars - carsByToyNumberPrefix.values.fold(0, (a, b) => a + b);
}
