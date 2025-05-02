class ShieldTriggersFlagsDto {
  final bool solarRayMustSelectCreature;
  final bool spiralGateMustSelectCreature;
  final bool targetShield;
  final bool shieldTrigger;
  final bool brainSerumMustDrawCards;
  final bool crystalMemoryMustDrawCard;
  final Map<String, dynamic> eachPlayerBattleZone;

  ShieldTriggersFlagsDto({
    required this.solarRayMustSelectCreature,
    required this.spiralGateMustSelectCreature,
    required this.targetShield,
    required this.shieldTrigger,
    required this.brainSerumMustDrawCards,
    required this.crystalMemoryMustDrawCard,
    required this.eachPlayerBattleZone,
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
    );
  }
}
