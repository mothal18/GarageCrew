import 'package:flutter/material.dart';

/// Button to quickly return to the user's garage (CarListScreen)
///
/// Usage in AppBar:
/// ```dart
/// appBar: AppBar(
///   actions: [
///     ReturnToGarageButton(),
///     // ... other actions
///   ],
/// ),
/// ```
class ReturnToGarageButton extends StatelessWidget {
  const ReturnToGarageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.garage_outlined),
      tooltip: 'Mój garaż',
      onPressed: () {
        // Pop until we reach the CarListScreen (root screen)
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
