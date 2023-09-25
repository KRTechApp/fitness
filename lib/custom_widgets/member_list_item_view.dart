import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/payment_history_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../mobile_pages/member_profile_screen.dart';
import '../providers/membership_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class MemberListItemView extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;

  const MemberListItemView({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  State<MemberListItemView> createState() => _MemberListItemView();
}

class _MemberListItemView extends State<MemberListItemView> {
  late WorkoutHistoryProvider workoutHistoryProvider;
  double totalProgress = 0.0;
  @override
  void initState() {
    super.initState();
    workoutHistoryProvider =
        Provider.of<WorkoutHistoryProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MemberProfileScreen(memberId: widget.documentSnapshot.id,memberProgress: totalProgress),
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
                        width: 70,
                        height: 70,
                        image: customImageProvider(
                            url: widget.documentSnapshot[keyProfile] ?? ""),
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
                        child: Text(
                          widget.documentSnapshot[keyName] ?? "",
                          maxLines: 1,
                          style: GymStyle.listTitle,
                        ),
                      ),
                      if ((widget.documentSnapshot.data()
                                  as Map<String, dynamic>)
                              .containsKey(keyCurrentMembership) &&
                          widget.documentSnapshot.get(keyCurrentMembership) !=
                              "")
                        FutureBuilder(
                            future: Provider.of<MembershipProvider>(context,
                                    listen: false)
                                .getMembershipDataFromId(
                                    membershipId: widget.documentSnapshot
                                        .get(keyCurrentMembership),
                                    createdById: widget.documentSnapshot
                                        .get(keyCreatedBy)),
                            builder: (context,
                                AsyncSnapshot<QueryDocumentSnapshot?>
                                    asyncSnapshot) {
                              if (asyncSnapshot.hasData &&
                                  asyncSnapshot.data != null) {
                                var queryDoc = asyncSnapshot.data;

                                DateTime tempDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        widget.documentSnapshot[
                                            keyMembershipTimestamp]);
                                debugPrint("tempDate : $tempDate");
                                int totalDays = queryDoc![keyPeriod];
                                debugPrint("totalDays : $totalDays");

                                return FutureBuilder(
                                    future: Provider.of<PaymentHistoryProvider>(
                                            context,
                                            listen: false)
                                        .getMyPaymentById(
                                            membershipId: widget
                                                .documentSnapshot
                                                .get(keyCurrentMembership),
                                            createdBy: widget.documentSnapshot
                                                .get(keyCreatedBy),
                                            createdAt: widget.documentSnapshot
                                                .get(keyMembershipTimestamp),
                                            createdFor:
                                                widget.documentSnapshot.id),
                                    builder: (context,
                                        AsyncSnapshot<QueryDocumentSnapshot?>
                                            snapshotHistory) {
                                      if (snapshotHistory.hasData &&
                                          snapshotHistory.data != null) {
                                        var historyDoc = snapshotHistory.data;
                                        int extendedDays =
                                            historyDoc![keyExtendDate];
                                        // int extendedDays = 0;
                                        var startDate = DateFormat(
                                                StaticData.currentDateFormat)
                                            .format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    widget.documentSnapshot[
                                                        keyMembershipTimestamp]));
                                        var newDate = DateFormat(
                                                StaticData.currentDateFormat)
                                            .format(tempDate.add(Duration(
                                                days:
                                                    totalDays + extendedDays)));
                                        debugPrint("newDate : $newDate");
                                        debugPrint(
                                            "historyDoc : ${historyDoc.id}");
                                        debugPrint(
                                            "extendedDays : $extendedDays");
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$startDate | $newDate',
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: ColorCode.listSubTitle,
                                                fontSize: getFontSize(14),
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            SizedBox(
                                                width: width * 0.35,
                                                child: Text(
                                                    queryDoc[keyMembershipName]
                                                        .toString(),
                                                    maxLines: 1,
                                                    style:
                                                        GymStyle.listSubTitle)),
                                          ],
                                        );
                                      }
                                      return Container();
                                    });
                              }
                              return Container();
                            }),
                    ],
                  ),
                  const Spacer(),
                  FutureBuilder(
                      future: workoutHistoryProvider
                          .getTotalWorkoutTotalExerciseProgress(
                              memberId: widget.documentSnapshot.id),
                      builder: (context, AsyncSnapshot<double> asyncSnapshot) {
                        if (asyncSnapshot.hasData &&
                            asyncSnapshot.data != null) {
                           totalProgress = asyncSnapshot.data!;
                          debugPrint('totalProgress : $totalProgress');
                          return Container(
                            width: 50,
                            margin: const EdgeInsets.only(right: 10, left: 10),
                            /*padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),*/
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
                              percent: totalProgress,
                              center: Text(
                                "${double.parse(totalProgress.toStringAsFixed(2)) >= double.parse('1.0') ? 1 : double.parse(totalProgress.toStringAsFixed(2))*100}%",
                                style: const TextStyle(
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: ColorCode.circleProgressBar),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const CircularProgressIndicator(),
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
          SizedBox(
            height: height * 0.012,
          ),
        ],
      ),
    );
  }
}
