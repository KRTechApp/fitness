import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/providers/exercise_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../custom_widgets/custom_calendar_app_demo.dart';
import '../custom_widgets/custom_card.dart';
import '../custom_widgets/workout_detail_card_view.dart';
import '../model/workout_days_model.dart';
import '../providers/workout_history_provider.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/utils_methods.dart';
import 'main_drawer_screen.dart';
import 'workout_exercise_details_screen.dart';

class MemberWorkoutDetailScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final String userRole;
  final String userId;

  const MemberWorkoutDetailScreen(
      {Key? key, required this.documentSnapshot, required this.userRole, required this.userId})
      : super(key: key);

  @override
  State<MemberWorkoutDetailScreen> createState() => _MemberWorkoutDetailScreenState();
}

class _MemberWorkoutDetailScreenState extends State<MemberWorkoutDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var selectedWeek = 0;
  late ExerciseProvider exerciseProvider;
  late WorkoutHistoryProvider workoutHistoryProvider;

  List<String> days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  String? selectedValue;
  int selectedDayIndex = 0;
  var dayCount = 0;
  WorkoutDaysModel? workoutDaysModel;
  List<ExerciseDataItem> exerciseDataList = [];
  List<String> exerciseIdList = [];
  bool searchVisible = false;
  var textSearchController = TextEditingController();
  String createdBy = "";
  var selectedDateTime = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late ShowProgressDialog progressDialog;
  final random = Random();

  @override
  void initState() {
    super.initState();
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    workoutHistoryProvider = Provider.of<WorkoutHistoryProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    debugPrint('count : $dayCount');
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        debugPrint('Time Count${(widget.documentSnapshot[keyTotalWorkoutTime] ?? 0) / 60.truncate()}');
        createdBy = await _preference.getValue(prefCreatedBy, "");
        getRefreshExercise();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
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
        title: Text(AppLocalizations.of(context)!.workout),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () async {
                /* progressDialog.show();
                await deleteAllTableData(tableName: tableWorkoutHistory, excludeCount: 1);
                progressDialog.hide();*/
                setState(
                  () {
                    searchVisible = !searchVisible;
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  height: 20,
                  width: 20,
                  'assets/images/search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchVisible)
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: Card(
                  // elevation: 5,
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
            Column(
              children: [
                WorkoutDetailCardView(documentSnapshot: widget.documentSnapshot),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    height: /*height * 0.164*/ height * 0.05,
                    width: width,
                    child: FittedBox(
                      child: Row(
                        children: List.generate(
                          7,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ActionChip(
                              label: Text(
                                "Day ${index + 1}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins-Bold',
                                  color: selectedDayIndex == index ? const Color(0xFFFFFFFF) : const Color(0xFF777777),
                                ),
                              ),
                              backgroundColor: selectedDayIndex == index ? ColorCode.mainColor : ColorCode.mainColor1,
                              onPressed: () {
                                onDateChange(index, null);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // child: CustomCalendarAppDemo(
                    //   currentView: CalendarViews.week,
                    //   onDateChange: onDateChange,
                    //   measurementList: const [],
                    // ),
                  ),
                ),
                SizedBox(
                  height: searchVisible ? height * 0.49 - 85 : height * 0.49 - 27,
                  width: width,
                  child: Consumer<WorkoutHistoryProvider>(
                    builder: (context, workoutHistoryData, child) => Consumer<ExerciseProvider>(
                      builder: (context, exerciseData, child) => exerciseData.memberExerciseListItem.isNotEmpty
                          ? ListView.builder(
                              key: UniqueKey(),
                              padding: const EdgeInsets.only(top: 10, right: 15, left: 15),
                              itemCount: exerciseData.memberExerciseListItem.length,
                              // physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final QueryDocumentSnapshot queryDocumentSnapshot =
                                    exerciseData.memberExerciseListItem[index];
                                List<ExerciseDataItem> trainerData = exerciseDataList
                                    .where((element) => element.exerciseId == queryDocumentSnapshot.id)
                                    .toList();
                                debugPrint('Trainer Data : ${exerciseData.memberExerciseListItem.length}');
                                debugPrint('Total exercise : ${trainerData.length}');
                                debugPrint('selectedIndex ${workoutHistoryData.allWorkoutHistoryListItem.length}');
                                List<QueryDocumentSnapshot> workoutHistory = workoutHistoryData
                                    .allWorkoutHistoryListItem
                                    .where((element) =>
                                        element[keyExerciseId] == queryDocumentSnapshot.id &&
                                        selectedDateTime
                                            .isSameDate(DateTime.fromMillisecondsSinceEpoch(element[keyCreatedAt])))
                                    .toList();
                                debugPrint('Same Day Total Workout length : ${workoutHistory.length}');
                                double progress = 0.0;
                                // double trainerDataSet = 0;
                                String displayTime = "00:00:00";
                                debugPrint("queryDocumentSnapshot : ${queryDocumentSnapshot[keyExerciseTitle]}");
                                if (workoutHistory.isNotEmpty) {
                                  debugPrint(
                                      "workoutHistory.first[keyCreatedAt] : ${DateTime.fromMillisecondsSinceEpoch(workoutHistory.first[keyCreatedAt])}");
                                }
                                if (workoutHistory.isNotEmpty &&
                                    trainerData.isNotEmpty &&
                                    selectedDateTime.isSameDate(
                                        DateTime.fromMillisecondsSinceEpoch(workoutHistory.first[keyCreatedAt])) &&
                                    workoutHistory.first.get(keySet) != "") {
                                  debugPrint("workoutHistory.first : ${workoutHistory.first.id}");
                                  debugPrint("queryDocumentSnapshot : ${queryDocumentSnapshot[keyExerciseTitle]}");
                                  /*  trainerDataSet = (double.parse((trainerData.first.set ?? "0").isEmpty
                                      ? "0"
                                      : (trainerData.first.set ?? "0")));*/
                                  var tempProgress = workoutHistory.first.get(keyExerciseProgress) ?? "0";

                                  progress = (double.parse(tempProgress == "null" ? "0" : tempProgress));

                                  /*((double.parse(workoutHistory.first.get(keySet) ?? "0")) /
                                      ((double.parse((trainerData.first.set ?? "0").isEmpty
                                          ? "0"
                                          : (trainerData.first.set ?? "0")))));*/
                                  debugPrint(
                                      'PrintValues${(double.parse((trainerData.first.set ?? "0").isEmpty ? "0.0" : (trainerData.first.set ?? "0")))} ${(double.parse(workoutHistory.first.get(keySet) ?? "0"))}');

                                  displayTime = workoutHistory.first.get(keyExerciseTime);
                                  debugPrint('display : $displayTime');
                                }

                                debugPrint('progress $progress');
                                return Column(
                                  key: UniqueKey(),
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WorkoutExerciseDetailsScreen(
                                              workoutId: widget.documentSnapshot.id,
                                              queryDocumentSnapshot: queryDocumentSnapshot,
                                              exerciseDataModel: exerciseDataList[index],
                                              getRefreshExercise: getRefreshExercise,
                                              selectedDateTime: selectedDateTime,
                                            ),
                                          ),
                                        );
                                      },
                                      child: customCard(
                                        blurRadius: 5,
                                        radius: 15,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: FadeInImage(
                                                    fit: BoxFit.fitWidth,
                                                    width: 50,
                                                    height: 50,
                                                    image: customImageProvider(
                                                      url: queryDocumentSnapshot[keyProfile],
                                                    ),
                                                    placeholderFit: BoxFit.fitWidth,
                                                    placeholder: customImageProvider(),
                                                    imageErrorBuilder: (context, error, stackTrace) {
                                                      return getPlaceHolder();
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: width * 0.35,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                                      child: Text(queryDocumentSnapshot[keyExerciseTitle],
                                                          maxLines: 1,
                                                          style: GymStyle.listTitle,
                                                          overflow: TextOverflow.ellipsis),
                                                    ),
                                                  ),
                                                  if (displayTime != "00:00:00")
                                                    SizedBox(
                                                      width: width * 0.35,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 5),
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              color: const Color(0xFF555555),
                                                              'assets/images/ic_Watch.svg',
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 6),
                                                              child: Text(
                                                                displayTime,
                                                                // '${dayCount} Days',
                                                                style: GymStyle.listSubTitle,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const Spacer(),
                                              progress > 0
                                                  ? Container(
                                                      height: height * 0.05,
                                                      width: width * 0.26,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(20),
                                                        child: Stack(
                                                          children: [
                                                            LinearProgressIndicator(
                                                              minHeight: 50,
                                                              value: double.parse(progress.toStringAsFixed(2)) >=
                                                                      double.parse('1.0')
                                                                  ? 1
                                                                  : double.parse(
                                                                      progress.toStringAsFixed(2)), // percent filled
                                                              valueColor: const AlwaysStoppedAnimation<Color>(
                                                                  ColorCode.mainColor),
                                                              backgroundColor: ColorCode.linearProgressBar,
                                                            ),
                                                            Positioned(
                                                                child: Center(
                                                                    child: Text(
                                                                        '${double.parse(progress.toStringAsFixed(2)) >= double.parse('1.0') ? 100 : double.parse(progress.toStringAsFixed(2)) * 100}%',
                                                                        style: GymStyle.progressText)))
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: height * 0.05,
                                                      width: width * 0.26,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => WorkoutExerciseDetailsScreen(
                                                                workoutId: widget.documentSnapshot.id,
                                                                queryDocumentSnapshot: queryDocumentSnapshot,
                                                                exerciseDataModel: exerciseDataList[index],
                                                                getRefreshExercise: getRefreshExercise,
                                                                selectedDateTime: selectedDateTime,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: GymStyle.buttonStyle,
                                                        child: Text(
                                                          AppLocalizations.of(context)!.start,
                                                          style: GymStyle.startButton,
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
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
                                ],
                              ),
                            ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  Future<void> getExercise() async {
    debugPrint('selectedDayIndex : $selectedDayIndex');
    exerciseDataList.clear();
    switch (selectedDayIndex) {
      case 0:
        exerciseDataList.addAll(getDayByExercise(day: daySunday, workoutDaysModel: workoutDaysModel));
        break;
      case 1:
        exerciseDataList.addAll(getDayByExercise(day: dayMonday, workoutDaysModel: workoutDaysModel));
        break;
      case 2:
        exerciseDataList.addAll(getDayByExercise(day: dayTuesday, workoutDaysModel: workoutDaysModel));

        break;
      case 3:
        exerciseDataList.addAll(getDayByExercise(day: dayWednesday, workoutDaysModel: workoutDaysModel));

        break;
      case 4:
        exerciseDataList.addAll(getDayByExercise(day: dayThursday, workoutDaysModel: workoutDaysModel));

        break;
      case 5:
        exerciseDataList.addAll(getDayByExercise(day: dayFriday, workoutDaysModel: workoutDaysModel));

        break;
      case 6:
        exerciseDataList.addAll(getDayByExercise(day: daySaturday, workoutDaysModel: workoutDaysModel));
        break;
    }
    debugPrint('Size : ${exerciseDataList.length}');
    exerciseIdList.clear();
    for (int i = 0; i < exerciseDataList.length; i++) {
      exerciseIdList.add(
        exerciseDataList[i].exerciseId ?? "",
      );
    }
    await exerciseProvider.getMemberMyExercise(
        exerciseIdList: exerciseIdList, createdBy: createdBy, searchText: textSearchController.text.trim());
  }

  onSearchTextChanged(String text) async {
    await exerciseProvider.getMemberMyExercise(exerciseIdList: exerciseIdList, createdBy: createdBy, searchText: text);
  }

  void getRefreshExercise() async {
    await workoutHistoryProvider.getAllWorkoutHistory(createdBy: widget.userId, workoutId: widget.documentSnapshot.id);
    debugPrint("MemberWorkoutDetailScreen : ${widget.documentSnapshot[keyWorkoutData]}");
    workoutDaysModel = WorkoutDaysModel.fromJson(
      json.decode(
        widget.documentSnapshot[keyWorkoutData],
      ),
    );

    selectedValue = DateFormat('EEEE').format(selectedDateTime);
    selectedDayIndex = days.indexWhere((element) => element == selectedValue);
    getExercise();
  }

  void onDateChange(/*DateTime tempDate*/ int index, QueryDocumentSnapshot? document) {
    setState(
      () {
        // selectedDateTime = tempDate;
        // debugPrint("onDateChange : $selectedDateTime");
        // selectedValue = DateFormat('EEEE').format(selectedDateTime);
        // selectedDayIndex = days.indexWhere((element) => element == selectedValue);
        selectedDayIndex = index;
        getExercise();
      },
    );
  }
}
