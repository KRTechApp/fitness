// ignore_for_file: file_names
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/model/trainer_modal.dart';
import 'package:crossfit_gym_trainer/providers/specialization_provider.dart';
import 'package:crossfit_gym_trainer/providers/trainer_provider.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path_extension;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/attachment_item_view.dart';
import '../custom_widgets/TagView/tags.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/attachment_list_item.dart';
import '../providers/membership_provider.dart';
import '../utils/firebase_interface.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/utils_methods.dart';
import 'add_trainer_package_screen.dart';
import 'specialization_item_view.dart';
import 'trainer_list_screen.dart';

class AddTrainer extends StatefulWidget {
  final String viewType;
  final DocumentSnapshot? documentSnapshot;
  final String? membershipId;
  final String? membershipName;

  const AddTrainer(
      {Key? key, required this.viewType, required this.documentSnapshot, this.membershipId, this.membershipName})
      : super(key: key);

  @override
  State<AddTrainer> createState() => _AddTrainerState();
}

class _AddTrainerState extends State<AddTrainer> {
  TrainerModal trainerModal = TrainerModal();
  bool showSpecialization = false;
  bool showMembership = false;
  late SpecializationProvider _specializationListProvider;
  late MembershipProvider _membershipProvider;
  late TrainerProvider trainerProvider;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  var birthDateMillisecond = getCurrentDateTime();
  late ShowProgressDialog progressDialog;
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  Uint8List? attachmentByte;
  File? profileImageFile;
  File? attachmentPath;
  var profile = '';
  var attachment = '';
  var fullName = TextEditingController();
  var dateOfBirth = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();
  var number = TextEditingController();
  var wpNumber = TextEditingController();
  FirebaseInterface firebaseInterface = FirebaseInterface();
  List<String> selectedSpecializationList = [];
  String oldPassword = "";
  String countryCode = "91";
  String wpCountryCode = "91";
  String gender = "male";
  bool whatsAppValue = false;
  List<AttachmentListItem> attachmentList = [];
  List<AttachmentListItem> removeAttachmentList = [];
  String currentUserId = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  bool _passwordVisible = false;
  String? selectedMembership;
  var selectedMembershipId = '';
  var selectedMembershipIdOld = '';
  var membershipTimeStamp = getCurrentDateTime();

