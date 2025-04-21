class ShieldTriggersFlagsDto {
  final bool mustSelectCreatureToTap;
  final bool targetShield;
  final bool shieldTrigger;

  ShieldTriggersFlagsDto({
    required this.mustSelectCreatureToTap,
    required this.targetShield,
    required this.shieldTrigger,
  });

  factory ShieldTriggersFlagsDto.fromJson(Map<String, dynamic> json) {
    return ShieldTriggersFlagsDto(
      mustSelectCreatureToTap: json['mustSelectCreatureToTap'] ?? false,
      targetShield: json['targetShield'] ?? false,
      shieldTrigger: json['shieldTrigger'] ?? false,
    );
  }
}
