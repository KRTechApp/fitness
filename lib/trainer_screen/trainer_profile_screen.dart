// ignore_for_file: must_be_immutable

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../admin_screen/specialization_item_view.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/trainer_modal.dart';
import '../providers/specialization_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class TrainerProfileScreen extends StatefulWidget {
  String viewType;
  final String trainerId;

  TrainerProfileScreen({Key? key, required this.viewType, required this.trainerId}) : super(key: key);

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userRole = "";
  TextEditingController currentPackage = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController specialization = TextEditingController();
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController countryName = TextEditingController();
  TextEditingController cityController = TextEditingController();
  String countryCodeShortName = "IN";
  late TrainerProvider trainerProvider;
  var birthDateMillisecond = 0;
  DocumentSnapshot? documentSnapshot;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  File? imagePath;
  var profile = '';
  bool showSpecialization = false;
  List<String> selectedSpecializationList = [];
  late SpecializationProvider _specializationListProvider;
  late MembershipProvider membershipProvider;
  late MemberProvider memberProvider;
  bool newPasswordVisible = false;
  bool oldPasswordVisible = false;
  String countryCode = "91";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  String? currentPackageName;
  var currentPackageNameOld = '';
  String switchRole = "";
  late ShowProgressDialog progressDialog;
  TrainerModal trainerModal = TrainerModal();

  @override
  void initState() {
    super.initState();
    _specializationListProvider = Provider.of<SpecializationProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        documentSnapshot = await trainerProvider.getSingleTrainer(userId: widget.trainerId);
        userRole = await _preference.getValue(prefUserRole, "");
        switchRole = await _preference.getValue(keySwitchRole, "");
        _specializationListProvider.getSpecializationList(isRefresh: true);
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
              color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
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
              child: SvgPicture.asset('assets/images/ic_edit_icon.svg', width: 25, height: 25),
            ),
          )
        ],
      ),
      body: documentSnapshot == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
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
                          child: /*Text(
                            documentSnapshot![keyName] ?? "",
                            textAlign: TextAlign.center,
                            style: GymStyle.adminProfileName,
                          ),*/
                              Padding(
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
                        Center(
                          child: Text(
                            documentSnapshot![keyEmail] ?? "",
                            textAlign: TextAlign.center,
                            style: GymStyle.adminProfileEmail,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (switchRole != userRoleAdmin)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.current_package,
                                  style: GymStyle.adminProfileEmail,
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
                                    membershipId: documentSnapshot?.get(keyCurrentMembership),
                                  ),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot?> asyncSnapshot) {
                                    if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                      var queryDoc = asyncSnapshot.data;
                                      debugPrint("membershipList : ${queryDoc![keyPeriod]}");
                                      int dateGap = DateTime.now()
                                          .difference(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              documentSnapshot?.get(keyMembershipTimestamp),
                                            ),
                                          )
                                          .inDays;
                                      int leftMemberShip = queryDoc[keyPeriod] - dateGap;
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                        child: Row(
                                          children: [
                                            Text(queryDoc[keyMembershipName], style: GymStyle.inputTextBold),
                                            const Spacer(),
                                            if (widget.trainerId.isNotEmpty)
                                              Text(
                                                leftMemberShip > 0 ? '$leftMemberShip Days left' : "Expired",
                                                style: const TextStyle(
                                                    color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
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
                            ],
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20.0,
                          ),
                          child: TextFormField(
                            controller: dob,
                            cursorColor: ColorCode.mainColor,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!.please_enter_date_of_birth;
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
                              labelText: '${AppLocalizations.of(context)!.date_of_birth}*',
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
                                          DateFormat(StaticData.currentDateFormat).format(pickedDate);
                                      birthDateMillisecond = pickedDate.millisecondsSinceEpoch;
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
                          padding: const EdgeInsets.only(left: 20, right: 20.0),
                          child: InkWell(
                            onTap: () {
                              setState(
                                () {
                                  showSpecialization = !showSpecialization;
                                },
                              );
                            },
                            child: Consumer<SpecializationProvider>(
                              builder: (context, specializationData, child) => SizedBox(
                                height: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(top: 16),
                                      alignment: Alignment.centerLeft,
                                      child: FutureBuilder(
                                        future: specializationData.getSpecializationListInSingleString(
                                            specializationIdList: selectedSpecializationList),
                                        builder: (context, AsyncSnapshot<String> asyncSnapshot) {
                                          if (asyncSnapshot.hasData) {
                                            var specializationList =
                                                asyncSnapshot.data != null ? asyncSnapshot.data as String : "";
                                            debugPrint("specializationList : $specializationList");
                                            return SizedBox(
                                              width: width * 0.70,
                                              child: Text(
                                                specializationList.isEmpty
                                                    ? AppLocalizations.of(context)!.select_specialization
                                                    : specializationList,
                                                overflow: TextOverflow.ellipsis,
                                                style: GymStyle.inputTextBold,
                                              ),
                                            );
                                          }
                                          return Text(
                                            AppLocalizations.of(context)!.select_specialization,
                                            style: GymStyle.inputText,
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 20, right: 16),
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        showSpecialization
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: const Color(0xFFADAEB0),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
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
                        if (showSpecialization)
                          Consumer<SpecializationProvider>(
                            builder: (context, tempSpecializationList, child) => ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tempSpecializationList.specializationList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20.0),
                                  child: SpecializationItemView(
                                      documentSnapshot: tempSpecializationList.specializationList[index],
                                      index: index,
                                      selectedSpecializationList: selectedSpecializationList,
                                      onSpecializationSelected: onSpecializationSelected),
                                );
                              },
                            ),
                          ),
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
                            /*validator: (value) {
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
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20.0),
                          child: TextFormField(
                            controller: cityController,
                            cursorColor: ColorCode.mainColor,
                            keyboardType: TextInputType.url,
                            readOnly: widget.viewType == "view" ? true : false,
                            /*validator: (value) {
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
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20.0),
                          child: TextFormField(
                            controller: pincodeController,
                            cursorColor: ColorCode.mainColor,
                            readOnly: widget.viewType == "view" ? true : false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              else {
                                if (value.trim().length > 4 && value.trim().length < 10) {
                                  return null;
                                } else {
                                  return AppLocalizations.of(context)!.please_enter_valid_pincode;
                                }
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
                              labelText: AppLocalizations.of(context)!.pincode,
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
                          padding: const EdgeInsets.only(left: 20, right: 20.0, bottom: 20),
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
                                        countryName.text = "${country.flagEmoji}  ${country.displayNameNoCountryCode}";
                                    countryCodeShortName = country.countryCode;
                                    debugPrint("countryCodeShortName : $countryCodeShortName");
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
                              labelText: AppLocalizations.of(context)!.select_country,
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
                          padding: const EdgeInsets.only(left: 20, right: 20.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: phone,
                            readOnly: widget.viewType == "view" ? true : false,
                            cursorColor: ColorCode.mainColor,
                            validator: (value) {
                              if (value != null && value.trim().length > 7) {
                                return null;
                              } else {
                                return AppLocalizations.of(context)!.please_enter_your_mobile_number;
                              }
                            },
                            decoration: InputDecoration(
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorCode.mainColor,
                                ),
                              ),
                              border: const UnderlineInputBorder(),
                              labelText: '${AppLocalizations.of(context)!.phone}*',
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
                                      onSelect: (Country country) => setState(
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
                        const SizedBox(
                          height: 10,
                        ),
                        if(StaticData.canEditField)
                        Form(
                          key: passwordFormKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20.0),
                                child: TextFormField(
                                  controller: oldPassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  cursorColor: ColorCode.mainColor,
                                  obscureText: oldPasswordVisible,
                                  validator: (value) {
                                    if (value != null && value.trim().length > 5) {
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
                                      icon:
                                          Icon(oldPasswordVisible ? Icons.visibility_off : Icons.visibility, size: 25),
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
                                    if (value != null && value.trim().length > 5) {
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
                                      icon:
                                          Icon(newPasswordVisible ? Icons.visibility_off : Icons.visibility, size: 25),
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
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 20, top: 50),
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
                    if (widget.viewType == "edit")
                      Positioned(
                        bottom: 1,
                        right: 20,
                        left: 20,
                        child: SizedBox(
                          height: height * 0.08,
                          width: width * 0.9,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if ((oldPassword.text.isNotEmpty || newPassword.text.isNotEmpty) &&
                                    passwordFormKey.currentState!.validate()) {
                                  progressDialog.show(message: 'Loading...');
                                  memberProvider
                                      .matchUserAndPassword(
                                        userId: widget.trainerId,
                                        password: oldPassword.text.trim(),
                                      )
                                      .then(
                                        (defaultResponse) => {
                                          progressDialog.hide(),
                                          if (defaultResponse.status == true)
                                            {updateTrainerProfile(isPasswordUpdate: true)}
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
                                  updateTrainerProfile(isPasswordUpdate: false);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: ColorCode.mainColor,
                            ),
                            child: Text(
                              widget.viewType == "view"
                                  ? AppLocalizations.of(context)!.go_back
                                  : AppLocalizations.of(context)!.save.toUpperCase(),
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
          //currentPackage.text = documentSnapshot.get(keyGymName);
          birthDateMillisecond = documentSnapshot.get(keyDateOfBirth);
          if (documentSnapshot.get(keyDateOfBirth) != null) {
            dob.text = DateFormat(StaticData.currentDateFormat)
                .format(DateTime.fromMillisecondsSinceEpoch(birthDateMillisecond));
          } else {
            dob.text = "-";
          }
          address.text = documentSnapshot.get(keyAddress);
          phone.text = documentSnapshot.get(keyPhone);
          profile = documentSnapshot.get(keyProfile);
          name.text = documentSnapshot.get(keyName);
          selectedSpecializationList = List.castFrom(documentSnapshot.get(keySpecialization) as List);
          pincodeController.text = getDocumentValue(documentSnapshot: documentSnapshot, key: keyZipCode);
          stateController.text = getDocumentValue(documentSnapshot: documentSnapshot, key: keyState);
          countryName.text = getDocumentValue(documentSnapshot: documentSnapshot, key: keyCountryCodeName);
          cityController.text = getDocumentValue(documentSnapshot: documentSnapshot, key: keyCity);
        },
      );
    }
  }

  void updateTrainerProfile({required bool isPasswordUpdate}) {
    trainerModal.trainerBirthDate = birthDateMillisecond;
    trainerModal.trainerSpecialization = selectedSpecializationList;
    trainerModal.trainerCountryCode = countryCode.trim();
    trainerModal.trainerMobileNumber = phone.text.trim();
    trainerModal.trainerPassword = newPassword.text.trim();
    trainerModal.trainerProfilePhoto = profile;
    trainerModal.trainerEmail = documentSnapshot![keyEmail] ?? "";
    trainerModal.trainerProfilePhotoFile = imagePath;
    progressDialog.show();
    trainerProvider
        .updateTrainerProfile(
      city: cityController.text.trim().toString(),
      countryCodeName: countryName.text.trim().toString(),
      countryShortName: countryCodeShortName,
      state: stateController.text.trim().toString(),
          pincode: pincodeController.text.trim().toString(),
          isPasswordUpdate: isPasswordUpdate,
          oldPassword: oldPassword.text.trim().toString(),
          name: name.text.firstCapitalize().trim().toString(),
          trainerId: documentSnapshot!.id,
          trainerModal: trainerModal,
          address: address.text.trim(),
        )
        .then(
          ((defaultResponseData) => {
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

  onSpecializationSelected(String id, bool selected) {
    if (selected) {
      if (!selectedSpecializationList.contains(id)) {
        selectedSpecializationList.add(id);
      }
    } else {
      selectedSpecializationList.remove(id);
    }
    debugPrint("onSubSubjectSelected :$selectedSpecializationList");
    _specializationListProvider.refreshList();
  }
}
