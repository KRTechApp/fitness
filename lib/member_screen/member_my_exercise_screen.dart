import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/trainer_exercise_list_item_view.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/workout_days_model.dart';
import '../trainer_screen/exercise_filter_bottom_sheet.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import '../main.dart';
import '../providers/exercise_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/utils_methods.dart';
import 'dashboard_screen.dart';

class MemberMyExerciseScreen extends StatefulWidget {
  final String? workoutCategoryId;
  final String userId;
  final String viewType;

  const MemberMyExerciseScreen({Key? key, this.workoutCategoryId, required this.userId, required this.viewType}) : super(key: key);

  @override
  State<MemberMyExerciseScreen> createState() => _MemberMyExerciseScreenState();
}

class _MemberMyExerciseScreenState extends State<MemberMyExerciseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late ExerciseProvider exerciseProvider;
  late WorkoutProvider workoutProvider;
  late ShowProgressDialog progressDialog;
  List<String> exerciseIdList = [];
  bool searchVisible = false;
  String currentUserId = "";
  String userRole = "";
  String createdBy = "";
  var textSearchController = TextEditingController();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String? categoryId = "all";

  @override
  void initState() {
    super.initState();
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        currentUserId = await _preference.getValue(prefUserId, "");
        createdBy = await _preference.getValue(prefCreatedBy, "");
        userRole = await _preference.getValue(prefUserRole, "");
        progressDialog.show();
        await getExercise();
        progressDialog.hide();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (Route<dynamic> route) => false);
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
          title: Text(AppLocalizations.of(context)!.my_exercises),
          actions: [
            InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                  splashColor: ColorCode.linearProgressBar,
                  onTap: () {
                    setState(
                      () {
                        searchVisible = !searchVisible;
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    height: 25,
                    width: 25,
                    'assets/images/ic_Search.svg',
                    color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                  ),
                ),
              ),
            ),
            if (widget.viewType == "filter")
              InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () async {
                hideKeyboard();
                String? tempCategoryId = await showModalBottomSheet(
                    context: context,
                    enableDrag: false,
                    isScrollControlled: true,
                    isDismissible: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    builder: (context) => ExerciseFilterBottomSheet(
                        userCreatedBy: createdBy,
                        userId: currentUserId,
                        userRole: userRole,
                        categoryId: categoryId.toString()));
                if (tempCategoryId != null) {
                  categoryId = tempCategoryId;
                  progressDialog.show();
                  await getExercise();
                  progressDialog.hide();
                  setState(() {});
                }
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                    child: SvgPicture.asset(
                      height: 16,
                      width: 16,
                      'assets/images/ic_Filter.svg',
                      color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 15,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: (categoryId == null || categoryId == "all") ? Colors.transparent : ColorCode.mainColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        body: SizedBox(
          height: height,
          width: width,
          child: Column(
            children: [
              if (searchVisible)
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFD9E1ED),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        controller: textSearchController,
                        cursorColor: ColorCode.mainColor,
                        onChanged: (value) {
                          if (value.trim().isNotEmpty) {
                            onSearchTextChanged(
                              value.trim(),
                            );
                          } else {
                            onSearchTextChanged("");
                          }
                        },
                        decoration: InputDecoration(
                          hintStyle: GymStyle.searchbox,
                          hintText: AppLocalizations.of(context)!.search_exercise,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            child: SvgPicture.asset(
                              "assets/images/SearchIcon.svg",
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(25, 0, 5, 0),
                        ),
                      ),
                    ),
                  ),
                ),
              RefreshIndicator(
                onRefresh: _pullRefresh,
                child: Consumer<ExerciseProvider>(
                  builder: (context, exerciseData, child) => SizedBox(
                    width: width,
                    height: searchVisible ? height - 158 : height * 0.88,
                    child: exerciseProvider.memberExerciseListItem.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            itemCount: exerciseProvider.memberExerciseListItem.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final QueryDocumentSnapshot documentSnapshot = exerciseData.memberExerciseListItem[index];
                              return TrainerExerciseListItemView(
                                userRole: userRole,
                                queryDocumentSnapshot: documentSnapshot,
                              );
                            },
                          )
                        : Column(
                            children: [
                              const Spacer(),
                              CircleAvatar(
                                backgroundColor: ColorCode.tabDivider,
                                maxRadius: 45,
                                child: Image.asset('assets/images/empty_box.png'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                child: Text(
                                  AppLocalizations.of(context)!.you_do_not_have_any_exercise,
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
                              const Spacer(),
                            ],
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  onSearchTextChanged(String text) async {
    await exerciseProvider.getMemberMyExercise(exerciseIdList: exerciseIdList, createdBy: createdBy, searchText: text);
  }

  List<String> getExerciseIdList(WorkoutDaysModel workoutDaysModel) {
    List<String> tempExerciseIdList = [];
    if (workoutDaysModel.exerciseDataList != null) {
      for (int i = 0; i < workoutDaysModel.exerciseDataList!.length; i++) {
        if (widget.workoutCategoryId != null) {
          if (widget.workoutCategoryId == workoutDaysModel.exerciseDataList![i].categoryId &&
              !tempExerciseIdList.contains(workoutDaysModel.exerciseDataList![i].exerciseId ?? "")) {
            tempExerciseIdList.add(workoutDaysModel.exerciseDataList![i].exerciseId ?? "");
          }
        } else {
          if (!tempExerciseIdList.contains(workoutDaysModel.exerciseDataList![i].exerciseId ?? "")) {
            tempExerciseIdList.add(workoutDaysModel.exerciseDataList![i].exerciseId ?? "");
          }
        }
      }
    }
    debugPrint('getExerciseIdList : ${tempExerciseIdList.length}');
    return tempExerciseIdList;
  }

  Future<void> _pullRefresh() async {
    progressDialog.show();
    await getExercise();
    progressDialog.hide();
  }

  Future<void> getExercise() async {
    await workoutProvider.getWorkoutForSelectedMember(selectedMemberId: currentUserId, searchText: "", isRefresh: true);
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
    exerciseIdList.clear();
    for (int i = 0; i < workoutDaysModelList.length; i++) {
      exerciseIdList.addAll(
        getExerciseIdList(
          workoutDaysModelList[i],
        ),
      );
    }
    debugPrint('exerciseIdList : ${exerciseIdList.length}');

    if (categoryId == "all" && widget.workoutCategoryId == null) {
      await exerciseProvider.getMemberMyExercise(exerciseIdList: exerciseIdList, createdBy: createdBy, searchText: "");
    } else if(widget.workoutCategoryId != null || categoryId != null){
      await exerciseProvider.getMemberMyExerciseCategory(
          exerciseIdList: exerciseIdList, createdBy: createdBy, searchText: "", categoryId: widget.workoutCategoryId != null ?
      widget.workoutCategoryId! : categoryId!);
    }
  }
}
