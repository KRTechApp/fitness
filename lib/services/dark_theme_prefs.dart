import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class DarkThemePrefs{
  static const themeStatus = "THEME_STATUS";
  setDarkTheme(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(themeStatus, value);
  }

  Future<bool> getTheme() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    isDarkTheme = preferences.getBool(themeStatus) ?? false;
    return isDarkTheme;
  }


}