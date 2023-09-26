import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/providers/payment_history_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_category_provider.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../../utils/shared_preferences_manager.dart';
import '../../utils/static_data.dart';
import '../admin_screen/add_workout_category.dart';
import '../admin_screen/admin_workout_category_list_screen.dart';
import '../custom_widgets/custom_card.dart';
import '../custom_widgets/expired_dailog.dart';
import '../custom_widgets/trainer_dashboard_workout.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../mobile_pages/member_workout_detail_screen.dart';
import '../model/global_search_model.dart';
import '../model/workout_days_model.dart';
import '../providers/class_provider.dart';
import '../providers/global_search_provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/workout_provider.dart';
import '../trainer_screen/add_class_screen.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/utils_methods.dart';
import 'join_virtual_class_bottom_sheet_screen.dart';
import 'member_my_exercise_screen.dart';
import 'member_workout_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late WorkoutProvider workoutProvider;
  late MemberProvider memberProvider;
  late PaymentHistoryProvider paymentHistoryProvider;
  late WorkoutCategoryProvider workoutCategoryProvider;
  late ShowProgressDialog showProgressDialog;
  String memberName = "";
  String userRole = "";
  String userId = "";
  String createdBy = "";
  bool searchBarVisible = false;
  List<String> workoutCategoryIdList = [];
  final TextEditingController _textEditingController = TextEditingController();
  late ClassProvider classProvider;
  late GlobalSearchProvider globalSearchProvider;
  late TrainerProvider trainerProvider;

  @override
  void initState() {
    super.initState();
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    classProvider = Provider.of<ClassProvider>(context, listen: false);
    globalSearchProvider = Provider.of<GlobalSearchProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);

    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        memberName = await _preference.getValue(prefName, "");
        userRole = await _preference.getValue(prefUserRole, "");
        userId = await _preference.getValue(prefUserId, "");
        createdBy = await _preference.getValue(prefCreatedBy, "");
        DocumentSnapshot trainerDoc = await trainerProvider.getSingleTrainer(userId: createdBy);

        setPaymentMethodAndKeys(documentSnapshot: trainerDoc, isAdmin: false);

        await _pullRefresh();
        DocumentSnapshot userDoc = await memberProvider.getSelectedMember(memberId: userId);

        if (userDoc[keyCurrentMembership] == null || userDoc[keyCurrentMembership] == "") {
          isExpired = true;
          if (context.mounted) {
            PlanExpiredDialog(context, userRole);
          }
        } else {
          int dateGap;
          int extendedDays;
          int leftMemberShip;
          paymentHistoryProvider
              .getMyPaymentById(
                  createdBy: userDoc[keyCreatedBy],
                  membershipId: userDoc[keyCurrentMembership],
                  createdAt: userDoc[keyMembershipTimestamp],
                  createdFor: userId)
              .then((queryDoc) => {
                    dateGap = DateTime.now()
                        .difference(
                          DateTime.fromMillisecondsSinceEpoch(
                            userDoc.get(keyMembershipTimestamp),
                          ),
                        )
                        .inDays,
                    extendedDays = queryDoc![keyExtendDate],
                    leftMemberShip = (queryDoc[keyPeriod] + extendedDays) - dateGap,
                    debugPrint('leftMemberShip $leftMemberShip'),
                    debugPrint('extendedDays $extendedDays'),
                    debugPrint('dateGap $dateGap'),
                    if (leftMemberShip < 1)
                      {
                        isExpired = true,
                        PlanExpiredDialog(context, userRole),
                      }
                  });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: showExitPopup,
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
          title: Text(AppLocalizations.of(context)!.member),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0),
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                splashColor: ColorCode.linearProgressBar,
                onTap: () async {
                  /* progressDialog.show();
                await updateRowFieldOfTable(tableName: tableUser,key: keyDateOfBirth,value: 1679910361248);
                progressDialog.hide();*/
                  if (isExpired) {
                    PlanExpiredDialog(context, userRole);
                    return;
                  }
                  setState(() {
                    searchBarVisible = !searchBarVisible;
                  });
                },
                child: SvgPicture.asset(
                  height: 25,
                  width: 25,
                  'assets/images/ic_Search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                ),
              ),
            ),
