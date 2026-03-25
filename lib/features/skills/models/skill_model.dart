class SkillModel {
  final String name;
  final double level;

  const SkillModel({required this.name, required this.level});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      name: json['name'] ?? '',
      level: (json['level'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
