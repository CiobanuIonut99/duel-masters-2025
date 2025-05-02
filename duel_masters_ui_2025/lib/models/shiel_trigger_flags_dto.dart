import 'package:duel_masters_ui_2025/models/card_model.dart';

class ShieldTriggersFlagsDto {

  final bool targetShield;
  final bool shieldTrigger;
  final bool brainSerumMustDrawCards;
  final bool crystalMemoryMustDrawCard;
  final bool solarRayMustSelectCreature;
  final bool spiralGateMustSelectCreature;
  final bool darkReversalMustSelectCreature;
  final bool terrorPitMustSelectCreature;
  final bool tornadoFlameMustSelectCreature;
  final bool dimensionGateMustDrawCard;
  final bool naturalSnareMustSelectCreature;

  final Map<String, dynamic> eachPlayerBattleZone;
  final List<CardModel> opponentUnder4000Creatures;

  ShieldTriggersFlagsDto({
    required this.solarRayMustSelectCreature,
    required this.spiralGateMustSelectCreature,
    required this.targetShield,
    required this.shieldTrigger,
    required this.brainSerumMustDrawCards,
    required this.crystalMemoryMustDrawCard,
    required this.eachPlayerBattleZone,
    required this.darkReversalMustSelectCreature,
    required this.terrorPitMustSelectCreature,
    required this.tornadoFlameMustSelectCreature,
    required this.opponentUnder4000Creatures,
    required this.dimensionGateMustDrawCard,
    required this.naturalSnareMustSelectCreature,
  });

  factory ShieldTriggersFlagsDto.fromJson(Map<String, dynamic> json) {
    return ShieldTriggersFlagsDto(
      solarRayMustSelectCreature: json['solarRayMustSelectCreature'] ?? false,
      spiralGateMustSelectCreature: json['spiralGateMustSelectCreature'] ?? false,
      targetShield: json['targetShield'] ?? false,
      shieldTrigger: json['shieldTrigger'] ?? false,
      brainSerumMustDrawCards: json['brainSerumMustDrawCards'] ?? false,
      crystalMemoryMustDrawCard: json['crystalMemoryMustDrawCard'] ?? false,
      darkReversalMustSelectCreature: json['darkReversalMustSelectCreature'] ?? false,
      terrorPitMustSelectCreature: json['terrorPitMustSelectCreature'] ?? false,
      tornadoFlameMustSelectCreature: json['tornadoFlameMustSelectCreature'] ?? false,
      dimensionGateMustDrawCard: json['dimensionGateMustDrawCard'] ?? false,
      naturalSnareMustSelectCreature: json['naturalSnareMustSelectCreature'] ?? false,
      eachPlayerBattleZone: json['eachPlayerBattleZone'] ?? {},
      opponentUnder4000Creatures: (json['opponentUnder4000Creatures'] as List<dynamic>? ?? [])
          .map((c) => CardModel.fromJson(c))
          .toList(),
    ); }}
