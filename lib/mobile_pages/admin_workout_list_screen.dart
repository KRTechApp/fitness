import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';

import '../Utils/shared_preferences_manager.dart';
import '../admin_screen/admin_add_workout_screen.dart';
import '../admin_screen/admin_dashboard_screen.dart';
import '../custom_widgets/admin_workout_list_item_view.dart';
import '../main.dart';
import '../member_screen/dashboard_screen.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import 'main_drawer_screen.dart';

class AdminWorkoutList extends StatefulWidget {
  final String viewType;
  final String trainerId;
final bool drawerList;
  const AdminWorkoutList({
    Key? key,
    required this.viewType, required this.trainerId, required this.drawerList,
  }) : super(key: key);

  @override
  State<AdminWorkoutList> createState() => _AdminWorkoutListState();
}

class _AdminWorkoutListState extends State<AdminWorkoutList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late WorkoutProvider workoutProvider;
  late ShowProgressDialog progressDialog;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";
  String userRole = "";

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        getWorkoutList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        if(widget.drawerList) {
          userRole == userRoleTrainer
              ? Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (context) => const TrainerDashboardScreen()), (
              Route<dynamic> route) => false)
              : userRole == userRoleAdmin
              ? Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()), (Route<dynamic> route) => false)
              : Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (Route<dynamic> route) => false);
        }
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
          title: Text(AppLocalizations.of(context)!.workout),
          actions: [
            userRole != userRoleTrainer
                ? const Text('')
                : Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10,left: 10),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50),
                      ),
                      splashColor: ColorCode.linearProgressBar,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminAddWorkoutScreen(userId: userId, userRole: userRole, viewType: ""),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: Text(
                          AppLocalizations.of(context)!.create_workout.allInCaps,
                          style: GymStyle.screenHeader2,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              RefreshIndicator(
                onRefresh: getWorkoutList,
                child: Stack(
                  children: [
                    SizedBox(
                      height: height * 0.8575,
                      width: width,
                      child: userRole == userRoleTrainer
                          ? Consumer<WorkoutProvider>(
                              builder: (context, workoutData, child) => workoutProvider.addByTrainerWorkoutList.isNotEmpty
                                  ? ListView.builder(
                                      padding: const EdgeInsets.only(bottom: 90),
                                      itemCount: workoutData.addByTrainerWorkoutList.length,
                                      scrollDirection: Axis.vertical,
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final QueryDocumentSnapshot documentSnapshot = workoutData.addByTrainerWorkoutList[index];
                                        return AdminWorkoutListItemView(
                                          userRole: userRole,
                                          index: index,
                                          queryDocumentSnapshot: documentSnapshot,
                                          userId: userId,
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
                            )
                          : userRole == userRoleAdmin
                              ? Consumer<WorkoutProvider>(
                                  builder: (context, allTrainerWorkoutData, child) => allTrainerWorkoutData.popularWorkout.isNotEmpty
                                      ? ListView.builder(
                                          padding: const EdgeInsets.only(bottom: 21),
                                          itemCount: allTrainerWorkoutData.popularWorkout.length,
                                          scrollDirection: Axis.vertical,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final QueryDocumentSnapshot documentSnapshot = allTrainerWorkoutData.popularWorkout[index];
                                            return AdminWorkoutListItemView(
                                              userRole: userRole,
                                              index: index,
                                              queryDocumentSnapshot: documentSnapshot,
                                              userId: userId,
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
                                )
                              : Consumer<WorkoutProvider>(
                                  builder: (context, workoutDataForMember, child) => workoutProvider.workoutListItem.isNotEmpty
                                      ? ListView.builder(
                                          padding: const EdgeInsets.only(bottom: 80),
                                          itemCount: workoutDataForMember.workoutListItem.length,
                                          scrollDirection: Axis.vertical,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final QueryDocumentSnapshot documentSnapshot = workoutDataForMember.workoutListItem[index];
                                            return AdminWorkoutListItemView(
                                                userRole: userRole, index: index, queryDocumentSnapshot: documentSnapshot, userId: userId);
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
                    ),
                    userRole != userRoleTrainer
                        ? const Text('')
                        : Positioned(
                            bottom: 10,
                            right: 5,
                            left: 5,
                            child: SizedBox(
                              height: height * 0.08,
                              width: width * 0.9,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminAddWorkoutScreen(userId: userId, userRole: userRole, viewType: ""),
                                    ),
                                  );
                                },
                                style: GymStyle.buttonStyle,
                                child: Text(
                                  AppLocalizations.of(context)!.create_custom_workout.toUpperCase(),
                                  style: GymStyle.buttonTextStyle,
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Future<void> getWorkoutList() async {
    progressDialog.show(message: 'Loading...');
    if (userRole == userRoleAdmin) {
      if(widget.viewType == "ViewWorkout"){
        await workoutProvider.getWorkoutOfTrainer(currentUserId: widget.trainerId);
      }else{
        await workoutProvider.getAllTrainerWorkout();
      }
    } else if (userRole == userRoleTrainer) {
      await workoutProvider.getWorkoutOfTrainer(currentUserId: userId);
    } else {
      await workoutProvider.getWorkoutList(isRefresh: true, searchText: "", currentUserId: userId);
    }
    progressDialog.hide();
    setState(() {});
  }
}
