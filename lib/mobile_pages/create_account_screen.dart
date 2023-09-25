import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/model/user_modal.dart';
import 'package:crossfit_gym_trainer/utils/firebase_interface.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';

import '../member_screen/gender_screen.dart';
import '../utils/color_code.dart';
import '../main.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool valueFirst = false;
  bool _passwordVisible = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UserModal userModal = UserModal();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  FirebaseInterface firebaseInterface = FirebaseInterface();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
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
        ),
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
                  SizedBox(
                    height: height * 0.12,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.create_your_account,
                      textAlign: TextAlign.center,
                      style: GymStyle.socialLoginLabel,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    cursorColor: isDarkTheme ? ColorCode.lightScreenBackground : ColorCode.socialLoginBackground,
                    style: GymStyle.emailTextStyle,
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
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.email_rounded),
                        filled: true,
                        fillColor: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                        hintText: AppLocalizations.of(context)!.email,
                        hintStyle: GymStyle.emailHintTextStyle),
                    validator: (String? value) {
                      if (value != null && value.trim().isValidEmail()) {
                        return null;
                      }
                      return AppLocalizations.of(context)!.please_enter_a_valid_email_id;
                    },
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  TextFormField(
                    cursorColor: isDarkTheme ? ColorCode.lightScreenBackground : ColorCode.socialLoginBackground,
                    style: GymStyle.emailTextStyle,
                    controller: passwordController,
                    obscureText: _passwordVisible,
                    keyboardType: TextInputType.visiblePassword,
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
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10.0),
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
                        hintText: AppLocalizations.of(context)!.password,
                        hintStyle: GymStyle.emailHintTextStyle),
                    validator: (String? value) {
                      if (value != null && value.trim().length > 5) {
                        return null;
                      } else {
                        return AppLocalizations.of(context)!.please_enter_password_of_at_least_six_character;
                      }
                    },
                  ),
                  SizedBox(
                    height: height * 0.06,
                  ),
                  SizedBox(
                    height: height * 0.08,
                    width: width * 0.9,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          userModal.userEmail = emailController.text.trim();
                          userModal.userPassword = passwordController.text.trim();
                          firebaseInterface
                              .checkEmailOrMobileExist(emailOrMobile: emailController.text.trim(), type: 'email')
                              .then(
                                (defaultResponseData) => {
                                  if (defaultResponseData.status != null && defaultResponseData.status!)
                                    {
                                      Fluttertoast.showToast(
                                          msg: AppLocalizations.of(context)!.member_already_exits,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0)
                                    }
                                  else
                                    {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Gender(
                                            userModal: userModal,
                                          ),
                                        ),
                                      )
                                    }
                                },
                              );
                        }
                      },
                      style: GymStyle.buttonStyle,
                      child: Text(
                        AppLocalizations.of(context)!.sign_up.toUpperCase(),
                        style: GymStyle.buttonTextStyle,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 2,
                        width: width * 0.20,
                        color: ColorCode.socialLoginBackground.withOpacity(0.70),
                      ),
                      const SizedBox(width: 15),
                      Text(AppLocalizations.of(context)!.or_continue_with, style: GymStyle.socialLoginText),
                      const SizedBox(width: 15),
                      Container(
                        height: 2,
                        width: width * 0.20,
                        color: ColorCode.socialLoginBackground.withOpacity(0.70),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
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
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                          decoration: BoxDecoration(
                            color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
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
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        decoration: BoxDecoration(
                          color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        height: 60,
                        width: 90,
                        child: SvgPicture.asset(
                          'assets/images/apple_logo.svg',
                          color: isDarkTheme ? ColorCode.white : ColorCode.backgroundColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: AppLocalizations.of(context)!.all_ready_have_an_account,
                        style: GymStyle.alreadyAccount1,
                        children: <TextSpan>[
                          const TextSpan(
                            text: ' ',
                          ),
                          TextSpan(
                              text: AppLocalizations.of(context)!.sign_in,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                              style: GymStyle.signUpAccount),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
