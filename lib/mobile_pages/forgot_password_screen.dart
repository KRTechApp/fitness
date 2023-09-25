// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/color_code.dart';
import '../utils/firebase_interface.dart';
import '../utils/gym_style.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import '../main.dart';
import 'login_screen.dart';
import 'social_login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  String mobileNumberOrEmail, type;

  ForgotPasswordScreen(this.mobileNumberOrEmail, this.type, {super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  var newPasswordController = TextEditingController();
  var conPasswordController = TextEditingController();
  bool _passwordVisible = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirebaseInterface firebaseInterface = FirebaseInterface();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late ShowProgressDialog progressDialog;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  UserCredential? currentUser;
  QuerySnapshot? document;

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
        leading: InkWell(
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
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 40),
                  child: Text(
                    AppLocalizations.of(context)!.forgot_password,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    cursorColor: isDarkTheme ? ColorCode.lightScreenBackground : ColorCode.socialLoginBackground,
                    style: GymStyle.emailTextStyle,
                    controller: newPasswordController,
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
                          borderSide: const BorderSide(color: Colors.red, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility, size: 25),
                          onPressed: () {
                            setState(
                              () {
                                _passwordVisible = !_passwordVisible;
                              },
                            );
                          },
                        ),
                        filled: true,
                        fillColor: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                        hintText: AppLocalizations.of(context)!.new_password,
                        hintStyle: GymStyle.emailHintTextStyle),
                    validator: (String? value) {
                      if (value != null && value.trim().length > 5) {
                        return null;
                      } else {
                        return AppLocalizations.of(context)!.please_enter_password_of_at_least_six_character;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    cursorColor: isDarkTheme ? ColorCode.lightScreenBackground : ColorCode.socialLoginBackground,
                    style: GymStyle.emailTextStyle,
                    controller: conPasswordController,
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
                          borderSide: const BorderSide(color: Colors.red, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility, size: 25),
                          onPressed: () {
                            setState(
                              () {
                                _passwordVisible = !_passwordVisible;
                              },
                            );
                          },
                        ),
                        filled: true,
                        fillColor: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                        hintText: AppLocalizations.of(context)!.confirm_password,
                        hintStyle: GymStyle.emailHintTextStyle),
                    validator: (String? value) {
                      if (value != null &&
                          value.trim().length > 5 &&
                          newPasswordController.text.trim() == value.trim()) {
                        return null;
                      } else {
                        return AppLocalizations.of(context)!.password_not_match;
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 25,
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
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        progressDialog.show(message: 'Loading...');
                        debugPrint(widget.mobileNumberOrEmail);
                        document = await firebaseFirestore
                            .collection(tableUser)
                            .where(keyEmail, isEqualTo: widget.mobileNumberOrEmail)
                            .get();
                        firebaseInterface
                            .resetPasswordFirebase(
                                emailOrMobile: widget.mobileNumberOrEmail,
                                newPassword: conPasswordController.text.trim(),
                                type: widget.type)
                            .then(
                          (defaultResponse) async {
                            if (defaultResponse.status!) {
                              debugPrint("updateAdminProfile : 1");
                              if (document!.docs.isNotEmpty &&
                                  document!.docs[0].get(keyEmail) == widget.mobileNumberOrEmail) {
                                debugPrint("updateAdminProfile : 2");
                                debugPrint("updateAdminProfile : 3 ${widget.mobileNumberOrEmail}");
                                debugPrint("updateAdminProfile : 4" "${document!.docs[0].get(keyPassword)}");

                                currentUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: widget.mobileNumberOrEmail,
                                  password: document!.docs[0].get(keyPassword),
                                );

                                debugPrint("updateAdminProfile : 5");
                                currentUser!.user!.updatePassword(newPasswordController.text.trim());
                              } else {
                                defaultResponse.statusCode = onFailed;
                                defaultResponse.status = false;
                                defaultResponse.message = "Please enter valid email";
                              }

                              _preference.setValue(
                                prefPassword,
                                defaultResponse.responseData[keyPassword],
                              );

                              if(context.mounted) {
                                Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context)!.password_updated_successfully,
                                  toastLength: Toast.LENGTH_LONG,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              }
                            } else {
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
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.submit,
                      style: GymStyle.buttonTextStyle,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
