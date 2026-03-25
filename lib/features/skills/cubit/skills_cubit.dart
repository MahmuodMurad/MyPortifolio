import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/cv_data_provider.dart';
import '../models/skill_model.dart';

class SkillsState {
  final List<SkillModel> flutterSkills;
  final List<SkillModel> generalSkills;
  final List<SkillModel> languages;

  const SkillsState({
    this.flutterSkills = const [],
    this.generalSkills = const [],
    this.languages = const [],
  });
}

class SkillsCubit extends Cubit<SkillsState> {
  SkillsCubit() : super(const SkillsState()) {
    _loadSkills();
  }

  void _loadSkills() {
    final skills = CvDataProvider.skills;

    final flutter = (skills['flutter_framework'] as List<dynamic>?)
            ?.map((s) => SkillModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];
    final general = (skills['general_concepts'] as List<dynamic>?)
            ?.map((s) => SkillModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];
    final langs = (skills['languages'] as List<dynamic>?)
            ?.map((s) => SkillModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    emit(SkillsState(
      flutterSkills: flutter,
      generalSkills: general,
      languages: langs,
    ));
  }
}
