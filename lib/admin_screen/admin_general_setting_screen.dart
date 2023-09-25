import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:crossfit_gym_trainer/providers/general_setting_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';

class AdminGeneralSettingScreen extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;

  const AdminGeneralSettingScreen({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  State<AdminGeneralSettingScreen> createState() => _AdminGeneralSettingScreenState();
}

class _AdminGeneralSettingScreenState extends State<AdminGeneralSettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController gymName = TextEditingController();
  TextEditingController startingYear = TextEditingController();
  TextEditingController gymAddress = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController memberPrefix = TextEditingController();
  TextEditingController logo = TextEditingController();
  String countryCode = "91";
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  File? imageFile;
  String? imagePath;
  late SettingProvider generalSettingProvider;
  late ShowProgressDialog showProgressDialog;
  var profile = '';

  @override
  void initState() {
    super.initState();
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: true);
    generalSettingProvider = Provider.of<SettingProvider>(context, listen: false);
    updateDocument(widget.documentSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
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
        title: Text(AppLocalizations.of(context)!.general_setting),
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
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0),
                        child: TextFormField(
                          controller: gymName,
                          keyboardType: TextInputType.text,
                          cursorColor: ColorCode.mainColor,
                          style: GymStyle.settingSubTitleText,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_your_gym_name;
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
                            labelText: '${AppLocalizations.of(context)!.gym_name}*',
                            labelStyle: GymStyle.settingHeadingTitleDefault,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0, top: 20),
                        child: TextFormField(
                          controller: startingYear,
                          keyboardType: TextInputType.number,
                          cursorColor: ColorCode.mainColor,
                          style: GymStyle.settingSubTitleText,
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
                            labelText: AppLocalizations.of(context)!.starting_year,
                            labelStyle: GymStyle.settingHeadingTitleDefault,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0, top: 20),
                        child: TextFormField(
                          controller: gymAddress,
                          keyboardType: TextInputType.text,
                          maxLines: 2,
                          minLines: 1,
                          cursorColor: ColorCode.mainColor,
                          style: GymStyle.settingSubTitleText,
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
                            labelText: AppLocalizations.of(context)!.gym_address,
                            labelStyle: GymStyle.settingHeadingTitleDefault,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0, top: 20),
                        child: TextFormField(
                          controller: mobileNumber,
                          keyboardType: TextInputType.number,
                          cursorColor: ColorCode.mainColor,
                          style: GymStyle.settingSubTitleText,
                          validator: (value) {
                            if (value != null && value.trim().length > 7) {
                              return null;
                            } else {
                              return AppLocalizations.of(context)!.please_enter_valid_mobile_number;
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
                            labelText: '${AppLocalizations.of(context)!.official_phone_number}*',
                            labelStyle: GymStyle.settingHeadingTitleDefault,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(top: 22),
                              child: InkWell(
                                onTap: () async {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode: true,
                                    onSelect: (Country country) => setState(
                                      () {
                                        countryCode = country.phoneCode;
                                      },
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  height: height * 0.04,
                                  width: width * 0.2,
                                  child: Text(
                                    '+$countryCode',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: ColorCode.backgroundColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0, top: 20),
                        child: TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: ColorCode.mainColor,
                          style: GymStyle.settingSubTitleText,
                          validator: (String? value) {
                            if (value != null && value.trim().isValidEmail()) {
                              return null;
                            } else {
                              return AppLocalizations.of(context)!.please_enter_valid_email;
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
                            labelText: '${AppLocalizations.of(context)!.official_email}*',
                            labelStyle: GymStyle.settingHeadingTitleDefault,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0, top: 20),
                        child: TextFormField(
                          controller: memberPrefix,
                          keyboardType: TextInputType.name,
                          cursorColor: ColorCode.mainColor,
                          style: GymStyle.settingSubTitleText,
                          maxLength: 5,
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
                            labelText: AppLocalizations.of(context)!.member_id_prefix,
                            labelStyle: GymStyle.settingHeadingTitleDefault,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0, top: 20),
                        child: TextFormField(
                          controller: logo,
                          readOnly: true,
                          // enabled: false,
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.choose_image,
                            labelStyle: GymStyle.settingHeadingTitleDefault,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                openImage();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA0A9C8),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                margin: const EdgeInsets.only(bottom: 15, left: 15),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(AppLocalizations.of(context)!.choose, style: GymStyle.buttenText),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
/*                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20.0, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width :width - 145,
                              child: Text(
                                imagePath == null ? "Choose Image" : imagePath!,
                                maxLines: 1,
                                style: imagePath == null
                                    ? GymStyle.settingHeadingTitle1
                                    : const TextStyle(
                                        fontSize: 16,
                                        color: ColorCode.backgroundColor,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.fade),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                openImage();
                              },
                              child: Container(
                                width: 85,
                                height: 25,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA0A9C8),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'CHOOSE',
                                  style: TextStyle(fontSize: 15, color: ColorCode.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),*/
                      const Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage(
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                            image: customImageProvider(url: profile, imageByte: imageByte),
                            placeholderFit: BoxFit.fitWidth,
                            placeholder: customImageProvider(),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return getPlaceHolder();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 27,
            child: Container(
              height: height * 0.08,
              width: width * 0.85,
              margin: const EdgeInsets.only(bottom: 38),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.documentSnapshot == null) {
                      showProgressDialog.show(message: "Loading");
                      generalSettingProvider
                          .addSetting(
                              gymName: gymName.text.trim().toString().firstCapitalize(),
                              startingYear: startingYear.text.trim().toString(),
                              gymAddress: gymAddress.text.trim().toString(),
                              mobileNumber: mobileNumber.text.trim().toString(),
                              gymEmail: email.text.trim().toString(),
                              gymLogo: imageFile,
                              imageUrl: profile,
                        memberPrefix: memberPrefix.text.trim().toString().toUpperCase(),
                      )
                          .then(
                            ((defaultResponse) => {
                                  showProgressDialog.hide(),
                                  if (defaultResponse.status != null && defaultResponse.status!)
                                    {
                                      Fluttertoast.showToast(
                                          msg: defaultResponse.message ??
                                              AppLocalizations.of(context)!.something_want_to_wrong,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0),
                                      refreshData()
                                    }
                                  else
                                    {
                                      Fluttertoast.showToast(
                                          msg: defaultResponse.message ??
                                              AppLocalizations.of(context)!.something_want_to_wrong,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0)
                                    }
                                }),
                          );
                    } else {
                      debugPrint("update : ");
                      showProgressDialog.show(message: 'Loading...');
                      generalSettingProvider
                          .updateSetting(
                              settingId: widget.documentSnapshot!.id,
                              gymName: gymName.text.trim().toString().firstCapitalize(),
                              startingYear: startingYear.text.trim().toString(),
                              gymAddress: gymAddress.text.trim().toString(),
                              mobileNumber: mobileNumber.text.trim().toString(),
                              gymEmail: email.text.trim().toString(),
                              gymLogo: imageFile,
                              imageUrl: profile,
                          memberPrefix: memberPrefix.text.trim().toString().toUpperCase())
                          .then(
                            ((defaultResponseData) => {
                                  showProgressDialog.hide(),
                                  if (defaultResponseData.status != null && defaultResponseData.status!)
                                    {
                                      Fluttertoast.showToast(
                                          msg: defaultResponseData.message ??
                                              AppLocalizations.of(context)!.something_want_to_wrong,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0),
                                      refreshData()
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
                                }),
                          );
                    }
                  }
                },
                style: GymStyle.buttonStyle,
                child: Text(
                  AppLocalizations.of(context)!.submit.toUpperCase(),
                  style: GymStyle.buttonTextStyle,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  openImage() async {
    try {
      var pickedFile = await imgPicker.pickImage(source: ImageSource.gallery);
      //you can use ImageCourse.camera for Camera capture
      if (pickedFile != null) {
        imageByte = await pickedFile.readAsBytes();
        imageFile = File(pickedFile.path);
        imagePath = pickedFile.name;
        logo.text = pickedFile.name;
        setState(
          () {},
        );
      }
    } catch (e) {
      debugPrint("error while picking file.");
    }
  }

  void updateDocument(DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null && (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyGymName)) {
      setState(
        () {
          gymName.text = documentSnapshot.get(keyGymName);
          startingYear.text = documentSnapshot.get(keyStartingYear);
          gymAddress.text = documentSnapshot.get(keyAddress);
          mobileNumber.text = documentSnapshot.get(keyPhone);
          email.text = documentSnapshot.get(keyEmail);
          memberPrefix.text = getDocumentValue(documentSnapshot: documentSnapshot, key: keyMemberPrefix);
          // selectedDate = widget.documentSnapshot!.get(keyDateFormat);
          profile = getDocumentValue(key: keyProfile, documentSnapshot: documentSnapshot);
          logo.text = getDocumentValue(key: keyProfile, documentSnapshot: documentSnapshot);
        },
      );
    }
  }

  Future<void> refreshData() async {
    generalSettingProvider.getSettingsList().then(
          (value) => {updateDocument(generalSettingProvider.generalSettingItem)},
        );
  }
}