  @override
  void initState() {
    super.initState();
    _specializationListProvider = Provider.of<SpecializationProvider>(context, listen: false);
    _membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        password.text = getRandomString(length: 8);
        currentUserId = await _preference.getValue(prefUserId, "");
        _specializationListProvider.getSpecializationList(isRefresh: true);
        /* progressDialog.show();
                await updateRowFieldOfTable(tableName: tableUser,key: keyPaymentStatus,value: paymentUnPaid);
                progressDialog.hide();*/
        await _membershipProvider.getMembershipList(createdById: currentUserId, isRefresh: true);

        if (widget.membershipId != null && widget.membershipName != null) {
          selectedMembershipId = widget.membershipId!;
          selectedMembershipIdOld = selectedMembershipId;
          selectedMembership = _membershipProvider.membershipListItem
              .firstWhere((element) => element.id == selectedMembershipId)[keyMembershipName];
        }

        if ((widget.viewType == "edit") && widget.documentSnapshot != null) {
          oldPassword = widget.documentSnapshot!.get(keyPassword);
          whatsAppValue = widget.documentSnapshot!.get(keyIsWhatsappNumber);
          fullName.text = widget.documentSnapshot!.get(keyName);
          birthDateMillisecond = widget.documentSnapshot!.get(keyDateOfBirth);
          dateOfBirth.text = DateFormat(StaticData.currentDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(birthDateMillisecond),
          );
          gender = widget.documentSnapshot!.get(keyGender);
          selectedSpecializationList = List.castFrom(widget.documentSnapshot!.get(keySpecialization) as List);
          selectedMembershipId = widget.documentSnapshot!.get(keyCurrentMembership);
          selectedMembershipIdOld = selectedMembershipId;
          var tempMembership =
              _membershipProvider.membershipListItem.where((element) => element.id == selectedMembershipId).toList();
          if (tempMembership.isNotEmpty) {
            selectedMembership = tempMembership.first[keyMembershipName];
          }
          membershipTimeStamp = widget.documentSnapshot!.get(keyMembershipTimestamp) ?? 0;
          email.text = widget.documentSnapshot!.get(keyEmail);
          password.text = widget.documentSnapshot!.get(keyPassword);
          number.text = widget.documentSnapshot!.get(keyPhone);
          wpNumber.text = widget.documentSnapshot!.get(keyWpPhone);
          profile = widget.documentSnapshot!.get(keyProfile);
          var attachmentUrlList = List.castFrom(widget.documentSnapshot!.get(keyAttachment) as List);
          attachmentUrlList.asMap().forEach(
            (index, attachment) {
              attachmentList.add(
                AttachmentListItem(
                    id: index,
                    attachmentNetwork: attachment,
                    attachmentType: path_extension.extension(attachment).replaceAll(".", "").split("?").first),
              );
            },
          );
        }
        setState(() {});
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
        title: Text(widget.viewType == "edit"
            ? AppLocalizations.of(context)!.edit_trainer
            : AppLocalizations.of(context)!.add_trainer),
      ),
      body: GestureDetector(
        onTap: () {
          if (showSpecialization) {
            setState(() {
              showSpecialization = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: SizedBox(
            height: height,
            width: width,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.025,
                    ),
                    TextFormField(
                      controller: fullName,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      cursorColor: ColorCode.mainColor,
                      style: GymStyle.drawerswitchtext,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.please_enter_full_name;
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
                        labelText: '${AppLocalizations.of(context)!.full_name}*',
                        labelStyle: GymStyle.inputText,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    TextFormField(
                      controller: dateOfBirth,
                      cursorColor: ColorCode.mainColor,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: GymStyle.drawerswitchtext,

                      /* validator: (value) {
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
                          String formattedDate = DateFormat(StaticData.currentDateFormat).format(pickedDate);
                          birthDateMillisecond = pickedDate.millisecondsSinceEpoch;
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
                    Text(
                      AppLocalizations.of(context)!.gender,
                      style: GymStyle.inputText,
                    ),
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
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(
                              () {
                                showSpecialization = !showSpecialization;
                              },
                            );
                          },
                          child: Consumer<SpecializationProvider>(
                            builder: (context, tempSpecializationList, child) => SizedBox(
                              width: width * 0.73,
                              height: height * 0.1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  tempSpecializationList.specializationList.isEmpty
                                      ? Container(
                                          padding: const EdgeInsets.only(top: 16),
                                          alignment: Alignment.centerLeft,
                                          child: Text(AppLocalizations.of(context)!.please_add_specialization,
                                              overflow: TextOverflow.ellipsis, style: GymStyle.inputText),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.only(top: 16),
                                          alignment: Alignment.centerLeft,
                                          child: FutureBuilder(
                                            future: tempSpecializationList.getSpecializationListInSingleString(
                                                specializationIdList: selectedSpecializationList),
                                            builder: (context, AsyncSnapshot<String> asyncSnapshot) {
                                              if (asyncSnapshot.hasData) {
                                                var specializationList =
                                                    asyncSnapshot.data != null ? asyncSnapshot.data as String : "";
                                                debugPrint("specializationList : $specializationList");
                                                return SizedBox(
                                                  width: width * 0.60,
                                                  child: Text(
                                                    specializationList.isEmpty
                                                        ? AppLocalizations.of(context)!.select_specialization
                                                        : specializationList,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: specializationList.isEmpty
                                                        ? GymStyle.inputText
                                                        : GymStyle.drawerswitchtext,
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            addSpecializationDialog();
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
                    if (showSpecialization)
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        child: Consumer<SpecializationProvider>(
                          builder: (context, tempSpecializationList, child) => ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tempSpecializationList.specializationList.length,
                            itemBuilder: (context, index) {
                              return SpecializationItemView(
                                  documentSnapshot: tempSpecializationList.specializationList[index],
                                  index: index,
                                  selectedSpecializationList: selectedSpecializationList,
                                  onSpecializationSelected: onSpecializationSelected);
                            },
                          ),
                        ),
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
                                          ? '${AppLocalizations.of(context)!.add_packages}*'
                                          : '${AppLocalizations.of(context)!.select_package}*',
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
                                builder: (context) => const AddTrainerPackageScreen(
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
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: email,
                      style: GymStyle.drawerswitchtext,
                      keyboardType: TextInputType.emailAddress,
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
                        suffixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFFADAEB0),
                        ),
                        labelText: '${AppLocalizations.of(context)!.email}*',
                        labelStyle: GymStyle.inputText,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    if(StaticData.canEditField)
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: password,
                      style: GymStyle.drawerswitchtext,
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
                          icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility, size: 25),
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
                    if(StaticData.canEditField && widget.viewType == "edit")
                      SizedBox(
                      height: height * 0.02,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: number,
                      style: GymStyle.drawerswitchtext,
                      cursorColor: ColorCode.mainColor,
                      maxLength: 15,
                      // readOnly: widget.viewType == "edit",
                      validator: (value) {
                        if (value != null && value.trim().length > 7) {
                          return null;
                        } else {
                          return AppLocalizations.of(context)!.please_enter_valid_mobile_number;
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
                        labelText: '${AppLocalizations.of(context)!.mobile_number}*',
                        labelStyle: GymStyle.inputText,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: InkWell(
                            onTap: () async {
                              if (widget.viewType == "edit") {
                                return;
                              }
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
                              padding: const EdgeInsets.only(top: 8),
                              child: SizedBox(
                                height: height * 0.03,
                                width: width * 0.2,
                                child: Text(
                                  '+$countryCode',
                                  style: GymStyle.inputText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                                    wpNumber.text = number.text;
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
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: InkWell(
                              onTap: () async {
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
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  height: height * 0.04,
                                  width: width * 0.2,
                                  child: Text(
                                    '+$wpCountryCode',
                                    style: GymStyle.inputText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Text(AppLocalizations.of(context)!.profile_photo, style: GymStyle.inputText),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50),
                      ),
                      splashColor: ColorCode.linearProgressBar,
                      onTap: () {
                        openImage();
                      },
                      child: DottedBorder(
                        color: ColorCode.mainColor,
                        strokeWidth: 1,
                        borderType: BorderType.Circle,
                        radius: const Radius.circular(10),
                        dashPattern: const [4, 4, 4, 4],
                        strokeCap: StrokeCap.round,
                        child: Container(
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.blueAccent, width: 3),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          height: 55,
                          width: 55,
                          child: imageByte != null || profile.isNotEmpty
                              ? CircleAvatar(
                                  radius: 50.0,
                                  backgroundImage: customImageProvider(imageByte: imageByte, url: profile),
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Color(0Xff6842FF),
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Text(AppLocalizations.of(context)!.attach_document, style: GymStyle.inputText),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Tags(
                      alignment: WrapAlignment.start,
                      itemCount: attachmentList.length,
                      customWidget: InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(50),
                        ),
                        splashColor: ColorCode.linearProgressBar,
                        onTapDown: (TapDownDetails details) async {
                          openAttachment();
                        },
                        child: DottedBorder(
                          color: ColorCode.mainColor,
                          strokeWidth: 1,
                          borderType: BorderType.Circle,
                          radius: const Radius.circular(10),
                          dashPattern: const [4, 4, 4, 4],
                          strokeCap: StrokeCap.round,
                          child: Container(
                            decoration: BoxDecoration(
                              // border: Border.all(color: Colors.blueAccent, width: 3),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            height: 55,
                            width: 55,
                            child: const Icon(
                              Icons.add,
                              color: Color(0Xff6842FF),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      itemBuilder: (index) {
                        return AttachmentItemView(index, attachmentList[index], onAttachmentRemove,viewType: widget.viewType,);
                      },
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: SizedBox(
                          height: height * 0.08,
                          width: width * 0.9,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (selectedMembershipId.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context)!.please_select_package,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  if (widget.viewType == "edit") {
                                    updateTrainer(isPasswordUpdate: true);
                                  } else {
                                    if (formKey.currentState!.validate()) {
                                      trainerModal.trainerName = fullName.text.trim().firstCapitalize();
                                      trainerModal.trainerBirthDate = birthDateMillisecond;
                                      trainerModal.trainerGender = gender.trim();
                                      trainerModal.trainerSpecialization = selectedSpecializationList;
                                      trainerModal.trainerCurrentMembership = selectedMembershipId;
                                      trainerModal.trainerMembershipTimestamp = membershipTimeStamp;
                                      trainerModal.trainerEmail = email.text.trim();
                                      trainerModal.trainerPassword = password.text.trim();
                                      trainerModal.trainerCountryCode = countryCode.trim();
                                      trainerModal.trainerMobileNumber = number.text.trim();
                                      trainerModal.trainerWpCountryCode = wpCountryCode.trim();
                                      trainerModal.trainerWhatsappNumber = wpNumber.text.trim();
                                      trainerModal.trainerProfilePhotoFile = profileImageFile;
                                      trainerModal.trainerAttachment = attachmentList;
                                      progressDialog.show(message: 'Loading...');
                                      trainerProvider
                                          .addTrainerFirebase(
                                              isWhatsappNumber: whatsAppValue,
                                              context: context,
                                              trainerModal: trainerModal,
                                              currentDate: getCurrentDate(),
                                              membershipDoc: _membershipProvider.membershipListItem
                                                  .firstWhere((element) => element.id == selectedMembershipId),
                                              currentUser: currentUserId)
                                          .then(
                                            (defaultResponseData) => {
                                              progressDialog.hide(),
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
                                                      fontSize: 16.0),
                                                }
                                            },
                                          );
                                    }
                                  }
                                }
                              }
                            },
                            style: GymStyle.buttonStyle,
                            child: Text(
                              widget.viewType == "edit"
                                  ? AppLocalizations.of(context)!.save_trainer
                                  : AppLocalizations.of(context)!.add_trainer,
                              style: GymStyle.buttonTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  void onSelectedItemIndex(int index) {
    setState(
      () {
        // showSubSubjectIndex = index;
      },
    );
  }

  openImage() async {
    try {
      var pickedFile = await imgPicker.pickImage(source: ImageSource.gallery);
      //you can use ImageCourse.camera for Camera capture
      if (pickedFile != null) {
        imageByte = await pickedFile.readAsBytes();
        profileImageFile = File(pickedFile.path);
        setState(
          () {},
        );
      }
    } catch (e) {
      debugPrint("error while picking file.");
    }
  }

  openAttachment() async {
    try {
      if (!await openFilePermission()) {
        if(context.mounted){ Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.please_give_a_storage_read_write_and_permission,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            timeInSecForIosWeb: 3,
            fontSize: 16.0);}

        return null;
      }
      var pickedFile = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'jpg',
            'jpeg',
            'png',
            'csv',
            'pdf',
            'doc',
            'docx',
            'txt',
            'ppt',
            'pptm',
            'pptx',
            'xls',
            'xlsx'
          ],
          allowMultiple: false,
          withData: true);
      if (pickedFile != null) {
        pickedFile.files.asMap().forEach(
          (index, platformFile) async {
            double sizeInMb = platformFile.size / (1024 * 1024);
            debugPrint("File Size : $sizeInMb");
            if (sizeInMb < 2) {
              if (StaticData.isAttachmentValid(platformFile.name, StaticData.attachmentExtensionList)) {
                attachmentList.add(
                  AttachmentListItem(
                      id: index,
                      attachment: File(platformFile.path!),
                      attachmentName: platformFile.name,
                      attachmentSize: platformFile.size,
                      attachmentType: platformFile.extension),
                );
              } else {
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.please_select_valid_file,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            } else {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.attachment_file_size_allow_only_mb,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
        );
        setState(
          () {},
        );
      }
    } catch (e) {
      debugPrint("error while picking file.");
    }
  }

  addSpecializationDialog() {
    var specialization = TextEditingController();
    var width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.add_specialization,
                  style: const TextStyle(fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: specialization,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.please_enter_specialization;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    // labelText: 'Full Name',
                    hintText: AppLocalizations.of(context)!.enter_specialization,
                    labelStyle: GymStyle.inputText,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: width * 0.7,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCode.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        progressDialog.show();
                        await _specializationListProvider
                            .addSpecialization(
                          specialization: specialization.text.trim().firstCapitalize(),
                        )
                            .then(
                          (defaultResponse) {
                            progressDialog.hide();
                            if (defaultResponse.status!) {
                              Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context)!.specialization_added_successfully,
                                  toastLength: Toast.LENGTH_LONG,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              Navigator.pop(context);
                            } else {
                              progressDialog.hide();
                              Fluttertoast.showToast(
                                  msg: defaultResponse.message!,
                                  toastLength: Toast.LENGTH_LONG,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          },
                        );
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.save.allInCaps,
                      style: const TextStyle(
                          color: ColorCode.white,
                          fontSize: 17,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  String getCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat(StaticData.currentDateFormat);
    String formattedDate = formatter.format(now);
    debugPrint("formattedDate : $formattedDate"); //07/02/2023
    return formattedDate;
  }

  Future<bool> openFilePermission() async {
    var status = await Permission.storage.status;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var sdkInt = await deviceInfo.androidInfo;
    if (status.isGranted || (Platform.isAndroid && (sdkInt.version.sdkInt) >= 33)) {
      return true;
    } else {
      var permissionRequest = await Permission.storage.request();
      if (permissionRequest.isGranted) {
        return true;
      }
    }
    return false;
  }

  void onAttachmentRemove(int index) {
    debugPrint("remove index : $index");
    setState(
      () {
        removeAttachmentList.add(
          attachmentList[index],
        );
        attachmentList.removeAt(index);
      },
    );
    debugPrint("listView size : ${removeAttachmentList.length}");
    debugPrint("listView size : ${attachmentList.length}");
  }

  void updateTrainer({required bool isPasswordUpdate}) {
    progressDialog.show(message: 'Loading...');

    trainerModal.trainerName = fullName.text.trim().firstCapitalize();
    trainerModal.trainerBirthDate = birthDateMillisecond;
    trainerModal.trainerGender = gender.trim();
    trainerModal.trainerSpecialization = selectedSpecializationList;
    trainerModal.trainerCurrentMembership = selectedMembershipId;
    trainerModal.trainerMembershipTimestamp =
        selectedMembershipIdOld != selectedMembershipId ? getCurrentDateTime() : membershipTimeStamp;
    trainerModal.trainerEmail = email.text.trim();
    trainerModal.trainerPassword = password.text.trim();
    trainerModal.trainerCountryCode = countryCode.trim();
    trainerModal.trainerMobileNumber = number.text.trim();
    trainerModal.trainerWpCountryCode = wpCountryCode.trim();
    trainerModal.trainerWhatsappNumber = wpNumber.text.trim();
    trainerModal.trainerProfilePhoto = profile;
    trainerModal.trainerProfilePhotoFile = profileImageFile;
    trainerModal.trainerAttachment = attachmentList;
    progressDialog.show(message: 'Loading...');
    trainerProvider
        .updateTrainer(
          isWhatsappNumber: whatsAppValue,
          oldPassword: oldPassword.trim().toString(),
          isPasswordUpdate: isPasswordUpdate,
          trainerId: widget.documentSnapshot!.id,
          trainerModal: trainerModal,
          membershipUpdated: selectedMembershipIdOld != selectedMembershipId,
          membershipDoc:
              _membershipProvider.membershipListItem.firstWhere((element) => element.id == selectedMembershipId),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrainerListScreen(),
                      ),
                    )
                  }
                else
                  {
                    progressDialog.hide(),
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
