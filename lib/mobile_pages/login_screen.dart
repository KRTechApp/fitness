import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/mobile_pages/admin_request_screen.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';

import '../Utils/color_code.dart';
import '../admin_screen/admin_dashboard_screen.dart';
import '../member_screen/dashboard_screen.dart';
import '../model/default_response.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import '../utils/firebase_interface.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/utils_methods.dart';
import 'envato_purchase_verify_screen.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isRemember = false;
  bool _passwordVisible = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  var emailMobileController = TextEditingController();
  var passwordController = TextEditingController();
  final GlobalKey<FormFieldState> _formStateKeyEmail =
      GlobalKey<FormFieldState>();
  FirebaseInterface firebaseInterface = FirebaseInterface();
  String countryCode = "+91";
  String? fcmToken;
  int? _resendToken;
  String _verificationId = "";
  late ShowProgressDialog progressDialog;
  String switchRole = "";

  @override
  void initState() {
    super.initState();
    progressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        progressDialog.show();
        await FirebaseInterface().defaultAdminCreate(context: context);
        progressDialog.hide();
        envatoProductKey();

        if (await _preference.getValue(keyRemember, false)) {
          _preference.getValue(prefEmail, "").then(
                (email) => {emailMobileController.text = email},
              );
          _preference.getValue(prefPassword, "").then(
                (password) => {passwordController.text = password},
              );
          _preference.getValue(keySwitchRole, "").then(
                (switchRole) => {switchRole = switchRole},
              );
          isRemember = true;
          setState(
            () {},
          );
        }

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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          /*leadingWidth: 48,
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
              'assets/images/back.svg',
              color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
            ),
          ),
        ),*/
          ),
      body: SizedBox(
        height: height,
        width: width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!StaticData.canEditField)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminRequestScreen()));
                      },
                      child: Center(
                        child: Text(
                          'Click to request admin access',
                          style: TextStyle(
                              fontSize: getFontSize(16),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: ColorCode.mainColor,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: height * 0.12,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.login_to_your_account,
                      style: GymStyle.socialLoginLabel,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  TextFormField(
                    key: _formStateKeyEmail,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: isDarkTheme
                        ? ColorCode.lightScreenBackground
                        : ColorCode.socialLoginBackground,
                    style: GymStyle.emailTextStyle,
                    controller: emailMobileController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF6842FF),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // prefixIcon: const Icon(Icons.email_rounded),
                        filled: true,
                        fillColor: isDarkTheme
                            ? ColorCode.socialLoginBackground
                            : ColorCode.lightScreenBackground,
                        hintText: AppLocalizations.of(context)!
                            .email_or_mobile_number,
                        hintStyle: GymStyle.emailHintTextStyle),
                    validator: (String? value) {
                      if (value != null &&
                          (value.trim().isValidEmail() ||
                              (value.trim().isValidPhone() &&
                                  value.length <= 15))) {
                        return null;
                      }
                      return AppLocalizations.of(context)!
                          .please_enter_a_valid_email_or_phone_number;
                    },
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  TextFormField(
                    cursorColor: isDarkTheme
                        ? ColorCode.lightScreenBackground
                        : ColorCode.socialLoginBackground,
                    style: GymStyle.emailTextStyle,
                    keyboardType: TextInputType.visiblePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF6842FF),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      // prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 25),
                        onPressed: () {
                          setState(
                            () {
                              _passwordVisible = !_passwordVisible;
                            },
                          );
                        },
                      ),
                      filled: true,
                      fillColor: isDarkTheme
                          ? ColorCode.socialLoginBackground
                          : ColorCode.lightScreenBackground,
                      hintText: AppLocalizations.of(context)!.password,
                      hintStyle: GymStyle.emailHintTextStyle,
                    ),
                    validator: (String? value) {
                      if (value != null && value.trim().length > 5) {
                        return null;
                      } else {
                        return AppLocalizations.of(context)!
                            .please_enter_password_of_at_least_six_character;
                      }
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF6842FF),
                          width: 2,
                        ),
                        checkColor: Colors.white,
                        activeColor: const Color(0xFF6842FF),
                        value: isRemember,
                        onChanged: (value) {
                          setState(
                            () {
                              isRemember = value!;
                            },
                          );
                        },
                      ),
                      Text(
                        AppLocalizations.of(context)!.remember_me,
                        style: GymStyle.formDescription,
                      )
                    ],
                  ),
                  SizedBox(
                    height: height * 0.035,
                  ),
                  SizedBox(
                    height: height * 0.08,
                    width: width * 0.9,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate() &&
                            _formStateKeyEmail.currentState!.validate()) {
                          handleLogin();
                        }
                      },
                      style: GymStyle.buttonStyle,
                      child: Text(
                        AppLocalizations.of(context)!.sign_in.toUpperCase(),
                        style: GymStyle.buttonTextStyle,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        if (StaticData.sendinblueSMTPServer == "" ||
                            StaticData.sendinblueSMTPServerPort == "" ||
                            StaticData.sendinblueSMTPPassword == "") {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!
                                  .please_update_email_setting_from_admin_side,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          return;
                        } else {
                          if (isNumeric(
                                emailMobileController.text.trim(),
                              ) &&
                              _formStateKeyEmail.currentState!.validate()) {
                            _formStateKeyEmail.currentState!.validate();
                            if (_formStateKeyEmail.currentState!.validate()) {
                              progressDialog.show(message: 'Loading...');
                              firebaseInterface
                                  .checkEmailOrMobileExist(
                                      emailOrMobile:
                                          emailMobileController.text.trim(),
                                      type: 'mobile')
                                  .then(
                                    (defaultResponseData) => {
                                      progressDialog.hide(),
                                      if (defaultResponseData.status != null &&
                                          defaultResponseData.status!)
                                        {
                                          countryCode =
                                              defaultResponseData.responseData[
                                                      keyCountryCode] ??
                                                  "+91",
                                          debugPrint(
                                              "emailMobileController : $emailMobileController"),
                                          sendVerificationMobile(
                                            mContext: context,
                                            mobile: countryCode +
                                                emailMobileController.text
                                                    .trim(),
                                          )
                                        }
                                      else
                                        {
                                          Fluttertoast.showToast(
                                              msg: defaultResponseData
                                                      .message ??
                                                  AppLocalizations.of(context)!
                                                      .user_not_found,
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 3,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0),
                                        }
                                    },
                                  );
                            }
                          } else {
                            _formStateKeyEmail.currentState!.validate();
                            if (_formStateKeyEmail.currentState!.validate()) {
                              progressDialog.show(message: 'Loading...');
                              firebaseInterface
                                  .checkEmailOrMobileExist(
                                      emailOrMobile:
                                          emailMobileController.text.trim(),
                                      type: 'Email')
                                  .then(
                                    (responseData) => {
                                      progressDialog.hide(),
                                      if (responseData.status != null &&
                                          responseData.status!)
                                        {
                                          sendVerificationMail(
                                            mContext: context,
                                            email: emailMobileController.text
                                                .trim()
                                                .toLowerCase(),
                                          )
                                        }
                                      else
                                        {
                                          Fluttertoast.showToast(
                                              msg: responseData.message ??
                                                  AppLocalizations.of(context)!
                                                      .user_not_found,
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 3,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0),
                                        }
                                    },
                                  );
                            }
                          }
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.forgot_password,
                          style: GymStyle.forgotPassword),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 2,
                        width: width * 0.20,
                        color:
                            ColorCode.socialLoginBackground.withOpacity(0.70),
                      ),
                      const SizedBox(width: 15),
                      Text(AppLocalizations.of(context)!.or_continue_with,
                          style: GymStyle.socialLoginText),
                      const SizedBox(width: 15),
                      Container(
                        height: 2,
                        width: width * 0.20,
                        color:
                            ColorCode.socialLoginBackground.withOpacity(0.70),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /* InkWell(
                        onTap: () {
                          FirebaseInterface().loginWithFacebook(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          // margin: EdgeInsets.only(right :width * 0.037,),
                          decoration: BoxDecoration(
                            color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          height: 60,
                          width: 90,
                          child: SvgPicture.asset(
                            'assets/images/facebook_logo.svg',
                          ),
                        ),
                      ),
                      const Spacer(),*/
                      if (Platform.isAndroid) const Spacer(),
                      InkWell(
                        onTap: () {
                          FirebaseInterface().signupWithGoogle(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          // margin: EdgeInsets.only(right :width * 0.037,),
                          decoration: BoxDecoration(
                            color: isDarkTheme
                                ? ColorCode.socialLoginBackground
                                : ColorCode.lightScreenBackground,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          height: 60,
                          width: 90,
                          child: SvgPicture.asset(
                            'assets/images/google_logo.svg',
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (Platform.isIOS)
                        InkWell(
                          onTap: () {
                            FirebaseInterface().signupWithApple(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            // margin: EdgeInsets.only(right :width * 0.037,),
                            decoration: BoxDecoration(
                              color: isDarkTheme
                                  ? ColorCode.socialLoginBackground
                                  : ColorCode.lightScreenBackground,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            height: 60,
                            width: 90,
                            child: SvgPicture.asset(
                              'assets/images/apple_logo.svg',
                              color: isDarkTheme
                                  ? ColorCode.white
                                  : ColorCode.backgroundColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  /*Center(
                    child: RichText(
                      text: TextSpan(
                        text: AppLocalizations.of(context)!.do_not_have_an_account,
                        style: GymStyle.alreadyAccount1,
                        children: <TextSpan>[
                          const TextSpan(
                            text: ' ',
                          ),
                          TextSpan(
                              text: AppLocalizations.of(context)!.sign_up,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => const CreateAccountScreen(),),);
                                },
                              style: GymStyle.signUpAccount),
                        ],
                      ),
                    ),
                  )*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void sendVerificationMobile(
      {required BuildContext mContext, required String mobile}) {
    debugPrint("mobile Number : $mobile");

    progressDialog.show(message: 'Loading...');
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+$mobile",
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("FirebaseAuthException : $e");
        progressDialog.hide();
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        progressDialog.hide();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOTPScreen(
              countryCode,
              emailMobileController.text.trim(),
              fcmToken ?? "",
              _resendToken ?? 0,
              _verificationId,
              verificationType: "mobile",
            ),
          ),
        );
      },
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationId = _verificationId;
      },
    );
  }

  Future<void> sendVerificationMail(
      {required BuildContext mContext, required String email}) async {
    try {
      progressDialog.show(message: 'Loading...');

      // Check is already sign up
      final client =
          SmtpClient(StaticData.sendinblueDomain, isLogEnabled: true);
      try {
        await client.connectToServer(StaticData.sendinblueSMTPServer,
            int.parse(StaticData.sendinblueSMTPServerPort),
            isSecure: false);
        await client.ehlo();
        if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
          await client.authenticate(StaticData.sendinblueEmail,
              StaticData.sendinblueSMTPPassword, AuthMechanism.plain);
        } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
          await client.authenticate(StaticData.sendinblueEmail,
              StaticData.sendinblueSMTPPassword, AuthMechanism.login);
        } else {
          return;
        }

        var otpNumber = int.parse(
          getOTPNumber(digit: 6),
        );
        final builder = MessageBuilder.prepareMultipartAlternativeMessage(
          plainText:
              '$otpNumber is your One Time Password(OTP) to validate your forgotten password on Gym Trainer App. This OTP is valid for 10 minutes. Kindly do not share it with anyone.\n\n Thanks & Regards',
          htmlText:
              '<p><b>$otpNumber</b> is your One Time Password(OTP) to validate your forgotten password on Gym Trainer App. This OTP is valid for 10 minutes. Kindly do not share it with anyone.</p>'
              '<p>Thanks & Regards</p>',
        )
          ..from = [
            MailAddress(
                StaticData.sendinblueEmailName, StaticData.sendinblueEmailFrom)
          ]
          ..to = [MailAddress(StaticData.sendinblueEmailName, email)]
          ..subject = '${StaticData.sendinblueEmailName} - Forgot Password';
        final mimeMessage = builder.buildMimeMessage();
        final sendResponse = await client.sendMessage(mimeMessage);
        debugPrint('message sent: ${sendResponse.isOkStatus}');
        progressDialog.hide();
        if (mContext.mounted) {
          redirectVerificationScreen(mContext: mContext, otpNumber: otpNumber);
        }
      } on SmtpException catch (e) {
        debugPrint('SMT P failed with $e');
        progressDialog.hide();
      }
    } catch (e) {
      progressDialog.hide();
      debugPrint(
        e.toString(),
      );
      if (e.toString().contains('invalid') ||
          e.toString().contains('code') ||
          e.toString().contains('verification')) {
        Fluttertoast.showToast(
          msg: e.toString(),
        );
      } else if (e.toString().contains('messaging/unsupported-browser')) {
        Fluttertoast.showToast(
            msg: 'This Browser does not supported Firebase Messaging');
      }
    }
  }

  void redirectVerificationScreen(
      {required BuildContext mContext, required int otpNumber}) {
    Navigator.push(
      mContext,
      MaterialPageRoute(
        builder: (context) => VerifyOTPScreen(
          countryCode,
          emailMobileController.text.trim(),
          fcmToken ?? "",
          otpNumber,
          _verificationId,
          verificationType: "email",
        ),
      ),
    );
  }

  Future<void> handleLogin() async {
    progressDialog.show();

    DefaultResponse defaultResponse = await firebaseInterface
        .getUserEmailOrMobile(emailOrMobile: emailMobileController.text.trim());
    debugPrint('LoginResponce : $defaultResponse');
    if (defaultResponse.status == false) {
      Fluttertoast.showToast(
          msg: defaultResponse.message!,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      progressDialog.hide();
      return;
    }
    User? currentUser;
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: defaultResponse.responseData[keyEmail],
      password: passwordController.text.trim(),
    )
        .then(
      (auth) {
        currentUser = auth.user;
        firebaseInterface
            .loginUserFromIdFirebase(
          id: currentUser!.uid.toString(),
          firebaseToken: fcmToken.toString(),
        )
            .then(
          (defaultResponse) async {
            if (defaultResponse.status!) {
              progressDialog.hide();
              _preference.setValue(prefIsLogin, true);
              _preference.setValue(prefFirebaseToken, fcmToken);
              _preference.setValue(
                prefName,
                defaultResponse.responseData[keyName],
              );
              _preference.setValue(
                prefEmail,
                defaultResponse.responseData[keyEmail],
              );
              _preference.setValue(
                prefPassword,
                defaultResponse.responseData[keyPassword],
              );
              _preference.setValue(
                prefAddress,
                defaultResponse.responseData[keyAddress],
              );
              _preference.setValue(
                prefAge,
                defaultResponse.responseData[keyAge],
              );
              _preference.setValue(
                prefCountryCode,
                defaultResponse.responseData[keyCountryCode],
              );
              _preference.setValue(
                prefPhone,
                defaultResponse.responseData[keyPhone],
              );
              _preference.setValue(
                prefWeight,
                defaultResponse.responseData[keyWeight],
              );
              _preference.setValue(
                prefHeight,
                defaultResponse.responseData[keyHeight],
              );
              _preference.setValue(
                prefGender,
                defaultResponse.responseData[keyGender],
              );
              _preference.setValue(
                prefDateOfBirth,
                defaultResponse.responseData[keyDateOfBirth],
              );
              _preference.setValue(
                prefUserRole,
                defaultResponse.responseData[keyUserRole],
              );
              _preference.setValue(
                prefAccountStatus,
                defaultResponse.responseData[keyAccountStatus],
              );
              _preference.setValue(
                prefProfile,
                defaultResponse.responseData[keyProfile],
              );
              _preference.setValue(
                prefCurrentDate,
                defaultResponse.responseData[keyCurrentDate],
              );
              _preference.setValue(prefUserId,
                  (defaultResponse.responseData as DocumentSnapshot).id);
              if (defaultResponse.responseData[keyUserRole] != userRoleAdmin &&
                  switchRole != userRoleAdmin) {
                _preference.setValue(
                  prefCreatedBy,
                  defaultResponse.responseData[keyCreatedBy],
                );
              }
              if (isRemember) {
                _preference.setValue(
                  keyEmail,
                  emailMobileController.text.trim(),
                );
                _preference.setValue(keyPassword, passwordController.text.trim);
                _preference.setValue(keyRemember, isRemember);
              } else {
                _preference.removeValue(keyEmail);
                _preference.removeValue(keyPassword);
                _preference.removeValue(keyRemember);
              }
              notificationInit();
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.login_successfully,
                  toastLength: Toast.LENGTH_LONG,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
              if (defaultResponse.responseData[keyUserRole] == userRoleAdmin) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                  ModalRoute.withName("/AdminScreen"),
                );
              } else if (defaultResponse.responseData[keyUserRole] ==
                  userRoleTrainer) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainerDashboardScreen(),
                  ),
                  ModalRoute.withName("/TrainerScreen"),
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                  ModalRoute.withName("/MemberScreen"),
                );
              }
            } else {
              progressDialog.hide();
              debugPrint('defaultResponse.message!${defaultResponse.message!}');
              Fluttertoast.showToast(
                  msg: defaultResponse.message!,
                  toastLength: Toast.LENGTH_LONG,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
        );
      },
    ).catchError(
      (error) {
        progressDialog.hide();
        debugPrint('error.message!${error.message!}');
        Fluttertoast.showToast(
            msg: error.message!,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  Future<void> envatoProductKey() async {
    progressDialog.show();

    var querySnapshot = await FirebaseInterface()
        .fireStore
        .collection(tableUser)
        .where(keyUserRole, isEqualTo: userRoleAdmin)
        .get();
    if (querySnapshot.docs.isNotEmpty &&
        getDocumentValue(
                documentSnapshot: querySnapshot.docs.first, key: keyClientEmail)
            .toString()
            .isNotEmpty &&
        getDocumentValue(
                documentSnapshot: querySnapshot.docs.first,
                key: keyEnventoPurchaseKey)
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
                        licenseKey:
                            querySnapshot.docs.first.get(keyEnventoPurchaseKey))
                    .then(
                      (defaultResponseData) => {
                        progressDialog.hide(),
                        debugPrint('line 288'),
                        if (defaultResponseData.status != null &&
                            defaultResponseData.status!)
                          {
                            debugPrint('line 291'),
                            if (defaultResponseData.responseData == '1')
                              {
                                Fluttertoast.showToast(
                                    msg:
                                        'Please provide correct Envato purchase key.',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0),
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) {
                                  return const EnvatoPurchaseVerifyScreen();
                                }), (route) => false),
                                debugPrint(
                                    'Please provide correct Envato purchase key.')
                              }
                            else if (defaultResponseData.responseData == '2')
                              {
                                Fluttertoast.showToast(
                                    msg:
                                        'This purchase key is already registered with the different domain. If have any issue please contact us at sales@mojoomla.com',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0),
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) {
                                  return const EnvatoPurchaseVerifyScreen();
                                }), (route) => false),
                                debugPrint(
                                    'This purchase key is already registered with the different domain. If have any issue please contact us at sales@mojoomla.com'),
                              }
                            else if (defaultResponseData.responseData == '3')
                              {
                                Fluttertoast.showToast(
                                    msg:
                                        'There seems to be some problem please try after sometime or contact us on sales@mojoomla.com',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0),
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) {
                                  return const EnvatoPurchaseVerifyScreen();
                                }), (route) => false),
                                debugPrint(
                                    'There seems to be some problem please try after sometime or contact us on sales@mojoomla.com'),
                              }
                            else if (defaultResponseData.responseData == '4')
                              {
                                Fluttertoast.showToast(
                                    msg:
                                        'Please provide correct Envato purchase key for this plugin.',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0),
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) {
                                  return const EnvatoPurchaseVerifyScreen();
                                }), (route) => false),
                                debugPrint(
                                    'Please provide correct Envato purchase key for this plugin.'),
                              }
                            else if (defaultResponseData.responseData == '0')
                              {
                                /* Fluttertoast.showToast(
                                    msg: defaultResponseData.message ??
                                        AppLocalizations.of(context)!.something_want_to_wrong,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0),*/
                                debugPrint(
                                    'success Responce ${defaultResponseData.message ?? AppLocalizations.of(context)!.something_want_to_wrong}'),
                              }
                            else
                              {
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!
                                        .something_want_to_wrong,
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
                                    AppLocalizations.of(context)!
                                        .something_want_to_wrong,
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0),
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) {
                              return const EnvatoPurchaseVerifyScreen();
                            }), (route) => false)
                          }
                      },
                    )
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
                })*/
              });
    } else {
      progressDialog.hide();
      debugPrint('line 334');
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return const EnvatoPurchaseVerifyScreen();
        }), (route) => false);
      }
    }
  }
}
