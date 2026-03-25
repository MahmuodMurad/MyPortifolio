import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  static const List<String> sectionNames = [
    'About',
    'Experience',
    'Projects',
    'Skills',
    'Contact',
  ];

  void updateSection(int index) {
    if (index != state) emit(index);
  }
}
