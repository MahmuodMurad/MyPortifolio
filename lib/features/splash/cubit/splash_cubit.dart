import 'package:flutter_bloc/flutter_bloc.dart';

enum SplashPhase { initial, rotating, sliding, typing, done }

class SplashCubit extends Cubit<SplashPhase> {
  SplashCubit() : super(SplashPhase.initial);

  void startRotation() => emit(SplashPhase.rotating);
  void startSliding() => emit(SplashPhase.sliding);
  void startTyping() => emit(SplashPhase.typing);
  void complete() => emit(SplashPhase.done);
}
