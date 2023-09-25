// ignore_for_file: must_be_immutable

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class MemberDetailProfileScreen extends StatefulWidget {
  String viewType;
  final String userId;

  MemberDetailProfileScreen(
      {Key? key, required this.userId, required this.viewType})
      : super(key: key);

  @override
  State<MemberDetailProfileScreen> createState() =>
      _MemberDetailProfileScreenState();
}

class _MemberDetailProfileScreenState extends State<MemberDetailProfileScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  DocumentSnapshot? documentSnapshot;
  late MemberProvider memberProvider;
  late MembershipProvider membershipProvider;
  late ShowProgressDialog showProgressDialog;
  TextEditingController currentPackage = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController countryName = TextEditingController();
  var dateOfBirthMillisecond = 0;
  String countryCode = "91";
  String countryCodeShortName = "IN";
  bool newPasswordVisible = false;
  bool oldPasswordVisible = false;
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController goal = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController oldPassword = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  File? imagePath;
  var profile = '';

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    membershipProvider =
        Provider.of<MembershipProvider>(context, listen: false);
    showProgressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        documentSnapshot =
            await memberProvider.getSelectedMember(memberId: widget.userId);
        updateDocument(documentSnapshot);
        setState(
          () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
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
              color: isDarkTheme
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF181A20),
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.profile),
        actions: [
          InkWell(
            onTap: () async {
              debugPrint('edit icon click');
              setState(
                () {
                  widget.viewType = "edit";
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset('assets/images/ic_edit_icon.svg',
                  width: 25, height: 25),
            ),
          )
        ],
      ),
      body: documentSnapshot == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              height: height,
              width: width,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Form(
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
                                image: customImageProvider(
                                    imageByte: imageByte, url: profile),
                                placeholderFit: BoxFit.fitWidth,
                                placeholder: customImageProvider(),
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
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
                        child: /*Text(
                          // "",
                          documentSnapshot![keyName] ?? "",
                          textAlign: TextAlign.center,
                          style: GymStyle.adminProfileName,
                        ),*/
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.name,
                                  controller: name,
                                  style: GymStyle.adminProfileName,
                                  textAlign: TextAlign.center,
                                  readOnly:
                                      widget.viewType == "view" ? true : false,
                                  cursorColor: ColorCode.mainColor,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    } else {
                                      return AppLocalizations.of(context)!
                                          .please_enter_your_name;
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    border: InputBorder.none,
                                  ),
                                )),
                      ),
                      Center(
                        child: Text(
                          documentSnapshot![keyEmail] ?? "",
                          textAlign: TextAlign.center,
                          style: GymStyle.adminProfileEmail,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, top: 10),
                        child: Text(
                          AppLocalizations.of(context)!.current_package,
                          style: GymStyle.adminProfileHeadingTitle,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20.0,
                        ),
                        child: FutureBuilder(
                          future: membershipProvider.getSingleMembership(
                            membershipId:
                                documentSnapshot?.get(keyCurrentMembership),
                          ),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot?> asyncSnapshot) {
                            if (asyncSnapshot.hasData &&
                                asyncSnapshot.data != null) {
                              var queryDoc = asyncSnapshot.data;
                              debugPrint(
                                  "membershipList : ${queryDoc![keyPeriod]}");
                              int dateGap = DateTime.now()
                                  .difference(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      documentSnapshot
                                          ?.get(keyMembershipTimestamp),
                                    ),
                                  )
                                  .inDays;
                              int leftMemberShip =
                                  queryDoc[keyPeriod] - dateGap;
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                child: Row(
                                  children: [
                                    Text(queryDoc[keyMembershipName],
                                        style: GymStyle.inputTextBold),
                                    const Spacer(),
                                    if (widget.userId.isNotEmpty)
                                      Text(
                                        leftMemberShip > 0
                                            ? '$leftMemberShip ${AppLocalizations.of(context)!.days_left}'
                                            : AppLocalizations.of(context)!
                                                .expired,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20.0),
                        child: SizedBox(
                          width: width,
                          child: const Divider(
                            color: Colors.black,
                            height: 5,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: dob,
                          cursorColor: ColorCode.mainColor,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!
                                  .please_enter_date_of_birth;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            suffixIcon: Container(
                              padding: const EdgeInsets.all(13),
                              child: SvgPicture.asset(
                                'assets/images/calendar.svg',
                              ),
                            ),
                            labelText:
                                '${AppLocalizations.of(context)!.date_of_birth}*',
                            labelStyle: GymStyle.inputText,
                          ),
                          readOnly: true,
                          onTap: widget.viewType == "view"
                              ? null
                              : () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime(2100),
                                  );

                                  if (pickedDate != null) {
                                    debugPrint(
                                      pickedDate.toString(),
                                    );
                                    String formattedDate =
                                        DateFormat(StaticData.currentDateFormat)
                                            .format(pickedDate);
                                    dateOfBirthMillisecond =
                                        pickedDate.millisecondsSinceEpoch;
                                    debugPrint(formattedDate);
                                    setState(
                                      () {
                                        dob.text = formattedDate;
                                      },
                                    );
                                  }
                                },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: phone,
                          readOnly: widget.viewType == "view" ? true : false,
                          cursorColor: ColorCode.mainColor,
                          validator: (value) {
                            if (value != null && value.trim().length > 7) {
                              return null;
                            } else {
                              return AppLocalizations.of(context)!
                                  .please_enter_your_mobile_number;
                            }
                          },
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText:
                                '${AppLocalizations.of(context)!.mobile_number}*',
                            labelStyle: GymStyle.inputText,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: InkWell(
                                onTap: widget.viewType == "view"
                                    ? null
                                    : () async {
                                        showCountryPicker(
                                          context: context,
                                          showPhoneCode: true,
                                          onSelect: (Country country) =>
                                              setState(
                                            () {
                                              countryCode = country.phoneCode;
                                            },
                                          ),
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: address,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          /*  validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_your_address;
                            }
                            return null;
                          },*/
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
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: cityController,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          /*  validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_your_address;
                            }
                            return null;
                          },*/
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
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: pincodeController,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            } else {
                              if (value.trim().length > 4 &&
                                  value.trim().length < 10) {
                                return null;
                              } else {
                                return AppLocalizations.of(context)!
                                    .please_enter_valid_pincode;
                              }
                            }
                          },
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
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: stateController,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          /*  validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_your_address;
                            }
                            return null;
                          },*/
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
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: countryName,
                          readOnly: true,
                          onTap: widget.viewType == "view"
                              ? null
                              : () async {
                                  showCountryPicker(
                                    context: context,
                                    onSelect: (Country country) => setState(
                                      () {
                                        countryName.text =
                                            "${country.flagEmoji}  ${country.displayNameNoCountryCode}";
                                        countryCodeShortName =
                                            country.countryCode;
                                        debugPrint(
                                            "countryCodeShortName : $countryCodeShortName");
                                      },
                                    ),
                                  );
                                },
                          cursorColor: ColorCode.mainColor,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText:
                                AppLocalizations.of(context)!.select_country,
                            labelStyle: GymStyle.inputText,

                            /*prefixIcon: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: SizedBox(
                                  height: height * 0.04,
                                  width: width * 0.06,
                                  child: Text(
                                    countryCodeName,
                                    style: GymStyle.inputTextBold,
                                  ),
                                ),
                              ),
                            ),*/
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: goal,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          /* validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_your_goal;
                            }
                            return null;
                          },*/
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.goal,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: age,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          /* validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_your_age;
                            }
                            return null;
                          },*/
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.age,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: weightController,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          /* validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_your_weight;
                            }
                            return null;
                          },*/
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.weight,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20.0, bottom: 20),
                        child: TextFormField(
                          controller: heightController,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          /* validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_your_height;
                            }
                            return null;
                          },*/
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.height,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                      ),
                      if (StaticData.canEditField)
                        Form(
                            key: passwordFormKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20.0, bottom: 20),
                                  child: TextFormField(
                                    controller: oldPassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    cursorColor: ColorCode.mainColor,
                                    readOnly: widget.viewType == "view"
                                        ? true
                                        : false,
                                    obscureText: oldPasswordVisible,
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().length > 5) {
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
                                      labelText: AppLocalizations.of(context)!
                                          .current_password,
                                      labelStyle: GymStyle.inputText,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            oldPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            size: 25),
                                        onPressed: () {
                                          setState(
                                            () {
                                              oldPasswordVisible =
                                                  !oldPasswordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20.0, bottom: 20),
                                  child: TextFormField(
                                    controller: newPassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    readOnly: widget.viewType == "view"
                                        ? true
                                        : false,
                                    cursorColor: ColorCode.mainColor,
                                    obscureText: newPasswordVisible,
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().length > 5) {
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
                                      labelText: AppLocalizations.of(context)!
                                          .new_password,
                                      labelStyle: GymStyle.inputText,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            newPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            size: 25),
                                        onPressed: () {
                                          setState(
                                            () {
                                              newPasswordVisible =
                                                  !newPasswordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),

                      // const Spacer(),
                      if (widget.viewType == "view")
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: InkWell(
                            onTap: () {
                              // Navigator.pop(context);
                              logoutDialog(context: context);
                            },
                            child: Text(
                              AppLocalizations.of(context)!
                                  .log_out
                                  .firstCapitalize(),
                              style: GymStyle.adminProfileLogoutText,
                            ),
                          ),
                        ),
                      if (widget.viewType == "edit")
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              height: height * 0.08,
                              width: width * 0.9,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    if (oldPassword.text.isNotEmpty ||
                                        newPassword.text.isNotEmpty &&
                                            passwordFormKey.currentState!
                                                .validate()) {
                                      showProgressDialog.show(
                                          message: 'Loading...');
                                      memberProvider
                                          .matchUserAndPassword(
                                            userId: widget.userId,
                                            password: oldPassword.text.trim(),
                                          )
                                          .then(
                                            (defaultResponse) => {
                                              showProgressDialog.hide(),
                                              if (defaultResponse.status ==
                                                  true)
                                                {
                                                  updateMemberProfile(
                                                      isPasswordUpdate: true),
                                                }
                                              else
                                                {
                                                  showProgressDialog.hide(),
                                                  Fluttertoast.showToast(
                                                      msg: defaultResponse
                                                              .message ??
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .password_not_match,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 3,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0),
                                                }
                                            },
                                          );
                                    } else {
                                      showProgressDialog.hide();
                                      updateMemberProfile(
                                          isPasswordUpdate: false);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: ColorCode.mainColor,
                                ),
                                child: Text(
                                  widget.viewType == "view"
                                      ? AppLocalizations.of(context)!
                                          .go_back
                                          .allInCaps
                                      : AppLocalizations.of(context)!
                                          .save
                                          .allInCaps,
                                  style: GymStyle.buttonTextStyle,
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  openImage() async {
    try {
      var pickedFile = await imgPicker.pickImage(source: ImageSource.gallery);
      //you can use ImageCourse.camera for Camera capture
      if (pickedFile != null) {
        imageByte = await pickedFile.readAsBytes();
        imagePath = File(pickedFile.path);
        setState(
          () {},
        );
      }
    } catch (e) {
      debugPrint("error while picking file.");
    }
  }

  void updateDocument(DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      setState(
        () {
          // currentPackage.text = documentSnapshot.get(keyCurrentMembership);
          dateOfBirthMillisecond = documentSnapshot.get(keyDateOfBirth);
          if (documentSnapshot.get(keyDateOfBirth) != null) {
            dob.text = DateFormat(StaticData.currentDateFormat).format(
                DateTime.fromMillisecondsSinceEpoch(dateOfBirthMillisecond));
          } else {
            dob.text = "-";
          }

          phone.text = '${documentSnapshot.get(keyPhone)}';
          goal.text = documentSnapshot.get(keyGoal);
          age.text = documentSnapshot.get(keyAge);
          weightController.text = documentSnapshot.get(keyWeight);
          heightController.text = documentSnapshot.get(keyHeight);
          profile = documentSnapshot.get(keyProfile);
          name.text = documentSnapshot.get(keyName);
          pincodeController.text = getDocumentValue(
              documentSnapshot: documentSnapshot, key: keyZipCode);
          stateController.text = getDocumentValue(
              documentSnapshot: documentSnapshot, key: keyState);
          address.text = getDocumentValue(
              documentSnapshot: documentSnapshot, key: keyAddress);
          countryName.text = getDocumentValue(
              documentSnapshot: documentSnapshot, key: keyCountryCodeName);
          cityController.text = getDocumentValue(
              documentSnapshot: documentSnapshot, key: keyCity);
        },
      );
    }
  }

  void updateMemberProfile({required bool isPasswordUpdate}) {
    memberProvider
        .updateMemberProfile(
          city: cityController.text.trim().toString(),
          countryCodeName: countryName.text.trim().toString(),
          countryShortName: countryCodeShortName,
          pincode: pincodeController.text.trim().toString(),
          state: stateController.text.trim().toString(),
          oldUrl: profile,
          profile: imagePath,
          height: heightController.text.toString(),
          weight: weightController.text.toString(),
          address: address.text.toString(),
          age: age.text.toString(),
          countryCode: countryCode,
          goal: goal.text.toString(),
          userId: widget.userId.trim().toString(),
          dateOfBirth: dateOfBirthMillisecond,
          phone: phone.text.trim().toString(),
          email: documentSnapshot![keyEmail] ?? "",
          name: name.text.firstCapitalize().trim().toString(),
          currentPassword: oldPassword.text.trim().toString(),
          isPasswordUpdate: isPasswordUpdate,
          newPassword: newPassword.text.trim().toString(),
        )
        .then(
          (defaultResponseData) => {
            showProgressDialog.hide(),
            if (defaultResponseData.status != null &&
                defaultResponseData.status!)
              {
                // widget.viewType = "view",
                Fluttertoast.showToast(
                    msg: defaultResponseData.message ??
                        AppLocalizations.of(context)!.something_want_to_wrong,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0),
                // Navigator.pop(context),
              }
            else
              {
                showProgressDialog.hide(),
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
        );
  }
}
