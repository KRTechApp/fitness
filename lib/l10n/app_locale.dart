import 'package:flutter/material.dart';

import '../utils/shared_preferences_manager.dart';
import '../utils/tables_keys_values.dart';

class AppLocale extends ChangeNotifier {
  Locale? _locale;

  AppLocale() {
    SharedPreferencesManager().getValue(prefLanguage, "en").then((language) => {
          if (_locale != Locale(language))
            {
              debugPrint("Current Language1 : $language"),
              _locale =  Locale(language),
              debugPrint("Current Language2 : $language"),
              notifyListeners()
            }
        });
  }

  Locale get locale => _locale ?? const Locale('en');
  void changeLocale(Locale newLocale) {
    if(newLocale == const Locale('es')) {
      _locale = const Locale('es');
    } else if(newLocale == const Locale('en')){
      _locale = const Locale('en');
    }else if(newLocale == const Locale('de')){
      _locale = const Locale('de');
    }else if(newLocale == const Locale('hi')){
      _locale = const Locale('hi');
    }else if(newLocale == const Locale('gu')){
      _locale = const Locale('gu');
    }else if(newLocale == const Locale('ar')){
      _locale = const Locale('ar');
    }else if(newLocale == const Locale('bn')){
      _locale = const Locale('bn');
    }else if(newLocale == const Locale('ca')){
      _locale = const Locale('ca');
    }else if(newLocale == const Locale('cs')){
      _locale = const Locale('cs');
    }else if(newLocale == const Locale('da')){
      _locale = const Locale('da');
    }else if(newLocale == const Locale('de')){
      _locale = const Locale('de');
    }else if(newLocale == const Locale('el')){
      _locale = const Locale('el');
    }else if(newLocale == const Locale('es')){
      _locale = const Locale('es');
    }else if(newLocale == const Locale('et')){
      _locale = const Locale('et');
    }else if(newLocale == const Locale('fa')){
      _locale = const Locale('fa');
    }else if(newLocale == const Locale('fi')){
      _locale = const Locale('fi');
    }else if(newLocale == const Locale('fr')){
      _locale = const Locale('fr');
    }else if(newLocale == const Locale('hr')){
      _locale = const Locale('hr');
    }else if(newLocale == const Locale('hu')){
      _locale = const Locale('hu');
    }else if(newLocale == const Locale('it')){
      _locale = const Locale('it');
    }else if(newLocale == const Locale('ja')){
      _locale = const Locale('ja');
    }else if(newLocale == const Locale('kn')){
      _locale = const Locale('kn');
    }else if(newLocale == const Locale('lt')){
      _locale = const Locale('lt');
    }else if(newLocale == const Locale('mi')){
      _locale = const Locale('mi');
    }else if(newLocale == const Locale('mr')){
      _locale = const Locale('mr');
    }else if(newLocale == const Locale('nl')){
      _locale = const Locale('nl');
    }else if(newLocale == const Locale('no')){
      _locale = const Locale('no');
    }else if(newLocale == const Locale('pa')){
      _locale = const Locale('pa');
    }else if(newLocale == const Locale('pl')){
      _locale = const Locale('pl');
    }else if(newLocale == const Locale('pt')){
      _locale = const Locale('pt');
    }else if(newLocale == const Locale('ro')){
      _locale = const Locale('ro');
    }else if(newLocale == const Locale('ru')){
      _locale = const Locale('ru');
    }else if(newLocale == const Locale('sv')){
      _locale = const Locale('sv');
    }else if(newLocale == const Locale('ta')){
      _locale = const Locale('ta');
    }else if(newLocale == const Locale('te')){
      _locale = const Locale('te');
    }else if(newLocale == const Locale('tr')){
      _locale = const Locale('tr');
    }else if(newLocale == const Locale('ur')){
      _locale = const Locale('ur');
    }
    notifyListeners();
  }

  void refreshApp() {
    notifyListeners();
  }
}
