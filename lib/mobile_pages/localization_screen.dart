import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../l10n/app_locale.dart';
import '../model/default_response.dart';
import '../model/language_list_data.dart';
import '../providers/trainer_provider.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class LocalizationScreen extends StatefulWidget {
  final String userRole;
  final String currentUserId;

  const LocalizationScreen(
      {Key? key, required this.userRole, required this.currentUserId})
      : super(key: key);

  @override
  State<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen> {
  final List<String> currencyList = ["U.S.Dollar", "Indian Rupee", "Euro"];
  String? selectedCurrency = "U.S.Dollar";

  final List<LanguageItem> languageList = [];
  String? selectedLanguage;
  bool showLanguage = false;
  String? currentLanguage;
  late TrainerProvider trainerProvider;

  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late AppLocale language;
  String currentLanguageCode = "en";
  int currentLanguageId = 0;
  late ShowProgressDialog showProgressDialog;

  @override
  void initState() {
    super.initState();
    showProgressDialog = ShowProgressDialog(context: context);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        currentLanguageCode = await _preference.getValue(prefLanguage, "en");
        updateLanguageList();
        if(widget.userRole == userRoleTrainer){
          refreshData();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    language = Provider.of<AppLocale>(context);
    return Scaffold(
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
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: ColorCode.tabBarBackground,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.select_language,
                  style: GymStyle.settingHeadingTitle,
                ),
                DropdownButton2(
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
                    _preference.setValue(prefLanguage, currentLanguageCode);
                    language.changeLocale(Locale(currentLanguageCode));
                  },
                ),
                if (widget.userRole == userRoleTrainer && StaticData.codeExist)
                  Text(
                    AppLocalizations.of(context)!.select_currency,
                    style: GymStyle.settingHeadingTitle,
                  ),
                if (widget.userRole == userRoleTrainer && StaticData.codeExist)
                  DropdownButton2(
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
                      debugPrint("currentTrainerCurrencyName : ${StaticData.currentTrainerCurrencyName}");
                      if( value == "Indian Rupee" && StaticData.paymentTrainerType == paymentTypePayPal) {
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
                          StaticData.currentCurrency = getCurrency(currencyName: selectedCurrency!,isAdmin: false);
                        },
                      );
                      updateSettingByKeyValue(keySelectedCurrency, selectedCurrency);
                    },
                  ),
              ])),
    );
  }

  Future<void> updateLanguageList() async {
    languageList.clear();

    LanguageListData languageListData = LanguageListData.fromJson(
        await StaticData.loadAssetsToJson('assets/language/user_language_$currentLanguageCode.json'));
    languageList.addAll(languageListData.languageList!);
    languageList.sort((a, b) => (a.languageTitle ?? "").toLowerCase().compareTo((b.languageTitle ?? "").toLowerCase()));
    for (var languageItem in languageList) {
      if (languageItem.languageCode == currentLanguageCode) {
        if(mounted){
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

  Future<void> updateSettingByKeyValue(String key, dynamic value) async {
    showProgressDialog.show(message: 'Loading...');
    DefaultResponse defaultResponse =
        await trainerProvider.updateTrainerByKeyValue(trainerId: widget.currentUserId, key: key, value: value);
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

  Future<void> refreshData() async {
    showProgressDialog.show();
    trainerProvider.getSingleTrainer(userId: widget.currentUserId).then(
          (documentSnap) => {
            showProgressDialog.hide(),
            updateDocument(documentSnap)},
        );
  }

  Future<void> updateDocument(DocumentSnapshot? documentSnapshot) async {
    if (documentSnapshot != null) {
      setState(() {
        selectedCurrency = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keySelectedCurrency)
            ? documentSnapshot.get(keySelectedCurrency)
            : selectedCurrency;
      });

      debugPrint("selected Currency $selectedCurrency");
    }
  }
}
