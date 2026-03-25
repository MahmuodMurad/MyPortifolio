import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/cv_data_provider.dart';
import '../models/project_model.dart';

class ProjectsCubit extends Cubit<List<ProjectModel>> {
  ProjectsCubit() : super([]) {
    _loadProjects();
  }

  void _loadProjects() {
    final projects = CvDataProvider.projects
        .map((p) => ProjectModel.fromJson(p as Map<String, dynamic>))
        .toList();
    emit(projects);
  }
}
