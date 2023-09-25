import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import '../../utils/gym_style.dart';
import '../Utils/color_code.dart';
import '../admin_screen/workout_detail_screen.dart';
import '../mobile_pages/member_workout_detail_screen.dart';
import '../providers/workout_provider.dart';
import '../utils/shared_preferences_manager.dart';
import '../providers/trainer_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/static_data.dart';
import '../utils/utils_methods.dart';

class JoinVirtualClassBottomSheetScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const JoinVirtualClassBottomSheetScreen({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  State<JoinVirtualClassBottomSheetScreen> createState() => _JoinVirtualClassBottomSheetScreenState();
}

class _JoinVirtualClassBottomSheetScreenState extends State<JoinVirtualClassBottomSheetScreen> {
  late TrainerProvider trainerProvider;
  late WorkoutProvider workoutProvider;
  String trainerName = "";
  String userId = "";
  String userRole = "";
  final random = Random();
  DocumentSnapshot? workoutDoc;

  final SharedPreferencesManager _preference = SharedPreferencesManager();
  NumberFormat formatter = NumberFormat("00");

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");

        DocumentSnapshot documentSnapshot = await trainerProvider.getSingleTrainer(
          userId: widget.documentSnapshot[keyCreatedBy],
        );
        workoutDoc = await workoutProvider.getSingleWorkout(
          workoutId: widget.documentSnapshot[keyWorkoutId],
        );
        debugPrint("widget.documentSnapshots DATA${documentSnapshot.id.toString()}");
        setState(
          () {
            trainerName = documentSnapshot.get(keyName);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: height * 0.65,
          width: width,
          margin: const EdgeInsets.only(top: 30),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset('assets/images/arrow-left.svg'),
                      ),
                      SizedBox(width: width * 0.03),
                      SizedBox(
                        width: width * 0.7,
                        child: widget.documentSnapshot[keyClassName].length > 18
                            ? SizedBox(
                                width: width * 0.52,
                                height: 29,
                                child: Marquee(
                                  text: widget.documentSnapshot[keyClassName] ?? "",
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 50.0,
                                  velocity: 20.0,
                                  pauseAfterRound: const Duration(seconds: 1),
                                  accelerationDuration: const Duration(seconds: 2),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration: const Duration(milliseconds: 200),
                                  decelerationCurve: Curves.easeOut,
                                  style:
                                      const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                                ),
                              )
                            : Text(
                                widget.documentSnapshot[keyClassName] ?? "",
                                style:
                                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                              ),
                        /*Text(
                          widget.documentSnapshot[keyClassName],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                        ),*/
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25,bottom: 80),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.class_name.allInCaps,
                              maxLines: 1, style: GymStyle.boldText),
                          const Spacer(),
                          SizedBox(
                            width: width * 0.45,
                            child: Text(widget.documentSnapshot[keyClassName], style: GymStyle.popupbox),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.trainer.allInCaps, maxLines: 1, style: GymStyle.boldText),
                          const Spacer(),
                          SizedBox(
                            width: width * 0.45,
                            child: Text(trainerName, style: GymStyle.popupbox),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.start_time.allInCaps,
                              maxLines: 1, style: GymStyle.boldText),
                          const Spacer(),
                          SizedBox(
                            width: width * 0.45,
                            child: Text(widget.documentSnapshot[keyStartTime], maxLines: 1, style: GymStyle.popupbox),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.end_time.allInCaps, maxLines: 1, style: GymStyle.boldText),
                          const Spacer(),
                          SizedBox(
                            width: width * 0.45,
                            child: Text(widget.documentSnapshot[keyEndTime], maxLines: 1, style: GymStyle.popupbox),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                      /* Row(
                        children: [
                          Text(AppLocalizations.of(context)!.membership.allInCaps, maxLines: 1, style: GymStyle.boldText),
                          const Spacer(),
                          SizedBox(
                            width: width * 0.45,
                            child: Text('Silver Membership', style: GymStyle.popupbox),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),*/
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.total_member.allInCaps,
                              maxLines: 1, style: GymStyle.boldText),
                          const Spacer(),
                          SizedBox(
                            width: width * 0.45,
                            child: Text(
                                formatter.format(List.castFrom(widget.documentSnapshot.get(keySelectedMember)).length),
                                maxLines: 1,
                                style: GymStyle.popupbox),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                      if (workoutDoc != null)
                        GestureDetector(
                          onTap: () {
                            userRole == userRoleMember
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MemberWorkoutDetailScreen(
                                        documentSnapshot: workoutDoc!,
                                        userRole: userRole,
                                        userId: userId,
                                      ),
                                    ),
                                  )
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkoutDetailScreen(
                                          documentSnapshot: workoutDoc!,
                                          userRole: userRole,
                                          workoutCreatedBy: workoutDoc![keyCreatedBy]),
                                    ),
                                  );
                          },
                          child: Directionality(
                            textDirection:  ui.TextDirection.ltr,
                            child: Stack(
                              children: [
                                Container(
                                  height: 147,
                                  width: width,
                                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                    color:
                                        StaticData.workoutColorList[random.nextInt(StaticData.workoutColorList.length)],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if ((workoutDoc![keyWorkoutType] ?? "") == "free")
                                              Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                height: 26,
                                                width: 100,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: ColorCode.workoutMembership,
                                                  borderRadius: BorderRadius.circular(50),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(context)!.free_for_all,
                                                  style: const TextStyle(color: ColorCode.white, fontSize: 12),
                                                ),
                                              ),
                                            if ((workoutDoc![keyWorkoutType] ?? "") == "premium")
                                              Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                height: 26,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: ColorCode.workoutPremiumMembership,
                                                  borderRadius: BorderRadius.circular(50),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset('assets/images/star.svg',
                                                        color: ColorCode.workoutPremiumMembershipText),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5.0),
                                                      child: Text(
                                                        AppLocalizations.of(context)!.premium,
                                                        style: const TextStyle(
                                                            color: ColorCode.workoutPremiumMembershipText, fontSize: 12),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            Text(
                                              workoutDoc![keyWorkoutFor] ?? "",
                                              style: GymStyle.containerSubHeader3,
                                            ),
                                            customMarquee(
                                                width: width * 0.52,
                                                text: workoutDoc![keyWorkoutTitle],
                                                textStyle: GymStyle.containerHeader2,
                                                height: 27),
                                            Row(
                                              children: [
                                                const Icon(Icons.watch_later_outlined, color: Colors.white),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    left: 4,
                                                  ),
                                                  child: Text(
                                                      "${((workoutDoc![keyTotalWorkoutTime] ?? 0) / 60).ceil().toString()} min",
                                                      style: GymStyle.containerSubHeader2),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5.0, top: 4),
                                                  child: SvgPicture.asset(
                                                    'assets/images/dumbbell.svg',
                                                    width: 15,
                                                    height: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 4),
                                                  child: /*FutureBuilder(
                                      future: trainerProvider.getTrainerFromId(
                                          memberId: documentSnapshot.get(keyCreatedBy), currentUserId: userId),
                                      builder: (context, AsyncSnapshot<DocumentSnapshot?> asyncSnapshot) {
                                        if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                          var queryDoc = asyncSnapshot.data;
                                          debugPrint("queryDocqueryDoc $queryDoc");
                                          return Text(queryDoc![keyName],
                                              maxLines: 1, style: GymStyle.containerSubHeader2);
                                        }
                                        return Container();
                                      },
                                    ),*/
                                                      Text(
                                                    '${workoutDoc![keyExerciseCount] ?? ""} ${AppLocalizations.of(context)!.exercises}',
                                                    style: GymStyle.containerSubHeader2,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: -12,
                                  child: Image.asset('assets/images/Circle.png', color: Colors.white, height: 200),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 15,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                    child: FadeInImage(
                                      fit: BoxFit.fill,
                                      width: 132,
                                      height: 147,
                                      image: customImageProvider(
                                        url: workoutDoc![keyProfile],
                                      ),
                                      placeholderFit: BoxFit.fitWidth,
                                      placeholder: customImageProvider(),
                                      imageErrorBuilder: (context, error, stackTrace) {
                                        return getPlaceHolder();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.documentSnapshot[keyClassType] != "inPerson")
          Positioned(
            bottom: 20,
            child: SizedBox(
              height: height * 0.08,
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: () async {
                  final Uri url = Uri.parse(
                      widget.documentSnapshot[keyVirtualClassLink] ?? "");

                  if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: const Color(0xFF6842FF),
                ),
                child: Text(
                  AppLocalizations.of(context)!.join_virtual_class.toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                ),
              ),
            ),
          )
      ],
    );
  }
}
