import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ZoneContainer extends StatelessWidget {
  final Widget child;
  final String label;
  final Color borderColor;

  const ZoneContainer({
    super.key,
    required this.child,
    required this.label,
    this.borderColor = Colors.white24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: child,  // <-- don't add extra label here
    );
  }
}
