import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../custom_widgets/custom_calendar_app_demo.dart';
import '../custom_widgets/member_exercise_detaiI_item_view.dart';
import '../custom_widgets/workout_detail_card_view.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/workout_days_model.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_history_provider.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class ShowMemberWorkoutDetailScreen extends StatefulWidget {
  final String userName;
  final String memberId;
  final QueryDocumentSnapshot documentSnapshot;

  const ShowMemberWorkoutDetailScreen({
    Key? key,
    required this.userName,
    required this.documentSnapshot,
    required this.memberId,
  }) : super(key: key);

  @override
  State<ShowMemberWorkoutDetailScreen> createState() => _ShowMemberWorkoutDetailScreenState();
}

class _ShowMemberWorkoutDetailScreenState extends State<ShowMemberWorkoutDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final random = Random();
  var selectedDateTime = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
  String? selectedValue;
  int selectedDayIndex = -1;
  late ExerciseProvider exerciseProvider;
  late WorkoutHistoryProvider workoutHistoryProvider;
  WorkoutDaysModel? workoutDaysModel;
  List<ExerciseDataItem> exerciseDataList = [];
  List<String> exerciseIdList = [];
  String createdBy = "";
  String currentUserId = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  List<String> days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

  @override
  void initState() {
    super.initState();
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    workoutHistoryProvider = Provider.of<WorkoutHistoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        createdBy = await _preference.getValue(prefCreatedBy, "");
        currentUserId = await _preference.getValue(prefUserId, "");
        getRefreshExercise();

        // memberWorkoutProgress = exerciseIdList
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
        title: Text(widget.userName),
      ),
      body: Column(
        children: [
          WorkoutDetailCardView(documentSnapshot: widget.documentSnapshot),
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              height: height * 0.164,
              width: width,
              child: CustomCalendarAppDemo(
                currentView: CalendarViews.week,
                onDateChange: onDateChange,
                measurementList: const [],
              ),
            ),
          ),
          SizedBox(
            height: height * 0.49 - 27,
            width: width,
            child: Consumer<WorkoutHistoryProvider>(
              builder: (context, workoutHistoryData, child) => Consumer<ExerciseProvider>(
                builder: (context, exerciseData, child) => exerciseData.memberExerciseListItem.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(top: 10, right: 15, left: 15),
                        itemCount: exerciseData.memberExerciseListItem.length,
                        // physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final QueryDocumentSnapshot queryDocumentSnapshot =
                              exerciseData.memberExerciseListItem[index];
                          debugPrint('Exercise Data : ${exerciseData.memberExerciseListItem.length}');
                          return ShowMemberExerciseDetailItemView(
                            key: UniqueKey(),
                            documentSnapshot: queryDocumentSnapshot,
                            workoutHistoryData: workoutHistoryData,
                            exerciseDataList: exerciseDataList,
                            selectedDateTime: selectedDateTime,
                          );
                        })
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
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  void onDateChange(DateTime tempDate, QueryDocumentSnapshot? document) {
    setState(
      () {
        selectedDateTime = tempDate;
        selectedValue = DateFormat('EEEE').format(selectedDateTime);
        selectedDayIndex = days.indexWhere((element) => element == selectedValue);
        getExercise();
      },
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
        exerciseIdList: exerciseIdList, createdBy: currentUserId, searchText: '');
  }

  void getRefreshExercise() async {
    debugPrint("widget.memberId : ${widget.memberId}");
    await workoutHistoryProvider.getAllWorkoutHistory(
        createdBy: widget.memberId, workoutId: widget.documentSnapshot.id);
    debugPrint("MemberWorkoutDetailScreen : ${widget.documentSnapshot[keyWorkoutData]}");
    workoutDaysModel = WorkoutDaysModel.fromJson(
      json.decode(
        widget.documentSnapshot[keyWorkoutData],
      ),
    );
    /*  memberWorkoutProgress.addAll(widget.documentSnapshot[keyExerciseProgress] ?? "");
    debugPrint('memberWorkoutProgress'+ memberWorkoutProgress.toString());*/
    selectedValue = DateFormat('EEEE').format(selectedDateTime);
    selectedDayIndex = days.indexWhere((element) => element == selectedValue);
    getExercise();
  }
}
