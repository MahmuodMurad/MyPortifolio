class ProjectModel {
  final String name;
  final String description;
  final List<String> technologies;
  final Map<String, String> links;

  const ProjectModel({
    required this.name,
    required this.description,
    required this.technologies,
    required this.links,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      technologies: List<String>.from(json['technologies'] ?? []),
      links: Map<String, String>.from(json['links'] ?? {}),
    );
  }
}
