import 'package:flutter_test/flutter_test.dart';
import 'package:garage_crew/models/car_item.dart';

void main() {
  group('CarItem.fromMap', () {
    test('parses complete map correctly', () {
      final car = CarItem.fromMap({
        'id': '123',
        'title': 'Porsche 911',
        'description': 'A nice car',
        'image_url': 'https://example.com/img.jpg',
        'created_at': '2025-01-15T10:30:00Z',
        'gallery_urls': ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
        'toy_number': 'JJM02',
        'quantity': 3,
        'variant': 'TH',
      });

      expect(car.id, '123');
      expect(car.title, 'Porsche 911');
      expect(car.description, 'A nice car');
      expect(car.imageUrl, 'https://example.com/img.jpg');
      expect(car.createdAt, isNotNull);
      expect(car.galleryUrls, ['https://example.com/1.jpg', 'https://example.com/2.jpg']);
      expect(car.toyNumber, 'JJM02');
      expect(car.quantity, 3);
      expect(car.variant, 'TH');
    });

    test('handles missing optional fields', () {
      final car = CarItem.fromMap({
        'title': 'Basic Car',
      });

      expect(car.id, isNull);
      expect(car.title, 'Basic Car');
      expect(car.description, isNull);
      expect(car.imageUrl, isNull);
      expect(car.createdAt, isNull);
      expect(car.galleryUrls, isEmpty);
      expect(car.toyNumber, '');
      expect(car.quantity, 1);
      expect(car.variant, isNull);
    });

    test('handles null title gracefully', () {
      final car = CarItem.fromMap({
        'title': null,
      });

      expect(car.title, '');
    });

    test('filters empty strings from gallery_urls', () {
      final car = CarItem.fromMap({
        'title': 'Car',
        'gallery_urls': ['https://example.com/1.jpg', null, '', 'https://example.com/2.jpg'],
      });

      expect(car.galleryUrls, ['https://example.com/1.jpg', 'https://example.com/2.jpg']);
    });

    test('handles non-list gallery_urls', () {
      final car = CarItem.fromMap({
        'title': 'Car',
        'gallery_urls': 'not a list',
      });

      expect(car.galleryUrls, isEmpty);
    });

    test('parses id as string regardless of input type', () {
      final car = CarItem.fromMap({
        'id': 42,
        'title': 'Car',
      });

      expect(car.id, '42');
    });
  });

  group('CarItem computed properties', () {
    test('primaryImageUrl returns first gallery URL', () {
      const car = CarItem(
        title: 'Car',
        galleryUrls: ['https://a.jpg', 'https://b.jpg'],
        imageUrl: 'https://legacy.jpg',
      );

      expect(car.primaryImageUrl, 'https://a.jpg');
    });

    test('primaryImageUrl falls back to legacy imageUrl', () {
      const car = CarItem(
        title: 'Car',
        imageUrl: 'https://legacy.jpg',
      );

      expect(car.primaryImageUrl, 'https://legacy.jpg');
    });

    test('primaryImageUrl returns null when no images', () {
      const car = CarItem(title: 'Car');

      expect(car.primaryImageUrl, isNull);
    });

    test('allImageUrls returns gallery when present', () {
      const car = CarItem(
        title: 'Car',
        galleryUrls: ['https://a.jpg', 'https://b.jpg'],
        imageUrl: 'https://legacy.jpg',
      );

      expect(car.allImageUrls, ['https://a.jpg', 'https://b.jpg']);
    });

    test('allImageUrls falls back to legacy imageUrl', () {
      const car = CarItem(
        title: 'Car',
        imageUrl: 'https://legacy.jpg',
      );

      expect(car.allImageUrls, ['https://legacy.jpg']);
    });

    test('allImageUrls returns empty list when no images', () {
      const car = CarItem(title: 'Car');

      expect(car.allImageUrls, isEmpty);
    });

    test('hasImages is true when gallery has URLs', () {
      const car = CarItem(
        title: 'Car',
        galleryUrls: ['https://a.jpg'],
      );

      expect(car.hasImages, isTrue);
    });

    test('hasImages is false when gallery is empty', () {
      const car = CarItem(
        title: 'Car',
        imageUrl: 'https://legacy.jpg',
      );

      expect(car.hasImages, isFalse);
    });

    test('toyNumberPrefix returns first 3 chars', () {
      const car = CarItem(title: 'Car', toyNumber: 'JJM02');

      expect(car.toyNumberPrefix, 'JJM');
    });

    test('toyNumberPrefix returns empty for short toy numbers', () {
      const car = CarItem(title: 'Car', toyNumber: 'AB');

      expect(car.toyNumberPrefix, '');
    });
  });

  group('CarItem.copyWith', () {
    test('copies all fields', () {
      const original = CarItem(
        id: '1',
        title: 'Original',
        description: 'Desc',
        imageUrl: 'https://img.jpg',
        galleryUrls: ['https://a.jpg'],
        likesCount: 5,
        isLiked: true,
        toyNumber: 'ABC12',
        quantity: 2,
        variant: 'TH',
      );

      final copy = original.copyWith(title: 'Updated');

      expect(copy.id, '1');
      expect(copy.title, 'Updated');
      expect(copy.description, 'Desc');
      expect(copy.imageUrl, 'https://img.jpg');
      expect(copy.galleryUrls, ['https://a.jpg']);
      expect(copy.likesCount, 5);
      expect(copy.isLiked, true);
      expect(copy.toyNumber, 'ABC12');
      expect(copy.quantity, 2);
      expect(copy.variant, 'TH');
    });

    test('preserves unchanged fields', () {
      const original = CarItem(title: 'Original', toyNumber: 'ABC12');
      final copy = original.copyWith();

      expect(copy.title, 'Original');
      expect(copy.toyNumber, 'ABC12');
    });
  });

  group('CarItem.toInsertMap', () {
    test('generates correct insert map', () {
      const car = CarItem(
        title: 'Porsche 911',
        description: 'Fast car',
        imageUrl: 'https://img.jpg',
        toyNumber: 'JJM02',
        quantity: 2,
        variant: 'Mint',
      );

      final map = car.toInsertMap('user-123');

      expect(map['user_id'], 'user-123');
      expect(map['title'], 'Porsche 911');
      expect(map['description'], 'Fast car');
      expect(map['image_url'], 'https://img.jpg');
      expect(map['toy_number'], 'JJM02');
      expect(map['quantity'], 2);
      expect(map['variant'], 'Mint');
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('created_at'), isFalse);
    });
  });
}
