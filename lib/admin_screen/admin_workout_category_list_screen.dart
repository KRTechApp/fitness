import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/workout_category_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Utils/shared_preferences_manager.dart';
import '../custom_widgets/custom_card.dart';
import '../main.dart';
import '../member_screen/dashboard_screen.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/workout_days_model.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import '../trainer_screen/trainer_exercise_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';
import 'add_workout_category.dart';
import 'admin_dashboard_screen.dart';

class AdminWorkoutCategoryListScreen extends StatefulWidget {
  final String userRole;
  final String userId;

  const AdminWorkoutCategoryListScreen({Key? key, required this.userRole, required this.userId}) : super(key: key);

  @override
  State<AdminWorkoutCategoryListScreen> createState() => _AdminWorkoutCategoryListScreenState();
}

class _AdminWorkoutCategoryListScreenState extends State<AdminWorkoutCategoryListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var selectedWeek = 0;
  late WorkoutCategoryProvider workoutCategoryProvider;
  late WorkoutProvider workoutProvider;
  String? selectedValue;
  List<String> workoutCategoryIdList = [];
  late ShowProgressDialog showProgressDialog;
  final SharedPreferencesManager _preference = SharedPreferencesManager();

  @override
  void initState() {
    super.initState();
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        /*if (widget.userRole == userRoleMember) {
          await workoutProvider.getWorkoutForSelectedMember(selectedMemberId: widget.userId);
          List<WorkoutDaysModel> workoutDaysModelList = [];
          for (int i = 0; i < workoutProvider.selectedMemberWorkout.length; i++) {
            workoutDaysModelList.add(
              WorkoutDaysModel.fromJson(
                json.decode(
                  workoutProvider.selectedMemberWorkout[i][keyWorkoutData],
                ),
              ),
            );
          }
          workoutCategoryIdList.clear();
          for (int i = 0; i < workoutDaysModelList.length; i++) {
            workoutCategoryIdList.addAll(
              getWorkoutCategoryIdList(workoutDaysModel:
                workoutDaysModelList[i],tempIdList: workoutCategoryIdList
              ),
            );
          }
          debugPrint('exerciseIdList : ${workoutCategoryIdList.length}');
          await workoutCategoryProvider.getSearchMyWorkoutCategory(
              isRefresh: true, workoutCategoryIdList: workoutCategoryIdList, createdBy: widget.userId);
        } else {
          await workoutCategoryProvider.getWorkoutCategoryList(isRefresh: true, createdBy: widget.userId);
        }*/
        _pullRefresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        widget.userRole == userRoleTrainer
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const TrainerDashboardScreen()),
                (Route<dynamic> route) => false)
            : widget.userRole == userRoleAdmin
                ? Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                    (Route<dynamic> route) => false)
                : Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()), (Route<dynamic> route) => false);
        return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leadingWidth: 50,
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
          title: Text(AppLocalizations.of(context)!.workout_category),
          actions: [
            if (widget.userRole == userRoleTrainer)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                  splashColor: ColorCode.linearProgressBar,
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
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      height: 20,
                      width: 20,
                      'assets/images/ic_add.svg',
                      color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          height: height * 0.881,
          width: width,
          child: widget.userRole == userRoleMember
              ? RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: Consumer<WorkoutCategoryProvider>(
                    builder: (context, workoutCategoryData, child) =>
                        workoutCategoryProvider.myWorkoutCategoryItem.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.only(top: 10),
                                itemCount: workoutCategoryData.myWorkoutCategoryItem.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final QueryDocumentSnapshot documentSnapshot =
                                      workoutCategoryData.myWorkoutCategoryItem[index];
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddWorkoutCategory(
                                                documentSnapshot: documentSnapshot,
                                                viewType: "view",
                                              ),
                                            ),
                                          );
                                        },
                                        child: customCard(
                                          blurRadius: 5,
                                          radius: 15,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: FadeInImage(
                                                    fit: BoxFit.cover,
                                                    width: 50,
                                                    height: 50,
                                                    image: customImageProvider(
                                                      url: documentSnapshot[keyProfile],
                                                    ),
                                                    placeholderFit: BoxFit.fitWidth,
                                                    placeholder: customImageProvider(),
                                                    imageErrorBuilder: (context, error, stackTrace) {
                                                      return getPlaceHolder();
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: width * 0.5,
                                                child: Text(documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                                    maxLines: 1,
                                                    style: GymStyle.listTitle,
                                                    overflow: TextOverflow.ellipsis),
                                              ),
                                              /*const Spacer(),
                                        PopupMenuButton(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          onSelected: (selection) async {
                                            switch (selection) {
                                              case 1:
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => AddWorkoutCategory(
                                                      documentSnapshot: documentSnapshot,
                                                      viewType: "edit",
                                                    ),
                                                  ),
                                                );
                                                break;
                                              case 2:
                                                deletePopup(documentSnapshot);
                                                break;
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            PopupMenuItem(
                                              value: 1,
                                              padding: const EdgeInsets.only(
                                                left: 17,
                                              ),
                                              child: Text(AppLocalizations.of(context)!.edit, style: GymStyle.popupbox),
                                            ),
                                            PopupMenuItem(
                                              value: 2,
                                              padding: const EdgeInsets.only(
                                                left: 17,
                                              ),
                                              child: Text(AppLocalizations.of(context)!.delete,
                                                  style: GymStyle.popupboxdelate),
                                            ),
                                          ],
                                          child: Container(
                                            height: 35,
                                            width: 30,
                                            margin: const EdgeInsets.only(right: 20),
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.more_vert, color: ColorCode.grayLight),
                                          ),
                                        )*/
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.015,
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: ColorCode.tabDivider,
                                      maxRadius: 45,
                                      child: Image.asset('assets/images/empty_box.png'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                      child: Text(
                                        AppLocalizations.of(context)!.you_do_not_have_any_workout_category,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          color: ColorCode.listSubTitle,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ))
              : widget.userRole == userRoleTrainer
                  ? RefreshIndicator(
                      onRefresh: _pullRefresh,
                      child: Consumer<WorkoutCategoryProvider>(
                        builder: (context, workoutCategoryData, child) => workoutCategoryProvider
                                .workoutCategoryItem.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.only(top: 10),
                                itemCount: workoutCategoryProvider.workoutCategoryItem.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final QueryDocumentSnapshot documentSnapshot =
                                      workoutCategoryData.workoutCategoryItem[index];
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TrainerExerciseScreen(
                                                  workoutCategoryId: documentSnapshot.id,
                                                  workoutCategoryName: documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                                  viewType: " "),
                                            ),
                                          );
                                        },
                                        child: customCard(
                                          blurRadius: 5,
                                          radius: 15,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: FadeInImage(
                                                    fit: BoxFit.cover,
                                                    width: 50,
                                                    height: 50,
                                                    image: customImageProvider(
                                                      url: documentSnapshot[keyProfile],
                                                    ),
                                                    placeholderFit: BoxFit.fitWidth,
                                                    placeholder: customImageProvider(),
                                                    imageErrorBuilder: (context, error, stackTrace) {
                                                      return getPlaceHolder();
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: width * 0.5,
                                                child: Text(documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                                    maxLines: 1,
                                                    style: GymStyle.listTitle,
                                                    overflow: TextOverflow.ellipsis),
                                              ),
                                              const Spacer(),
                                              PopupMenuButton(
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                ),
                                                onSelected: (selection) async {
                                                  switch (selection) {
                                                    case 1:
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => AddWorkoutCategory(
                                                            documentSnapshot: documentSnapshot,
                                                            viewType: "edit",
                                                          ),
                                                        ),
                                                      );
                                                      break;
                                                    case 2:
                                                      deletePopup(documentSnapshot);
                                                      break;
                                                  }
                                                },
                                                itemBuilder: (_) => [
                                                  PopupMenuItem(
                                                    value: 1,
                                                    padding: const EdgeInsets.only(
                                                      left: 17,right: 17
                                                    ),
                                                    child: Text(AppLocalizations.of(context)!.edit.firstCapitalize(),
                                                        style: GymStyle.popupbox),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 2,
                                                    padding: const EdgeInsets.only(
                                                      left: 17,right: 17
                                                    ),
                                                    child: Text(AppLocalizations.of(context)!.delete.firstCapitalize(),
                                                        style: GymStyle.popupboxdelate),
                                                  ),
                                                ],
                                                child: Container(
                                                  height: 35,
                                                  width: 30,
                                                  margin: const EdgeInsets.only(right: 20),
                                                  alignment: Alignment.center,
                                                  child: const Icon(Icons.more_vert, color: ColorCode.grayLight),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.015,
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
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
                                    child: CircleAvatar(
                                      backgroundColor: ColorCode.tabDivider,
                                      maxRadius: 45,
                                      child: SvgPicture.asset(
                                        'assets/images/ic_add.svg',
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                    child: Text(
                                      AppLocalizations.of(context)!.you_do_not_have_any_workout_category,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: ColorCode.listSubTitle,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.tap_to_add.firstCapitalize(),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      color: ColorCode.listSubTitle,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )),
                      ))
                  : Consumer<WorkoutCategoryProvider>(
                      builder: (context, workoutCategoryData, child) =>
                          workoutCategoryProvider.workoutCategoryItem.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.only(top: 10),
                                  itemCount: workoutCategoryProvider.workoutCategoryItem.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final QueryDocumentSnapshot documentSnapshot =
                                        workoutCategoryData.workoutCategoryItem[index];
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AddWorkoutCategory(
                                                  documentSnapshot: documentSnapshot,
                                                  viewType: "view",
                                                ),
                                              ),
                                            );
                                          },
                                          child: customCard(
                                            blurRadius: 5,
                                            radius: 15,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(15),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: FadeInImage(
                                                      fit: BoxFit.cover,
                                                      width: 50,
                                                      height: 50,
                                                      image: customImageProvider(
                                                        url: documentSnapshot[keyProfile],
                                                      ),
                                                      placeholderFit: BoxFit.fitWidth,
                                                      placeholder: customImageProvider(),
                                                      imageErrorBuilder: (context, error, stackTrace) {
                                                        return getPlaceHolder();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width * 0.5,
                                                  child: Text(documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                                      maxLines: 1,
                                                      style: GymStyle.listTitle,
                                                      overflow: TextOverflow.ellipsis),
                                                ), /*
                                            const Spacer(),
                                            PopupMenuButton(
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                              onSelected: (selection) async {
                                                switch (selection) {
                                                  case 1:
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => AddWorkoutCategory(
                                                          documentSnapshot: documentSnapshot,
                                                          viewType: "edit",
                                                        ),
                                                      ),
                                                    );
                                                    break;
                                                  case 2:
                                                    deletePopup(documentSnapshot);
                                                    break;
                                                }
                                              },
                                              itemBuilder: (_) => [
                                                PopupMenuItem(
                                                  value: 1,
                                                  padding: const EdgeInsets.only(
                                                    left: 17,
                                                  ),
                                                  child:
                                                      Text(AppLocalizations.of(context)!.edit, style: GymStyle.popupbox),
                                                ),
                                                PopupMenuItem(
                                                  value: 2,
                                                  padding: const EdgeInsets.only(
                                                    left: 17,
                                                  ),
                                                  child: Text(AppLocalizations.of(context)!.delete,
                                                      style: GymStyle.popupboxdelate),
                                                ),
                                              ],
                                              child: Container(
                                                height: 35,
                                                width: 30,
                                                margin: const EdgeInsets.only(right: 20),
                                                alignment: Alignment.center,
                                                child: const Icon(Icons.more_vert, color: ColorCode.grayLight),
                                              ),
                                            )*/
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.015,
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
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
                                      child: CircleAvatar(
                                        backgroundColor: ColorCode.tabDivider,
                                        maxRadius: 45,
                                        child: SvgPicture.asset(
                                          'assets/images/ic_add.svg',
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                      child: Text(
                                        AppLocalizations.of(context)!.you_do_not_have_any_workout_category,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          color: ColorCode.listSubTitle,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.tap_to_add.firstCapitalize(),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: ColorCode.listSubTitle,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )),
                    ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  deletePopup(QueryDocumentSnapshot documentSnapshot) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: height * 0.01,
              ),
              Container(
                padding: const EdgeInsets.all(30),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF000E).withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset('assets/images/delete.svg'),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text(AppLocalizations.of(context)!.are_you_sure_want_to_delete, style: GymStyle.inputTextBold),
              Text((documentSnapshot[keyWorkoutCategoryTitle] ?? "") + '?', style: GymStyle.inputTextBold),
              SizedBox(
                height: height * 0.03,
              ),
              Row(
                children: [
                  Container(
                    width: width * 0.3,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: ColorCode.mainColor,
                        width: 2,
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel.toUpperCase(),
                        style: TextStyle(
                            color: ColorCode.mainColor,
                            fontSize: getFontSize(17),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.04,
                  ),
                  Container(
                    width: width * 0.3,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        workoutCategoryProvider.deleteCategory(categoryId: documentSnapshot.id);
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.delete.toUpperCase(),
                        style: TextStyle(
                            color: ColorCode.white,
                            fontSize: getFontSize(17),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> getWorkoutCategoryIdList(WorkoutDaysModel workoutDaysModel) {
    List<String> tempWorkoutCategoryList = [];
    if (workoutDaysModel.exerciseDataList != null) {
      for (int i = 0; i < workoutDaysModel.exerciseDataList!.length; i++) {
        tempWorkoutCategoryList.add(workoutDaysModel.exerciseDataList![i].categoryId ?? "");
      }
    }
    debugPrint('getWorkoutCategoryIdList : ${tempWorkoutCategoryList.length}');
    return tempWorkoutCategoryList;
  }

  Future<void> _pullRefresh() async {
    showProgressDialog.show(message: 'Loading...');
    if (widget.userRole == userRoleMember) {
      await workoutProvider.getWorkoutForSelectedMember(selectedMemberId: widget.userId);
      List<WorkoutDaysModel> workoutDaysModelList = [];
      for (int i = 0; i < workoutProvider.selectedMemberWorkout.length; i++) {
        workoutDaysModelList.add(
          WorkoutDaysModel.fromJson(
            json.decode(
              workoutProvider.selectedMemberWorkout[i][keyWorkoutData],
            ),
          ),
        );
      }
      workoutCategoryIdList.clear();
      for (int i = 0; i < workoutDaysModelList.length; i++) {
        workoutCategoryIdList.addAll(
          getWorkoutCategoryIdList(
            workoutDaysModelList[i],
          ),
        );
      }
      debugPrint('exerciseIdList 123: ${workoutCategoryIdList.length}');
      var createdBy = await _preference.getValue(prefCreatedBy, "");
      await workoutCategoryProvider.getSearchMyWorkoutCategory(
          isRefresh: true, workoutCategoryIdList: workoutCategoryIdList, createdBy: createdBy);
    } else {
      await workoutCategoryProvider.getWorkoutCategoryList(isRefresh: true, createdBy: widget.userId);
    }
    showProgressDialog.hide();
  }
}
