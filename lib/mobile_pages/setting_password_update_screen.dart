import 'package:crossfit_gym_trainer/providers/general_setting_provider.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/default_response.dart';
import '../utils/color_code.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import 'main_drawer_screen.dart';

class SettingPasswordUpdateScreen extends StatefulWidget {
  const SettingPasswordUpdateScreen({Key? key}) : super(key: key);

  @override
  State<SettingPasswordUpdateScreen> createState() => _SettingPasswordUpdateScreenState();
}

class _SettingPasswordUpdateScreenState extends State<SettingPasswordUpdateScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late MemberProvider memberProvider;
  String currentUserId = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late ShowProgressDialog showProgressDialog;
  var passwordController = TextEditingController();
  var passwordNewController = TextEditingController();
  bool _passwordVisible = true;
  bool _passwordNewVisible = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: true);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        currentUserId = await _preference.getValue(prefUserId, "");
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
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
              color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.update_password),
      ),
      body: Consumer<SettingProvider>(
        builder: (context, settingData, child) => Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 64),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: ColorCode.tabBarBackground,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: passwordController,
                  obscureText: _passwordVisible,
                  cursorColor: ColorCode.mainColor,
                  validator: (value) {
                    if (value != null && value.trim().length > 5) {
                      return null;
                    } else {
                      return AppLocalizations.of(context)!.please_enter_password_of_at_least_six_character;
                    }
                  },
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorCode.mainColor,
                      ),
                    ),
                    border: const UnderlineInputBorder(),
                    labelText: '${AppLocalizations.of(context)!.old_password}*',
                    labelStyle: GymStyle.inputText,
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, size: 25),
                      onPressed: () {
                        setState(
                          () {
                            _passwordVisible = !_passwordVisible;
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: passwordNewController,
                  obscureText: _passwordNewVisible,
                  cursorColor: ColorCode.mainColor,
                  validator: (value) {
                    if (value != null && value.trim().length > 5) {
                      return null;
                    } else {
                      return AppLocalizations.of(context)!.please_enter_password_of_at_least_six_character;
                    }
                  },
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorCode.mainColor,
                      ),
                    ),
                    border: const UnderlineInputBorder(),
                    labelText: '${AppLocalizations.of(context)!.new_password}*',
                    labelStyle: GymStyle.inputText,
                    suffixIcon: IconButton(
                      icon: Icon(_passwordNewVisible ? Icons.visibility : Icons.visibility_off, size: 25),
                      onPressed: () {
                        setState(
                          () {
                            _passwordNewVisible = !_passwordNewVisible;
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 50,
                  width: width * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        showProgressDialog.show();
                        memberProvider
                            .matchUserAndPassword(
                              userId: currentUserId,
                              password: passwordController.text.trim(),
                            )
                            .then(
                              (defaultResponse) => {
                                showProgressDialog.hide(),
                                if (defaultResponse.status == true)
                                  {
                                    updateUserPassword(
                                      keyPassword,
                                      passwordNewController.text.trim(),
                                    )
                                  }
                                else
                                  {
                                    Fluttertoast.showToast(
                                        msg:
                                            defaultResponse.message ?? AppLocalizations.of(context)!.password_not_match,
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
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: ColorCode.mainColor,
                    ),
                    child:
                        Text(AppLocalizations.of(context)!.update_password.allInCaps, style: GymStyle.buttonTextStyle),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  Future<void> updateUserPassword(String key, dynamic value) async {
    showProgressDialog.show(message: 'Loading...');
    DefaultResponse defaultResponse =
        await memberProvider.updateDataByKeyValue(userId: currentUserId, key: key, value: value);
    showProgressDialog.hide();
    if (context.mounted) {
      if (defaultResponse.status != null && defaultResponse.status!) {
        passwordController.text = "";
        passwordNewController.text = "";
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.password_updated_successfully,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
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
}
