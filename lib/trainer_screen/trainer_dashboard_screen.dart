import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/payment_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';

import '../../utils/static_data.dart';
import '../admin_screen/add_trainer_package_screen.dart';
import '../admin_screen/add_workout_category.dart';
import '../admin_screen/admin_add_workout_screen.dart';
import '../admin_screen/admin_workout_category_list_screen.dart';
import '../admin_screen/workout_detail_screen.dart';
import '../custom_widgets/admin_popular_packages_item_view.dart';
import '../custom_widgets/exercise_details_bottom_sheet.dart';
import '../custom_widgets/expired_dailog.dart';
import '../custom_widgets/trainer_dashboard_workout.dart';
import '../mobile_pages/admin_workout_list_screen.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../mobile_pages/trainer_package_list_screen.dart';
import '../model/global_search_model.dart';
import '../providers/global_search_provider.dart';
import '../providers/membership_provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/workout_category_provider.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/utils_methods.dart';
import 'member_list.dart';
import 'trainer_add_membership.dart';
import 'trainer_exercise_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late WorkoutProvider workoutProvider;
  late WorkoutCategoryProvider workoutCategoryProvider;
  late TrainerProvider trainerProvider;
  late MembershipProvider membershipProvider;
  late PaymentHistoryProvider paymentHistoryProvider;
  String userId = "";
  String userName = "";
  String userRole = "";
  late ShowProgressDialog progressDialog;
  late GlobalSearchProvider globalSearchProvider;
  bool searchBarVisible = false;
  final TextEditingController _textEditingController = TextEditingController();
  final random = Random();
  String switchRole = "";

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    globalSearchProvider = Provider.of<GlobalSearchProvider>(context, listen: false);
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userName = await _preference.getValue(prefName, "");
        userRole = await _preference.getValue(prefUserRole, "");
        switchRole = await _preference.getValue(keySwitchRole, "");

        await _pullRefresh();
        DocumentSnapshot trainerDoc = await trainerProvider.getSingleTrainer(userId: userId);

        setPaymentMethodAndKeys(documentSnapshot: trainerDoc, isAdmin: false);

        if(switchRole != userRoleAdmin){
          if(trainerDoc[keyCurrentMembership] == null || trainerDoc[keyCurrentMembership] == "") {
            isExpired = true;
            debugPrint('a1a');
            if(context.mounted) {
              PlanExpiredDialog(context, userRole);
            }
          }else{
            int dateGap;
            int extendedDays;
            int leftMemberShip;
            paymentHistoryProvider.getMyPaymentById(createdBy: trainerDoc[keyCreatedBy],membershipId: trainerDoc[keyCurrentMembership],createdAt: trainerDoc[keyMembershipTimestamp],createdFor: userId).then((queryDoc) =>
            {

              dateGap = DateTime.now()
                  .difference(
                DateTime.fromMillisecondsSinceEpoch(
                  trainerDoc.get(keyMembershipTimestamp),
                ),
              ).inDays,
              if(queryDoc != null){
                extendedDays = queryDoc[keyExtendDate],
                leftMemberShip = (queryDoc[keyPeriod] + extendedDays) - dateGap,
                debugPrint('leftMemberShip $leftMemberShip'),
                debugPrint('extendedDays $extendedDays'),
                debugPrint('dateGap $dateGap'),
                if(leftMemberShip < 1){
                  isExpired = true,
                  debugPrint('b2b'),
                  PlanExpiredDialog(context,userRole),
                }
              },
            });
          }
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
          title: Text(AppLocalizations.of(context)!.trainer),
          actions: [
            InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () async {
             /* progressDialog.show();
                await updateRowFieldOfTable(tableName: tableWorkoutHistory, key: keyExerciseProgress,value:"0.3333333333333333");
                progressDialog.hide();*/

               /* progressDialog.show();
                await deleteAllTableData(tableName: tableWorkout, excludeCount: 1);
                progressDialog.hide();*/
                if(isExpired){
                  PlanExpiredDialog(context,userRole);
                  return;
                }
                setState(() {
                  searchBarVisible = !searchBarVisible;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0,left: 20.0),
                child: SvgPicture.asset(
                  height: 25,
                  width: 25,
                  'assets/images/ic_Search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                ),
              ),
            ),
            /*Padding(
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
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchBarVisible)
                  Container(
                    height: 65,
                    margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
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
                if (_textEditingController.text.trim().isNotEmpty)
                  Consumer<GlobalSearchProvider>(
                      builder: (context, globalSearchData, child) => globalSearchData.globalSearchList.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              itemCount: globalSearchData.globalSearchList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final GlobalSearchModel globalSearch = globalSearchData.globalSearchList[index];
                                return InkWell(
                                  onTap: () {
                                    if (globalSearch.type == "member") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const MemberList(),
                                        ),
                                      );
                                    } else if (globalSearch.type == "membership") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddTrainerPackageScreen(
                                            documentSnapshot: globalSearch.queryDocument,
                                            viewType: "view",
                                          ),
                                        ),
                                      );
                                    } else if (globalSearch.type == "workout") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WorkoutDetailScreen(
                                              documentSnapshot: globalSearch.queryDocument!,
                                              userRole: userRole,
                                              workoutCreatedBy: globalSearch.queryDocument![keyCreatedBy]),
                                        ),
                                      );
                                    } else if (globalSearch.type == "exercise") {
                                      showModalBottomSheet(
                                        context: context,
                                        enableDrag: false,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                        ),
                                        builder: (context) => ExerciseDetailsBottomSheet(
                                            exerciseDataModel: null,
                                            queryDocumentSnapshot: globalSearch.queryDocument!),
                                      );
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (globalSearch.type == "membership")
                                        Text(globalSearch.queryDocument![keyMembershipName],
                                            style: GymStyle.globalSearchTitle),
                                      if (globalSearch.type == "member")
                                        Text(globalSearch.queryDocument![keyName], style: GymStyle.globalSearchTitle),
                                      if (globalSearch.type == "workout")
                                        Text(globalSearch.queryDocument![keyWorkoutTitle],
                                            style: GymStyle.globalSearchTitle),
                                      if (globalSearch.type == "exercise")
                                        Text(globalSearch.queryDocument![keyExerciseTitle],
                                            style: GymStyle.globalSearchTitle),
                                      Text(
                                        "From ${getGlobalSearchType(type: globalSearch.type ?? "")}",
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
                          :
                      SizedBox(
                            height: height * 0.8,
                            width: width,
                            child: Center(child: Text(AppLocalizations.of(context)!.no_data_available))),
                  ),
                if (_textEditingController.text.trim().isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "${StaticData.greetingMessage(context)} $userName !",
                          style: GymStyle.seeAllStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
                        child: Text(
                          AppLocalizations.of(context)!.let_s_shape_yourself,
                          style: const TextStyle(
                              fontSize: 28,
                              color: Color(0xFF181A20),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.workout,
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
                                    builder: (context) =>  const AdminWorkoutList(
                                        // userId: userId, userRole: userRole,
                                        viewType: "",trainerId: "",drawerList: true),
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
                        height: 191,
                        width: width,
                        child: Consumer<WorkoutProvider>(
                          builder: (context, workoutData, child) => workoutData.selectedMemberWorkout.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  itemCount: workoutData.selectedMemberWorkout.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final QueryDocumentSnapshot documentSnapshot =
                                        workoutData.selectedMemberWorkout[index];
                                    return TrainerDashboardWorkout(
                                      userRole: userRole,
                                      queryDocumentSnapshot: documentSnapshot,
                                      userId: userId,
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if(isExpired){
                                            PlanExpiredDialog(context,userRole);
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminAddWorkoutScreen(
                                                  userId: userId, userRole: userRole, viewType: ""),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: ColorCode.tabDivider,
                                          maxRadius: 25,
                                          child: SvgPicture.asset('assets/images/ic_add.svg', height: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 17.0, right: 17, top: 10),
                                        child: Text(
                                          AppLocalizations.of(context)!.you_do_not_have_any_workout,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: GymStyle.dashbordNodataText,
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.tap_to_add.firstCapitalize(),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: GymStyle.dashbordNodataText,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
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
                        height: 206,
                        child: Consumer<WorkoutCategoryProvider>(
                          builder: (context, workoutCategoryData, child) => workoutCategoryProvider
                                  .workoutCategoryItem.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  itemCount: workoutCategoryData.workoutCategoryItem.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final QueryDocumentSnapshot documentSnapshot =
                                        workoutCategoryData.workoutCategoryItem[index];
                                    Color bgColor = StaticData.colorList[random.nextInt(StaticData.colorList.length)];
                                    return InkWell(
                                      onTap: () {
                                        if(isExpired){
                                          PlanExpiredDialog(context,userRole);
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TrainerExerciseScreen(
                                              workoutCategoryId: documentSnapshot.id,
                                              workoutCategoryName: documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                              viewType: "",
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Directionality(
                                                textDirection: TextDirection.ltr,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 8),
                                                      height: 160,
                                                      width: 175,
                                                      decoration: BoxDecoration(
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(15),
                                                        ),
                                                        color: bgColor.withOpacity(0.50),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        bottom: -1,
                                                        child: SvgPicture.asset(
                                                          'assets/images/StarDesign.svg',
                                                          color: bgColor.withOpacity(0.90),
                                                        )),
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
                                              Padding(
                                                padding: const EdgeInsets.only(top: 5,bottom: 10),
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if(isExpired){
                                            PlanExpiredDialog(context,userRole);
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const AddWorkoutCategory(
                                                documentSnapshot: null,
                                                viewType: "Add",
                                              ),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: ColorCode.tabDivider,
                                          maxRadius: 25,
                                          child: SvgPicture.asset('assets/images/ic_add.svg', height: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 17.0, right: 17, top: 10),
                                        child: Text(
                                          AppLocalizations.of(context)!.you_do_not_have_any_workout_category,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: GymStyle.dashbordNodataText,
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.tap_to_add.firstCapitalize(),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: GymStyle.dashbordNodataText,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15,bottom: 10),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.my_membership,
                              style: GymStyle.containerUpperText,
                            ),
                            const Spacer(),
                            InkWell(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                              onTap: () {
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  const TrainerPackageListScreen(drawerList: true),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(AppLocalizations.of(context)!.see_all, style: GymStyle.seeAllStyle),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 157,
                        width: width,
                        child: Consumer<MembershipProvider>(
                          builder: (context, packagesData, child) => packagesData.membershipListItem.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  itemCount: packagesData.membershipListItem.length > 3
                                      ? 3
                                      : packagesData.membershipListItem.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final QueryDocumentSnapshot documentSnapshot =
                                        packagesData.membershipListItem[index];
                                    return AdminPopularPackagesItemView(
                                      documentSnapshot: documentSnapshot,
                                      userRole: userRole,
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if(isExpired){
                                            PlanExpiredDialog(context,userRole);
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const TrainerAddMemberShip(
                                                documentSnapshot: null,
                                                viewType: "Add",
                                              ),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: ColorCode.tabDivider,
                                          maxRadius: 25,
                                          child: SvgPicture.asset('assets/images/ic_add.svg', height: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 17.0, right: 17, top: 10),
                                        child: Text(
                                          AppLocalizations.of(context)!.you_do_not_have_any_membership,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: GymStyle.dashbordNodataText,
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.tap_to_add.firstCapitalize(),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: GymStyle.dashbordNodataText,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  )
              ],
            ),
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Future<bool> showExitPopup() async {
    var width = MediaQuery.of(context).size.width;
    bool opened = _scaffoldKey.currentState!.isDrawerOpen;
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
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () => {Navigator.of(context).pop(true)},
                  child: Text(
                    AppLocalizations.of(context)!.yes,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 17),
                  ),
                ),
              ),
              SizedBox(width: width * 0.05),
              Container(
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF26950),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    AppLocalizations.of(context)!.no,
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

  onSearchTextChanged(String text) async {
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    globalSearchProvider.getTrainerGlobalSearchList(currentUserId: userId, searchText: text);
    setState(() {});
  }

  String getGlobalSearchType({required String type}) {
    if (type == "membership") {
      return AppLocalizations.of(context)!.membership;
    } else if (type == "member") {
      return AppLocalizations.of(context)!.member;
    } else if (type == "workout") {
      return AppLocalizations.of(context)!.workout;
    } else if (type == "exercise") {
      return AppLocalizations.of(context)!.exercises;
    }
    return "";
  }

  Future<void> _pullRefresh() async {
    progressDialog.show();
    await workoutProvider.getThreeWorkoutForCreatedBy(createdBy: userId);
    await workoutCategoryProvider.getWorkoutCategoryList(isRefresh: true, createdBy: userId);
    membershipProvider.membershipListItem.clear();
    await membershipProvider.getMembershipList(createdById: userId);
    progressDialog.hide();
    setState(
      () {},
    );
  }
}
