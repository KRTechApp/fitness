import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/trainer_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../admin_screen/admin_add_workout_screen.dart';
import '../admin_screen/workout_detail_screen.dart';
import '../mobile_pages/member_workout_detail_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/utils_methods.dart';

class AdminWorkoutListItemView extends StatefulWidget {
  final int index;
  final String userRole;
  final String userId;
  final QueryDocumentSnapshot queryDocumentSnapshot;

  const AdminWorkoutListItemView(
      {Key? key,
      required this.index,
      required this.queryDocumentSnapshot,
      required this.userRole,
      required this.userId})
      : super(key: key);

  @override
  State<AdminWorkoutListItemView> createState() => _AdminWorkoutListItemViewState();
}

class _AdminWorkoutListItemViewState extends State<AdminWorkoutListItemView> {
  late TrainerProvider trainerProvider;
  late ShowProgressDialog showProgressDialog;
  late WorkoutProvider workoutProvider;
  final random = Random();

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Slidable(
        key: UniqueKey(),
        startActionPane: ActionPane(
          extentRatio: widget.userRole == userRoleTrainer ? 0.22 : 0.001,
          motion: const ScrollMotion(),
          children: [
            if (widget.userRole == userRoleTrainer)
              GestureDetector(
                onTap: () {
                  if (widget.userRole == userRoleTrainer) {
                    // showProgressDialog.show(message: 'Loading...');
                    deletePopup(widget.queryDocumentSnapshot);
                    debugPrint('widget.queryDocumentSnapshot${widget.queryDocumentSnapshot}');
                    showProgressDialog.hide();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFFFF000E).withOpacity(0.20),
                  ),
                  padding: const EdgeInsets.all(20),
                  width: 70,
                  height: 70,
                  child: SvgPicture.asset(
                    "assets/images/delete.svg",
                  ),
                ),
              )
          ],
        ),
        endActionPane: ActionPane(
            extentRatio: widget.userRole == userRoleTrainer ? 0.22 : 0.001,
            motion: const ScrollMotion(),
            children: [
              if (widget.userRole == userRoleTrainer)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminAddWorkoutScreen(
                                  userId: widget.userId,
                                  userRole: widget.userRole,
                                  viewType: "edit",
                                  querySnapshot: widget.queryDocumentSnapshot,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFF06AF03).withOpacity(0.20),
                      ),
                      padding: const EdgeInsets.all(20),
                      width: 70,
                      height: 70,
                      child: SvgPicture.asset(
                        "assets/images/Edit_Icon.svg",
                      ),
                    ),
                  ),
                )
            ]),
        child: GestureDetector(
          onTap: () {
            widget.userRole == userRoleMember
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberWorkoutDetailScreen(
                        documentSnapshot: widget.queryDocumentSnapshot,
                        userRole: widget.userRole,
                        userId: widget.userId,
                      ),
                    ),
                  )
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailScreen(
                          documentSnapshot: widget.queryDocumentSnapshot,
                          userRole: widget.userRole,
                          workoutCreatedBy: widget.queryDocumentSnapshot[keyCreatedBy]),
                    ),
                  );
          },
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                Container(
                  height: 132,
                  width: width,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: StaticData.workoutColorList[random.nextInt(StaticData.workoutColorList.length)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((widget.queryDocumentSnapshot[keyWorkoutType] ?? "") == "free")
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
                            if ((widget.queryDocumentSnapshot[keyWorkoutType] ?? "") == "premium")
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
                                        style:
                                            const TextStyle(color: ColorCode.workoutPremiumMembershipText, fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            Text(
                              widget.queryDocumentSnapshot[keyWorkoutFor] ?? "",
                              style: GymStyle.containerSubHeader3,
                            ),
                            widget.queryDocumentSnapshot[keyWorkoutTitle].length > 16
                                ? SizedBox(
                                    width: width * 0.52,
                                    height: 29,
                                    child: Marquee(
                                      text: widget.queryDocumentSnapshot[keyWorkoutTitle] ?? "",
                                      scrollAxis: Axis.horizontal,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      blankSpace: 50.0,
                                      velocity: 20.0,
                                      pauseAfterRound: const Duration(seconds: 1),
                                      accelerationDuration: const Duration(seconds: 2),
                                      accelerationCurve: Curves.linear,
                                      decelerationDuration: const Duration(milliseconds: 200),
                                      decelerationCurve: Curves.easeOut,
                                      style: GymStyle.containerHeader2,
                                    ),
                                  )
                                : Text(
                                    widget.queryDocumentSnapshot[keyWorkoutTitle] ?? "",
                                    style: GymStyle.containerHeader2,
                                  ),
                            widget.userRole == userRoleAdmin
                                ? Row(
                                    children: [
                                      const Icon(Icons.man_rounded, color: Colors.white),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: FutureBuilder(
                                          future: trainerProvider.getTrainerFromId(
                                              memberId: widget.queryDocumentSnapshot.get(keyCreatedBy),
                                              createdBy: widget.userId),
                                          builder: (context, AsyncSnapshot<DocumentSnapshot?> asyncSnapshot) {
                                            if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                              var queryDoc = asyncSnapshot.data;
                                              return Text(queryDoc![keyName],
                                                  maxLines: 1, style: GymStyle.containerSubHeader2);
                                            }
                                            return Container();
                                          },
                                        ),
                                        /*Text(
                                widget.queryDocumentSnapshot[keyWorkoutTitle] ??"",
                                style: GymStyle.containerSubHeader2,
                              ),*/
                                      ),
                                    ],
                                  )
                                : Row(children: [
                                    const Icon(Icons.watch_later_outlined, color: Colors.white),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                          "${((widget.queryDocumentSnapshot[keyTotalWorkoutTime] ?? 0) / 60).ceil().toString()} min",
                                          style: GymStyle.containerSubHeader2),
                                    )
                                  ]),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: -12,
                  child: Image.asset('assets/images/Circle.png', color: Colors.white, height: 200),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                    child: FadeInImage(
                      fit: BoxFit.fill,
                      width: 132,
                      height: 132,
                      image: customImageProvider(
                        url: widget.queryDocumentSnapshot[keyProfile],
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
        ));
  }

  deletePopup(QueryDocumentSnapshot documentSnapshot) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
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
              Text((documentSnapshot[keyWorkoutTitle] ?? "") + '?', style: GymStyle.inputTextBold),
              SizedBox(
                height: height * 0.03,
              ),
              Row(
                children: [
                  Container(
                    width: width * 0.3,
                    height: 45,
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
                    height: 45,
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
                        workoutProvider.deleteWorkout(workoutId: documentSnapshot.id);
                        showProgressDialog.hide();
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
}
