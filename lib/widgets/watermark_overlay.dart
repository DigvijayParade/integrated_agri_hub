import 'package:flutter/material.dart';

class WatermarkOverlay extends StatelessWidget {
  final Widget child;

  const WatermarkOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.1,
              child: const Center(
                child: Text(
                  'KrishiVed Experimental',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
