import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:garage_crew/widgets/car_thumbnail.dart';

void main() {
  testWidgets('CarThumbnail shows fallback icon when url is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CarThumbnail(url: null),
        ),
      ),
    );

    expect(find.byIcon(Icons.directions_car_filled_outlined), findsOneWidget);
  });
}
