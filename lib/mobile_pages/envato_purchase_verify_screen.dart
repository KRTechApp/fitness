import 'package:crossfit_gym_trainer/mobile_pages/login_screen.dart';
import 'package:crossfit_gym_trainer/mobile_pages/social_login_screen.dart';
import 'package:crossfit_gym_trainer/providers/payment_history_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../main.dart';
import '../utils/firebase_interface.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';

class EnvatoPurchaseVerifyScreen extends StatefulWidget {
  const EnvatoPurchaseVerifyScreen({super.key});

  @override
  State<EnvatoPurchaseVerifyScreen> createState() => _EnvatoPurchaseVerifyScreenState();
}

class _EnvatoPurchaseVerifyScreenState extends State<EnvatoPurchaseVerifyScreen> {
  var email = TextEditingController();
  var envatoKey = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late PaymentHistoryProvider paymentHistoryProvider;
  FirebaseInterface firebaseInterface = FirebaseInterface();
  late ShowProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.1,
                ),
                Text(
                  AppLocalizations.of(context)!.app_name,
                  style: GymStyle.screenHeader,
                ),
                const SizedBox(height: 20),
                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: email,
                    cursorColor: ColorCode.mainColor,
                    validator: (String? value) {
                      if (value != null && value.trim().isValidEmail()) {
                        return null;
                      } else {
                        return AppLocalizations.of(context)!.please_enter_valid_email;
                      }
                    },
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
                      filled: true,
                      fillColor: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                      hintText: "${AppLocalizations.of(context)!.email}*",
                      hintStyle: GymStyle.inputText,
                    ),
                    style: GymStyle.drawerswitchtext),
                const SizedBox(height: 20),
                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: envatoKey,
                    cursorColor: ColorCode.mainColor,
                    validator: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        return null;
                      } else {
                        return AppLocalizations.of(context)!.please_enter_envato_purchase_key;
                      }
                    },
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
                      filled: true,
                      fillColor: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.lightScreenBackground,
                      hintText: "${AppLocalizations.of(context)!.envanto_key}*",
                      hintStyle: GymStyle.inputText,
                    ),
                    style: GymStyle.drawerswitchtext),
                const SizedBox(height: 30),
                SizedBox(
                  height: height * 0.08,
                  width: width * 0.9,
                  child: ElevatedButton(
                      style: GymStyle.buttonStyle,
                      child: Text(
                        AppLocalizations.of(context)!.submit.allInCaps,
                        style: GymStyle.buttonTextStyle,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await firebaseInterface
                              .initialCheck(email: email.text.trim().toString(), licenseKey: envatoKey.text.trim().toString())
                              .then((defaultResponseData) => {
                                    progressDialog.hide(),
                                    debugPrint('line 288'),
                                    if (defaultResponseData.status != null && defaultResponseData.status!)
                                      {
                                        debugPrint('defaultResponseData.responseData : ${defaultResponseData.responseData}'),
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
                                            debugPrint('Please provide correct Envato purchase key.')
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
                                            debugPrint('Please provide correct Envato purchase key for this plugin.'),
                                          }
                                        else if (defaultResponseData.responseData == '0')
                                          {
                                            FirebaseInterface()
                                                .fireStore
                                                .collection(tableUser)
                                                .where(keyUserRole, isEqualTo: userRoleAdmin)
                                                .get()
                                                .then((querySnapshot) => {
                                                      if (querySnapshot.docs.isNotEmpty)
                                                        {
                                                          FirebaseAuth.instance
                                                              .signInWithEmailAndPassword(
                                                                email: querySnapshot.docs.first.get(keyEmail),
                                                                password: querySnapshot.docs.first.get(keyPassword),
                                                              )
                                                              .then((value) async => {
                                                                    paymentHistoryProvider
                                                                        .updateAdminDocument(
                                                                            envatoEmail: email.text.trim().toString(),
                                                                            envatoKey: envatoKey.text.trim().toString())
                                                                        .then(
                                                                          (defaultResponseData) => {
                                                                            if (defaultResponseData.status != null && defaultResponseData.status!)
                                                                              {
                                                                                Fluttertoast.showToast(
                                                                                    msg: defaultResponseData.message ??
                                                                                        AppLocalizations.of(context)!.something_want_to_wrong,
                                                                                    toastLength: Toast.LENGTH_LONG,
                                                                                    gravity: ToastGravity.BOTTOM,
                                                                                    timeInSecForIosWeb: 3,
                                                                                    backgroundColor: Colors.red,
                                                                                    textColor: Colors.white,
                                                                                    fontSize: 16.0),
                                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                                    MaterialPageRoute(builder: (context) {
                                                                                  return const LoginScreen();
                                                                                }), (route) => false)
                                                                              }
                                                                            else
                                                                              {
                                                                                Fluttertoast.showToast(
                                                                                    msg: defaultResponseData.message ??
                                                                                        AppLocalizations.of(context)!.something_want_to_wrong,
                                                                                    toastLength: Toast.LENGTH_LONG,
                                                                                    gravity: ToastGravity.BOTTOM,
                                                                                    timeInSecForIosWeb: 3,
                                                                                    backgroundColor: Colors.red,
                                                                                    textColor: Colors.white,
                                                                                    fontSize: 16.0)
                                                                              }
                                                                          },
                                                                        ),
                                                                  })
                                                        }
                                                    }),
                                          }
                                        else
                                          {
                                            Fluttertoast.showToast(
                                                msg: AppLocalizations.of(context)!.something_want_to_wrong,
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0)
                                          }
                                      },
                                  });
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
