import 'package:duel_masters_ui_2025/dialogs/styled_dialog_container.dart';
import 'package:flutter/material.dart';

class SelectCardCountDialog extends StatelessWidget {
  final void Function(int count) onConfirm;
  final VoidCallback onCancel;

  const SelectCardCountDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return StyledDialogContainer(
      borderColor: Colors.blueAccent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "How many cards do you want to choose?",
            style: kDialogTitleStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            "Please select whether you want to pick 1 or 2 cards.",
            style: kDialogSubtitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm(1);
                },
                icon: const Icon(Icons.filter_1),
                label: const Text("Choose 1"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm(2);
                },
                icon: const Icon(Icons.filter_2),
                label: const Text("Choose 2"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
