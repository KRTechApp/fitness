/*
// ignore_for_file: unused_field

import 'dart:io';

import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/firebase_interface.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import 'envato_purchase_verify_screen.dart';
import 'login_screen.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({Key? key}) : super(key: key);

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  final SharedPreferencesManager preference = SharedPreferencesManager();
  // final plugin = FacebookLogin(debug: true);

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', "https://www.googleapis.com/auth/userinfo.profile"],
  );
  FirebaseInterface firebaseInterface = FirebaseInterface();
  String? fcmToken;
  // String? _sdkVersion;
  late ShowProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    // _getSdkVersion();

    /// heads up notifications.
    debugPrint("Firebase Token init :");
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      debugPrint(messaging.app.toString());
      messaging.requestPermission().then((_) async {
        debugPrint("requestPermission");
        final token = await messaging.getToken();
        fcmToken = token;
        debugPrint("Firebase Token : $token");
        // _messaging.deleteToken();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      progressDialog.show();
      await FirebaseInterface().defaultAdminCreate(context: context);
      progressDialog.hide();
      envatoProductKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.12,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.lets_you_in,
                  style: GymStyle.socialLoginLabel,
                ),
              ),
              SizedBox(
                height: height * 0.04,
              ),
              */
/*InkWell(
                onTap: () {
                  FirebaseInterface().loginWithFacebook(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                  ),
                  height: height * 0.08,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/facebook_logo.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.continue_with_facebook,
                        style: GymStyle.socialLoginText,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),*//*

              InkWell(
                onTap: () {
                  FirebaseInterface().signupWithGoogle(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                  ),
                  height: height * 0.08,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/google_logo.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.continue_with_google,
                        style: GymStyle.socialLoginText,
                      )
                    ],
                  ),
                ),
              ),
              if(Platform.isIOS)
              SizedBox(
                height: height * 0.02,
              ),
              if(Platform.isIOS)
              InkWell(
                onTap: () {
                  FirebaseInterface().signupWithApple(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                  ),
                  height: height * 0.08,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/apple_logo.svg',
                        color: isDarkTheme ? ColorCode.white : ColorCode.backgroundColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.continue_with_apple,
                        style: GymStyle.socialLoginText,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 2,
                    width: width * 0.36,
                    color: ColorCode.socialLoginBackground.withOpacity(0.70),
                  ),
                  const SizedBox(width: 15),
                  Text(AppLocalizations.of(context)!.or, style: GymStyle.socialLoginText),
                  const SizedBox(width: 15),
                  Container(
                    height: 2,
                    width: width * 0.36,
                    color: ColorCode.socialLoginBackground.withOpacity(0.70),
                  )
                ],
              ),
              SizedBox(
                height: height * 0.05,
              ),
              SizedBox(
                height: height * 0.08,
                width: width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ));
                  },
                  style: GymStyle.buttonStyle,
                  child: Text(
                    AppLocalizations.of(context)!.sign_in_with_password.toUpperCase(),
                    style: GymStyle.buttonTextStyle,
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
//Get Facebook sdk version
  */
/*Future<void> _getSdkVersion() async {
    final sdkVersion = await plugin.sdkVersion;
    setState(() {
      _sdkVersion = sdkVersion;
    });
  }*//*


  Future<void> envatoProductKey() async {
    progressDialog.show();

    var querySnapshot =
        await FirebaseInterface().fireStore.collection(tableUser).where(keyUserRole, isEqualTo: userRoleAdmin).get();
    if (querySnapshot.docs.isNotEmpty &&
        getDocumentValue(documentSnapshot: querySnapshot.docs.first, key: keyClientEmail).toString().isNotEmpty &&
        getDocumentValue(documentSnapshot: querySnapshot.docs.first, key: keyEnventoPurchaseKey)
            .toString()
            .isNotEmpty) {
      debugPrint('line 273');
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: querySnapshot.docs.first.get(keyEmail),
            password: querySnapshot.docs.first.get(keyPassword),
          )
          .then((value) async => {
                debugPrint('line 279'),
                await firebaseInterface
                    .initialCheck(
                        email: querySnapshot.docs.first.get(keyClientEmail),
                        licenseKey: querySnapshot.docs.first.get(keyEnventoPurchaseKey))
                    .then(
                      (defaultResponseData) => {
                        progressDialog.hide(),
                        debugPrint('line 288'),
                        if (defaultResponseData.status != null && defaultResponseData.status!)
                          {
                            debugPrint('line 291'),
                            if (defaultResponseData.responseData == '1')
                              {
                                Fluttertoast.showToast(
                                    msg: 'Please provide correct Envato purchase key.',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0),
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                                  return const EnvatoPurchaseVerifyScreen();
                                }), (route) => false),
                                debugPrint('Please provide correct Envato purchase key.')
                              }
                            else if (defaultResponseData.responseData == '2')
                              {
                                Fluttertoast.showToast(
                                    msg: 'This purchase key is already registered with the different domain. If have any issue please contact us at sales@mojoomla.com',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0),
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                                  return const EnvatoPurchaseVerifyScreen();
                                }), (route) => false),
                                debugPrint(
                                    'This purchase key is already registered with the different domain. If have any issue please contact us at sales@mojoomla.com'),
                              }
                            else if (defaultResponseData.responseData == '3')
                              {
                                Fluttertoast.showToast(
                                    msg: 'There seems to be some problem please try after sometime or contact us on sales@mojoomla.com',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0),
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                                  return const EnvatoPurchaseVerifyScreen();
                                }), (route) => false),
                                debugPrint(
                                    'There seems to be some problem please try after sometime or contact us on sales@mojoomla.com'),
                              }
                            else if (defaultResponseData.responseData == '4')
                              {
                                Fluttertoast.showToast(
                                    msg: 'Please provide correct Envato purchase key for this plugin.',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0),
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                                  return const EnvatoPurchaseVerifyScreen();
                                }), (route) => false),
                                debugPrint('Please provide correct Envato purchase key for this plugin.'),
                              }
                            else if (defaultResponseData.responseData == '0')
                              {
                               */
/* Fluttertoast.showToast(
                                    msg: defaultResponseData.message ??
                                        AppLocalizations.of(context)!.something_want_to_wrong,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0),*//*

                                debugPrint('success Responce ${defaultResponseData.message ??
                                    AppLocalizations.of(context)!.something_want_to_wrong}'),
                              }else{
                                      Fluttertoast.showToast(
                                          msg:AppLocalizations.of(context)!.something_want_to_wrong,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0),
                                    }
                          }
                        else
                          {
                            debugPrint('line 304'),
                            Fluttertoast.showToast(
                                msg: defaultResponseData.message ??
                                    AppLocalizations.of(context)!.something_want_to_wrong,
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0),
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                              return const EnvatoPurchaseVerifyScreen();
                            }), (route) => false)
                          }
                      },
                    )
                */
/* .catchError((error) {
                  progressDialog.hide();
                  debugPrint('error.message!${error.message}');
                  Fluttertoast.showToast(
                      msg: error.message,
                      toastLength: Toast.LENGTH_LONG,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                })*//*

              });
    } else {
      progressDialog.hide();
      debugPrint('line 334');
      if(context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return const EnvatoPurchaseVerifyScreen();
        }), (route) => false);
      }
    }
  }
}
*/
