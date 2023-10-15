// ignore_for_file: file_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/providers/general_setting_provider.dart';
import 'package:crossfit_gym_trainer/utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:provider/provider.dart';

import '../admin_screen/admin_dashboard_screen.dart';
import '../main.dart';
import '../member_screen/dashboard_screen.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import '../utils/color_code.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'login_screen.dart';
import 'social_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late SettingProvider settingProvider;

  @override
  void initState() {
    super.initState();
    settingProvider = Provider.of<SettingProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // debugPrint('Project Id: ${FirebaseFirestore.instance.app.options.androidClientId}');
        Timer(
          const Duration(seconds: 2),
          () => settingProvider.getSettingsList().then(
                (defaultResponseData) => {
                  if (settingProvider.generalSettingItem != null)
                    {
                      StaticData.currentDateFormat = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyDateFormat,
                          defaultValue: StaticData.currentDateFormat),
                      if (getDocumentValue(documentSnapshot: settingProvider.generalSettingItem!, key: keyProfile)
                          .toString()
                          .isNotEmpty)
                        {
                          StaticData.defaultPlaceHolder = settingProvider.generalSettingItem![keyProfile],
                        },
                      debugPrint('currentCurrency : ${StaticData.currentCurrency}'),
                      StaticData.weight = getDocumentValue(
                                  documentSnapshot: settingProvider.generalSettingItem!,
                                  key: keyWeight,
                                  defaultValue: 'kg') ==
                              'kg'
                          ? "KG"
                          : "LBS",
                      StaticData.height = getDocumentValue(
                                  documentSnapshot: settingProvider.generalSettingItem!,
                                  key: keyHeight,
                                  defaultValue: 'inches') ==
                              'inches'
                          ? "IN"
                          : "CM",
                      StaticData.chest = getDocumentValue(
                                  documentSnapshot: settingProvider.generalSettingItem!,
                                  key: keyChest,
                                  defaultValue: 'inches') ==
                              'inches'
                          ? "IN"
                          : "CM",
                      StaticData.waist = getDocumentValue(
                                  documentSnapshot: settingProvider.generalSettingItem!,
                                  key: keyWaist,
                                  defaultValue: 'inches') ==
                              'inches'
                          ? "IN"
                          : "CM",
                      StaticData.thigh = getDocumentValue(
                                  documentSnapshot: settingProvider.generalSettingItem!,
                                  key: keyThigh,
                                  defaultValue: 'inches') ==
                              'inches'
                          ? "IN"
                          : "CM",
                      StaticData.arms = getDocumentValue(
                                  documentSnapshot: settingProvider.generalSettingItem!,
                                  key: keyArms,
                                  defaultValue: 'inches') ==
                              'inches'
                          ? "IN"
                          : "CM",
                      StaticData.adminNotification = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyNotification,
                          defaultValue: true),
                      StaticData.adminEmailNotification = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyEmailNotification,
                          defaultValue: true),
                      StaticData.adminVirtualClass = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyVirtualClass,
                          defaultValue: true),
                      StaticData.memberIdPrefix = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyMemberPrefix,
                          defaultValue: StaticData.memberIdPrefix),
                      setPaymentMethodAndKeys(documentSnapshot: settingProvider.generalSettingItem!, isAdmin: true),
                      StaticData.sendinblueEmailFrom = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyEmailFrom,
                          defaultValue: StaticData.sendinblueEmailFrom),
                      StaticData.sendinblueDomain = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyDomain,
                          defaultValue: StaticData.sendinblueDomain),
                      StaticData.sendinblueEmailName = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyEmailName,
                          defaultValue: StaticData.sendinblueEmailName),
                      StaticData.sendinblueSMTPServer = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keySMTPServer,
                          defaultValue: StaticData.sendinblueSMTPServer),
                      StaticData.sendinblueSMTPServerPort = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keySMTPServerPort,
                          defaultValue: StaticData.sendinblueSMTPServerPort),
                      StaticData.sendinblueEmail = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keyLoginEmail,
                          defaultValue: StaticData.sendinblueEmail),
                      StaticData.sendinblueSMTPPassword = getDocumentValue(
                          documentSnapshot: settingProvider.generalSettingItem!,
                          key: keySMTPPassword,
                          defaultValue: StaticData.sendinblueSMTPPassword),
                    },
                  SharedPreferencesManager().getValue(prefIsLogin, false).then(
                        (isLogin) => {
                          if (isLogin)
                            {
                              notificationInit(),
                              SharedPreferencesManager().getValue(prefUserRole, userRoleMember).then(
                                    (role) => {
                                      if (role == userRoleAdmin)
                                        {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const AdminDashboardScreen(),
                                            ),
                                            ModalRoute.withName("/AdminScreen"),
                                          )
                                        }
                                      else if (role == userRoleTrainer)
                                        {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const TrainerDashboardScreen(),
                                            ),
                                            ModalRoute.withName("/TrainerScreen"),
                                          )
                                        }
                                      else
                                        {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const DashboardScreen(),
                                            ),
                                            ModalRoute.withName("/MemberScreen"),
                                          )
                                        }
                                    },
                                  )
                            }
                          else
                            {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              ),
                            }
                        },
                      )
                },
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF500B75),
        /*decoration: const BoxDecoration(
          // Box decoration takes a gradient
          gradient: LinearGradient(
            colors: [
              ColorCode.splashColor,
              ColorCode.splashColorTwo,
              ColorCode.splashColor,
            ],
            begin: FractionalOffset(0.0, 0.1),
            end: FractionalOffset(0.1, 1.0),
            stops: [0.0, 0.5, 1.0],
          ),
        ),*/
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80,
            ),
            Center(
              child: Image.asset(
                "assets/appLogo/gym_logo.png",
                width: 200,
                height: 200, /* color: ColorCode.white*/
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Image.asset('assets/appLogo/progress_logo.gif', width: 100, height: 100, color: ColorCode.white),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
