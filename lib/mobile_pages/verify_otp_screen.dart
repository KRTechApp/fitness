// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/color_code.dart';
import '../utils/firebase_interface.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import 'forgot_password_screen.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String countryCode, mobileNumberOrEmail, fcmToken;
  int resendMobileToken;
  String verificationId;
  String verificationType;

  VerifyOTPScreen(
      this.countryCode, this.mobileNumberOrEmail, this.fcmToken, this.resendMobileToken, this.verificationId,
      {required this.verificationType, super.key});

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  var code = "";
  late Timer timer;
  int secondsRemaining = 60;
  bool enableResend = false;
  late ShowProgressDialog progressDialog;
  FirebaseInterface firebaseInterface = FirebaseInterface();

  @override
  initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (secondsRemaining != 0) {
          setState(
            () {
              secondsRemaining--;
            },
          );
        } else {
          setState(
            () {
              enableResend = true;
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = ColorCode.mainColor;
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = ColorCode.splashColorTwo;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/arrow-left.svg',
                  width: 22,
                  height: 22,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                AppLocalizations.of(context)!.verify_with_otp,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181A20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        length: 6,
                        controller: pinController,
                        focusNode: focusNode,
                        androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                        listenForMultipleSmsOnAndroid: true,
                        defaultPinTheme: defaultPinTheme,
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          debugPrint('onCompleted: $pin');
                        },
                        onChanged: (value) {
                          debugPrint('onChanged: $value');
                          code = value;
                        },
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 9),
                              width: 22,
                              height: 1,
                              color: focusedBorderColor,
                            ),
                          ],
                        ),
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        errorPinTheme: defaultPinTheme.copyBorderWith(
                          border: Border.all(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 38,
            ),
            Center(
              child: Text("${AppLocalizations.of(context)!.enter_sms_code_sent_to} ${getCurrentMobileOrMail()}",
                  style: const TextStyle(
                    color: Color(0xFF181A20),
                  ),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(
                bottom: 25,
                left: 20,
                right: 20,
              ),
              child: ElevatedButton(
                style: GymStyle.buttonStyle,
                onPressed: () {
                  if (code.length < 6) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.please_enter_valid_otp,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    loginWithEmailOrMobile();
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.verify_code,
                  style: GymStyle.buttonTextStyle,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (enableResend)
                    InkWell(
                      onTap: enableResend ? _resendCode : null,
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.resend_code,
                              style: const TextStyle(
                                color: Color(0xFF181A20),
                              ),
                              textAlign: TextAlign.center),
                          const Icon(Icons.refresh, color: Colors.red),
                        ],
                      ),
                    ),
                  if (!enableResend)
                    Text("${AppLocalizations.of(context)!.resend_code_in} $secondsRemaining ${AppLocalizations.of(context)!.seconds}",
                        style: const TextStyle(
                          color: Color(0xFF181A20),
                        ),
                        textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resendCode() async {
    if (widget.verificationType == "email") {
      try {
        // ShowLoading().open(key: _keyLoader, context: context);

        progressDialog.show(message: 'Loading...');

        // Check is already sign up
        final client = SmtpClient(StaticData.sendinblueDomain, isLogEnabled: true);
        try {
          await client.connectToServer(StaticData.sendinblueSMTPServer, int.parse(StaticData.sendinblueSMTPServerPort), isSecure: false);
          await client.ehlo();
          if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
            await client.authenticate(StaticData.sendinblueEmail, StaticData.sendinblueSMTPPassword, AuthMechanism.plain);
          } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
            await client.authenticate(StaticData.sendinblueEmail, StaticData.sendinblueSMTPPassword, AuthMechanism.login);
          } else {
            return;
          }

          var otpNumber = int.parse(
            getOTPNumber(digit: 6),
          );
          final builder = MessageBuilder.prepareMultipartAlternativeMessage(
            plainText:
                '$otpNumber is your One Time Password(OTP) to validate your login on NiftyHMS App. This OTP is valid for 10 minutes. Kindly do not share it with anyone.\n\n Thanks & Regards',
            htmlText:
                '<p><b>$otpNumber</b> is your One Time Password(OTP) to validate your login on NiftyHMS App. This OTP is valid for 10 minutes. Kindly do not share it with anyone.</p>'
                '<p>Thanks & Regards</p>',
          )
            ..from = [MailAddress(StaticData.sendinblueEmailName, StaticData.sendinblueEmailFrom)]
            ..to = [MailAddress(StaticData.sendinblueEmailName, widget.mobileNumberOrEmail)]
            ..subject = '${StaticData.sendinblueEmailName} - Email Verification';
          final mimeMessage = builder.buildMimeMessage();
          final sendResponse = await client.sendMessage(mimeMessage);
          debugPrint('message sent: ${sendResponse.isOkStatus}');
          progressDialog.hide();

          widget.resendMobileToken = otpNumber;
          setState(
            () {
              secondsRemaining = 60;
              enableResend = false;
            },
          );
        } on SmtpException catch (e) {
          debugPrint('SMTP failed with $e');
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
          Fluttertoast.showToast(msg: 'This Browser does not supported Firebase Messaging');
        }
      }
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.countryCode + widget.mobileNumberOrEmail.trim(),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          widget.verificationId = verificationId;
          widget.resendMobileToken = resendToken!;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: widget.resendMobileToken,
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = widget.verificationId;
        },
      );
      setState(
        () {
          secondsRemaining = 60;
          enableResend = false;
        },
      );
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    timer.cancel();
    super.dispose();
  }

  String getCurrentMobileOrMail() {
    return (widget.verificationType == "email"
        ? widget.mobileNumberOrEmail
        : "${widget.countryCode}-${widget.mobileNumberOrEmail}");
  }

  Future<void> loginWithEmailOrMobile() async {
    if (widget.verificationType == "email") {
      if (code == widget.resendMobileToken.toString()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordScreen(widget.mobileNumberOrEmail, widget.verificationType),
          ),
        );
      } else {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.please_enter_valid_otp,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      try {
        PhoneAuthCredential credential =
            PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: code);

        await auth.signInWithCredential(credential).then(
          (value) {
            progressDialog.show(message: 'Loading...');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ForgotPasswordScreen(widget.mobileNumberOrEmail, widget.verificationType),
              ),
            );
          },
        ).onError(
          (error, stackTrace) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.please_enter_valid_otp,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          },
        );
      } catch (e) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.please_enter_valid_otp,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        if (kDebugMode) {
          print("Wrong OTP : $e");
        }
      }
    }
  }

}
