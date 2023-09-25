import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/workout_history_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_card.dart';
import '../mobile_pages/member_profile_screen.dart';
import '../model/member_selection_model.dart';
import '../providers/member_provider.dart';
import '../trainer_screen/select_member_list.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';

class WorkoutDetailMemberScreen extends StatefulWidget {
  final DocumentSnapshot queryDocumentSnapshot;
  final String userRole;
  final String workoutCreatedBy;
  final Function() getWorkoutDetails;
  final ShowProgressDialog showProgressDialog;

  const WorkoutDetailMemberScreen({
    Key? key,
    required this.queryDocumentSnapshot,
    required this.userRole,
    required this.workoutCreatedBy,
    required this.getWorkoutDetails,
    required this.showProgressDialog,
  }) : super(key: key);

  @override
  State<WorkoutDetailMemberScreen> createState() => _WorkoutDetailMemberScreenState();
}

class _WorkoutDetailMemberScreenState extends State<WorkoutDetailMemberScreen> {
  late WorkoutProvider workoutProvider;
  late WorkoutHistoryProvider workoutHistoryProvider;
  late MemberProvider memberProvider;
  MemberSelectionModel memberSelectionModel =
      MemberSelectionModel(unselectedMember: [], selectedMember: [], alreadySelectedMember: []);
  double totalProgress = 0.0;

  @override
  void initState() {
    super.initState();
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    workoutHistoryProvider = Provider.of<WorkoutHistoryProvider>(context,listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        widget.showProgressDialog.show();
        if ((widget.queryDocumentSnapshot.data() as Map<String, dynamic>).containsKey(keySelectedMember)) {
          List<String> memberList = List.castFrom(widget.queryDocumentSnapshot.get(keySelectedMember));
          memberSelectionModel.selectedMember = memberList;
        }
        await memberProvider.getMemberOfTrainer(createdById: widget.workoutCreatedBy);
        debugPrint("WorkoutDetailMemberScreen selectedMember : ${memberSelectionModel.selectedMember}");
        if (mounted) {
          setState(() {});
        }
        widget.showProgressDialog.hide();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
        width: width,
        height: height,
        child: memberSelectionModel.selectedMember!.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 80),
                itemCount: memberSelectionModel.selectedMember!.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: memberProvider.getMemberFromId(
                        createdById: widget.workoutCreatedBy, userId: memberSelectionModel.selectedMember![index]),
                    builder: (context, AsyncSnapshot<DocumentSnapshot?> asyncSnapshot) {
                      if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                        DocumentSnapshot documentSnapshot = asyncSnapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: widget.userRole != userRoleMember
                                    ? () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MemberProfileScreen(memberId: documentSnapshot.id,memberProgress: totalProgress,)));
                                      }
                                    : null,
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
                                            width: 50,
                                            height: 50,
                                            image: customImageProvider(url: documentSnapshot[keyProfile]),
                                            placeholderFit: BoxFit.fitWidth,
                                            placeholder: customImageProvider(),
                                            imageErrorBuilder: (context, error, stackTrace) {
                                              return Image.asset(width: 50, height: 50, 'getPlaceHolder()');
                                            },
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: width * 0.38,
                                            child: Text(
                                              documentSnapshot[keyName] ?? "",
                                              // widget.documentSnapshot[keyExerciseTitle] ?? "",
                                              maxLines: 1,
                                              style: GymStyle.listTitle,
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.38,
                                            child: Text(
                                              '+${documentSnapshot[keyCountryCode] ?? ""} ${documentSnapshot[keyPhone] ?? ""}',
                                              // widget.documentSnapshot[keyExerciseTitle] ?? "",
                                              maxLines: 1,
                                              style: GymStyle.listSubTitle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      FutureBuilder(
                                          future: workoutHistoryProvider
                                              .getTotalWorkoutTotalExerciseProgress(
                                              memberId: documentSnapshot.id),
                                          builder: (context, AsyncSnapshot<double> asyncSnapshot) {
                                            if (asyncSnapshot.hasData &&
                                                asyncSnapshot.data != null) {
                                              totalProgress = asyncSnapshot.data!;
                                              debugPrint('totalProgress : $totalProgress');
                                              return Container(
                                                width: 50,
                                                margin: const EdgeInsets.only(right: 10, left: 20),
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
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
                      return const Text("");
                    },
                  );
                })
            : widget.userRole == userRoleTrainer
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            MemberSelectionModel tempSelectedMember = (await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SelectMemberList(
                                              memberSelectionModel: memberSelectionModel,
                                            )))) ??
                                memberSelectionModel;
                            widget.showProgressDialog.show();
                            await workoutProvider.updateWorkoutMember(
                                workoutId: widget.queryDocumentSnapshot.id,
                                selectMemberList: tempSelectedMember.selectedMember!,
                                currentUserId: widget.queryDocumentSnapshot[keyCreatedBy] ?? "",
                                unselectMemberList: tempSelectedMember.unselectedMember!,
                                memberCount: tempSelectedMember.selectedMember!.length);
                            widget.showProgressDialog.hide();
                            widget.getWorkoutDetails();
                          },
                          child: CircleAvatar(
                            backgroundColor: ColorCode.tabDivider,
                            maxRadius: 45,
                            child: SvgPicture.asset('assets/images/add_member.svg', height: 30),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                          child: Text(
                            AppLocalizations.of(context)!.workout_not_assign_to_member,
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
                        Text(
                          AppLocalizations.of(context)!.tap_to_add,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: ColorCode.listSubTitle,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
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
                            AppLocalizations.of(context)!.you_do_not_have_any_member,
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
                  ));
  }
}
