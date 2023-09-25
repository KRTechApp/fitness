import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/providers/class_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/shared_preferences_manager.dart';
import '../custom_widgets/custom_card.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import 'join_virtual_class_bottom_sheet_screen.dart';

class TrainerProfileClassScheduleForMember extends StatefulWidget {
  final String trainerId;

  const TrainerProfileClassScheduleForMember({Key? key, required this.trainerId}) : super(key: key);

  @override
  State<TrainerProfileClassScheduleForMember> createState() => _TrainerProfileClassScheduleForMemberState();
}

class _TrainerProfileClassScheduleForMemberState extends State<TrainerProfileClassScheduleForMember> {
  late ClassProvider classProvider;
  late ShowProgressDialog progressDialog;
  String userId = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();

  @override
  void initState() {
    super.initState();
    classProvider = Provider.of<ClassProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        setState(
          () {},
        );
        classProvider.getClassByUser(userId: userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
            height: height * 0.79,
            width: width,
            child: RefreshIndicator(
              onRefresh: _pullRefresh,
              color: ColorCode.mainColor,
              child: Consumer<ClassProvider>(
                builder: (context, classData, child) => classProvider.classListItem.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: classData.classListItem.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final QueryDocumentSnapshot documentSnapshot = classData.classListItem[index];
                          return Column(
                            children: [
                              customCard(
                                blurRadius: 5,
                                radius: 15,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            height: 60,
                                            width: 60,
                                            color: const Color(0xFF6842FF).withOpacity(0.10),
                                            child: SvgPicture.asset(
                                              fit: BoxFit.contain,
                                              'assets/images/ic_desktop.svg',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: width * 0.34,
                                            child: documentSnapshot[keyClassName].length > 12
                                                ? SizedBox(
                                                    width: width * 0.34,
                                                    height: 29,
                                                    child: Marquee(
                                                      text: documentSnapshot[keyClassName] ?? "",
                                                      scrollAxis: Axis.horizontal,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      blankSpace: 50.0,
                                                      velocity: 20.0,
                                                      pauseAfterRound: const Duration(seconds: 1),
                                                      accelerationDuration: const Duration(seconds: 2),
                                                      accelerationCurve: Curves.linear,
                                                      decelerationDuration: const Duration(milliseconds: 200),
                                                      decelerationCurve: Curves.easeOut,
                                                      style: GymStyle.listTitle,
                                                    ),
                                                  )
                                                : Text(documentSnapshot[keyClassName] ?? "",
                                                    style: GymStyle.listTitle, maxLines: 1),
                                          ),
                                          /*Text(documentSnapshot[keyClassName] ?? "",
                                                maxLines: 1, style: GymStyle.listTitle),
                                          )*/
                                          SizedBox(
                                            width: width * 0.34,
                                            child: RichText(
                                              text: TextSpan(
                                                text: documentSnapshot[keyStartTime] ?? "",
                                                style: GymStyle.listSubTitle,
                                                children: <TextSpan>[
                                                  const TextSpan(
                                                    text: ' - ',
                                                  ),
                                                  TextSpan(
                                                      text: documentSnapshot[keyEndTime] ?? "",
                                                      style: GymStyle.listSubTitle),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.34,
                                            child: Text(getSelectedDay(documentSnapshot),
                                                maxLines: 1, style: GymStyle.listSubTitle),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10,left: 10),
                                        child: SizedBox(
                                          height: 50,
                                          width: 85,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showModalBottomSheet(
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
                                                builder: (context) => JoinVirtualClassBottomSheetScreen(
                                                  documentSnapshot: documentSnapshot,
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const StadiumBorder(),
                                              backgroundColor: ColorCode.mainColor,
                                            ),
                                            child: Text(
                                              documentSnapshot[keyClassType] != "inPerson"
                                                  ? AppLocalizations.of(context)!.join.toUpperCase()
                                                  : AppLocalizations.of(context)!.view.toUpperCase(),
                                              style: GymStyle.startButton,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.012,
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
                                AppLocalizations.of(context)!.you_do_not_have_any_class_schedule,
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
          ),
        ],
      ),
    );
  }

  Future<void> _pullRefresh() async {
    await classProvider.getClassByUser(userId: widget.trainerId);
  }

  String getDay(int index) {
    switch (index) {
      case 0:
        return "Su";
      case 1:
        return "Mo";
      case 2:
        return "Tu";
      case 3:
        return "We";
      case 4:
        return "Th";
      case 5:
        return "Fr";
      case 6:
        return "Sa";
    }
    return "Sunday";
  }

  getSelectedDay(QueryDocumentSnapshot documentSnapshot) {
    var dayListString = "";
    List<int> selectDayList = [];
    selectDayList = List.castFrom(documentSnapshot.get(keySelectedDays) as List);
    // debugPrint("selected day list : $selectDayList");
    for (var i = 0; i < selectDayList.length; i++) {
      dayListString = dayListString +
          (getDay(
            selectDayList[i],
          ).isNotEmpty
              ? "${dayListString.isNotEmpty ? " | " : ""}${getDay(
                  selectDayList[i],
                )}"
              : "");
    }
    return dayListString;
  }
}
