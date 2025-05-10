abstract class AppCubitState {}

class AppInitialState extends AppCubitState {}

class AppThemeChangedState extends AppCubitState {
  final String themeName;

  AppThemeChangedState(this.themeName);
}

// Special state to force UI rebuild
class AppRefreshState extends AppCubitState {}
