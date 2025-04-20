import 'package:duel_masters_ui_2025/models/shiel_trigger_flags_dto.dart';

class GameStateDto {
  final ShieldTriggersFlagsDto? shieldTriggersFlagsDto;

  GameStateDto({this.shieldTriggersFlagsDto});

  factory GameStateDto.fromJson(Map<String, dynamic> json) {
    return GameStateDto(
      shieldTriggersFlagsDto: json['shieldTriggersFlagsDto'] != null
          ? ShieldTriggersFlagsDto.fromJson(json['shieldTriggersFlagsDto'])
          : null,
    );
  }
}
