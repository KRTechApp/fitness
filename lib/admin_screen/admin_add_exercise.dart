import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/exercise_provider.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Utils/shared_preferences_manager.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/exercise_model.dart';
import '../providers/workout_category_provider.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'add_workout_category.dart';

class AdminAddExercise extends StatefulWidget {
  final List<String> selectedCategoryId;
  final String viewType;
  final DocumentSnapshot? documentSnapshot;

  const AdminAddExercise({
    Key? key,
    required this.selectedCategoryId,
    required this.viewType,
    this.documentSnapshot,
  }) : super(key: key);

  @override
  State<AdminAddExercise> createState() => _AdminAddExerciseState();
}

class _AdminAddExerciseState extends State<AdminAddExercise> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker imgPicker = ImagePicker();
  late ShowProgressDialog progressDialog;
  late WorkoutCategoryProvider workoutCategoryProvider;
  ExerciseModel exerciseModel = ExerciseModel();
  ExerciseProvider exerciseProvider = ExerciseProvider();
  Uint8List? imageByte, exerciseImageByte;
  File? imagePath, exerciseImagePath;
  var exerciseProfile = '';
  var exerciseDetailUrl = '';
  var exerciseImageName = TextEditingController();
  var exerciseTitle = TextEditingController();
  var description = TextEditingController();
  bool showCategory = false;
  var youtubeLink = TextEditingController();
  var notes = TextEditingController();
  String? selectCategory;
  List<String> selectedWorkoutCategory = [];
  var selectedCategoryId = '';
  String createdBy = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        createdBy = await _preference.getValue(prefUserId, "");
        setState(
          () {},
        );
        selectedWorkoutCategory = widget.selectedCategoryId;
        progressDialog.show(message: 'Loading...');
        await workoutCategoryProvider.getWorkoutCategoryList(isRefresh: true, searchText: "", createdBy: createdBy);
        progressDialog.hide();
        if (widget.viewType == "edit" && widget.documentSnapshot != null) {
          DocumentSnapshot documentSnapshot = await workoutCategoryProvider.getCategoryById(
            categoryId: widget.documentSnapshot!.get(keyCategoryId),
          );
          debugPrint("widget.documentSnapshots DATA${widget.documentSnapshot?.data().toString()}");
          setState(
            () {
              debugPrint("widget.documentSnapshot${widget.documentSnapshot}");
              exerciseTitle.text = widget.documentSnapshot!.get(keyExerciseTitle);
              description.text = widget.documentSnapshot!.get(keyDescription);
              exerciseImageName.text = widget.documentSnapshot!.get(keyExerciseDetailImage);
              youtubeLink.text = widget.documentSnapshot!.get(keyYoutubeLink);
              notes.text = widget.documentSnapshot!.get(keyNotes);
              exerciseProfile = widget.documentSnapshot!.get(keyProfile);
              exerciseDetailUrl = widget.documentSnapshot!.get(keyExerciseDetailImage);
              selectCategory = documentSnapshot[keyWorkoutCategoryTitle];
              selectedCategoryId = documentSnapshot.id;
              selectedWorkoutCategory = [selectedCategoryId];
              debugPrint("selectCategory :$selectCategory");
            },
          );
        }
        if (widget.selectedCategoryId.isNotEmpty) {
          DocumentSnapshot documentSnapshot =
              await workoutCategoryProvider.getCategoryById(categoryId: widget.selectedCategoryId.first);
          selectCategory = documentSnapshot[keyWorkoutCategoryTitle];
          selectedCategoryId = documentSnapshot.id;
          setState(
            () {},
          );
        }
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
        title: Text(widget.viewType == "add"
            ? AppLocalizations.of(context)!.add_exercise
            : AppLocalizations.of(context)!.edit_exercise),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(bottom: 95),
              child: Column(
                children: [
                  Column(
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
                                  backgroundImage: getImage(),
                                )
                        ),
                      ),
                      SizedBox(
                        height: height * 0.012,
                      ),
                      Text(
                        '${AppLocalizations.of(context)!.upload_image}*',
                        style: GymStyle.listTitle,
                      ),
                    ],
                  ),
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: height * 0.02,
                          ),
                          TextFormField(
                            controller: exerciseTitle,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            cursorColor: ColorCode.mainColor,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!.please_enter_your_exercise_title;
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
                                labelText: '${AppLocalizations.of(context)!.exercise_title}*',
                                labelStyle: GymStyle.inputText),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          TextFormField(
                            controller: description,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            cursorColor: ColorCode.mainColor,
                            decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                border: const UnderlineInputBorder(),
                                labelText: AppLocalizations.of(context)!.description,
                                labelStyle: GymStyle.inputText),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          Row(
                            children: [
                              Consumer<WorkoutCategoryProvider>(
                                builder: (context, categoryData, child) => DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    hint: Text(
                                        categoryData.workoutCategoryItem.isEmpty
                                            ? AppLocalizations.of(context)!.please_add_workout_category
                                            : AppLocalizations.of(context)!.select_workout_category,
                                        style: categoryData.workoutCategoryItem.isEmpty
                                            ? GymStyle.inputText
                                            : GymStyle.exerciseLableText),
                                    items: categoryData.workoutCategoryItem
                                        .map(
                                          (item) => DropdownMenuItem<String>(
                                            value: item[keyWorkoutCategoryTitle] ?? "",
                                            child: Text(item[keyWorkoutCategoryTitle] ?? "",
                                                style: GymStyle.exerciseLableText),
                                          ),
                                        )
                                        .toList(),
                                    value: selectCategory,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          selectCategory = value ?? "";
                                          debugPrint('selectedCategory : $selectedWorkoutCategory');
                                          selectedCategoryId = categoryData.workoutCategoryItem
                                              .firstWhere((element) => element[keyWorkoutCategoryTitle] == value)
                                              .id;
                                          debugPrint('selectedCategory ID : $selectedCategoryId');
                                        },
                                      );
                                    },
                                    buttonHeight: 40,
                                    buttonWidth: width * 0.73,
                                    itemHeight: 40,
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
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
                                      builder: (context) => const AddWorkoutCategory(
                                        documentSnapshot: null,
                                        viewType: "Add",
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 0),
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
                            height: height * 0.01,
                          ),
                          SizedBox(
                            width: width * 0.69,
                            child: Divider(height: 1, color: ColorCode.backgroundColor.withOpacity(0.40), thickness: 1),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          Text('${AppLocalizations.of(context)!.exercise_image}*', style: GymStyle.inputText),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: exerciseImageName,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              hintText: AppLocalizations.of(context)!.select_exercise_image,
                              hintStyle: GymStyle.exerciseLableText,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _getExerciseFromGallery();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA0A9C8),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  margin: const EdgeInsets.only(right: 15, bottom: 15, left: 15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(AppLocalizations.of(context)!.choose, style: GymStyle.buttenText),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Center(
                            child: Text(AppLocalizations.of(context)!.or, style: GymStyle.exerciseLableText),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: youtubeLink,
                            cursorColor: ColorCode.mainColor,
                            decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                border: const UnderlineInputBorder(),
                                labelText: '${AppLocalizations.of(context)!.youtube_url}*',
                                labelStyle: GymStyle.inputText),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          TextFormField(
                            controller: notes,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            cursorColor: ColorCode.mainColor,
                            decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCode.mainColor,
                                  ),
                                ),
                                border: const UnderlineInputBorder(),
                                labelText: AppLocalizations.of(context)!.notes,
                                labelStyle: GymStyle.inputText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 15,
            left: 15,
            child: SizedBox(
              height: height * 0.08,
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  if (imagePath == null && exerciseProfile.isEmpty) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.please_select_image,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else if (formKey.currentState!.validate()) {
                    if (selectedCategoryId.isEmpty) {
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.please_select_Category,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      return;
                    } else if (exerciseImageName.text.trim().isEmpty && youtubeLink.text.trim().isEmpty) {
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.please_select_exercise_image_or_youtube_url,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      return;
                    } else if (exerciseImageName.text.isEmpty) {
                      if (!isYoutubeUrl(youtubeLink.text.trim())) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.please_enter_valid_youtube_link,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 3,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        return;
                      }
                    }
                    if (exerciseImageName.text.trim().isNotEmpty) {
                      youtubeLink.text = "";
                    }
                    if (widget.viewType == "edit") {
                      progressDialog.show();
                      exerciseModel.exerciseExerciseTitle = exerciseTitle.text.trim().firstCapitalize();
                      exerciseModel.exerciseDescription = description.text.trim();
                      exerciseModel.exerciseImageFile = exerciseImagePath;
                      exerciseModel.exerciseImage = exerciseDetailUrl;
                      exerciseModel.exerciseYoutubeLink = youtubeLink.text.trim();
                      exerciseModel.exerciseNotes = notes.text.trim();
                      exerciseModel.profilesImage = exerciseProfile;
                      exerciseModel.profilesImageFile = imagePath;
                      exerciseProvider
                          .updateExercise(
                            exerciseId: widget.documentSnapshot!.id,
                            exerciseProvider: exerciseModel,
                            selectCategory: selectedCategoryId,
                            selectedCategoryId: selectedWorkoutCategory,
                            currentUser: createdBy,
                          )
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
                    } else {
                      progressDialog.show();
                      exerciseModel.exerciseExerciseTitle = exerciseTitle.text.trim().firstCapitalize();
                      exerciseModel.exerciseDescription = description.text.trim().firstCapitalize();
                      exerciseModel.exerciseImageFile = exerciseImagePath;
                      exerciseModel.exerciseYoutubeLink = youtubeLink.text.trim();
                      exerciseModel.exerciseNotes = notes.text.trim();
                      exerciseModel.profilesImageFile = imagePath;
                      exerciseProvider
                          .addExercise(
                              exerciseProvider: exerciseModel,
                              selectCategory: selectedCategoryId,
                              selectedCategoryId: selectedWorkoutCategory,
                              currentUser: createdBy)
                          .then(
                            (defaultResponseData) => {
                              progressDialog.hide(),
                              if (defaultResponseData.status != null && defaultResponseData.status!)
                                {
                                  Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context)!.exercise_added_successfully,
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
                                      msg: AppLocalizations.of(context)!.exercise_already_exist,
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
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: ColorCode.mainColor,
                ),
                child: Text(AppLocalizations.of(context)!.save.allInCaps, style: GymStyle.buttonTextStyle),
              ),
            ),
          )
        ],
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

  _getExerciseFromGallery() async {
    final ImagePicker exerciseImagePicker = ImagePicker();
    try {
      XFile? exerciseImgFile = await exerciseImagePicker.pickImage(source: ImageSource.gallery);
      if (exerciseImgFile != null) {
        exerciseImageByte = await exerciseImgFile.readAsBytes();
        exerciseImagePath = File(exerciseImgFile.path);
        exerciseImageName.text = exerciseImgFile.name;
        setState(
          () {},
        );
      }
    } catch (e) {
      debugPrint("error while picking file.");
    }
  }

  ImageProvider getImage() {
    if (imageByte != null) {
      return MemoryImage(imageByte!);
    } else if (exerciseProfile.isEmpty) {
      return const AssetImage(
        'assets/images/UploadImage.png',
      );
    } else {
      return customImageProvider(url: exerciseProfile);
    }
  }
}
