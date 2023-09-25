import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Utils/shared_preferences_manager.dart';
import '../admin_screen/admin_add_exercise.dart';
import '../custom_widgets/trainer_exercise_list_item_view.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'exercise_filter_bottom_sheet.dart';
import 'trainer_dashboard_screen.dart';

class TrainerExerciseScreen extends StatefulWidget {
  final String? workoutCategoryId;
  final String workoutCategoryName;
  final String viewType;

  const TrainerExerciseScreen({
    Key? key,
    this.workoutCategoryId,
    required this.workoutCategoryName,
    required this.viewType,
  }) : super(key: key);

  @override
  State<TrainerExerciseScreen> createState() => _TrainerExerciseScreenState();
}

class _TrainerExerciseScreenState extends State<TrainerExerciseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? categoryId = "all";

  late ExerciseProvider exerciseProvider;
  late ShowProgressDialog progressDialog;
  bool searchVisible = false;
  var textSearchController = TextEditingController();
  String userId = "";
  String userCreatedBy = "";
  String userRole = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  List<String> exerciseIdList = [];
  late WorkoutProvider workoutProvider;

  @override
  void initState() {
    super.initState();
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        userCreatedBy = await _preference.getValue(prefCreatedBy, "");
        debugPrint('widget.selectedCategoryId${widget.workoutCategoryId}');
        progressDialog.show();
        await getMyExercises();
        progressDialog.hide();
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
        if (widget.workoutCategoryId == null) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const TrainerDashboardScreen()),
              (Route<dynamic> route) => false);
        }
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
          title: Text(widget.workoutCategoryName),
          actions: [
            InkWell(
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
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  height: 25,
                  width: 25,
                  'assets/images/ic_Search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
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
                            userId: userId,
                            userRole: userRole,
                            categoryId: categoryId.toString(),
                            userCreatedBy: userCreatedBy,
                          ));
                  if (tempCategoryId != null) {
                    categoryId = tempCategoryId;
                    progressDialog.show();
                    await getMyExercises();
                    progressDialog.hide();
                    setState(() {});
                  }
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
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
            if (userRole != userRoleMember)
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
                        builder: (context) => AdminAddExercise(
                          selectedCategoryId: widget.workoutCategoryId != null ? [widget.workoutCategoryId!] : [],
                          viewType: 'add',
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
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
        body: SizedBox(
          height: height,
          width: width,
          child: RefreshIndicator(
            onRefresh: _pullRefresh,
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
                Consumer<ExerciseProvider>(
                  builder: (context, exerciseData, child) => exerciseProvider.myExerciseListItem.isNotEmpty
                      ? SizedBox(
                          width: width,
                          height: searchVisible ? height - 158 : height * 0.88,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            itemCount: exerciseProvider.myExerciseListItem.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final QueryDocumentSnapshot documentSnapshot = exerciseData.myExerciseListItem[index];

                              return TrainerExerciseListItemView(
                                queryDocumentSnapshot: documentSnapshot,
                                userRole: userRole,
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: height * 0.2,
                            ),
                            userRole == userRoleTrainer
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminAddExercise(
                                            selectedCategoryId:
                                                widget.workoutCategoryId != null ? [widget.workoutCategoryId!] : [],
                                            viewType: 'add',
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
                                  )
                                : CircleAvatar(
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
                            if (userRole != userRoleMember)
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
              ],
            ),
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
    await getMyExercises(searchText: text);
  }

  Future<void> _pullRefresh() async {
    progressDialog.show();
    await getMyExercises();
    progressDialog.hide();
  }

  Future<void> getMyExercises({String searchText = ""}) async {
    // progressDialog.show(message: 'Loading...');
    if (widget.workoutCategoryId == null && categoryId == "all") {
      await exerciseProvider.getExerciseByUserId(isRefresh: true, currentUserId: userId, searchText: searchText);
    } else if (widget.workoutCategoryId != null || categoryId != null) {
      await exerciseProvider.getCategoryExercise(
          createdBy: userId, categoryId: widget.workoutCategoryId ?? categoryId , searchText: searchText, isRefresh: true);
    }
  }
/*else {
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
      await exerciseProvider.getSearchMyExercise(exerciseIdList: exerciseIdList, isRefresh: true,searchText: searchText);
    }
    // progressDialog.hide();*/
}

/*List<String> getExerciseIdList(WorkoutDaysModel workoutDaysModel) {
    List<String> tempExerciseIdList = [];
    List<ExerciseDataModel> exerciseDataList = [];
    if (workoutDaysModel.workoutSunday != null) {
    exerciseDataList.addAll(
    workoutDaysModel.workoutSunday!.exerciseDataModel ?? [],
    );
    }
    if (workoutDaysModel.workoutMonday != null) {
    exerciseDataList.addAll(
    workoutDaysModel.workoutMonday!.exerciseDataModel ?? [],
    );
    }
    if (workoutDaysModel.workoutTuesday != null) {
    exerciseDataList.addAll(
    workoutDaysModel.workoutTuesday!.exerciseDataModel ?? [],
    );
    }
    if (workoutDaysModel.workoutWednesday != null) {
    exerciseDataList.addAll(
    workoutDaysModel.workoutWednesday!.exerciseDataModel ?? [],
    );
    }
    if (workoutDaysModel.workoutThursday != null) {
    exerciseDataList.addAll(
    workoutDaysModel.workoutThursday!.exerciseDataModel ?? [],
    );
    }
    if (workoutDaysModel.workoutFriday != null) {
    exerciseDataList.addAll(
    workoutDaysModel.workoutFriday!.exerciseDataModel ?? [],
    );
    }
    if (workoutDaysModel.workoutSaturday != null) {
    exerciseDataList.addAll(
    workoutDaysModel.workoutSaturday!.exerciseDataModel ?? [],
    );
    }
    debugPrint('Size : ${exerciseDataList.length}');

    for (int i = 0; i < exerciseDataList.length; i++) {
    tempExerciseIdList.add(exerciseDataList[i].id ?? "");
    }
    return tempExerciseIdList;
    }*/
