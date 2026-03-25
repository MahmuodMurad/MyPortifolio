import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_title.dart';
import '../cubit/projects_cubit.dart';
import '../models/project_model.dart';
import 'project_card.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectsCubit(),
      child: Container(
        padding: Responsive.getSectionPadding(context),
        constraints:
            BoxConstraints(maxWidth: Responsive.getContentWidth(context)),
        child: Column(
          children: [
            const SectionTitle(
              title: 'Projects',
              subtitle: 'What I\'ve built',
            ),
            BlocBuilder<ProjectsCubit, List<ProjectModel>>(
              builder: (context, projects) {
                final crossAxisCount = Responsive.getCrossAxisCount(context);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: crossAxisCount == 1 ? 1.4 : 1.1,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return ProjectCard(
                      project: projects[index],
                      index: index,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
