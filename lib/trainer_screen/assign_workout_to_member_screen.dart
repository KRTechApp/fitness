import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';
import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../admin_screen/admin_add_workout_screen.dart';
import '../custom_widgets/assign_workout_to_member_item_view.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../providers/workout_provider.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';

class AssignWorkoutToMemberScreen extends StatefulWidget {
  // final String memberId;
  final DocumentSnapshot documentSnapshot;
  final List<String> workoutIdList;
  const AssignWorkoutToMemberScreen({Key? key, required this.documentSnapshot, required this.workoutIdList}) : super(key: key);

  @override
  State<AssignWorkoutToMemberScreen> createState() => _AssignWorkoutToMemberScreenState();
}

class _AssignWorkoutToMemberScreenState extends State<AssignWorkoutToMemberScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late WorkoutProvider workoutProvider;
  late ShowProgressDialog progressDialog;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";
  String userRole = "";
  List<String> selectWorkoutList = [];
  List<String> unSelectWorkoutList = [];
  List<String> alreadySelectedWorkoutList = [];

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");

        selectWorkoutList.clear();
        alreadySelectedWorkoutList.clear();
        selectWorkoutList.addAll(widget.workoutIdList);
        alreadySelectedWorkoutList.addAll(widget.workoutIdList);
        await getWorkoutList();

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
        title: const Text('Workout'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
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
      body: Column(
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
                    builder: (context, workoutData, child) => workoutProvider.addByTrainerWorkoutList.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: workoutData.addByTrainerWorkoutList.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final QueryDocumentSnapshot documentSnapshot =
                                  workoutData.addByTrainerWorkoutList[index];
                              return AssignWorkoutToMemberItemView(
                                index: index,
                                queryDocumentSnapshot: documentSnapshot,
                                userRole: userRole,
                                userId: userId,
                                selectedWorkoutList: selectWorkoutList,
                                onSelectedWorkout: onSelectedWorkout,);
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
              ),
              Positioned(
                bottom: 5,
                left: 15,
                right: 15,
                child: SizedBox(
                  height: height * 0.08,
                  width: width * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      progressDialog.show();
                      workoutProvider.assignWorkoutForMember(
                          memberId: widget.documentSnapshot.id,
                          selectWorkoutList: selectWorkoutList,
                        alreadySelectedWorkoutList: alreadySelectedWorkoutList,
                        unSelectedWorkoutList: unSelectWorkoutList
                      ) .then(
                        ((defaultResponseData) => {
                          progressDialog.hide(),
                          if (defaultResponseData.status != null && defaultResponseData.status!)
                            {
                              debugPrint('1111'),
                              Fluttertoast.showToast(
                                  msg: defaultResponseData.message ??
                                      AppLocalizations.of(context)!.something_want_to_wrong,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0),
                      workoutProvider.getWorkoutForSelectedMember(isRefresh: true,selectedMemberId: widget.documentSnapshot.id),
                              Navigator.pop(context),
                            }
                          else
                            {
                              debugPrint('2222'),
                              Fluttertoast.showToast(
                                  msg: defaultResponseData.message ??
                                      AppLocalizations.of(context)!.something_want_to_wrong,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0)
                            }
                        }),
                      );
                    },
                    style: GymStyle.buttonStyle,
                    child: Text(
                      AppLocalizations.of(context)!.assign_workout.toUpperCase(),
                      style: GymStyle.buttonTextStyle,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  Future<void> _pullRefresh() async {
    progressDialog.show(message: 'Loading...');
    await getWorkoutList();
    progressDialog.hide();
  }
  onSelectedWorkout(String id, bool selected) {
    setState(
          () {
        if (selected) {
          if (!selectWorkoutList.contains(id)) {
            selectWorkoutList.add(id);
            unSelectWorkoutList.remove(id);
          }
          if (unSelectWorkoutList.contains(id)) {
            unSelectWorkoutList.remove(id);
          }
        } else {
          selectWorkoutList.remove(id);
          unSelectWorkoutList.add(id);
        }
      },
    );
  }

  Future<void> getWorkoutList() async {
    progressDialog.show(message: 'Loading...');
    await workoutProvider.getWorkoutOfTrainer(currentUserId: userId);
    progressDialog.hide();
    setState(
     () {},
    );
  }

}
