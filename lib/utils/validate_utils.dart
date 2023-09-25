import 'package:flutter/material.dart';

extension StringValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  bool isValidPhone() {
    return RegExp(r'^-?[0-9]+$').hasMatch(this);
  }
}

bool isYoutubeUrl(String url) {
  // return url.isNotEmpty ;
  debugPrint("isYoutubeUrl : $url");
  return url.isNotEmpty && (url.startsWith("https://www.youtube.com/") || url.startsWith("https://youtu.be/"));
}

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

extension StringNoValidator on String {
  bool isValidNo() {
    return RegExp(r'^(?:[+0][1-9])?[0-9]{10,12}$/').hasMatch(this);
  }
}

extension UseNameValidator on String {
  bool isValidUsername() {
    return RegExp("[a-zA-Z]._").hasMatch(this);
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to true (default is true).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension StringExtension on String {
  String firstCapitalize() {
    if (isEmpty) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String get inCaps => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';

  String get allInCaps => toUpperCase();

  String get capitalizeFirstOfEach => replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }
}

DateTime findFirstDateOfTheWeek(DateTime dateTime) {
  return dateTime.subtract(Duration(days: dateTime.weekday - 1));
}

DateTime findLastDateOfTheWeek(DateTime dateTime) {
  return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
}

DateTime findFirstDateOfTheNextWeek(DateTime dateTime) {
  return dateTime.subtract(Duration(days: dateTime.weekday - 8));
}

DateTime findLastDateOfTheNextWeek(DateTime dateTime) {
  return dateTime.subtract(Duration(days: dateTime.weekday - 14));
}
