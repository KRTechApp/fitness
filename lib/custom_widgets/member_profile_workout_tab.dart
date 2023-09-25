import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../providers/workout_history_provider.dart';
import '../trainer_screen/assign_workout_to_member_screen.dart';
import '../trainer_screen/show_member_workout_detail_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class MemberProfileWorkoutTab extends StatefulWidget {
  final String userRole;
  final String trainerName;
  final String userId;
  final DocumentSnapshot documentSnapshot;
  final double memberProgress;

  const MemberProfileWorkoutTab(
      {Key? key,
      required this.documentSnapshot,
      required this.userRole,
      required this.trainerName,
      required this.userId, required this.memberProgress})
      : super(key: key);

  @override
  State<MemberProfileWorkoutTab> createState() =>
      _MemberProfileWorkoutTabState();
}

class _MemberProfileWorkoutTabState extends State<MemberProfileWorkoutTab> {
  late WorkoutProvider workoutProvider;
  late WorkoutHistoryProvider workoutHistoryProvider;
  String? selectedValue;
  int selectedDayIndex = -1;
  List<String> days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  var selectedDateTime =
      DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
  double memberProgress = 0.0;

  @override
  void initState() {
    super.initState();
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    workoutHistoryProvider =
        Provider.of<WorkoutHistoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await workoutHistoryProvider.getAllWorkoutHistoryForSeamDay(
        createdBy: widget.userId,
        currentDate: getCurrentDateOnly(),
      );
      workoutProvider.getWorkoutForSelectedMember(
          isRefresh: true, selectedMemberId: widget.documentSnapshot.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          const SizedBox(
            height: 18,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffEE7650).withOpacity(0.20),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Text(
                        AppLocalizations.of(context)!.total_workout_completed,
                        maxLines: 1,
                        style: GymStyle.listTitle2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                              width: 55,
                              margin:
                                  const EdgeInsets.only(right: 15, left: 15),
                              padding: const EdgeInsets.only(
                                  left: 8, right: 16, top: 8, bottom: 8),
                              child: CircularPercentIndicator(
                                rotateLinearGradient: true,
                                linearGradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    ColorCode.circleProgressBar,
                                    ColorCode.circleProgressBar
                                  ],
                                ),
                                radius: 25.0,
                                lineWidth: 5.5,
                                animation: true,
                                animationDuration: 1000,
                                startAngle: 360,
                                percent: widget.memberProgress,
                                center: Text(
                                  "${double.parse(widget.memberProgress.toStringAsFixed(2)) >= double.parse('1.0') ? 100 : double.parse(widget.memberProgress.toStringAsFixed(2)) * 100}%",
                                  style: const TextStyle(
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      color: ColorCode.circleProgressBar),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                            ),

                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Stack(
            children: [
              SizedBox(
                height: height * 0.51,
                child: Consumer<WorkoutProvider>(
                  builder: (context, workoutData, child) => workoutProvider
                          .selectedMemberWorkout.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80, top: 10),
                          itemCount: workoutData.selectedMemberWorkout.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final QueryDocumentSnapshot documentSnapshot =
                                workoutData.selectedMemberWorkout[index];
                           /* workoutHistoryProvider.getTotalWorkoutTotalExerciseProgress(workoutDoc: workoutData.selectedMemberWorkout).then((value) =>
                            {
                              memberProgress = value,
                              debugPrint('MWMBWRPROGRESS : $memberProgress'),
                            });*/
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ShowMemberWorkoutDetailScreen(
                                      userName: widget.trainerName,
                                      documentSnapshot: documentSnapshot,
                                      memberId: widget.userId,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15, bottom: 15),
                                child: customCard(
                                  blurRadius: 5,
                                  radius: 15,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: FadeInImage(
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                            image: customImageProvider(
                                                url: documentSnapshot[
                                                    keyProfile]),
                                            placeholderFit: BoxFit.fitWidth,
                                            placeholder: customImageProvider(),
                                            imageErrorBuilder:
                                                (context, error, stackTrace) {
                                              return getPlaceHolder();
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: width * 0.4,
                                              child: Text(
                                                  documentSnapshot[
                                                          keyWorkoutTitle] ??
                                                      "",
                                                  maxLines: 1,
                                                  style: GymStyle.listTitle,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            SizedBox(
                                              width: width * 0.4,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                  documentSnapshot[
                                                          keyWorkoutFor] ??
                                                      "",
                                                  style: GymStyle.listSubTitle,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        FutureBuilder(
                                            future: workoutHistoryProvider
                                                .getTotalExerciseProgress(
                                                    workoutDoc:
                                                        documentSnapshot),
                                            builder: (context,
                                                AsyncSnapshot<double>
                                                    asyncSnapshot) {
                                              if (asyncSnapshot.hasData &&
                                                  asyncSnapshot.data != null) {
                                                double totalProgress =
                                                    asyncSnapshot.data!;
                                                memberProgress = totalProgress +
                                                    memberProgress;
                                                debugPrint(
                                                    'MembrerProgress $memberProgress');
                                                debugPrint(
                                                    'totalProgress : $totalProgress');
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 1),
                                                  height: height * 0.05,
                                                  width: width * 0.26,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Stack(
                                                      children: [
                                                        LinearProgressIndicator(
                                                          minHeight: 50,
                                                          value: totalProgress,
                                                          // percent filled
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                      Color>(ColorCode.mainColor),
                                                          backgroundColor: ColorCode
                                                              .linearProgressBar,
                                                        ),
                                                        Center(
                                                            child: Text(
                                                                '${double.parse(totalProgress.toStringAsFixed(2)) >= double.parse('1.0') ? 100 : double.parse(totalProgress.toStringAsFixed(2)) * 100}%',
                                                                /*'${totalProgress.toString()}%',*/
                                                                style: GymStyle.progressText))
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text("");
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
                                child:
                                    Image.asset('assets/images/empty_box.png'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 17.0, right: 17, top: 15),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .you_do_not_have_any_workout,
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
              if (widget.userRole == userRoleTrainer)
                Positioned(
                  bottom: 15,
                  left: 20,
                  right: 20,
                  child: SizedBox(
                    height: height * 0.08,
                    width: width * 0.9,
                    child: ElevatedButton(
                      onPressed: () {
                        List<String> tempList = [];
                        for (QueryDocumentSnapshot doc
                            in workoutProvider.selectedMemberWorkout) {
                          tempList.add(doc.id);
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AssignWorkoutToMemberScreen(
                                      documentSnapshot: widget.documentSnapshot,
                                      workoutIdList: tempList,
                                    )));
                      },
                      style: GymStyle.buttonStyle,
                      child: Text(
                        AppLocalizations.of(context)!
                            .assign_workout
                            .toUpperCase(),
                        style: GymStyle.buttonTextStyle,
                      ),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}
