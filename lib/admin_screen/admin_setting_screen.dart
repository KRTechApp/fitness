import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/general_setting_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/default_response.dart';
import '../providers/dark_theme_provider.dart';
import '../utils/color_code.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import 'admin_dashboard_screen.dart';
import 'admin_email_settings_screen.dart';
import 'admin_general_setting_screen.dart';
import 'admin_localization_settings_screen.dart';
import 'admin_measurement_units_screen.dart';
import 'admin_payment_setting_screen.dart';
import 'admin_virtual_class_settings_screen.dart';

class AdminSettingScreen extends StatefulWidget {
  const AdminSettingScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingScreen> createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _switchController = ValueNotifier<bool>(false);
  ValueNotifier<bool> notificationsController = ValueNotifier<bool>(false);
  late DarkThemeProvider themeState;
  bool adminTrainerValue = false;
  late SettingProvider generalSettingProvider;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late ShowProgressDialog showProgressDialog;

  @override
  void initState() {
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: true);
    generalSettingProvider = Provider.of<SettingProvider>(context, listen: false);
    _switchController.addListener(
      () {
        debugPrint("_switchController.value : ${_switchController.value}");
        themeState.setDarkTheme = _switchController.value;
      },
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        showProgressDialog.show();
        generalSettingProvider.getSettingsList().then(
              (value) => {
                showProgressDialog.hide(),
                updateDocument(generalSettingProvider.generalSettingItem),
                notificationsController.addListener(
                  () {
                    var notificationValue = notificationsController.value;
                    _preference.setValue(keyNotification, notificationValue);
                    updateSetting(keyNotification, notificationValue);
                  },
                )
              },
            );
        _switchController.value = themeState.getDarkTheme;
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeState = Provider.of<DarkThemeProvider>(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            (Route<dynamic> route) => false);
        return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leadingWidth: 48,
          leading: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
            splashColor: ColorCode.linearProgressBar,
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
              child: SvgPicture.asset(
                'assets/images/appbar_menu.svg',
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),
          ),
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        body: Consumer<SettingProvider>(
          builder: (context, settingData, child) => SizedBox(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 64),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: ColorCode.tabBarBackground,
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminGeneralSettingScreen(
                                key: UniqueKey(), documentSnapshot: settingData.generalSettingItem),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.general_setting,
                            style: GymStyle.settingTitle,
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            'assets/images/ic_setting_arrow.svg',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminMeasurementUnitsScreen(
                                key: UniqueKey(), documentSnapshot: generalSettingProvider.generalSettingItem),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.measurement_units,
                            style: GymStyle.settingTitle,
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            'assets/images/ic_setting_arrow.svg',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminVirtualClassSettingsScreen(
                                key: UniqueKey(), documentSnapshot: generalSettingProvider.generalSettingItem),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.virtual_class_settings,
                            style: GymStyle.settingTitle,
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            'assets/images/ic_setting_arrow.svg',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(StaticData.showPaymentGateway)
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdminPaymentSettingScreen(documentSnapshot: generalSettingProvider.generalSettingItem),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.payment_settings,
                            style: GymStyle.settingTitle,
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            'assets/images/ic_setting_arrow.svg',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminLocalizationSettingsScreen(
                                key: UniqueKey(), documentSnapshot: generalSettingProvider.generalSettingItem),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.localization_setting,
                            style: GymStyle.settingTitle,
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            'assets/images/ic_setting_arrow.svg',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminEmailSettingsScreen(
                                key: UniqueKey(), documentSnapshot: generalSettingProvider.generalSettingItem),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.email_settings,
                            style: GymStyle.settingTitle,
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            'assets/images/ic_setting_arrow.svg',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.notification,
                          style: GymStyle.settingTitle,
                        ),
                        const Spacer(),
                        AdvancedSwitch(
                          width: 32,
                          height: 16,
                          activeColor: ColorCode.mainColor,
                          controller: notificationsController,
                        )
                      ],
                    ),
                  ),
                  /* Container(
                    margin: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dark_mode,
                          style: GymStyle.settingTitle,
                        ),
                        const Spacer(),
                        AdvancedSwitch(
                          width: 32,
                          height: 16,
                          activeColor: ColorCode.mainColor,
                          controller: _switchController,
                        ),
                      ],
                    ),
                  ),*/
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.administrator_is_trainer,
                          style: GymStyle.settingTitle,
                        ),
                        const Spacer(),
                        Transform.scale(
                          scale: 1,
                          child: Checkbox(
                            visualDensity: VisualDensity.compact,
                            activeColor: ColorCode.mainColor,
                            value: adminTrainerValue,
                            onChanged: (bool? value) {
                              if (value != null) {
                                setState(
                                  () {
                                    adminTrainerValue = value;
                                  },
                                );
                                updateSetting(keyAdminIsTrainer, adminTrainerValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Future<void> updateSetting(String key, dynamic value) async {
    showProgressDialog.show(message: 'Loading...');
    DefaultResponse defaultResponse = await generalSettingProvider.updateSettingByKeyValue(
        settingId: generalSettingProvider.generalSettingItem?.id, key: key, value: value);
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
        refreshData();
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

  void updateDocument(DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      setState(
        () {
          notificationsController.value = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyNotification)
              ? documentSnapshot.get(keyNotification)
              : false;

          adminTrainerValue = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyAdminIsTrainer)
              ? documentSnapshot.get(keyAdminIsTrainer)
              : adminTrainerValue;
        },
      );
    }
  }

  Future<void> refreshData() async {
    showProgressDialog.show();
    generalSettingProvider.getSettingsList().then(
          (value) => {showProgressDialog.hide(), updateDocument(generalSettingProvider.generalSettingItem)},
        );
  }
}
