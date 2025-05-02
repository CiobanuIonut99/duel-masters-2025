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

  final Map<String, dynamic> eachPlayerBattleZone;

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
  });

  factory ShieldTriggersFlagsDto.fromJson(Map<String, dynamic> json) {
    return ShieldTriggersFlagsDto(
      solarRayMustSelectCreature: json['solarRayMustSelectCreature'] ?? false,
      spiralGateMustSelectCreature: json['spiralGateMustSelectCreature'] ?? false,
      targetShield: json['targetShield'] ?? false,
      shieldTrigger: json['shieldTrigger'] ?? false,
      brainSerumMustDrawCards: json['brainSerumMustDrawCards'] ?? false,
      crystalMemoryMustDrawCard: json['crystalMemoryMustDrawCard'] ?? false,
      eachPlayerBattleZone: json['eachPlayerBattleZone'] ?? {},
      darkReversalMustSelectCreature: json['darkReversalMustSelectCreature'] ?? {},
      terrorPitMustSelectCreature: json['terrorPitMustSelectCreature'] ?? {},
      tornadoFlameMustSelectCreature: json['tornadoFlameMustSelectCreature'] ?? {},
    );
  }
}
