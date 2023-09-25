import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../utils/tables_keys_values.dart';

class AdminVirtualClassSettingsScreen extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;

  const AdminVirtualClassSettingsScreen({Key? key, this.documentSnapshot}) : super(key: key);

  @override
  State<AdminVirtualClassSettingsScreen> createState() => _AdminVirtualClassSettingsScreenState();
}

class _AdminVirtualClassSettingsScreenState extends State<AdminVirtualClassSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool virtualClassSchedule = false;
  TextEditingController clientId = TextEditingController();
  TextEditingController secretClientId = TextEditingController();
  TextEditingController url = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SettingProvider generalSettingProvider;
  late ShowProgressDialog showProgressDialog;


  @override
  void initState() {
    super.initState();
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: true);
    generalSettingProvider = Provider.of<SettingProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
        showProgressDialog.show();
        generalSettingProvider
            .getSettingsList()
            .then((value) => {showProgressDialog.hide(), updateDocument(generalSettingProvider.generalSettingItem)});
      },
    );
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
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.virtual_class_settings),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Container(
              width: width,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: ColorCode.tabBarBackground,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.virtual_class_schedule,
                        style: GymStyle.settingHeadingTitle,
                      ),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1,
                            child: Checkbox(
                              visualDensity: VisualDensity.compact,
                              activeColor: ColorCode.mainColor,
                              value: virtualClassSchedule,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    virtualClassSchedule = value;
                                  });
                                  updateEmailSetting(keyVirtualClass, virtualClassSchedule);
                                }
                              },
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.enable,
                            style: TextStyle(
                                fontSize: 16,
                                color: virtualClassSchedule ? ColorCode.backgroundColor : ColorCode.tabBarText,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      /* if (virtualClassSchedule)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                            TextFormField(
                              controller: clientId,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.text,
                              style: GymStyle.settingSubTitleText,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!.please_enter_your_clint_id;
                                }
                                return null;
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
                                labelText: '${AppLocalizations.of(context)!.clint_id}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                            ),
                            Text(
                              "(${AppLocalizations.of(context)!.that_will_be_provide_by_zoom})",
                              style: TextStyle(fontSize: 14, color: ColorCode.hintText, fontStyle: FontStyle.italic),
                            ),
                            TextFormField(
                              controller: secretClientId,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.text,
                              style: GymStyle.settingSubTitleText,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!.please_enter_your_secret_client_id;
                                }
                                return null;
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
                                labelText: '${AppLocalizations.of(context)!.client_secret_id}*',
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                            ),
                            Text(
                              "(${AppLocalizations.of(context)!.that_will_be_provide_by_zoom})",
                              style: TextStyle(fontSize: 14, color: ColorCode.hintText, fontStyle: FontStyle.italic),
                            ),
                            TextFormField(
                              controller: url,
                              cursorColor: ColorCode.mainColor,
                              keyboardType: TextInputType.url,
                              style: GymStyle.settingSubTitleText,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!.please_enter_redirect_url;
                                }
                                return null;
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
                                labelText: AppLocalizations.of(context)!.redirect_url,
                                labelStyle: GymStyle.settingHeadingTitleDefault,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                            ),
                            Text(
                              "(${AppLocalizations.of(context)!.please_copy_this_redirect_url_and_ass_in_your_zoom_account_redirect_url})",
                              style: TextStyle(fontSize: 14, color: ColorCode.hintText, fontStyle: FontStyle.italic),
                            ),
                          ],
                        )*/
                    ],
                  ),
                ),
              ),
            ),
          ),
          /*if (virtualClassSchedule)
            Positioned(
              bottom: 10,
              left: 27,
              child: Container(
                height: height * 0.08,
                width: width * 0.85,
                margin: const EdgeInsets.only(bottom: 38),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {}
                  },
                  style: GymStyle.buttonStyle,
                  child: Text(
                    AppLocalizations.of(context)!.submit.toUpperCase(),
                    style: GymStyle.buttonTextStyle,
                  ),
                ),
              ),
            )*/
        ],
      ),
    );
  }

  Future<void> updateEmailSetting(String key, dynamic value) async {
    showProgressDialog.show(message: 'Loading...');
    DefaultResponse defaultResponse = await generalSettingProvider.updateSettingByKeyValue(
        settingId: widget.documentSnapshot?.id, key: key, value: value);
    showProgressDialog.hide();
    if(context.mounted){ if (defaultResponse.status != null && defaultResponse.status!) {
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
    }}

  }

  void updateDocument(DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      setState(() {
        virtualClassSchedule = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyVirtualClass)
            ? documentSnapshot.get(keyVirtualClass)
            : virtualClassSchedule;
      });
    }
  }

  Future<void> refreshData() async {
    showProgressDialog.show();
    generalSettingProvider
        .getSettingsList()
        .then((value) => {showProgressDialog.hide(), updateDocument(generalSettingProvider.generalSettingItem)});
  }

}
