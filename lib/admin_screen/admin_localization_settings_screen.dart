import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Utils/shared_preferences_manager.dart';
import '../l10n/app_locale.dart';
import '../model/default_response.dart';
import '../model/language_list_data.dart';
import '../providers/general_setting_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';

class AdminLocalizationSettingsScreen extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;

  const AdminLocalizationSettingsScreen({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  State<AdminLocalizationSettingsScreen> createState() => _AdminLocalizationSettingsScreenState();
}

class _AdminLocalizationSettingsScreenState extends State<AdminLocalizationSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<LanguageItem> languageList = [];
  final List<String> currencyList = ["U.S.Dollar", "Indian Rupee", "Euro"];
  final List<String> timeZoneList = [
    "Asia/Calcutta UTC + 05:30",
    "	Asia/Tashkent UTC + 05:00",
    "Asia/Kabul UTC + 04:30"
  ];
  final List<String> dateList = ["dd/MM/yyyy", "MM/dd/yyyy", "yyyy/dd/MM", "yyyy/MM/dd"];
  String? currentLanguage;

  String? selectedCurrency = "U.S.Dollar";
  String? selectedTimeZone = "Asia/Calcutta UTC + 05:30";
  String? selectedDateFormat = StaticData.currentDateFormat;
  late SettingProvider settingProvider;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late ShowProgressDialog showProgressDialog;
  bool showLanguage = false;
  String currentLanguageCode = "en";
  int currentLanguageId = 0;
  late AppLocale language;

  @override
  void initState() {
    super.initState();
    showProgressDialog = ShowProgressDialog(context: context);
    settingProvider = Provider.of<SettingProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        showProgressDialog.show();
        currentLanguageCode = await _preference.getValue(prefLanguage, "en");
        settingProvider
            .getSettingsList()
            .then((value) => {showProgressDialog.hide(), updateDocument(settingProvider.generalSettingItem)});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    language = Provider.of<AppLocale>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leadingWidth: 38,
        leading: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          splashColor: ColorCode.linearProgressBar,
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
            child: SvgPicture.asset(
              'assets/images/ic_left_arrow.svg',
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.localization_setting),
      ),
      body: Container(
        width: width,
        height: 415,
        margin: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 25),
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: ColorCode.tabBarBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.select_language,
              style: GymStyle.settingHeadingTitle,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                buttonWidth: width,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                hint: Text(
                  AppLocalizations.of(context)!.english,
                  style: GymStyle.settingSubTitleText,
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 35, color: ColorCode.tabBarText),
                items: languageList
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.languageTitle,
                        child: Text(
                          item.languageTitle.toString(),
                          style: GymStyle.settingSubTitleText,
                        ),
                      ),
                    )
                    .toList(),
                value: currentLanguage,
                onMenuStateChange: (isOpen) {
                  setState(() {
                    showLanguage = isOpen;
                  });
                },
                onChanged: (value) async {
                  currentLanguage = value;
                  var languageItem = languageList.firstWhere((element) => element.languageTitle == value);
                  currentLanguageId = languageItem.languageId!;
                  currentLanguageCode = languageItem.languageCode!;
                  updateLanguageList();
                  await updateEmailSetting(keySelectedLanguage, currentLanguage);
                  _preference.setValue(prefLanguage, currentLanguageCode);
                  language.changeLocale(Locale(currentLanguageCode));
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
            ),
            Text(
              AppLocalizations.of(context)!.select_currency,
              style: GymStyle.settingHeadingTitle,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                buttonWidth: width,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                hint: Text(
                  AppLocalizations.of(context)!.select_currency,
                  style: GymStyle.settingSubTitleText,
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 35, color: ColorCode.tabBarText),
                items: currencyList
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: GymStyle.settingSubTitleText,
                        ),
                      ),
                    )
                    .toList(),
                value: selectedCurrency,
                onChanged: (value) {
                  if( value == "Indian Rupee" && StaticData.paymentType == paymentTypePayPal) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!
                            .please_update_currency_inr_not_supported_in_paypal,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }
                  setState(
                    () {
                      selectedCurrency = value;
                      StaticData.currentCurrency = getCurrency(currencyName: selectedCurrency!,isAdmin: true);
                      debugPrint("currentCurrencyName : ${StaticData.currentCurrencyName}");

                    },
                  );
                  updateEmailSetting(keySelectedCurrency, selectedCurrency);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
            ),
            Text(
              AppLocalizations.of(context)!.select_timezone,
              style: GymStyle.settingHeadingTitle,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                buttonWidth: width,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                hint: Text(
                  AppLocalizations.of(context)!.select_timezone,
                  style: GymStyle.settingSubTitleText,
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 35, color: ColorCode.tabBarText),
                items: timeZoneList
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: GymStyle.settingSubTitleText,
                        ),
                      ),
                    )
                    .toList(),
                value: selectedTimeZone,
                onChanged: (value) {
                  setState(
                    () {
                      selectedTimeZone = value;
                    },
                  );
                  updateEmailSetting(keySelectedTimeZone, selectedTimeZone);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
            ),
            Text(
              AppLocalizations.of(context)!.select_date_format,
              style: GymStyle.settingHeadingTitle,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                buttonWidth: width,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                hint: Text(
                  AppLocalizations.of(context)!.select_date_format,
                  style: GymStyle.settingSubTitleText,
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 35, color: ColorCode.tabBarText),
                items: dateList
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: GymStyle.settingSubTitleText,
                        ),
                      ),
                    )
                    .toList(),
                value: selectedDateFormat,
                onChanged: (value) {
                  if( value == "Indian Rupee" && StaticData.paymentType == paymentTypePayPal) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!
                            .please_update_currency_inr_not_supported_in_paypal,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }
                  setState(
                    () {
                      selectedDateFormat = value;
                      StaticData.currentDateFormat = selectedDateFormat!;
                    },
                  );
                  updateEmailSetting(keyDateFormat, selectedDateFormat);
                },
              ),
            ),
            const Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
          ],
        ),
      ),
    );
  }

  Future<void> updateEmailSetting(String key, dynamic value) async {
    showProgressDialog.show(message: 'Loading...');
    DefaultResponse defaultResponse =
        await settingProvider.updateSettingByKeyValue(settingId: widget.documentSnapshot?.id, key: key, value: value);
    showProgressDialog.hide();
    if (context.mounted) {
      if (defaultResponse.status != null && defaultResponse.status!) {
        Fluttertoast.showToast(
            msg: defaultResponse.message ?? AppLocalizations.of(context)!.something_want_to_wrong,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        await refreshData();
      } else {
        Fluttertoast.showToast(
            msg: defaultResponse.message ?? AppLocalizations.of(context)!.something_want_to_wrong,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Future<void> updateDocument(DocumentSnapshot? documentSnapshot) async {
    if (documentSnapshot != null) {

        selectedCurrency = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keySelectedCurrency)
            ? documentSnapshot.get(keySelectedCurrency)
            : selectedCurrency;
        debugPrint("selected Currency $selectedCurrency");

      currentLanguage = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keySelectedLanguage)
          ? documentSnapshot.get(keySelectedLanguage)
          : currentLanguage;
      debugPrint("selected language $currentLanguage");
      selectedTimeZone = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keySelectedTimeZone)
          ? documentSnapshot.get(keySelectedTimeZone)
          : selectedTimeZone;
      debugPrint("selected Time zone $selectedTimeZone");
      selectedDateFormat = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyDateFormat)
          ? documentSnapshot.get(keyDateFormat)
          : selectedDateFormat;
      debugPrint("selected date format $selectedDateFormat");

      updateLanguageList();
    }
  }

  Future<void> refreshData() async {
    showProgressDialog.show();
    await settingProvider.getSettingsList();
    showProgressDialog.hide();
    updateDocument(settingProvider.generalSettingItem);
  }

  Future<void> updateLanguageList() async {
    languageList.clear();

    LanguageListData languageListData = LanguageListData.fromJson(
        await StaticData.loadAssetsToJson('assets/language/user_language_$currentLanguageCode.json'));
    languageList.addAll(languageListData.languageList!);
    languageList.sort((a, b) => (a.languageTitle ?? "").toLowerCase().compareTo((b.languageTitle ?? "").toLowerCase()));
    debugPrint('Language List; $languageList');
    for (var languageItem in languageList) {
      if (languageItem.languageCode == currentLanguageCode) {
        setState(() {
          currentLanguageId = languageItem.languageId!;
          currentLanguage = languageItem.languageTitle!;
          debugPrint('CurrentLanguageTitle : $currentLanguage');
          debugPrint('CurrentLanguageId : $currentLanguageId');
        });
      }
    }
  }
}
