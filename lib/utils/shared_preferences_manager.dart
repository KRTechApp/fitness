import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {

  SharedPreferences? _sharedPreferences;

  //############Get values################

  Future<dynamic> getValue(String key, dynamic defaultValue) async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    // debugPrint("getValue : "+key);
    switch (defaultValue.runtimeType) {
      case String:
        return _sharedPreferences!.getString(key) ?? defaultValue;
      case int :
        return _sharedPreferences!.getInt(key) ?? defaultValue;
      case double :
        return _sharedPreferences!.getDouble(key) ?? defaultValue;
      case bool :
        return _sharedPreferences!.getBool(key) ?? defaultValue;
    }
  }
  Future<List<String>> getStringList(String key, List<String> stringSet) async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!.getStringList(key) ?? stringSet;
  }


  //############Set values################

  Future<void> setValue(String key, dynamic defaultValue) async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    switch (defaultValue.runtimeType) {
      case String:
        _sharedPreferences!.setString(key, defaultValue);
        break;
      case int :
        _sharedPreferences!.setInt(key, defaultValue);
        break;
      case double :
        _sharedPreferences!.setDouble(key, defaultValue);
        break;
      case bool :
        _sharedPreferences!.setBool(key, defaultValue);
        break;
    }
  }

  Future<void> setListString(String key, List<String> stringSet) async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    _sharedPreferences!.setStringList(key, stringSet);
  }


  //############ Remove value by key ################
  Future<void> removeValue(String key) async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    _sharedPreferences!.remove(key);
  }

  //############ Clear Preference ################
  Future<void> clear() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    _sharedPreferences!.clear();
  }
}