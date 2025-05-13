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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: child, // only keep padding around the zone
    );
  }

}
