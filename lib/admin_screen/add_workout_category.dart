import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/workout_category_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../utils/color_code.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class AddWorkoutCategory extends StatefulWidget {
  final String viewType;
  final QueryDocumentSnapshot? documentSnapshot;

  const AddWorkoutCategory({
    Key? key,
    required this.viewType,
    required this.documentSnapshot,
  }) : super(key: key);

  @override
  State<AddWorkoutCategory> createState() => _AddWorkoutCategoryState();
}

class _AddWorkoutCategoryState extends State<AddWorkoutCategory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var selectedWeek = 0;
  final ImagePicker imgPicker = ImagePicker();
  String? selectedValue;
  Uint8List? imageByte;
  File? imagePath;
  var profile = '';
  var title = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late WorkoutCategoryProvider workoutCategoryProvider;
  late ShowProgressDialog progressDialog;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    if ((widget.viewType == "edit" || widget.viewType == "view") && widget.documentSnapshot != null) {
      setState(
        () {
          title.text = widget.documentSnapshot!.get(keyWorkoutCategoryTitle);
          profile = widget.documentSnapshot!.get(keyProfile);
        },
      );
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
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
          title: Text(
            widget.viewType == "view"
                ? AppLocalizations.of(context)!.view_workout_category
                : (widget.viewType == "edit"
                    ? AppLocalizations.of(context)!.edit_workout_category
                    : AppLocalizations.of(context)!.add_workout_category),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height * 0.02,
                ),
                TextFormField(
                  controller: title,
                  readOnly: widget.viewType == "view" ? true : false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.please_enter_title;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: '${AppLocalizations.of(context)!.title}*',
                    labelStyle: GymStyle.inputText,
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(AppLocalizations.of(context)!.image, style: GymStyle.inputText),
                SizedBox(
                  height: height * 0.02,
                ),
                DottedBorder(
                  color: ColorCode.mainColor,
                  strokeWidth: 1,
                  borderType: BorderType.Circle,
                  radius: const Radius.circular(10),
                  dashPattern: const [4, 4, 4, 4],
                  strokeCap: StrokeCap.round,
                  child: InkWell(
                    onTap: () {
                      openImage();
                    },
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
                              backgroundImage: customImageProvider(url: profile, imageByte: imageByte),
                            )
                          : const Icon(
                              Icons.add,
                              color: Color(0Xff6842FF),
                              size: 30,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
                SizedBox(
                  height: height * 0.08,
                  width: width * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.viewType == "view") {
                        Navigator.pop(context);
                        return;
                      }
                      if (formKey.currentState!.validate()) {
                        if (widget.viewType == "edit") {
                          progressDialog.show(message: 'Loading...');
                          workoutCategoryProvider
                              .updateCategory(
                                  categoryId: widget.documentSnapshot!.id,
                                  title: title.text.trim().toString(),
                                  profile: imagePath,
                                  imageUrl: profile,
                                  createdBy: userId)
                              .then(
                                ((defaultResponseData) => {
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
                                          Navigator.pop(context)
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
                        } else {
                          progressDialog.show(message: 'Loading...');
                          workoutCategoryProvider
                              .addWorkoutCategory(
                                  workoutCategoryTitle: title.text.trim().firstCapitalize(),
                                  categoryImage: imagePath,
                                  createdBy: userId)
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
                                      Navigator.pop(context)
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
                        }
                      }
                    },
                    style: GymStyle.buttonStyle,
                    child: Text(
                      widget.viewType == "view"
                          ? AppLocalizations.of(context)!.go_back.allInCaps
                          : widget.viewType == "edit"
                              ? AppLocalizations.of(context)!.save.allInCaps
                              : AppLocalizations.of(context)!.add_category.allInCaps,
                      style: GymStyle.buttonTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
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
      if (kDebugMode) {
        print("error while picking file.");
      }
    }
  }
}
