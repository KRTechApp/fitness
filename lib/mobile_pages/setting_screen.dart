import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/general_setting_provider.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../admin_screen/admin_dashboard_screen.dart';
import '../trainer_screen/trainer_payment_setting_screen.dart';
import '../main.dart';
import '../member_screen/dashboard_screen.dart';
import '../model/default_response.dart';
import '../providers/dark_theme_provider.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import '../utils/color_code.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import 'localization_screen.dart';
import 'main_drawer_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _switchController = ValueNotifier<bool>(false);
  ValueNotifier<bool> notificationsController = ValueNotifier<bool>(false);
  ValueNotifier<bool> emailNotificationsController = ValueNotifier<bool>(false);
  late DarkThemeProvider themeState;
  late MemberProvider memberProvider;
  String currentUserId = "";
  String userRole = "";
  DocumentSnapshot? currentMemberDoc;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late ShowProgressDialog showProgressDialog;

  @override
  void initState() {
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: true);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    _switchController.addListener(
      () {
        debugPrint("_switchController.value : ${_switchController.value}");
        themeState.setDarkTheme = _switchController.value;
      },
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        showProgressDialog.show();
        currentUserId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
         await memberProvider.getSelectedMember(memberId: currentUserId).then(
              (documentSnap) => {
                showProgressDialog.hide(),
                updateDocument(documentSnap),
                notificationsController.addListener(
                  () {
                    var notificationValue = notificationsController.value;
                    _preference.setValue(keyNotification, notificationValue);
                    updateSetting(keyNotification, notificationValue);
                  },
                ),
                emailNotificationsController.addListener(
                  () {
                    var emailNotificationValue = emailNotificationsController.value;
                    _preference.setValue(prefEmailNotification, emailNotificationValue);
                    updateSetting(keyEmailNotification, emailNotificationValue);
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
        userRole == userRoleTrainer
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const TrainerDashboardScreen()),
                (Route<dynamic> route) => false)
            : userRole == userRoleAdmin
                ? Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                    (Route<dynamic> route) => false)
                : Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()), (Route<dynamic> route) => false);

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
          builder: (context, settingData, child) => Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: ColorCode.tabBarBackground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*  Container(
                  margin: const EdgeInsets.all(20),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPasswordUpdateScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.update_password,
                          style: GymStyle.settingTitle,
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          'assets/images/ic_setting_arrow.svg',
                        ),
                      ],
                    ),
                  ),
                ),*/
                Container(
                  margin: const EdgeInsets.all(20),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocalizationScreen(
                              key: UniqueKey(),
                              userRole: userRole,
                          currentUserId: currentUserId),
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
                  if (userRole == userRoleTrainer && StaticData.codeExist && StaticData.showPaymentGateway)
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TrainerPaymentSettingScreen(),
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
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.email_notification,
                        style: GymStyle.settingTitle,
                      ),
                      const Spacer(),
                      AdvancedSwitch(
                        width: 32,
                        height: 16,
                        activeColor: ColorCode.mainColor,
                        controller: emailNotificationsController,
                      )
                    ],
                  ),
                ),
/*              Container(
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
              ],
            ),
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Future<void> updateSetting(String key, dynamic value) async {
    showProgressDialog.show(message: 'Loading...');
    DefaultResponse defaultResponse =
        await memberProvider.updateDataByKeyValue(userId: currentUserId, key: key, value: value);
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
          currentMemberDoc = documentSnapshot;
          notificationsController.value = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyNotification)
              ? documentSnapshot.get(keyNotification)
              : false;
          emailNotificationsController.value =
              (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyEmailNotification)
                  ? documentSnapshot.get(keyEmailNotification)
                  : false;
        },
      );
    }
  }

  Future<void> refreshData() async {
    showProgressDialog.show();
    memberProvider.getSelectedMember(memberId: currentUserId).then(
          (documentSnap) => {showProgressDialog.hide(), updateDocument(documentSnap)},
        );
  }
}