/*            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: SvgPicture.asset(
                height: 20,
                width: 20,
                'assets/images/ic_Filter.svg',
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),*/
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchBarVisible)
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Container(
                      height: 65,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorCode.searchBorder, width: 1.0, style: BorderStyle.solid),
                        color: ColorCode.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14.0),
                        ),
                      ),
                      child: TextField(
                        textAlign: TextAlign.start,
                        cursorColor: ColorCode.mainColor,
                        textAlignVertical: TextAlignVertical.center,
                        controller: _textEditingController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            onSearchTextChanged(value);
                          } else {
                            onSearchTextChanged("");
                          }
                        },
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(fontSize: 17, color: ColorCode.searchHint),
                          hintText: AppLocalizations.of(context)!.search_anything_here,
                          contentPadding: const EdgeInsets.only(left: 20),
                          suffixIcon: SizedBox(
                            width: 60,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14.0),
                                child: Container(
                                  height: 43.0,
                                  width: 43.0,
                                  padding: const EdgeInsets.all(7),
                                  color: ColorCode.tabBarBackground,
                                  child: SvgPicture.asset(
                                    "assets/images/ic_Search.svg",
                                    color: ColorCode.searchBorder,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          // contentPadding: const EdgeInsets.fromLTRB(25, 16, 5, 0),
                        ),
                      ),
                    ),
                  ),
                if (_textEditingController.text.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Consumer<GlobalSearchProvider>(
                      builder: (context, globalSearchData, child) => globalSearchData.globalSearchList.isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: globalSearchData.globalSearchList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final GlobalSearchModel globalSearch = globalSearchData.globalSearchList[index];
                                return InkWell(
                                  onTap: () {
                                    if (globalSearch.type == "memberWorkout") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MemberWorkoutDetailScreen(
                                            documentSnapshot: globalSearch.queryDocument!,
                                            userRole: userRole,
                                            userId: userId,
                                          ),
                                        ),
                                      );
                                    } else if (globalSearch.type == "memberClass") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddClass(
                                            viewType: "view",
                                            documentSnapshot: globalSearch.queryDocument,
                                          ),
                                        ),
                                      );
                                    } else if (globalSearch.type == "memberWorkoutCategory") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddWorkoutCategory(
                                            documentSnapshot: globalSearch.queryDocument,
                                            viewType: "view",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (globalSearch.type == "memberWorkout")
                                        Text(globalSearch.queryDocument![keyWorkoutTitle],
                                            style: GymStyle.globalSearchTitle),
                                      if (globalSearch.type == "memberExercise")
                                        Text(globalSearch.queryDocument![keyExerciseTitle],
                                            style: GymStyle.globalSearchTitle),
                                      if (globalSearch.type == "memberWorkoutCategory")
                                        Text(globalSearch.queryDocument![keyWorkoutCategoryTitle],
                                            style: GymStyle.globalSearchTitle),
                                      if (globalSearch.type == "memberClass")
                                        Text(globalSearch.queryDocument![keyClassName],
                                            style: GymStyle.globalSearchTitle),
                                      Text(
                                        "${AppLocalizations.of(context)!.from} ${getGlobalSearchType(type: globalSearch.type ?? "")}",
                                        style: GymStyle.italicText,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Divider(height: 1, thickness: GymStyle.deviderThiknes)
                                    ],
                                  ),
                                );
                              },
                            )
                          : SizedBox(
                              height: height * 0.8,
                              width: width,
                              child: Center(child: Text(AppLocalizations.of(context)!.no_data_available))),
                    ),
                  ),
                if (_textEditingController.text.trim().isEmpty)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    /* Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "${StaticData.greetingMessage(context)} $memberName !",
                        style: GymStyle.seeAllStyle,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        AppLocalizations.of(context)!.let_s_shape_yourself,
                        style: const TextStyle(
                            fontSize: 28, color: Color(0xFF181A20), fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      ),
                    ),*/
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Stack(
                      children: [
                        Image.asset(
                          'assets/images/demo_img.JPG',
                          width: width,
                          height: 250,
                          fit: BoxFit.fill,
                        ),
                        Positioned(
                          left: 20,
                          top: 20,
                          child: Text(
                            "Hey $memberName,",
                            style: GymStyle.containerUpperText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        """Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.""",
                        style: GymStyle.tabbar.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.program,
                            style: GymStyle.containerUpperText,
                          ),
                          const Spacer(),
                          InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(50),
                            ),
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if (isExpired) {
                                PlanExpiredDialog(context, userRole);
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberWorkoutScreen(userId: userId, userRole: userRole),
                                  ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                AppLocalizations.of(context)!.see_all,
                                style: GymStyle.seeAllStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 191,
                      width: width,
                      child: Consumer<WorkoutProvider>(
                        builder: (context, workoutData, child) => workoutData.selectedMemberWorkout.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.only(left: 15, right: 15),
                                itemCount: workoutData.selectedMemberWorkout.length > 3
                                    ? 3
                                    : workoutData.selectedMemberWorkout.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final QueryDocumentSnapshot documentSnapshot =
                                      workoutData.selectedMemberWorkout[index];
                                  return TrainerDashboardWorkout(
                                    userRole: userRole,
                                    userId: userId,
                                    queryDocumentSnapshot: documentSnapshot,
                                  );
                                },
                              )
                            : Center(
                                child: Text(AppLocalizations.of(context)!.ask_your_trainer_to_assign_workout),
                              ),
                      ),
                    ),
                    /* const SizedBox(
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.workout_categories,
                            style: GymStyle.containerUpperText,
                          ),
                          const Spacer(),
                          InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(50),
                            ),
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if(isExpired){
                                PlanExpiredDialog(context,userRole);
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminWorkoutCategoryListScreen(
                                    userId: userId,
                                    userRole: userRole,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                AppLocalizations.of(context)!.see_all,
                                style: GymStyle.seeAllStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width,
                      height: 201,
                      child: Consumer<WorkoutCategoryProvider>(
                        builder: (context, workoutCategoryData, child) =>
                            workoutCategoryData.myWorkoutCategoryItem.isNotEmpty
                                ? ListView.builder(
                                    padding: const EdgeInsets.only(left: 15, right: 15),
                                    itemCount: workoutCategoryData.myWorkoutCategoryItem.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final QueryDocumentSnapshot documentSnapshot =
                                          workoutCategoryData.myWorkoutCategoryItem[index];
                                      return GestureDetector(
                                        onTap: () {
                                          if(isExpired){
                                            PlanExpiredDialog(context,userRole);
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MemberMyExerciseScreen(
                                                workoutCategoryId: documentSnapshot.id,
                                                userId: userId,
                                                viewType: "",
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 8),
                                                      height: 160,
                                                      width: 175,
                                                      decoration: BoxDecoration(
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(15),
                                                        ),
                                                        color: const Color(0xFF44CB7F).withOpacity(0.30),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 1,
                                                      child: SvgPicture.asset(
                                                        'assets/images/StarDesign.svg',
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(15),
                                                        child: FadeInImage(
                                                          fit: BoxFit.cover,
                                                          width: 175,
                                                          height: 160,
                                                          image: customImageProvider(
                                                            url: documentSnapshot[keyProfile] ?? "",
                                                          ),
                                                          placeholderFit: BoxFit.cover,
                                                          placeholder: customImageProvider(),
                                                          imageErrorBuilder: (context, error, stackTrace) {
                                                            return getPlaceHolder();
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Text(
                                                    documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                                    style: GymStyle.containerLowarText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 15)
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(AppLocalizations.of(context)!.ask_your_trainer_to_assign_workout_category),
                                  ),
                      ),
                    ),
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        AppLocalizations.of(context)!.today_s_class,
                        style: GymStyle.containerUpperText,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Consumer<ClassProvider>(
                      builder: (context, classData, child) => classProvider.classListItem.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              itemCount: classData.classListItem.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final QueryDocumentSnapshot documentSnapshot = classData.classListItem[index];
                                return GestureDetector(
                                  onTap: () {
                                    if(isExpired){
                                      PlanExpiredDialog(context,userRole);
                                      return;
                                    }
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
                                  child: Column(
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
                                                    width: width * 0.35,
                                                    child: documentSnapshot[keyClassName].length > 14
                                                        ? SizedBox(
                                                            width: width * 0.35,
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
                                                    */ /*Text(documentSnapshot[keyClassName] ?? "",
                                                      maxLines: 1, style: GymStyle.listTitle)*/ /*
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.35,
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
                                                    width: width * 0.35,
                                                    child: Text(getSelectedDay(documentSnapshot),
                                                        maxLines: 1, style: GymStyle.listSubTitle),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10),
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
                                  ),
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
                    ),*/
                  ]),
              ],
            ),
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Future<bool> showExitPopup() async {
    bool opened = _scaffoldKey.currentState!.isDrawerOpen;
    var width = MediaQuery.of(context).size.width;
    if (opened) {
      Navigator.pop(context);
      return false;
    }
    bool? isExit = await showGeneralDialog(
      context: context,
      barrierLabel: AppLocalizations.of(context)!.gym_trainer_app,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          contentPadding: const EdgeInsets.all(5.0),
          title: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              AppLocalizations.of(context)!.are_you_sure_you_want_to_exit_from_gym_trainer_app,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins-Bold', color: Color(0xFF0B204C), fontSize: 17),
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () => {Navigator.of(context).pop(true)},
                  child: Text(
                    AppLocalizations.of(context)!.yes.firstCapitalize(),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 17),
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.05,
              ),
              Container(
                width: 100,
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF26950),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    AppLocalizations.of(context)!.no.firstCapitalize(),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 17),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
    if (isExit != null && isExit) {
      return isExit;
    } else {
      return false;
    }
  }

  List<String> getWorkoutCategoryIdList(
      {required WorkoutDaysModel workoutDaysModel, required List<String> tempIdList}) {
    List<String> tempWorkoutCategoryList = [];
    if (workoutDaysModel.exerciseDataList != null) {
      for (int i = 0; i < workoutDaysModel.exerciseDataList!.length; i++) {
        if (!tempIdList.contains(workoutDaysModel.exerciseDataList![i].categoryId ?? "") &&
            !tempWorkoutCategoryList.contains(workoutDaysModel.exerciseDataList![i].categoryId ?? "")) {
          tempWorkoutCategoryList.add(workoutDaysModel.exerciseDataList![i].categoryId ?? "");
        }
      }
    }
    debugPrint('getWorkoutCategoryIdList : ${tempWorkoutCategoryList.length}');
    return tempWorkoutCategoryList;
  }

  onSearchTextChanged(String text) async {
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    globalSearchProvider.getMemberGlobalSearchList(selectedMemberId: userId, isRefresh: true, searchText: text);
    setState(() {});
  }

  String getGlobalSearchType({required String type}) {
    if (type == "memberWorkout") {
      return AppLocalizations.of(context)!.workout;
    } else if (type == "memberClass") {
      return AppLocalizations.of(context)!.class_list;
    } else if (type == "memberExercise") {
      return AppLocalizations.of(context)!.exercises;
    } else if (type == "memberWorkoutCategory") {
      return AppLocalizations.of(context)!.workout_category;
    }
    return "";
  }

  Future<void> _pullRefresh() async {
    showProgressDialog.show();
    // await workoutProvider.getThreeWorkoutForSelectedMember(selectedMemberId: userId);
    await classProvider.getClassByUser(userId: userId);
    workoutProvider.selectedMemberWorkout.clear();
    await workoutProvider.getWorkoutForSelectedMember(selectedMemberId: userId);
    // await workoutCategoryProvider.getWorkoutCategoryList(createdBy: createdBy, isRefresh: true);
    List<WorkoutDaysModel> workoutDaysModelList = [];
    for (int i = 0; i < workoutProvider.selectedMemberWorkout.length; i++) {
      workoutDaysModelList.add(WorkoutDaysModel.fromJson(
        json.decode(
          workoutProvider.selectedMemberWorkout[i][keyWorkoutData],
        ),
      ));
    }
    workoutCategoryIdList.clear();
    for (int i = 0; i < workoutDaysModelList.length; i++) {
      workoutCategoryIdList.addAll(
        getWorkoutCategoryIdList(
          tempIdList: workoutCategoryIdList,
          workoutDaysModel: workoutDaysModelList[i],
        ),
      );
    }

    debugPrint('workoutCategory : $workoutCategoryIdList');
    await workoutCategoryProvider.getSearchMyWorkoutCategory(
        isRefresh: true, workoutCategoryIdList: workoutCategoryIdList, createdBy: createdBy);
    showProgressDialog.hide();
    setState(
      () {},
    );
  }
}
