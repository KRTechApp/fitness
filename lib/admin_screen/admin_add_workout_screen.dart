import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/model/workout_days_model.dart';
import 'package:crossfit_gym_trainer/providers/class_provider.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/assign_package_item_view.dart';
import '../custom_widgets/rearrange_exercise_list_item_view_new.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../trainer_screen/add_class_screen.dart';
import '../trainer_screen/trainer_add_membership.dart';
import '../utils/utils_methods.dart';

class AdminAddWorkoutScreen extends StatefulWidget {
  final String userId;
  final String userRole;
  final String viewType;
  final DocumentSnapshot? querySnapshot;

  const AdminAddWorkoutScreen(
      {Key? key, required this.userId, required this.userRole, required this.viewType, this.querySnapshot})
      : super(key: key);

  @override
  State<AdminAddWorkoutScreen> createState() => _AdminAddWorkoutScreenState();
}

class _AdminAddWorkoutScreenState extends State<AdminAddWorkoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  NumberFormat formatter = NumberFormat("00");

  List<String> days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  late List<String> alreadySelectedCategory = [];
  String day = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  late List<ExerciseDataItem> selectExerciseDataList = [
    ExerciseDataItem(dayList: [day])
  ];
  List<String> selectedPackageId = [];
  var workoutTitle = TextEditingController();
  var duration = TextEditingController();
  String workoutType = "free";
  bool showAssignPackage = false;
  late WorkoutProvider workoutProvider;
  late MembershipProvider membershipProvider;
  late ClassProvider classProvider;
  late ShowProgressDialog showProgressDialog;
  String? selectedValue;
  List<String> selectedMembershipId = [];
  bool showMembership = false;
  var profile = '';
  String classScheduleId = '';
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  File? imagePath;
  XFile? image;
  var setController = TextEditingController();
  var repsController = TextEditingController();
  var secController = TextEditingController();
  var restController = TextEditingController();

  String? selectedValueByCategory;
  String? selectedValueByExercise;
  bool showClassList = false;
  String? selectedClass;
  String lastCategoryId = '';

  @override
  void initState() {
    super.initState();
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    classProvider = Provider.of<ClassProvider>(context, listen: false);
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await membershipProvider.getMembershipList(createdById: widget.userId);
      await classProvider.getSearchTrainerClassList(currentUserId: widget.userId, isRefresh: true);
      if (widget.querySnapshot != null && widget.viewType == "edit") {
        debugPrint("Workout Id : ${widget.querySnapshot!.id}");
        setState(() {
          workoutTitle.text = widget.querySnapshot!.get(keyWorkoutTitle).toString();
          profile = widget.querySnapshot!.get(keyProfile).toString();
          duration.text = widget.querySnapshot!.get(keyDuration).toString();
          selectedValue = widget.querySnapshot!.get(keyWorkoutFor).toString();
          workoutType = widget.querySnapshot!.get(keyWorkoutType).toString();
          selectedMembershipId = List.castFrom(widget.querySnapshot!.get(keyMembershipId) as List);
          var workoutDaysModel = WorkoutDaysModel.fromJson(json.decode(widget.querySnapshot!.get(keyWorkoutData)));
          selectExerciseDataList = workoutDaysModel.exerciseDataList ?? [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final List<String> workoutLevel = [
      'BEGINNER',
      'INTERMEDIATE',
      'ADVANCE'];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leadingWidth: 48,
        leading: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
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
        title: widget.viewType == "edit"
            ? Text(AppLocalizations.of(context)!.edit_workout)
            : Text(AppLocalizations.of(context)!.add_workout),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              hideKeyboard();
            },
            child: Form(
              key: formKey,
              child: SizedBox(
                height: height,
                width: width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? 20 : 80),
                  child: Column(
                    children: [
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
                        padding: const EdgeInsets.only(right: 15, left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            // Text('${AppLocalizations.of(context)!.workout_title}*', style: GymStyle.listTitle),
                            TextFormField(
                              style: GymStyle.drawerswitchtext,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: workoutTitle,
                              // readOnly: widget.viewType == "view" ? true : false,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!.please_enter_workout_title;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: '${AppLocalizations.of(context)!.workout_title}*',
                                labelStyle: GymStyle.inputText,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            // Text(AppLocalizations.of(context)!.workout_for, style: GymStyle.listTitle),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                buttonWidth: width,
                                hint: Text(
                                  AppLocalizations.of(context)!.select_item,
                                  style: GymStyle.inputText,
                                ),
                                items: workoutLevel
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: GymStyle.drawerswitchtext,
                                          ),
                                        ))
                                    .toList(),
                                value: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value as String;
                                  });
                                },
                                dropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                onMenuStateChange: (isOpen) {
                                  setState(
                                    () {
                                      showMembership = isOpen;
                                    },
                                  );
                                },
                                icon: Icon(
                                  showMembership ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFFADAEB0),
                                ),
                              ),
                            ),
                            Divider(height: 1, color: ColorCode.backgroundColor.withOpacity(0.40), thickness: 1),
                            /* SizedBox(
                              height: height * 0.02,
                            ),*/
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showAssignPackage = !showAssignPackage;
                                      debugPrint("drawer open");
                                    });
                                  },
                                  child: Consumer<MembershipProvider>(
                                    builder: (context, tempMembershipList, child) => SizedBox(
                                      width: width * 0.73,
                                      height: height * 0.1,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          tempMembershipList.membershipListItem.isEmpty
                                              ? Container(
                                                  padding: const EdgeInsets.only(top: 16),
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(AppLocalizations.of(context)!.please_add_membership,
                                                      overflow: TextOverflow.ellipsis, style: GymStyle.inputText),
                                                )
                                              : Container(
                                                  padding: const EdgeInsets.only(top: 16),
                                                  alignment: Alignment.centerLeft,
                                                  child: FutureBuilder(
                                                      future: tempMembershipList.getMembershipListInSingleString(
                                                          membershipIdList: selectedMembershipId,
                                                          currentUserId: widget.userId),
                                                      builder: (context, AsyncSnapshot<String> asyncSnapshot) {
                                                        if (asyncSnapshot.hasData) {
                                                          var membershipList = asyncSnapshot.data != null
                                                              ? asyncSnapshot.data as String
                                                              : "";
                                                          debugPrint("membershipList : $membershipList");
                                                          return SizedBox(
                                                            width: width * 0.60,
                                                            child: Text(
                                                              membershipList.isEmpty
                                                                  ? AppLocalizations.of(context)!.assign_membership
                                                                  : membershipList,
                                                              style: membershipList.isEmpty
                                                                  ? GymStyle.inputText
                                                                  : GymStyle.drawerswitchtext,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          );
                                                        }
                                                        return Text(
                                                          AppLocalizations.of(context)!.assign_package,
                                                          style: GymStyle.inputText,
                                                        );
                                                      }),
                                                ),
                                          Container(
                                            margin: const EdgeInsets.only(top: 20, right: 16),
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              showAssignPackage
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
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const TrainerAddMemberShip(
                                                  viewType: "Add",
                                                  documentSnapshot: null,
                                                )));
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
                              width: width * 0.7,
                              child: const Divider(
                                color: ColorCode.backgroundColor,
                                height: 1,
                              ),
                            ),
                            if (showAssignPackage)
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                child: Consumer<MembershipProvider>(
                                  builder: (context, tempMembershipList, child) => ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: tempMembershipList.membershipListItem.length,
                                      itemBuilder: (context, index) {
                                        return AssignPackageItemView(
                                            documentSnapshot: tempMembershipList.membershipListItem[index],
                                            index: index,
                                            selectedAssignPackageList: selectedMembershipId,
                                            onAssignPackageSelected: onAssignPackageSelected);
                                      }),
                                ),
                              ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Row(
                              children: [
                                Consumer<ClassProvider>(
                                  builder: (context, classData, child) => SizedBox(
                                    width: width * 0.69,
                                    height: height * 0.1,
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 20),
                                      alignment: Alignment.centerLeft,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2(
                                          hint: Text(
                                              classData.classListItem.isEmpty
                                                  ? AppLocalizations.of(context)!.please_add_class
                                                  : AppLocalizations.of(context)!.select_class,
                                              overflow: TextOverflow.ellipsis,
                                              style: GymStyle.inputText),
                                          items: classData.classListItem
                                              .map(
                                                (item) => DropdownMenuItem<String>(
                                                  value: item[keyClassName] ?? "",
                                                  child: SizedBox(
                                                    width: width * 0.6,
                                                    child: Text(item[keyClassName] ?? "",
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GymStyle.drawerswitchtext),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          value: selectedClass,
                                          onMenuStateChange: (isOpen) {
                                            setState(
                                              () {
                                                showClassList = isOpen;
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            showClassList
                                                ? Icons.keyboard_arrow_up_rounded
                                                : Icons.keyboard_arrow_down_rounded,
                                            color: const Color(0xFFADAEB0),
                                          ),
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                selectedClass = value ?? "";
                                                QueryDocumentSnapshot queryDoc = classData.classListItem
                                                    .firstWhere((element) => element[keyClassName] == value);
                                                classScheduleId = queryDoc.id;
                                                debugPrint('selectedWorkout : $selectedClass');
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
                                        builder: (context) => AddClass(
                                          viewType: "",
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
                                width: width * 0.7,
                                child: Divider(
                                    height: 1, color: ColorCode.backgroundColor.withOpacity(0.40), thickness: 1)),
                            const SizedBox(
                              height: 10,
                            ),
                            // Text('${AppLocalizations.of(context)!.duration_weeks}*', style: GymStyle.listTitle),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GymStyle.exerciseLableText,
                              controller: duration,
                              maxLength: 2,
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              // readOnly: widget.viewType == "view" ? true : false,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!.please_enter_duration_weeks;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                counterText: "",
                                border: const UnderlineInputBorder(),
                                labelText: '${AppLocalizations.of(context)!.duration_weeks}*',
                                labelStyle: GymStyle.inputText,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              AppLocalizations.of(context)!.workout_type,
                              style: GymStyle.listTitle,
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
                                      AppLocalizations.of(context)!.free,
                                      style: GymStyle.inputTextBold,
                                    ),
                                    leading: Radio(
                                      activeColor: ColorCode.mainColor,
                                      value: "free",
                                      groupValue: workoutType,
                                      onChanged: (value) {
                                        setState(() {
                                          workoutType = value.toString();
                                        });
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
                                      AppLocalizations.of(context)!.premium,
                                      style: GymStyle.inputTextBold,
                                    ),
                                    leading: Radio(
                                      activeColor: ColorCode.mainColor,
                                      value: "premium",
                                      groupValue: workoutType,
                                      onChanged: (value) {
                                        setState(() {
                                          workoutType = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(height: 1, thickness: GymStyle.deviderThiknes),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 15, bottom: selectExerciseDataList.isEmpty ? 15 : 0),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.add_exercise,
                              style: GymStyle.headerColor,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectExerciseDataList.insert(
                                      0, ExerciseDataItem(dayList: [day], categoryId: lastCategoryId));
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                width: 30,
                                height: 30,
                                color: ColorCode.mainColor,
                                child: SvgPicture.asset('assets/images/ic_add.svg', color: ColorCode.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ReorderableListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: selectExerciseDataList.map((exerciseItem) {
                          /*QueryDocumentSnapshot documentSnapshot = exerciseData.selectedCategoryExercise
                              .where((element) => element.id == item)
                              .first;*/
                          var index = selectExerciseDataList.indexOf(exerciseItem);

                          return RearrangeExerciseListItemViewNew(
                            key: ValueKey(exerciseItem),
                            index: index,
                            exerciseItem: exerciseItem,
                            userId: widget.userId,
                            onExerciseSelect: onExerciseSelect,
                            onExerciseItemUpdate: onExerciseItemUpdate,
                          );
                        }).toList(),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = selectExerciseDataList.removeAt(oldIndex);
                            selectExerciseDataList.insert(newIndex, item);
                          });
                        },
                      ),
                      if (keyboardHeight > 0) getSubmitButton(height: height, width: width)
                      /*Container(
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        width: width,
                        // height: height * 0.6,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80),
                          scrollDirection: Axis.vertical,
                          itemCount: 7,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                elevation: 5,
                                color: ColorCode.tabBarBackground,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Text(days[index].toString(), style: GymStyle.listTitle),
                                    ),
                                    const Spacer(),
                                    Container(
                                        margin: const EdgeInsets.only(left: 11),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(50)),
                                          color: ColorCode.mainColor,
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: IconButton(
                                          onPressed: () async {
                                            workoutDaysModel = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => WorkoutCategoryList(
                                                          dayIndex: index,
                                                          workoutDaysModel: workoutDaysModel,
                                                          // alreadySelectedCategory: alreadySelectedCategory,
                                                        )));
                                            setState(() {});
                                          },
                                          icon: SvgPicture.asset('assets/images/editIcon.svg'),
                                        )),
                                    Container(
                                        margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 2, color: ColorCode.mainColor),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50),
                                          ),
                                          color: ColorCode.white,
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                          child: Text(
                                            getExerciseCount(dayIndex: index, workoutDaysModel: workoutDaysModel),
                                            style: TextStyle(
                                                color: ColorCode.mainColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'poppins'),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),*/
                    ],
                  ),
                ),
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
    );
  }

  Widget getSubmitButton({required double height, required double width}) {
    return SizedBox(
      height: height * 0.08,
      width: width * 0.9,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            showProgressDialog.show();
            WorkoutDaysModel workoutDaysModel = WorkoutDaysModel(exerciseDataList: selectExerciseDataList);

            if (widget.viewType == "edit") {
              workoutProvider
                  .updateWorkout(
                      oldImageUrl: profile,
                      totalTime: getWorkoutTotalTime(workoutDaysModel: workoutDaysModel),
                      exerciseCount: workoutDaysModel.exerciseDataList!.length,
                      workoutId: widget.querySnapshot!.id,
                      profile: imagePath,
                      workoutTitle: workoutTitle.text.trim().toString().firstCapitalize(),
                      duration: int.parse(duration.text.trim()),
                      workoutType: workoutType,
                      workoutFor: selectedValue.toString().trim(),
                      membershipId: selectedMembershipId,
                      workoutData: jsonEncode(workoutDaysModel),
                      classScheduleId: classScheduleId,
                      currentUserId: widget.userId)
                  .then(((defaultResponseData) => {
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
                            Navigator.pop(context, true)
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
                      }));
            } else {
              workoutProvider
                  .addWorkout(
                      totalTime: getWorkoutTotalTime(workoutDaysModel: workoutDaysModel),
                      workoutTitle: workoutTitle.text.trim().toString().firstCapitalize(),
                      workoutFor: selectedValue.toString().trim(),
                      workoutDuration: int.parse(duration.text.trim()),
                      workoutData: jsonEncode(workoutDaysModel),
                      exerciseCount: workoutDaysModel.exerciseDataList!.length,
                      createdById: widget.userId.toString(),
                      workoutType: workoutType.trim(),
                      membershipId: selectedMembershipId,
                      classScheduleId: classScheduleId,
                      profile: imagePath)
                  .then(((defaultResponseData) => {
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
                            Navigator.pop(context, true)
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
                      }));
            }
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: ColorCode.mainColor,
        ),
        child: Text(AppLocalizations.of(context)!.save, style: GymStyle.buttonTextStyle),
      ),
    );
  }

  onAssignPackageSelected(String id, bool selected) {
    if (selected) {
      if (!selectedMembershipId.contains(id)) {
        selectedMembershipId.add(id);
      }
    } else {
      selectedMembershipId.remove(id);
    }
    debugPrint("onSubSubjectSelected :${selectedMembershipId.length}");
    membershipProvider.refreshList();
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

  void onExerciseSelect(ExerciseDataItem item) {
    setState(() {
      selectExerciseDataList.remove(item);
    });
  }

  void onExerciseItemUpdate(int index, String categoryId, String exerciseId, String sets, String reps, String second,
      String rest, List<String> dayList) {
    debugPrint("onExerciseItemUpdate index : $index");
    lastCategoryId = categoryId;
    selectExerciseDataList[index].categoryDataId = categoryId;
    selectExerciseDataList[index].exerciseDataId = exerciseId;
    selectExerciseDataList[index].exerciseDataSet = sets;
    selectExerciseDataList[index].exerciseDataReps = reps;
    selectExerciseDataList[index].exerciseDataSec = second;
    selectExerciseDataList[index].exerciseDataRest = rest;
    selectExerciseDataList[index].dayDataList = dayList;
  }
}
