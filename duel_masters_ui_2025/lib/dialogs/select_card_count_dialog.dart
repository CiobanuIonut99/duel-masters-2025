import 'package:duel_masters_ui_2025/dialogs/styled_dialog_container.dart';
import 'package:flutter/material.dart';

class SelectCardCountDialog extends StatelessWidget {
  final bool isMyShieldTrigger;
  final void Function(int count) onConfirm;
  final VoidCallback onCancel;

  const SelectCardCountDialog({
    super.key,
    required this.isMyShieldTrigger,
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
          Text(
            isMyShieldTrigger
                ? "How many cards do you want to choose?"
                : "Opponent is deciding how many cards to choose...",
            style: kDialogTitleStyle.copyWith(color: Colors.blueAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isMyShieldTrigger
                ? "Please select whether you want to pick 1 or 2 cards."
                : "Waiting for opponent's decision...",
            style: kDialogSubtitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (isMyShieldTrigger)
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
          if (!isMyShieldTrigger)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          const SizedBox(height: 12),
          if (isMyShieldTrigger)
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
