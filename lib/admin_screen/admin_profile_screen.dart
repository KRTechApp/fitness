// ignore_for_file: must_be_immutable

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../providers/member_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'admin_dashboard_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  String viewType;
  final String userId;

  AdminProfileScreen({Key? key, required this.viewType, required this.userId}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController phone = TextEditingController();
  late TrainerProvider trainerProvider;
  late MemberProvider memberProvider;
  DocumentSnapshot? documentSnapshot;

  final SharedPreferencesManager preferencesManager = SharedPreferencesManager();
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  File? imagePath;
  var profile = '';
  String countryCode = "91";
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pincode = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ShowProgressDialog progressDialog;
  String oldEmail = "";
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  bool newPasswordVisible = false;
  bool oldPasswordVisible = false;
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
        documentSnapshot = await trainerProvider.getSingleTrainer(userId: widget.userId);
        updateDocument(documentSnapshot);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var keyboardHeight = MediaQuery
        .of(context)
        .viewInsets
        .bottom;
    debugPrint("keyboardHeight : $keyboardHeight");
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                (Route<dynamic> route) => false);

        return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 48,
          leading: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
            splashColor: ColorCode.linearProgressBar,
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
              child: SvgPicture.asset(
                'assets/images/appbar_menu.svg',
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),
          ),
          title: Text(AppLocalizations.of(context)!.profile),
          actions: [
            InkWell(
              onTap: () async {
                debugPrint('edit icon click');
                setState(() {
                  widget.viewType = "edit";
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SvgPicture.asset('assets/images/ic_edit_icon.svg', width: 25, height: 25),
              ),
            )
          ],
        ),
        body: documentSnapshot == null
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SizedBox(
          height: height - keyboardHeight,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                image: customImageProvider(imageByte: imageByte, url: profile),
                                placeholderFit: BoxFit.fitWidth,
                                placeholder: customImageProvider(),
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return getPlaceHolder();
                                },
                              ),
                            ),
                            if (widget.viewType == 'edit')
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    openImage();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: ColorCode.mainColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20.0),
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              controller: name,
                              style: GymStyle.adminProfileName,
                              textAlign: TextAlign.center,
                              readOnly: widget.viewType == "view" ? true : false,
                              cursorColor: ColorCode.mainColor,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!.please_enter_your_name;
                                }
                              },
                              decoration: const InputDecoration(
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            )),
                      ),
                      if(StaticData.canEditField && widget.viewType == "edit")
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20.0),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: email,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GymStyle.adminProfileEmail,
                              textAlign: TextAlign.center,
                              readOnly: widget.viewType == "view" ? true : false,
                              cursorColor: ColorCode.mainColor,
                              validator: (value) {
                                if (value != null && (value.trim().isValidEmail())) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!.please_enter_valid_email;
                                }
                              },
                              decoration: const InputDecoration(
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            )),
                      ),
                      if(StaticData.canEditField && widget.viewType == "edit")
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: phone,
                            readOnly: widget.viewType == "view" ? true : false,
                            cursorColor: ColorCode.mainColor,
                            validator: (value) {
                              if (value != null && value
                                  .trim()
                                  .length > 7) {
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
                              border: const UnderlineInputBorder(),
                              labelText: '${AppLocalizations.of(context)!.mobile_number}*',
                              labelStyle: GymStyle.inputText,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: InkWell(
                                  onTap: () async {
                                    showCountryPicker(
                                      context: context,
                                      showPhoneCode: true,
                                      onSelect: (Country country) =>
                                          setState(() {
                                            countryCode = country.phoneCode;
                                          }),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      height: height * 0.04,
                                      width: width * 0.2,
                                      child: Text(
                                        '+$countryCode',
                                        style: GymStyle.inputTextBold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0),
                        child: TextFormField(
                          controller: address,
                          cursorColor: ColorCode.mainColor,
                          keyboardType: TextInputType.url,
                          readOnly: widget.viewType == "view" ? true : false,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.address,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0),
                        child: TextFormField(
                          controller: city,
                          cursorColor: ColorCode.mainColor,
                          keyboardType: TextInputType.url,
                          readOnly: widget.viewType == "view" ? true : false,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.city,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0),
                        child: TextFormField(
                          controller: state,
                          cursorColor: ColorCode.mainColor,
                          keyboardType: TextInputType.url,
                          readOnly: widget.viewType == "view" ? true : false,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.state,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0),
                        child: TextFormField(
                          controller: pincode,
                          cursorColor: ColorCode.mainColor,
                          keyboardType: TextInputType.url,
                          readOnly: widget.viewType == "view" ? true : false,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.pincode,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                      ),
                      if(StaticData.canEditField)
                      Form(
                        key: passwordFormKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20.0),
                              child: TextFormField(
                                controller: currentPassword,
                                keyboardType: TextInputType.visiblePassword,
                                cursorColor: ColorCode.mainColor,
                                obscureText: oldPasswordVisible,
                                validator: (value) {
                                  if (value != null && value
                                      .trim()
                                      .length > 5) {
                                    return null;
                                  } else {
                                    return AppLocalizations.of(context)!
                                        .please_enter_password_of_at_least_six_character;
                                  }
                                },
                                readOnly: widget.viewType == "view" ? true : false,
                                decoration: InputDecoration(
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorCode.mainColor,
                                    ),
                                  ),
                                  border: const UnderlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(oldPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        size: 25),
                                    onPressed: () {
                                      setState(
                                            () {
                                          oldPasswordVisible = !oldPasswordVisible;
                                        },
                                      );
                                    },
                                  ),
                                  labelText: AppLocalizations.of(context)!.current_password,
                                  labelStyle: GymStyle.inputText,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20.0),
                              child: TextFormField(
                                controller: newPassword,
                                keyboardType: TextInputType.visiblePassword,
                                cursorColor: ColorCode.mainColor,
                                readOnly: widget.viewType == "view" ? true : false,
                                obscureText: newPasswordVisible,
                                validator: (value) {
                                  if (value != null && value
                                      .trim()
                                      .length > 5) {
                                    return null;
                                  } else {
                                    return AppLocalizations.of(context)!
                                        .please_enter_password_of_at_least_six_character;
                                  }
                                },
                                decoration: InputDecoration(
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorCode.mainColor,
                                    ),
                                  ),
                                  border: const UnderlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(newPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        size: 25),
                                    onPressed: () {
                                      setState(
                                            () {
                                          newPasswordVisible = !newPasswordVisible;
                                        },
                                      );
                                    },
                                  ),
                                  labelText: AppLocalizations.of(context)!.new_password,
                                  labelStyle: GymStyle.inputText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: InkWell(
                          onTap: () {
                            // Navigator.pop(context);
                            logoutDialog(context: context);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.log_out.firstCapitalize(),
                            style: GymStyle.adminProfileLogoutText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.viewType == "edit")
                  Positioned(
                    bottom: 1,
                    right: 21,
                    left: 21,
                    child: SizedBox(
                      height: height * 0.08,
                      width: width * 0.9,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (newPassword.text.isNotEmpty && passwordFormKey.currentState!.validate()) {
                              progressDialog.show(message: 'Loading...');
                              memberProvider
                                  .matchUserAndPassword(
                                userId: widget.userId,
                                password: currentPassword.text.trim(),
                              )
                                  .then(
                                    (defaultResponse) =>
                                {
                                  progressDialog.hide(),
                                  if (defaultResponse.status == true)
                                    {updateAdminProfile(isPasswordUpdate: true)}
                                  else
                                    {
                                      Fluttertoast.showToast(
                                          msg: defaultResponse.message ??
                                              AppLocalizations.of(context)!.password_not_match,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0),
                                    }
                                },
                              );
                            } else if (oldEmail != email.text.trim()) {
                              if (currentPassword.text.isEmpty) {
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!.please_enter_current_password,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                return;
                              }
                              progressDialog.show(message: 'Loading...');
                              memberProvider
                                  .matchUserAndPassword(
                                userId: widget.userId,
                                password: currentPassword.text.trim(),
                              )
                                  .then(
                                    (defaultResponse) =>
                                {
                                  progressDialog.hide(),
                                  if (defaultResponse.status == true)
                                    {updateAdminProfile(isPasswordUpdate: false)}
                                  else
                                    {
                                      Fluttertoast.showToast(
                                          msg: defaultResponse.message ??
                                              AppLocalizations.of(context)!.password_not_match,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0),
                                    }
                                },
                              );
                            } else {
                              updateAdminProfile(isPasswordUpdate: false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: ColorCode.mainColor,
                        ),
                        child: Text(
                          AppLocalizations
                              .of(context)!
                              .save
                              .allInCaps,
                          style: GymStyle.buttonTextStyle,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  void updateDocument(DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      setState(() {
        //currentPackage.text = documentSnapshot.get(keyGymName);
        address.text = documentSnapshot.get(keyAddress);
        city.text = documentSnapshot.get(keyCity);
        state.text = documentSnapshot.get(keyState);
        pincode.text = documentSnapshot.get(keyZipCode);
        phone.text = documentSnapshot.get(keyPhone);
        profile = documentSnapshot.get(keyProfile);
        name.text = documentSnapshot.get(keyName);
        email.text = documentSnapshot.get(keyEmail);
        oldEmail = documentSnapshot.get(keyEmail);
        preferencesManager.setValue(prefProfile, profile);

        // selectedSpecializationList = List.castFrom(documentSnapshot.get(keySpecialization) as List);
      });
    }
  }

  openImage() async {
    try {
      var pickedFile = await imgPicker.pickImage(source: ImageSource.gallery);
      //you can use ImageCourse.camera for Camera capture
      if (pickedFile != null) {
        imageByte = await pickedFile.readAsBytes();
        imagePath = File(pickedFile.path);
        setState(() {});
      }
    } catch (e) {
      debugPrint("error while picking file.");
    }
  }

  void updateAdminProfile({required bool isPasswordUpdate}) {
    hideKeyboard();
    trainerProvider
        .updateAdminProfile(
      oldEmail: oldEmail,
      email: email.text.trim().toString(),
      name: name.text.firstCapitalize().trim().toString(),
      userId: documentSnapshot!.id,
      address: address.text.trim(),
      city: city.text.trim(),
      state: state.text.trim(),
      zipcode: pincode.text.trim(),
      mobileNumber: phone.text.trim(),
      countryCode: countryCode.trim(),
      profilePhoto: profile,
      profilePhotoFile: imagePath,
      newPassword: newPassword.text.trim(),
      currentPassword: currentPassword.text.trim(),
      isPasswordUpdate: isPasswordUpdate,
    )
        .then(
      ((defaultResponseData) =>
      {
        progressDialog.hide(),
        if (defaultResponseData.status != null && defaultResponseData.status!)
          {
            Fluttertoast.showToast(
                msg: defaultResponseData.message ?? AppLocalizations.of(context)!.something_want_to_wrong,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0),
            if (oldEmail != email.text.trim()) {oldEmail = email.text.trim()}
            // Navigator.pop(context),
          }
        else
          {
            Fluttertoast.showToast(
                msg: defaultResponseData.message ?? AppLocalizations.of(context)!.something_want_to_wrong,
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
