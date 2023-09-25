import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:crossfit_gym_trainer/model/user_modal.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/providers/trainer_provider.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
import '../utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'member_list.dart';
import 'trainer_add_membership.dart';

class AddMemberScreen extends StatefulWidget {
  final String viewType;
  final DocumentSnapshot? documentSnapshot;

  const AddMemberScreen({Key? key, required this.viewType, this.documentSnapshot}) : super(key: key);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  UserModal userModal = UserModal();
  late MemberProvider memberProvider;
  late TrainerProvider trainerProvider;
  late MembershipProvider membershipProvider;
  late ShowProgressDialog showProgressDialog;
  var dateOfBirth = TextEditingController();
  var dateOfBirthMillisecond = getCurrentDateTime();
  var fullName = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();
  var phone = TextEditingController();
  var age = TextEditingController();
  var heightController = TextEditingController();
  var weightController = TextEditingController();
  var address = TextEditingController();
  var wpNumber = TextEditingController();
  var goal = TextEditingController();
  DocumentSnapshot? trainerDoc, membershipDoc;
  String? selectedMembership;
  var selectedMembershipId = '';
  var selectedMembershipIdOld = '';
  var membershipTimeStamp = getCurrentDateTime();
  bool showMembership = false;
  String oldPassword = "";
  String gender = "male";
  String userRole = "";
  String userId = "";
  String switchRole = "";
  String countryCode = "91";
  String wpCountryCode = "91";
  bool _passwordVisible = false;
  var profile = '';
  bool whatsAppValue = false;
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  File? imagePath;
  XFile? image;

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        password.text = getRandomString(length: 8);
        userRole = await _preference.getValue(prefUserRole, "");
        userId = await _preference.getValue(prefUserId, "");
        switchRole = await _preference.getValue(keySwitchRole, "");

        debugPrint('SwitchRole : $switchRole');
        trainerDoc = await trainerProvider.getSingleTrainer(userId: userId);

        if(switchRole != userRoleAdmin) {
          debugPrint('documentSnapshot ${trainerDoc![keyCurrentMembership] ?? ""}');
          membershipDoc =
              await membershipProvider.getSingleMembership(membershipId: trainerDoc![keyCurrentMembership] ?? "");
          debugPrint('trainerDoc ${trainerDoc![keyCurrentMembership] ?? ""}');
          debugPrint('membershipDoc => ${membershipDoc![keyMemberLimit] ?? 0}');
        }

        memberProvider.getMemberOfTrainer(createdById: userId);

        await membershipProvider.getMembershipList(createdById: userId, isRefresh: true);

