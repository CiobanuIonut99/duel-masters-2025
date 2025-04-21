class ShieldTriggersFlagsDto {
  final bool mustSelectCreatureToTap;
  final bool targetShield;
  final bool shieldTrigger;
  final bool mustDrawCardsFromDeck;

  ShieldTriggersFlagsDto({
    required this.mustSelectCreatureToTap,
    required this.targetShield,
    required this.shieldTrigger,
    required this.mustDrawCardsFromDeck,
  });

  factory ShieldTriggersFlagsDto.fromJson(Map<String, dynamic> json) {
    return ShieldTriggersFlagsDto(
      mustSelectCreatureToTap: json['mustSelectCreatureToTap'] ?? false,
      targetShield: json['targetShield'] ?? false,
      shieldTrigger: json['shieldTrigger'] ?? false,
      mustDrawCardsFromDeck: json['mustDrawCardsFromDeck'] ?? false,
    );
  }
}
