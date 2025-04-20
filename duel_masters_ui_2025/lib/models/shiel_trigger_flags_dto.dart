class ShieldTriggersFlagsDto {
  final bool mustSelectCreatureToTap;

  ShieldTriggersFlagsDto({required this.mustSelectCreatureToTap});

  factory ShieldTriggersFlagsDto.fromJson(Map<String, dynamic> json) {
    return ShieldTriggersFlagsDto(
      mustSelectCreatureToTap: json['mustSelectCreatureToTap'] ?? false,
    );
  }
}
