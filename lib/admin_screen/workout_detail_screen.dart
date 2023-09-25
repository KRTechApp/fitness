import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/providers/workout_history_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Utils/shared_preferences_manager.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/member_selection_model.dart';
import '../providers/trainer_provider.dart';
import '../trainer_screen/select_member_list.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/utils_methods.dart';
import 'admin_add_workout_screen.dart';
import 'workout_detail_exercise_screen.dart';
import 'workout_detail_member_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final String userRole;
  final String workoutCreatedBy;

  const WorkoutDetailScreen(
      {Key? key,
      required this.documentSnapshot,
      required this.userRole,
      required this.workoutCreatedBy})
      : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentTab = 0;
  MemberSelectionModel memberSelectionModel = MemberSelectionModel(
      unselectedMember: [], selectedMember: [], alreadySelectedMember: []);
  late WorkoutProvider workoutProvider;
  late WorkoutHistoryProvider workoutHistoryProvider;
  late ShowProgressDialog showProgressDialog;
  late TabController _tabController;
  String userId = "";
  String userRole = "";
  String currentLanguage = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  final random = Random();
  late TrainerProvider trainerProvider;
  late DocumentSnapshot documentSnapshot;
  var tabViewKey = UniqueKey();
  var tab1Key = UniqueKey();
  var tab2Key = UniqueKey();
  var tabControllerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    documentSnapshot = widget.documentSnapshot;
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    workoutHistoryProvider = Provider.of<WorkoutHistoryProvider>(context,listen: false);
    showProgressDialog =
        ShowProgressDialog(barrierDismissible: false, context: context);
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(
      () {
        setState(
          () {
            currentTab = _tabController.index;
            debugPrint("currentTab: $currentTab");
            _tabController.animateTo(currentTab);
          },
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        currentLanguage = await _preference.getValue(prefLanguage, "");
        await workoutHistoryProvider.getTrainerAllWorkout(
          trainerId: userRole == userRoleTrainer
              ? userId
              : widget.documentSnapshot.get(keyCreatedBy),
          isRefresh: true,
        );
        await workoutHistoryProvider.getAllMemberWorkoutHistory(
          trainerId: userRole == userRoleTrainer
              ? userId
              : widget.documentSnapshot.get(keyCreatedBy),
          isRefresh: true,
        );
        getWorkoutDetails();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    debugPrint("tab1Key : $tab1Key");
    debugPrint("tab2Key : $tab2Key");

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
              color: isDarkTheme
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF181A20),
            ),
          ),
        ),
        title: Text(documentSnapshot[keyWorkoutTitle]),
        actions: [
          if (currentTab == 1 && widget.userRole == userRoleTrainer)
            InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () async {
                MemberSelectionModel tempSelectedMember = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectMemberList(
                          memberSelectionModel: memberSelectionModel,
                        ),
                      ),
                    ) ??
                    memberSelectionModel;
                memberSelectionModel = tempSelectedMember;
                showProgressDialog.show();
                await workoutProvider.updateWorkoutMember(
                    currentUserId: documentSnapshot[keyCreatedBy] ?? "",
                    workoutId: documentSnapshot.id,
                    selectMemberList: tempSelectedMember.selectedMember!,
                    unselectMemberList: tempSelectedMember.unselectedMember!,
                    memberCount: tempSelectedMember.selectedMember!.length);
                showProgressDialog.hide();
                getWorkoutDetails();
                debugPrint(
                    'SelectMemberForWorkout :${tempSelectedMember.selectedMember!}');
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  height: 20,
                  width: 20,
                  'assets/images/add_member.svg',
                  color: isDarkTheme
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF181A20),
                ),
              ),
            ),
          if (widget.userRole == userRoleTrainer)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                onSelected: (selection) {
                  switch (selection) {
                    case 0:
                      editWorkout();
                      break;
                    case 1:
                      deletePopup(documentSnapshot);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text(
                        AppLocalizations.of(context)!.edit.firstCapitalize(),
                        style: GymStyle.popupbox),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Text(
                        AppLocalizations.of(context)!.delete.firstCapitalize(),
                        style: GymStyle.popupboxdelate),
                  ),
                ],
                child: Container(
                  height: 35,
                  width: 30,
                  alignment: Alignment.center,
                  child: const Icon(Icons.more_vert,
                      color: ColorCode.backgroundColor),
                ),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                Container(
                  height: 150,
                  width: width,
                  margin: const EdgeInsets.only(
                      left: 15, top: 15, right: 15, bottom: 15),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: StaticData.workoutColorList[
                        random.nextInt(StaticData.workoutColorList.length)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((documentSnapshot[keyWorkoutType] ?? "") ==
                                "free")
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
                                  style: const TextStyle(
                                      color: ColorCode.white, fontSize: 12),
                                ),
                              ),
                            if ((documentSnapshot[keyWorkoutType] ?? "") ==
                                "premium")
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
                                        color: ColorCode
                                            .workoutPremiumMembershipText),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        AppLocalizations.of(context)!.premium,
                                        style: const TextStyle(
                                            color: ColorCode
                                                .workoutPremiumMembershipText,
                                            fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            Text(
                              documentSnapshot[keyWorkoutFor] ?? "",
                              style: GymStyle.containerSubHeader3,
                            ),
                            customMarquee(
                                width: width * 0.52,
                                text: documentSnapshot[keyWorkoutTitle],
                                textStyle: GymStyle.containerHeader2,
                                height: 30),
                            widget.userRole == userRoleAdmin
                                ? Row(
                                    children: [
                                      const Icon(Icons.man_rounded,
                                          color: Colors.white),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: FutureBuilder(
                                          future:
                                              trainerProvider.getTrainerFromId(
                                                  memberId: documentSnapshot
                                                      .get(keyCreatedBy),
                                                  createdBy: userId),
                                          builder: (context,
                                              AsyncSnapshot<DocumentSnapshot?>
                                                  asyncSnapshot) {
                                            if (asyncSnapshot.hasData &&
                                                asyncSnapshot.data != null) {
                                              var queryDoc = asyncSnapshot.data;
                                              return Text(queryDoc![keyName],
                                                  maxLines: 1,
                                                  style: GymStyle
                                                      .containerSubHeader2);
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
                                : Row(
                                    children: [
                                      const Icon(Icons.watch_later_outlined,
                                          color: Colors.white),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 4,
                                        ),
                                        child: Text(
                                            "${((documentSnapshot[keyTotalWorkoutTime] ?? 0) / 60).ceil().toString()} min",
                                            style:
                                                GymStyle.containerSubHeader2),
                                      )
                                    ],
                                  ),
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5.0, top: 4),
                                  child: SvgPicture.asset(
                                    'assets/images/dumbbell.svg',
                                    width: 15,
                                    height: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    '${documentSnapshot[keyExerciseCount] ?? ""} ${AppLocalizations.of(context)!.exercises}',
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
                  right: 5,
                  left: 165,
                  child: Image.asset('assets/images/Circle.png',
                      color: Colors.white, height: 200),
                ),
                Positioned(
                  bottom: 15,
                  right: 14,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: FadeInImage(
                      fit: BoxFit.fill,
                      width: 132,
                      height: 150,
                      image: customImageProvider(
                        url: documentSnapshot[keyProfile],
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
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: isDarkTheme
                        ? ColorCode.socialLoginBackground
                        : ColorCode.tabBarBackground),
                child: DefaultTabController(
                  key: tabControllerKey,
                  initialIndex: currentTab,
                  length: 2,
                  child: Column(
                    children: [
                      SizedBox(
                        width: width,
                        height: 50,
                        child: TabBar(
                          controller: _tabController,
                          onTap: (index) {
                            setState(
                              () {
                                currentTab = index;
                                // _tabController.animateTo(currentTab);
                              },
                            );
                          },
                          // controller: _tabController,
                          indicatorColor: ColorCode.backgroundColor,
                          indicatorPadding: const EdgeInsets.only(
                              top: 46, left: 30, right: 30),
                          tabs: [
                            Tab(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .exercises
                                    .allInCaps,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Tab(
                              child: Text(
                                AppLocalizations.of(context)!.member.allInCaps,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: width,
                        height: height - 313,
                        color: isDarkTheme
                            ? ColorCode.backgroundColor
                            : ColorCode.white,
                        child: TabBarView(
                          key: tabViewKey,
                          controller: _tabController,
                          children: <Widget>[
                            WorkoutDetailExerciseScreen(
                                key: tab1Key,
                                queryDocumentSnapshot: documentSnapshot,
                                workoutCreatedBy: widget.workoutCreatedBy,
                                userRole: widget.userRole,
                                currentLanguage: currentLanguage,
                                showProgressDialog: showProgressDialog),
                            // UpperBodyWorkoutExercise(documentSnapshot: documentSnapshot),
                            WorkoutDetailMemberScreen(
                                key: tab2Key,
                                queryDocumentSnapshot: documentSnapshot,
                                workoutCreatedBy: widget.workoutCreatedBy,
                                userRole: widget.userRole,
                                getWorkoutDetails: getWorkoutDetails,
                                showProgressDialog: showProgressDialog),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  deletePopup(DocumentSnapshot documentSnapshot) {
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
              Text(AppLocalizations.of(context)!.are_you_sure_want_to_delete,
                  style: GymStyle.inputTextBold),
              Text((documentSnapshot[keyWorkoutTitle] ?? "") + '?',
                  style: GymStyle.inputTextBold),
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
                        style: const TextStyle(
                            color: ColorCode.mainColor,
                            fontSize: 17,
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
                        showProgressDialog.show(message: 'Loading...');
                        workoutProvider.deleteWorkout(
                            workoutId: documentSnapshot.id);
                        showProgressDialog.hide();
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.delete.toUpperCase(),
                        style: const TextStyle(
                            color: ColorCode.white,
                            fontSize: 17,
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

  Future<void> getWorkoutDetails() async {
    showProgressDialog.show();
    documentSnapshot = (await workoutProvider.getSingleWorkout(
        workoutId: widget.documentSnapshot.id))!;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey(keySelectedMember)) {
      memberSelectionModel.selectedMember =
          List.castFrom(documentSnapshot.get(keySelectedMember) as List);
    }
    showProgressDialog.hide();
    tabViewKey = UniqueKey();
    tab1Key = UniqueKey();
    tab2Key = UniqueKey();
    tabControllerKey = UniqueKey();
    setState(
      () {},
    );
  }

  Future<void> editWorkout() async {
    bool? isRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAddWorkoutScreen(
          userId: userId,
          userRole: widget.userRole,
          viewType: "edit",
          querySnapshot: documentSnapshot,
        ),
      ),
    );
    debugPrint("AdminAddWorkoutScreen isRefresh = $isRefresh");
    if (isRefresh == true) {
      getWorkoutDetails();
    }
  }
}
