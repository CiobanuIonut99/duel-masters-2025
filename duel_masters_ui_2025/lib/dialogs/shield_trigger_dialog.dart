import 'package:duel_masters_ui_2025/dialogs/shared_dialog_styles.dart';
import 'package:duel_masters_ui_2025/dialogs/styled_dialog_container.dart' hide kDialogTitleStyle, kDialogSubtitleStyle;
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: StyledDialogContainer(
        borderColor: Colors.greenAccent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMyShieldTrigger
                  ? "Shield Trigger Activated!"
                  : "Opponent is deciding on Shield Trigger...",
              style: kDialogTitleStyle.copyWith(color: Colors.greenAccent),
            ),
            const SizedBox(height: 8),
            Text(
              isMyShieldTrigger
                  ? "Do you want to cast this spell for free?"
                  : "The shield you broke had a trigger. Waiting for response...",
              style: kDialogSubtitleStyle,
              textAlign: TextAlign.center,
            ),
            if (shieldTriggerCard.ability != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  shieldTriggerCard.ability!,
                  textAlign: TextAlign.center,
                  style: kAbilityTextStyle,
                ),
              ),
            const SizedBox(height: 16),
            Image.asset(shieldTriggerCard.imagePath, width: 100),
            const SizedBox(height: 16),
            if (isMyShieldTrigger)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConfirmButton(
                    label: "Use Trigger",
                    icon: Icons.flash_on,
                    color: Colors.greenAccent,
                    onPressed: onUseTrigger,
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: onSkip,
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
