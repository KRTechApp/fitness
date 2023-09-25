import 'package:flutter/cupertino.dart';

import '../Services/dark_theme_prefs.dart';
import '../main.dart';

class DarkThemeProvider with ChangeNotifier{

  DarkThemePrefs darkThemePrefs = DarkThemePrefs();

  bool get getDarkTheme => isDarkTheme;


  set setDarkTheme (bool value){
    isDarkTheme = value;
    darkThemePrefs.setDarkTheme(value);
    notifyListeners();
  }

}