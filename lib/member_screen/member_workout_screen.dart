import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../custom_widgets/admin_workout_list_item_view.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../providers/workout_provider.dart';
import 'dashboard_screen.dart';

class MemberWorkoutScreen extends StatefulWidget {
  final String userId;
  final String userRole;

  const MemberWorkoutScreen({Key? key, required this.userId, required this.userRole}) : super(key: key);

  @override
  State<MemberWorkoutScreen> createState() => _MemberWorkoutScreenState();
}

class _MemberWorkoutScreenState extends State<MemberWorkoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late WorkoutProvider workoutProvider;
  late ShowProgressDialog showProgressDialog;

  @override
  void initState() {
    super.initState();
    showProgressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        showProgressDialog.show();
        await workoutProvider.getWorkoutForSelectedMember(isRefresh: true, selectedMemberId: widget.userId);
        showProgressDialog.hide();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (Route<dynamic> route) => false);
        return Future.value(true);
      },
      child: Scaffold(
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
          title: Text(AppLocalizations.of(context)!.my_workout),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Stack(
                children: [
                  SizedBox(
                      height: height * 0.8575,
                      width: width,
                      child: RefreshIndicator(
                        onRefresh: _pullRefresh,
                        child: Consumer<WorkoutProvider>(
                          builder: (context, workoutData, child) => workoutProvider.selectedMemberWorkout.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: workoutData.selectedMemberWorkout.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final QueryDocumentSnapshot documentSnapshot =
                                        workoutData.selectedMemberWorkout[index];
                                    return AdminWorkoutListItemView(
                                      userRole: widget.userRole,
                                      index: index,
                                      queryDocumentSnapshot: documentSnapshot,
                                      userId: widget.userId,
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
                                          AppLocalizations.of(context)!.you_do_not_have_any_workout,
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
                      )),
                ],
              ),
            ],
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    showProgressDialog.show();
    await workoutProvider.getWorkoutForSelectedMember(selectedMemberId: widget.userId);
    showProgressDialog.hide();
  }
}
