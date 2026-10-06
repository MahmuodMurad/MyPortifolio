class ProjectModel {
  final String name;
  final String category;
  final String impact;
  final String description;
  final List<String> technologies;
  final List<String> images;
  final Map<String, String> links;

  const ProjectModel({
    required this.name,
    required this.category,
    required this.impact,
    required this.description,
    required this.technologies,
    required this.images,
    required this.links,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      impact: json['impact'] ?? '',
      description: json['description'] ?? '',
      technologies: List<String>.from(json['technologies'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      links: Map<String, String>.from(json['links'] ?? {}),
    );
  }
}
