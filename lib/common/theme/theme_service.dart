import '../../config.dart';
import 'app_theme.dart';

class ThemeService extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final BuildContext? context;

  ThemeService(this.sharedPreferences, this.context);

  /// Gets the saved theme index: 0 = light, 1 = dark, 2 = system (default)
  int get themeIndex => sharedPreferences.getInt(session.themeIndex) ?? 2;

  /// Determines if dark mode should be used
  bool get isDarkMode {
    if (themeIndex == 2) {
      return MediaQuery.of(context!).platformBrightness == Brightness.dark;
    } else {
      return themeIndex == 1;
    }
  }

  /// Returns the current ThemeMode
  ThemeMode get theme {
    if (themeIndex == 2) {
      return ThemeMode.system;
    } else if (themeIndex == 1) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  /// Applies a new theme based on index and saves to SharedPreferences
  void switchTheme(bool isDark, int index) {
    sharedPreferences.setInt(session.themeIndex, index);
    sharedPreferences.setBool(session.isDarkMode, isDark);
    notifyListeners();
  }

  /// Gets the custom AppTheme based on current mode
  AppTheme get appTheme => isDarkMode
      ? AppTheme.fromType(ThemeType.dark)
      : AppTheme.fromType(ThemeType.light);
}