        if ((widget.viewType == "edit") && widget.documentSnapshot != null) {
          oldPassword = widget.documentSnapshot!.get(keyPassword);
          whatsAppValue = widget.documentSnapshot!.get(keyIsWhatsappNumber);
          membershipTimeStamp = widget.documentSnapshot!.get(keyMembershipTimestamp) ?? 0;
          fullName.text = widget.documentSnapshot!.get(keyName);
          email.text = widget.documentSnapshot!.get(keyEmail);
          password.text = widget.documentSnapshot!.get(keyPassword);
          countryCode = widget.documentSnapshot!.get(keyCountryCode);
          phone.text = widget.documentSnapshot!.get(keyPhone);
          wpCountryCode = widget.documentSnapshot!.get(keyWpCountryCode);
          wpNumber.text = widget.documentSnapshot!.get(keyWpPhone);
          gender = widget.documentSnapshot!.get(keyGender);
          age.text = widget.documentSnapshot!.get(keyAge);
          heightController.text = widget.documentSnapshot!.get(keyHeight);
          weightController.text = widget.documentSnapshot!.get(keyWeight);
          address.text = widget.documentSnapshot!.get(keyAddress);
          goal.text = widget.documentSnapshot!.get(keyGoal);
          dateOfBirthMillisecond = widget.documentSnapshot!.get(keyDateOfBirth);
          dateOfBirth.text = DateFormat(StaticData.currentDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(dateOfBirthMillisecond),
          );
          profile = widget.documentSnapshot!.get(keyProfile);
          selectedMembershipId = widget.documentSnapshot!.get(keyCurrentMembership);
          selectedMembershipIdOld = selectedMembershipId;
          var tempMembership =
              membershipProvider.membershipListItem.where((element) => element.id == selectedMembershipId).toList();
          if (tempMembership.isNotEmpty) {
            selectedMembership = tempMembership.first[keyMembershipName];
          }
          debugPrint('tempMembership $tempMembership');
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    debugPrint("keyboardHeight : $keyboardHeight");
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(true);
      },
      child: Scaffold(
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
          title: Text(widget.viewType == "edit"
              ? AppLocalizations.of(context)!.edit_member
              : AppLocalizations.of(context)!.add_member),
        ),
        body: Stack(
          children: [
            SizedBox(
              height: height,
              width: width,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? 20 : 80),
                child: Column(
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            height: height * 0.015,
                          ),
                          GestureDetector(
                            onTap: () {
                              openImage();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FD),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              height: 100,
                              width: 100,
                              child: CircleAvatar(
                                radius: 50.0,
                                backgroundColor: const Color(0xFFF0F4FD),
                                backgroundImage: getImage(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.012,
                          ),
                          Text(
                            AppLocalizations.of(context)!.upload_image,
                            style: GymStyle.listTitle,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: height * 0.02,
                                ),
                                TextFormField(
                                  controller: fullName,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: ColorCode.mainColor,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppLocalizations.of(context)!.please_enter_your_name;
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
                                    labelText: "${AppLocalizations.of(context)!.name}*",
                                    labelStyle: GymStyle.inputText,
                                  ),
                                  style: GymStyle.drawerswitchtext,
                                ),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: email,
                                    cursorColor: ColorCode.mainColor,
                                    readOnly: widget.viewType == "edit" ? true : false,
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
                                      border: const UnderlineInputBorder(),
                                      labelText: "${AppLocalizations.of(context)!.email}*",
                                      labelStyle: GymStyle.inputText,
                                    ),
                                    style: GymStyle.drawerswitchtext),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                if(StaticData.canEditField)
                                  TextFormField(
                                    keyboardType: TextInputType.visiblePassword,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: password,
                                    obscureText: !_passwordVisible,
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
                                      labelText: "${AppLocalizations.of(context)!.password}*",
                                      labelStyle: GymStyle.inputText,
                                      suffixIcon: IconButton(
                                        icon:
                                            Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility, size: 25),
                                        onPressed: () {
                                          setState(
                                            () {
                                              _passwordVisible = !_passwordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    style: GymStyle.drawerswitchtext),
                                if(StaticData.canEditField && widget.viewType == "edit")
                                  SizedBox(
                                  height: height * 0.03,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.phone,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  controller: phone,
                                  cursorColor: ColorCode.mainColor,
                                  maxLength: 15,
                                  readOnly: widget.viewType == "edit",
                                  validator: (value) {
                                    if (value != null && value.trim().length > 7) {
                                      return null;
                                    } else {
                                      return AppLocalizations.of(context)!.please_enter_your_phone;
                                    }
                                  },
                                  style: GymStyle.drawerswitchtext,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ColorCode.mainColor,
                                      ),
                                    ),
                                    border: const UnderlineInputBorder(),
                                    labelText: "${AppLocalizations.of(context)!.phone}*",
                                    labelStyle: GymStyle.inputText,
                                    prefixIcon: InkWell(
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
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Text(
                                          '+$countryCode',
                                          style: GymStyle.inputTextBold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      activeColor: ColorCode.mainColor,
                                      value: whatsAppValue,
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          setState(
                                            () {
                                              whatsAppValue = newValue;
                                              if (whatsAppValue) {
                                                wpNumber.text = phone.text;
                                              } else {
                                                wpNumber.text = "";
                                              }
                                            },
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ), //SizedBox
                                    Text(
                                      AppLocalizations.of(context)!.this_is_whatsapp_number,
                                      style: GymStyle.inputText,
                                    ),
                                  ],
                                ),
                                if (!whatsAppValue)
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                if (!whatsAppValue)
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: wpNumber,
                                    maxLength: 15,
                                    style: GymStyle.drawerswitchtext,
                                    cursorColor: ColorCode.mainColor,
                                    validator: (value) {
                                      if (value != null && value.trim().length > 7) {
                                        return null;
                                      } else {
                                        return AppLocalizations.of(context)!.please_enter_valid_whatsapp_number;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      counterText: "",
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: ColorCode.mainColor,
                                        ),
                                      ),
                                      border: const UnderlineInputBorder(),
                                      labelText: '${AppLocalizations.of(context)!.whatsapp_number}*',
                                      labelStyle: GymStyle.inputText,
                                      prefixIcon: InkWell(
                                        onTap: () async {
                                          if (widget.viewType == "edit") {
                                            return;
                                          }
                                          showCountryPicker(
                                            context: context,
                                            showPhoneCode: true,
                                            onSelect: (Country country) => setState(
                                              () {
                                                wpCountryCode = country.phoneCode;
                                              },
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 20),
                                          child: Text(
                                            '+$wpCountryCode',
                                            style: GymStyle.inputTextBold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Text(AppLocalizations.of(context)!.gender, style: GymStyle.inputText),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: height * 0.05,
                                      width: width * 0.4,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        horizontalTitleGap: -5,
                                        title: Text(
                                          AppLocalizations.of(context)!.male,
                                          style: GymStyle.inputTextBold,
                                        ),
                                        leading: Radio(
                                          activeColor: ColorCode.mainColor,
                                          value: "male",
                                          groupValue: gender,
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                gender = value.toString();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.05,
                                      width: width * 0.4,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        horizontalTitleGap: -5,
                                        title: Text(
                                          AppLocalizations.of(context)!.female,
                                          style: GymStyle.inputTextBold,
                                        ),
                                        leading: Radio(
                                          activeColor: ColorCode.mainColor,
                                          value: "female",
                                          groupValue: gender,
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                gender = value.toString();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                Row(
                                  children: [
                                    Consumer<MembershipProvider>(
                                      builder: (context, membershipData, child) => SizedBox(
                                        width: width * 0.69,
                                        height: height * 0.1,
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 16),
                                          alignment: Alignment.centerLeft,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2(
                                              hint: Text(
                                                  membershipData.membershipListItem.isEmpty
                                                      ? '${AppLocalizations.of(context)!.please_add_membership}*'
                                                      : '${AppLocalizations.of(context)!.assign_membership}*',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GymStyle.inputText),
                                              items: membershipData.membershipListItem
                                                  .map(
                                                    (item) => DropdownMenuItem<String>(
                                                      value: item[keyMembershipName] ?? "",
                                                      child: Text(
                                                        item[keyMembershipName] ?? "",
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GymStyle.drawerswitchtext,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                              value: selectedMembership,
                                              onMenuStateChange: (isOpen) {
                                                setState(
                                                  () {
                                                    showMembership = isOpen;
                                                  },
                                                );
                                              },
                                              icon: Icon(
                                                showMembership
                                                    ? Icons.keyboard_arrow_up_rounded
                                                    : Icons.keyboard_arrow_down_rounded,
                                                color: const Color(0xFFADAEB0),
                                              ),
                                              onChanged: (value) {
                                                setState(
                                                  () {
                                                    selectedMembership = value ?? "";
                                                    QueryDocumentSnapshot queryDoc = membershipData.membershipListItem
                                                        .firstWhere((element) => element[keyMembershipName] == value);
                                                    selectedMembershipId = queryDoc.id;
                                                    debugPrint('membershipDoc : $selectedMembershipId');
                                                    debugPrint('selectedMembershipId : $selectedMembershipId');
                                                  },
                                                );
                                              },
                                              buttonHeight: 40,
                                              buttonWidth: width,
                                              itemHeight: 40,
                                              dropdownDecoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const TrainerAddMemberShip(
                                              viewType: "Add",
                                              documentSnapshot: null,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child: DottedBorder(
                                          color: ColorCode.mainColor,
                                          strokeWidth: 1,
                                          borderType: BorderType.Circle,
                                          radius: const Radius.circular(10),
                                          dashPattern: const [4, 4, 4, 4],
                                          strokeCap: StrokeCap.round,
                                          padding: const EdgeInsets.all(7),
                                          child: const Icon(Icons.add, color: ColorCode.mainColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: width * 0.73,
                                  child: const Divider(
                                    color: Colors.black,
                                    height: 5,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                TextFormField(
                                  controller: dateOfBirth,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: ColorCode.mainColor,
                                  style: GymStyle.drawerswitchtext,
                                  /*validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppLocalizations.of(context)!.please_enter_date_of_birth;
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
                                    suffixIcon: Container(
                                      padding: const EdgeInsets.all(13),
                                      child: SvgPicture.asset(
                                        'assets/images/calendar.svg',
                                      ),
                                    ),
                                    labelText: AppLocalizations.of(context)!.date_of_birth,
                                    labelStyle: GymStyle.inputText,
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime.now(),
                                    );

                                    if (pickedDate != null) {
                                      debugPrint(
                                        pickedDate.toString(),
                                      );
                                      String formattedDate =
                                          DateFormat(StaticData.currentDateFormat).format(pickedDate);
                                      dateOfBirthMillisecond = pickedDate.millisecondsSinceEpoch;
                                      debugPrint(formattedDate);
                                      setState(
                                        () {
                                          dateOfBirth.text = formattedDate;
                                        },
                                      );
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                TextFormField(
                                  // keyboardType: TextInputType.number,
                                  controller: age,
                                  style: GymStyle.drawerswitchtext,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: ColorCode.mainColor,
                                  /* validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please Enter Your Age';
                                      }
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
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                TextFormField(
                                  // keyboardType: TextInputType.number,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  controller: heightController,
                                  style: GymStyle.drawerswitchtext,
                                  cursorColor: ColorCode.mainColor,
/*                                  validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please Enter Your Height';
                                      }
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
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                TextFormField(
                                  // keyboardType: TextInputType.number,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  controller: weightController,
                                  style: GymStyle.drawerswitchtext,
                                  cursorColor: ColorCode.mainColor,
                                  /* validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please Enter Your Weight';
                                      }
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
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                TextFormField(
                                  // keyboardType: TextInputType.number,
                                  controller: address,
                                  style: GymStyle.drawerswitchtext,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: ColorCode.mainColor,
                                  /* validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please Enter Your Address';
                                      }
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
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                TextFormField(
                                  // keyboardType: TextInputType.number,
                                  controller: goal,
                                  style: GymStyle.drawerswitchtext,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: ColorCode.mainColor,
                                  /* validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please Enter Your Goal';
                                      }
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
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    if (keyboardHeight > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: getSubmitButton(height: height, width: width),
                      )
                  ],
                ),
              ),
            ),
            if (keyboardHeight == 0)
              Positioned(
                bottom: 10,
                right: 20,
                left: 20,
                child: getSubmitButton(height: height, width: width),
              )
          ],
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Widget getSubmitButton({required double height, required double width}) {
    return SizedBox(
      height: height * 0.08,
      width: width * 0.9,
      child: ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            if (selectedMembershipId.isEmpty) {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.please_select_membership,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              showProgressDialog.show();
              if (widget.viewType == "edit") {
                debugPrint('selectedMembershipIdOld : $selectedMembershipIdOld => $selectedMembershipId');
                updateMember(isPasswordUpdate: true);
              } else {
                if (switchRole == userRoleAdmin ||
                    (membershipDoc![keyMemberLimit] ?? 0) > memberProvider.myMemberListItem.length) {
                  userModal.userName = fullName.text.trim().toString().firstCapitalize();
                  userModal.userEmail = email.text.trim().toString();
                  userModal.userPassword = password.text.trim().toString();
                  userModal.userPhoneNumber = phone.text.trim().toString();
                  userModal.userGender = gender.trim().toString();
                  userModal.userBirthDate = dateOfBirthMillisecond;
                  userModal.userAge = age.text.trim().toString();
                  userModal.userHeight = heightController.text.trim().toString();
                  userModal.userWeight = weightController.text.trim().toString();
                  userModal.userAddress = address.text.trim().trim();
                  userModal.userCountryCode = countryCode.trim().toString();
                  userModal.userMembershipTimestemp = membershipTimeStamp;
                  userModal.userCurrentMembership = selectedMembershipId;
                  memberProvider
                      .addMember(
                          isWhatsappNumber: whatsAppValue,
                          wpCountryCode: wpCountryCode.trim(),
                          wpNumber: wpNumber.text.trim(),
                          userModal: userModal,
                          profile: imagePath,
                          context: context,
                          membershipDoc: membershipProvider.membershipListItem
                              .firstWhere((element) => element.id == selectedMembershipId),
                          currentDate: getCurrentDate(),
                          goal: goal.text.trim().toString(),
                          currentUser: userId)
                      .then(
                        (defaultResponseData) => {
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
                              Navigator.pop(context),
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
                      );
                } else {
                  showProgressDialog.hide();
                  Fluttertoast.showToast(
                      msg: "Your Member Limit is Over",
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
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: ColorCode.mainColor,
        ),
        child: Text(AppLocalizations.of(context)!.save.toUpperCase(), style: GymStyle.buttonTextStyle),
      ),
    );
  }

  ImageProvider getImage() {
    if (imageByte != null) {
      return MemoryImage(imageByte!);
    } else if (profile.isEmpty) {
      return const AssetImage(
        'assets/images/UploadImage.png',
      );
    } else {
      return customImageProvider(url: profile);
    }
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

  String getCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('dd/MM/yyyy');
    String formattedDate = formatter.format(now);
    debugPrint("formattedDate : $formattedDate"); //07/02/2023
    return formattedDate;
  }

  void updateMember({required bool isPasswordUpdate}) {
    memberProvider
        .updateMember(
          isWhatsappNumber: whatsAppValue,
          currentMembership: selectedMembershipId,
          membershipTimestamp:
              selectedMembershipIdOld != selectedMembershipId ? getCurrentDateTime() : membershipTimeStamp,
          membershipUpdated: selectedMembershipIdOld != selectedMembershipId,
          membershipDoc:
              membershipProvider.membershipListItem.firstWhere((element) => element.id == selectedMembershipId),
          memberId: widget.documentSnapshot!.id,
          profile: imagePath,
          name: fullName.text.trim().toString().firstCapitalize(),
          email: email.text.trim().toString(),
          oldPassword: oldPassword.trim().toString(),
          phone: phone.text.trim().toString(),
          phoneCountryCode: countryCode.trim().toString(),
          whatsappCountryCode: wpCountryCode.trim().toString(),
          whatsappPhone: wpNumber.text.trim().toString(),
          gender: gender.trim().toString(),
          dateofBirth: dateOfBirthMillisecond,
          age: age.text.trim().toString(),
          height: heightController.text.trim().toString(),
          weight: weightController.text.trim().toString(),
          address: address.text.trim().toString(),
          goal: goal.text.trim().toString(),
          imageUrl: profile,
          isPasswordUpdate: isPasswordUpdate,
          newPassword: password.text.trim().toString(),
        )
        .then((defaultResponseData) => {
              showProgressDialog.hide(),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MemberList())),
                }
            });
  }
}
