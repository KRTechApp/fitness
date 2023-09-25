import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/class_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_card.dart';
import '../trainer_screen/add_class_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class TrainerProfileClassSchedule extends StatefulWidget {
  final String trainerId;

  const TrainerProfileClassSchedule({Key? key, required this.trainerId}) : super(key: key);

  @override
  State<TrainerProfileClassSchedule> createState() => _TrainerProfileClassScheduleState();
}

class _TrainerProfileClassScheduleState extends State<TrainerProfileClassSchedule> {
  late ClassProvider classProvider;
  late ShowProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
    classProvider = Provider.of<ClassProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // progressDialog.show();
        await classProvider.getSearchTrainerClassList(currentUserId: widget.trainerId);
        debugPrint("Class List: ${classProvider.classListItem.length}");
        debugPrint("Trainer Id: ${widget.trainerId}");
        // progressDialog.hide();
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
                              GestureDetector(
                                /*borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                splashColor: ColorCode.linearProgressBar,*/
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddClass(
                                        viewType: "view",
                                        documentSnapshot: documentSnapshot,
                                      ),
                                    ),
                                  );
                                },
                                child: customCard(
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
                                              width: width * 0.55,
                                              child: documentSnapshot[keyClassName].length > 16
                                                  ? SizedBox(
                                                      width: width * 0.55,
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
                                            ),*/
                                            SizedBox(
                                              width: width * 0.55,
                                              child: RichText(
                                                text: TextSpan(
                                                  text: documentSnapshot[keyStartTime] ?? "",
                                                  style: GymStyle.listSubTitle,
                                                  children: <TextSpan>[
                                                    const TextSpan(
                                                      text: '-',
                                                    ),
                                                    TextSpan(
                                                        text: documentSnapshot[keyEndTime] ?? "",
                                                        style: GymStyle.listSubTitle),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * 0.55,
                                              child: Text(getSelectedDay(documentSnapshot),
                                                  maxLines: 1, style: GymStyle.listSubTitle),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        PopupMenuButton(
                                          splashRadius: 50,
                                          elevation: 10,
                                          onSelected: (selection) async {
                                            switch (selection) {
                                              case 0:
                                                deletePopup(documentSnapshot);
                                                break;
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            PopupMenuItem(
                                              value: 0,
                                              padding: const EdgeInsets.only(
                                                left: 17,right: 17
                                              ),
                                              child: Text(AppLocalizations.of(context)!.delete.firstCapitalize(),
                                                  style: GymStyle.popupboxdelate),
                                            ),
                                          ],
                                          child: Container(
                                            padding: const EdgeInsets.only(right: 15),
                                            height: 35,
                                            width: 30,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.more_vert, color: ColorCode.grayLight),
                                          ),
                                        ),
                                      ],
                                    ),
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
              Text((documentSnapshot[keyClassName] ?? "") + '?', style: GymStyle.inputTextBold),
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
                        classProvider.deleteClass(classId: documentSnapshot.id);
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

  Future<void> _pullRefresh() async {
    await classProvider.getSearchTrainerClassList(currentUserId: widget.trainerId);
  }
}
