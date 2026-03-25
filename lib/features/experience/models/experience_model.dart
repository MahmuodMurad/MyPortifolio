class ExperienceModel {
  final String role;
  final String company;
  final String period;
  final String description;

  const ExperienceModel({
    required this.role,
    required this.company,
    required this.period,
    required this.description,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      role: json['role'] ?? '',
      company: json['company'] ?? '',
      period: json['period'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
