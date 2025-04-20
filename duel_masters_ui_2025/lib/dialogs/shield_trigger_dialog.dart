import 'package:flutter/material.dart';
import '../../models/card_model.dart';
class ShieldTriggerDialog extends StatelessWidget {
  final CardModel shieldTriggerCard;
  final bool isMyShieldTrigger;
  final VoidCallback onUseTrigger;
  final VoidCallback onSkip;

  const ShieldTriggerDialog({
    super.key,
    required this.shieldTriggerCard,
    required this.isMyShieldTrigger,
    required this.onUseTrigger,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyanAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMyShieldTrigger
                  ? "Shield Trigger Activated!"
                  : "Opponent is deciding on Shield Trigger...",
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              isMyShieldTrigger
                  ? "Do you want to cast this spell for free?"
                  : "The shield you broke had a trigger. Waiting for response...",
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (isMyShieldTrigger)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  shieldTriggerCard.ability ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Image.asset(shieldTriggerCard.imagePath, width: 100),
            if (!isMyShieldTrigger)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  shieldTriggerCard.ability ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (isMyShieldTrigger)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      onUseTrigger();
                    },
                    icon: const Icon(Icons.flash_on),
                    label: const Text("Use Trigger"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      onSkip();
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
