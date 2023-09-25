import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crossfit_gym_trainer/model/user_modal.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/static_data.dart';
import '../utils/utils_methods.dart';

class ProfileScreen extends StatefulWidget {
  final UserModal userModal;

  const ProfileScreen({Key? key, required this.userModal}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  ImagePicker picker = ImagePicker();
  File? imagePath;
  XFile? image;
  var profile = '';
  var nameController = TextEditingController();
  late var emailController = '';
  var numberController = TextEditingController();
  var dateController = TextEditingController();
  var addressController = TextEditingController();
  String countryCode = "91";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        setState(
          () {
            emailController = widget.userModal.email ?? "";
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.fill_your_profile,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    textAlign: TextAlign.center,
                    AppLocalizations.of(context)!.do_not_worry_you_can_always_change_it_letter_or,
                    style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                  ),
                ),
                Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.you_can_skip_it_for_now,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        openImage();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          // border: Border.all(color: Colors.blueAccent, width: 3),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        height: 90,
                        width: 90,
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.black54,
                          backgroundImage: getProfile(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      right: 1,
                      child: InkWell(
                        onTap: () {
                          openImage();
                        },
                        child: const ImageIcon(
                          AssetImage('assets/images/EditImage.png'),
                          color: ColorCode.mainColor,
                        ),
                      ),
                    )
                  ],
                ),
                TextFormField(
                  // cursorColor: Colors.white,
                  style: const TextStyle(fontFamily: 'Poppins'),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.please_enter_your_name;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: ColorCode.mainColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: AppLocalizations.of(context)!.name,
                    hintStyle: const TextStyle(
                      color: Color(0xFF95979C),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    height: height * 0.08,
                    width: width,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF000000).withOpacity(0.40), width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        emailController,
                        style: const TextStyle(
                          color: Color(0xFF95979C),
                        ),
                      ),
                      trailing: const Icon(Icons.email_rounded),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: numberController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.please_enter_your_phone;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: ColorCode.mainColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: AppLocalizations.of(context)!.phone,
                      labelStyle: GymStyle.inputText,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 19),
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
                            height: height * 0.053,
                            width: 27,
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
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: TextFormField(
                    // cursorColor: Colors.white,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    controller: dateController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.please_enter_date_of_birth;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: ColorCode.mainColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      suffixIcon: Container(
                        padding: const EdgeInsets.all(13),
                        child: SvgPicture.asset('assets/images/calendar.svg'),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: AppLocalizations.of(context)!.date_of_birth,
                      hintStyle: const TextStyle(
                        color: Color(0xFF95979C),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        debugPrint("$pickedDate");
                        String formattedDate = DateFormat(StaticData.currentDateFormat).format(pickedDate);
                        debugPrint(formattedDate);
                        setState(
                          () {
                            dateController.text = formattedDate;
                          },
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: TextFormField(
                    style: const TextStyle(fontFamily: 'Poppins'),
                    controller: addressController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.please_enter_your_address;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: ColorCode.mainColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: AppLocalizations.of(context)!.address,
                      hintStyle: const TextStyle(
                        color: Color(0xFF95979C),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.079,
                ),
                Row(
                  children: [
                    SizedBox(
                      height: height * 0.08,
                      width: width * 0.40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: GymStyle.backButtonStyle,
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: GymStyle.buttonTextStyle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        height: height * 0.08,
                        width: width * 0.40,
                        child: ElevatedButton(
                          onPressed: () async {},
                          style: GymStyle.buttonStyle,
                          child: Text(
                            AppLocalizations.of(context)!.done.allInCaps,
                            style: GymStyle.buttonTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider getProfile() {
    if (imageByte != null) {
      return MemoryImage(imageByte!);
    } else if (profile.isEmpty) {
      return const AssetImage('assets/images/Profile.png');
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
    var formatter = DateFormat(StaticData.currentDateFormat);
    String formattedDate = formatter.format(now);
    debugPrint("formattedDate : $formattedDate"); //07/02/2023
    return formattedDate;
  }
}
