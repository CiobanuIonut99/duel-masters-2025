class ShieldTriggersFlagsDto {
  final bool solarRayMustSelectCreature;
  final bool targetShield;
  final bool shieldTrigger;
  final bool brainSerumMustDrawCards;
  final bool crystalMemoryMustDrawCard;

  ShieldTriggersFlagsDto({
    required this.solarRayMustSelectCreature,
    required this.targetShield,
    required this.shieldTrigger,
    required this.brainSerumMustDrawCards,
    required this.crystalMemoryMustDrawCard,
  });

  factory ShieldTriggersFlagsDto.fromJson(Map<String, dynamic> json) {
    return ShieldTriggersFlagsDto(
      solarRayMustSelectCreature: json['solarRayMustSelectCreature'] ?? false,
      targetShield: json['targetShield'] ?? false,
      shieldTrigger: json['shieldTrigger'] ?? false,
      brainSerumMustDrawCards: json['brainSerumMustDrawCards'] ?? false,
      crystalMemoryMustDrawCard: json['crystalMemoryMustDrawCard'] ?? false,
    );
  }
}
