import 'package:flutter/material.dart';

import 'color_code.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
        scaffoldBackgroundColor: isDarkTheme ? const Color(0xFF181A20) : const Color(0xFFFFFFFF),
        primaryColor: isDarkTheme ? const Color(0xFF181A20) : const Color(0xFFFFFFFF),
        colorScheme: ThemeData().colorScheme.copyWith(
            secondary: isDarkTheme ? const Color(0xFF181A20) : const Color(0xFFFFFFFF),
            brightness: isDarkTheme ? Brightness.dark : Brightness.light),
        cardColor: isDarkTheme ? const Color(0xFF181A20) : const Color(0xFFFFFFFF),
        canvasColor: isDarkTheme ? const Color(0xFF181A20) : const Color(0xFFFFFFFF),
        unselectedWidgetColor: ColorCode.tabBarBoldText,
        disabledColor: Colors.blue,
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: ColorCode.listSubTitle2,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicator: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
              color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20)),
        ),
        appBarTheme: AppBarTheme(
            centerTitle: false,
            color: isDarkTheme ? const Color(0xFF181A20) : const Color(0xFFFFFFFF),
            titleSpacing: 2,
            actionsIconTheme: IconThemeData(color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20)),
            iconTheme: IconThemeData(color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20)),
            titleTextStyle: TextStyle(
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                fontSize: 25,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins'),
            elevation: 0),
        fontFamily: 'Poppins',
        iconTheme: IconThemeData(
          color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          displayMedium: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          displaySmall: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          titleLarge: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          titleMedium: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          titleSmall: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          bodyLarge: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          bodyMedium: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          bodySmall: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          labelLarge: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          labelMedium: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          labelSmall: TextStyle(color: isDarkTheme ? const Color(0xffe8fdfd) : const Color(0xff1a1f3c)),
          headlineSmall: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          headlineLarge: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          headlineMedium: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),

          /*  headline1: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          headline2: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          headline3: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          headline4: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          headline5: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          headline6: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          subtitle1: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          subtitle2: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          bodyText1: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          bodyText2: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          button: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          caption: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          overline: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),*/

          /* headline1: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        headline2: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        headline3: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        headline4: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        headline5: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        headline6: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        subtitle1:TextStyle(color: isDarkTheme ? Colors.black : Colors.white) ,
        subtitle2:TextStyle(color: isDarkTheme ? Colors.black : Colors.white) ,
        bodyText1: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        bodyText2: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        button: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        caption: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
        overline: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),*/
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.green;
            }
            return null;
          }),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.green;
            }
            return null;
          }),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.green;
            }
            return null;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.green;
            }
            return null;
          }),
        ));
  }
}
