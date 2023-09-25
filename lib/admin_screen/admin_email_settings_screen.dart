import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../model/default_response.dart';
import '../providers/general_setting_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/utils_methods.dart';

class AdminEmailSettingsScreen extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;

  const AdminEmailSettingsScreen({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  State<AdminEmailSettingsScreen> createState() =>
      _AdminEmailSettingsScreenState();
}

class _AdminEmailSettingsScreenState extends State<AdminEmailSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool enableMailNotification = false;
  bool expirationMailNotification = false;
  bool membershipRunsOut = false;
  late SettingProvider generalSettingProvider;
  late ShowProgressDialog showProgressDialog;
  var emailController = TextEditingController();
  var domainController = TextEditingController();
  var emailNameController = TextEditingController();
  var smtpServerController = TextEditingController();
  var smtpServerPortController = TextEditingController();
  var loginEmailController = TextEditingController();
  var smtpPasswordController = TextEditingController();
  var sendinBlueApiKey = TextEditingController();

  @override
  void initState() {
    super.initState();
    showProgressDialog =
        ShowProgressDialog(context: context, barrierDismissible: true);
    generalSettingProvider =
        Provider.of<SettingProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        showProgressDialog.show();
        generalSettingProvider.getSettingsList().then((value) => {
              showProgressDialog.hide(),
              updateDocument(generalSettingProvider.generalSettingItem)
            });
        if(getDocumentValue(documentSnapshot: widget.documentSnapshot!,key: keyEmailFrom,defaultValue: "").toString().isNotEmpty) {
          emailController.text = widget.documentSnapshot!.get(keyEmailFrom);
          domainController.text = widget.documentSnapshot!.get(keyDomain);
          emailNameController.text = widget.documentSnapshot!.get(keyEmailName);
          smtpServerController.text = widget.documentSnapshot!.get(keySMTPServer);
          smtpServerPortController.text = (widget.documentSnapshot!.get(keySMTPServerPort)).toString();
          loginEmailController.text = widget.documentSnapshot!.get(keyLoginEmail);
          smtpPasswordController.text = widget.documentSnapshot!.get(keySMTPPassword);
          sendinBlueApiKey.text = widget.documentSnapshot!.get(keySendinBlueApi);
          debugPrint('SMTP Server port : ${widget.documentSnapshot!.get(keySMTPServerPort)}');
          debugPrint('SMTP Login Email : ${widget.documentSnapshot!.get(keyLoginEmail)}');
          debugPrint('SMTP Password : ${widget.documentSnapshot!.get(keySMTPPassword)}');
      }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
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
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.email_setting),
      ),
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
            margin: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: ColorCode.tabBarBackground,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      AppLocalizations.of(context)!.enable_mail_notification,
                      style:
                      const TextStyle(fontSize: 14, color: ColorCode.tabBarText),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1,
                          child: Checkbox(
                            visualDensity: VisualDensity.compact,
                            activeColor: ColorCode.mainColor,
                            value: enableMailNotification,
                            onChanged: (bool? value) {
                              if (value != null) {
                                setState(
                                      () {
                                    enableMailNotification = value;
                                  },
                                );
                                updateEmailSetting(
                                    keyEnableMail, enableMailNotification);
                              }
                            },
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.enable,
                          style: TextStyle(
                              fontSize: 16,
                              color: enableMailNotification
                                  ? ColorCode.backgroundColor
                                  : ColorCode.tabBarText,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding:
                    EdgeInsets.only(top: 10.0, bottom: 25, left: 20, right: 20),
                    child:
                    Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                  ),
                  if (enableMailNotification == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              AppLocalizations.of(context)!.expiration_mail_notification,
                              style: const TextStyle(fontSize: 14, color: ColorCode.tabBarText),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 1,
                                  child: Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    activeColor: ColorCode.mainColor,
                                    value: expirationMailNotification,
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        setState(
                                          () {
                                            expirationMailNotification = value;
                                          },
                                        );
                                        updateEmailSetting(keyExpirationMail, expirationMailNotification);
                                      }
                                    },
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.enable,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: expirationMailNotification ? ColorCode.backgroundColor : ColorCode.tabBarText,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 25, left: 20, right: 20),
                            child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              AppLocalizations.of(context)!.membership_runs_out,
                              style: const TextStyle(fontSize: 14, color: ColorCode.tabBarText),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 1,
                                  child: Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    activeColor: ColorCode.mainColor,
                                    value: membershipRunsOut,
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        setState(
                                          () {
                                            membershipRunsOut = value;
                                          },
                                        );
                                        updateEmailSetting(keyMembershipRunsOut, membershipRunsOut);
                                      }
                                    },
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.enable,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: membershipRunsOut ? ColorCode.backgroundColor : ColorCode.tabBarText,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, left: 20, right: 20),
                            child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                          ),*/
                            Center(
                              child: Text(
                                AppLocalizations.of(context)!.sendinblue_details,
                                style: GymStyle.containerHeader,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: emailController,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.text,
                              style: GymStyle.settingSubTitleText,
                              validator: (String? value) {
                                if (value != null &&
                                    value.trim().isValidEmail()) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!
                                      .please_enter_valid_email;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabDivider,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabBarBoldText,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                labelText:
                                '${AppLocalizations.of(context)!.email_from}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: domainController,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.text,
                              style: GymStyle.settingSubTitleText,
                              validator: (String? value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!
                                      .please_enter_domain;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabDivider,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabBarBoldText,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                labelText:
                                '${AppLocalizations.of(context)!.domain}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: emailNameController,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.text,
                              style: GymStyle.settingSubTitleText,
                              validator: (String? value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!
                                      .please_enter_email_name;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabDivider,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabBarBoldText,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                labelText:
                                '${AppLocalizations.of(context)!.email_name}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: smtpServerController,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.text,
                              style: GymStyle.settingSubTitleText,
                              validator: (String? value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!
                                      .please_enter_smtp_server;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabDivider,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabBarBoldText,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                labelText:
                                '${AppLocalizations.of(context)!.smtp_server}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: smtpServerPortController,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.number,
                              style: GymStyle.settingSubTitleText,
                              validator: (String? value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!
                                      .please_enter_smtp_server_port;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabDivider,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabBarBoldText,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                labelText:
                                '${AppLocalizations.of(context)!.smtp_server_port}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: loginEmailController,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.emailAddress,
                              style: GymStyle.settingSubTitleText,
                              validator: (String? value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!
                                      .please_enter_login_email;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabDivider,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabBarBoldText,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                labelText:
                                '${AppLocalizations.of(context)!.login_email}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: smtpPasswordController,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.visiblePassword,
                              style: GymStyle.settingSubTitleText,
                              validator: (String? value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!
                                      .please_enter_smtp_password;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabDivider,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabBarBoldText,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                labelText:
                                '${AppLocalizations.of(context)!.smtp_password}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: sendinBlueApiKey,
                              cursorColor: ColorCode.mainColor,
                              style: GymStyle.settingSubTitleText,
                              validator: (String? value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!
                                      .please_enter_sendinblue_api;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabDivider,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.tabBarBoldText,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                labelText:
                                '${AppLocalizations.of(context)!.api_key}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (keyboardHeight > 0) getSubmitButton(height: height, width: width)
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          if (keyboardHeight == 0)
            Positioned(
              bottom: 20,
              right: 15,
              left: 15,
              child: getSubmitButton(height: height, width: width))
        ],
      ),
    );
  }

  Future<void> updateEmailSetting(String key, dynamic value) async {
    showProgressDialog.show(message: 'Loading...');
    DefaultResponse defaultResponse =
        await generalSettingProvider.updateSettingByKeyValue(
            settingId: widget.documentSnapshot?.id, key: key, value: value);
    showProgressDialog.hide();
    if (context.mounted) {
      if (defaultResponse.status != null && defaultResponse.status!) {
        Fluttertoast.showToast(
            msg: defaultResponse.message ??
                AppLocalizations.of(context)!.something_want_to_wrong,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        refreshData();
      } else {
        Fluttertoast.showToast(
            msg: defaultResponse.message ??
                AppLocalizations.of(context)!.something_want_to_wrong,
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
      setState(() {
        enableMailNotification =
            (documentSnapshot.data() as Map<String, dynamic>)
                    .containsKey(keyEnableMail)
                ? documentSnapshot.get(keyEnableMail)
                : enableMailNotification;
        /* expirationMailNotification = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyExpirationMail)
            ? documentSnapshot.get(keyExpirationMail)
            : expirationMailNotification;
        membershipRunsOut = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyMembershipRunsOut)
            ? documentSnapshot.get(keyMembershipRunsOut)
            : membershipRunsOut;*/
      });
    }
  }

  Future<void> refreshData() async {
    showProgressDialog.show();
    generalSettingProvider.getSettingsList().then((value) => {
          showProgressDialog.hide(),
          updateDocument(generalSettingProvider.generalSettingItem)
        });
  }

  Widget getSubmitButton({required double height, required double width}) {
    return SizedBox(
      height: height * 0.08,
      width: width * 0.9,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            showProgressDialog.show();
            generalSettingProvider.updateEmailSetting(
                settingId: widget.documentSnapshot!.id,
                domain: domainController.text.trim().toString(),
                emailFrom: emailController.text.trim().toString(),
                emailName: emailNameController.text.trim().toString(),
                loginEmail: loginEmailController.text.trim().toString(),
                smtpPassword: smtpPasswordController.text.trim().toString(),
                smtpServer: smtpServerController.text.trim().toString(),
                apikey: sendinBlueApiKey.text.trim().toString(),
                smtpServerPort: smtpServerPortController.text.trim()) .then(
                  (defaultResponse) {
                showProgressDialog.hide();
                if (defaultResponse.status!) {
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.sendblue_details_updated_successfully,
                      toastLength: Toast.LENGTH_LONG,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  showProgressDialog.hide();
                  Fluttertoast.showToast(
                      msg: defaultResponse.message!,
                      toastLength: Toast.LENGTH_LONG,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },);
          }        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: ColorCode.mainColor,
        ),
        child: Text(AppLocalizations.of(context)!.save, style: GymStyle.buttonTextStyle),
      ),
    );
  }
}
