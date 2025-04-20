import 'package:flutter/material.dart';


const kDialogTitleStyle = TextStyle(color: Colors.white, fontSize: 20);
const kDialogSubtitleStyle = TextStyle(color: Colors.white70);
const kDialogAbilityStyle = TextStyle(
  color: Colors.white70,
  fontSize: 12,
  fontStyle: FontStyle.italic,
);

class StyledDialogContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;

  const StyledDialogContainer({
    super.key,
    required this.child,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.7),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: child,
      ),
    );
  }
}

class ConfirmButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const ConfirmButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = Colors.greenAccent,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
