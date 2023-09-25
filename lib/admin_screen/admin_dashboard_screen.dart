import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/admin_popular_packages_item_view.dart';
import '../main.dart';
import '../mobile_pages/admin_workout_list_screen.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../mobile_pages/trainer_package_list_screen.dart';
import '../mobile_pages/trainer_profile_screen_old.dart';
import '../model/global_search_model.dart';
import '../providers/global_search_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/color_code.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'add_trainer_package_screen.dart';
import 'new_members_screen.dart';
import 'trainer_list_screen.dart';
import 'workout_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late MembershipProvider membershipProvider;
  late GlobalSearchProvider globalSearchProvider;
  late WorkoutProvider workoutProvider;
  late TrainerProvider trainerProvider;
  final random = Random();
  late ShowProgressDialog showProgressDialog;
  bool searchBarVisible = false;
  String userName = "";
  String userId = "";
  String userRole = "";
  String currentLanguageCode = "";
  NumberFormat formatter = NumberFormat("00");
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    membershipProvider =
        Provider.of<MembershipProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    showProgressDialog =
        ShowProgressDialog(barrierDismissible: false, context: context);
    globalSearchProvider =
        Provider.of<GlobalSearchProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userName = await _preference.getValue(prefName, "");
      userId = await _preference.getValue(prefUserId, "");
      userRole = await _preference.getValue(prefUserRole, "");
      currentLanguageCode = await _preference.getValue(prefLanguage, "");
      // trainerProvider.getOwnTrainer(currentUserId: userId);
      _pullRefresh();
    });
  }

/*  void onDrawerSelected(bool drawerOpen) {
    if (drawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    } else {
      _scaffoldKey.currentState!.openEndDrawer();
    }
  }*/

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
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            splashColor: ColorCode.linearProgressBar,
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Center(
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
          ),
          title: Text(AppLocalizations.of(context)!.admin),
          actions: [
            InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                setState(() {
                  searchBarVisible = !searchBarVisible;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SvgPicture.asset('assets/images/ic_Search.svg',
                    width: 25, height: 25),
              ),
            ),
          ],
          // elevation: 5,
        ),
        body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchBarVisible)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: 65,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: ColorCode.searchBorder,
                            width: 1.0,
                            style: BorderStyle.solid),
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
                          hintStyle: const TextStyle(
                              fontSize: 17, color: ColorCode.searchHint),
                          hintText: AppLocalizations.of(context)!
                              .search_anything_here,
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
                  Consumer<GlobalSearchProvider>(
                    builder: (context, globalSearchData, child) =>
                        globalSearchData.globalSearchList.isNotEmpty
                            ? ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                itemCount:
                                    globalSearchData.globalSearchList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final GlobalSearchModel globalSearch =
                                      globalSearchData.globalSearchList[index];
                                  return InkWell(
                                    onTap: () {
                                      if (globalSearch.type == "trainer") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TrainerProfileScreenOld(
                                              trainerId: globalSearch
                                                  .queryDocument!.id,
                                            ),
                                          ),
                                        );
                                      } else if (globalSearch.type ==
                                          "membership") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddTrainerPackageScreen(
                                              documentSnapshot:
                                                  globalSearch.queryDocument,
                                              viewType: "view",
                                            ),
                                          ),
                                        );
                                      } else if (globalSearch.type ==
                                          "workout") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WorkoutDetailScreen(
                                                    documentSnapshot:
                                                        globalSearch
                                                            .queryDocument!,
                                                    userRole: userRole,
                                                    workoutCreatedBy:
                                                        globalSearch
                                                                .queryDocument![
                                                            keyCreatedBy]),
                                          ),
                                        );
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (globalSearch.type == "membership")
                                          Text(
                                              globalSearch.queryDocument![
                                                  keyMembershipName],
                                              style:
                                                  GymStyle.globalSearchTitle),
                                        if (globalSearch.type == "trainer")
                                          Text(
                                              globalSearch
                                                  .queryDocument![keyName],
                                              style:
                                                  GymStyle.globalSearchTitle),
                                        if (globalSearch.type == "workout")
                                          Text(
                                              globalSearch.queryDocument![
                                                  keyWorkoutTitle],
                                              style:
                                                  GymStyle.globalSearchTitle),
                                        Text(
                                          "${AppLocalizations.of(context)!.from} ${getGlobalSearchType(type: globalSearch.type ?? "")}",
                                          style: GymStyle.italicText,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                            height: 1,
                                            thickness: GymStyle.deviderThiknes)
                                      ],
                                    ),
                                  );
                                },
                              )
                            : SizedBox(
                                height: height * 0.8,
                                width: width,
                                child: Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .no_data_available))),
                  ),
                if (_textEditingController.text.trim().isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${StaticData.greetingMessage(context)} $userName !",
                              style: GymStyle.seeAllStyle,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .let_s_shape_yourself,
                              style: const TextStyle(
                                  fontSize: 28,
                                  color: Color(0xFF181A20),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            /*Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                decoration: BoxDecoration(
                    color: const Color(0xffEE7650).withOpacity(0.20),
                    borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                    children: [
                      Text(
                        'New member request',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: GymStyle.listTitle2,
                      ),
                      Spacer(),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorCode.circleProgressBar, width: 6),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: FutureBuilder<QuerySnapshot>(
                              // <2> Pass `Future<QuerySnapshot>` to future
                              future: FirebaseFirestore.instance
                                  .collection(tableUser)
                                  .where(keyAccountStatus, isEqualTo: accountRequested)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                                  return Center(
                                    child: Text(formatter.format(documents.length),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: ColorCode.circleProgressBar,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500)),
                                  );
                                }
                                return CircularProgressIndicator();
                              }),
                        ),
                      ),
                    ],
                ),
              ),
              SizedBox(
                height: height * 0.015,
              ),*/
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TrainerListScreen()));
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          height: height * 0.15,
                                          width: width * 0.438,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15)),
                                            color: const Color(0xFFFF8400)
                                                .withOpacity(0.3),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Consumer<TrainerProvider>(
                                                  builder: (context, value,
                                                          child) =>
                                                      FutureBuilder(
                                                          // <2> Pass `Future<QuerySnapshot>` to future
                                                          key: UniqueKey(),
                                                          future: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  tableUser)
                                                              .where(
                                                                  keyCreatedBy,
                                                                  isEqualTo:
                                                                      userId)
                                                              .where(
                                                                  keyUserRole,
                                                                  isEqualTo:
                                                                      userRoleTrainer)
                                                              .get(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .hasData &&
                                                                snapshot.data !=
                                                                    null) {
                                                              final List<
                                                                      DocumentSnapshot>
                                                                  documents =
                                                                  snapshot.data!
                                                                      .docs;
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            12),
                                                                child: Text(
                                                                    "${documents.length}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            30,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              );
                                                            }
                                                            return const CircularProgressIndicator();
                                                          }),
                                                ),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .total_trainer,
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          )),
                                      Positioned(
                                        bottom: 0,
                                        child: SvgPicture.asset(
                                            'assets/images/StarDesign.svg',
                                            width: width * 0.43,
                                            color: const Color(0xFFFF8400)
                                                .withOpacity(0.3)),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const NewMemberScreen()));
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        height: height * 0.15,
                                        width: width * 0.438,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            color: ColorCode.linearProgressBar),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FutureBuilder<QuerySnapshot>(
                                                  // <2> Pass `Future<QuerySnapshot>` to future
                                                  future: FirebaseFirestore
                                                      .instance
                                                      .collection(tableUser)
                                                      .where(keyUserRole,
                                                          isEqualTo:
                                                              userRoleMember)
                                                      .get(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData &&
                                                        snapshot.data != null) {
                                                      final List<
                                                              DocumentSnapshot>
                                                          documents =
                                                          snapshot.data!.docs;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 12),
                                                        child: Text(
                                                            "${documents.length}",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontSize: 30,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      );
                                                    }
                                                    return const CircularProgressIndicator();
                                                  }),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .total_member,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                          bottom: 1,
                                          right: 0,
                                          child: SvgPicture.asset(
                                              'assets/images/star_design_yoga.svg',
                                              width: width * 0.43,
                                              color: const Color(0xFF6691FF)
                                                  .withOpacity(0.30))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 7, left: 15),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.popular_workout,
                              style: GymStyle.containerUpperText,
                            ),
                            const Spacer(),
                            InkWell(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              splashColor: ColorCode.linearProgressBar,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AdminWorkoutList(
                                              viewType: "",
                                              trainerId: "",
                                              drawerList: true,
                                            )));
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
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: width,
                        height: 202,
                        child: Consumer<WorkoutProvider>(
                            builder: (context, workoutData, child) =>
                                workoutData.popularWorkout.isNotEmpty
                                    ? ListView.builder(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        itemCount:
                                            workoutData.popularWorkout.length,
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final QueryDocumentSnapshot
                                              documentSnapshot =
                                              workoutData.popularWorkout[index];
                                          Color bgColor = StaticData.colorList[
                                              random.nextInt(
                                                  StaticData.colorList.length)];
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      WorkoutDetailScreen(
                                                          documentSnapshot:
                                                              documentSnapshot,
                                                          userRole: userRole,
                                                          workoutCreatedBy:
                                                              documentSnapshot[
                                                                  keyCreatedBy]),
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
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(top: 8),
                                                          height: 160,
                                                          width: 175,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                const BorderRadius
                                                                        .all(
                                                                    Radius
                                                                        .circular(
                                                                            15)),
                                                            color: bgColor
                                                                .withOpacity(
                                                                    0.50),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 1,
                                                          left: 1,
                                                          child: SvgPicture.asset(
                                                              'assets/images/admin_ellipse.svg',
                                                              width: 172,
                                                              color: bgColor
                                                                  .withOpacity(
                                                                      0.60)),
                                                        ),
                                                        Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              child:
                                                                  FadeInImage(
                                                                fit: BoxFit
                                                                    .fitHeight,
                                                                width: 175,
                                                                height: 160,
                                                                image:
                                                                    customImageProvider(
                                                                  url: documentSnapshot[
                                                                          keyProfile] ??
                                                                      "",
                                                                ),
                                                                placeholderFit:
                                                                    BoxFit
                                                                        .fitWidth,
                                                                placeholder:
                                                                    customImageProvider(),
                                                                imageErrorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return getPlaceHolder();
                                                                },
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Text(
                                                        documentSnapshot[
                                                                keyWorkoutTitle] ??
                                                            "",
                                                        style: GymStyle
                                                            .containerLowarText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                )
                                                /*Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 8),
                                          height: 160,
                                          width: 175,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            color: Color(0xFF7A26FF).withOpacity(0.3),
                                          ),
                                        ),
                                        Positioned(
                                          child: SvgPicture.asset('assets/images/admin_ellipse.svg',width: 172,
                                              color: Colors.deepPurpleAccent.withOpacity(0.3)),
                                          bottom: 1,left: 1,
                                        ),
                                        Positioned(child: Image.asset('assets/images/Femail_Yoga.png'), left: 30),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text('Yoga', style: GymStyle.containerLowarText),
                                    ),
                                  ],
                                ),
                                  ),*/
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .no_data_available),
                                      )),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 7),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.popular_packages,
                              style: GymStyle.containerUpperText,
                            ),
                            const Spacer(),
                            InkWell(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              splashColor: ColorCode.linearProgressBar,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TrainerPackageListScreen(
                                              drawerList: true,
                                            )));
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
                        height: 165,
                        width: width,
                        child: Consumer<MembershipProvider>(
                          builder: (context, popularPackageData, child) =>
                              popularPackageData.popularMembership.isNotEmpty
                                  ? ListView.builder(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 15),
                                      itemCount: popularPackageData
                                          .popularMembership.length,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final QueryDocumentSnapshot
                                            documentSnapshot =
                                            popularPackageData
                                                .popularMembership[index];
                                        return AdminPopularPackagesItemView(
                                          documentSnapshot: documentSnapshot,
                                          userRole: userRole,
                                        );
                                      })
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AddTrainerPackageScreen(
                                                    documentSnapshot: null,
                                                    viewType: "Add",
                                                  ),
                                                ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  ColorCode.tabDivider,
                                              maxRadius: 25,
                                              child: SvgPicture.asset(
                                                  'assets/images/ic_add.svg',
                                                  height: 15),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0, right: 17, top: 10),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .you_do_not_have_any_membership,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style:
                                                  GymStyle.dashbordNodataText,
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .tap_to_add
                                                .firstCapitalize(),
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
                        height: height * 0.1,
                      ),
                    ],
                  ),
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
              AppLocalizations.of(context)!
                  .are_you_sure_you_want_to_exit_from_gym_trainer_app,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Poppins-Bold',
                  color: Color(0xFF0B204C),
                  fontSize: 17),
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
                  onPressed: () => {
                    Navigator.of(context).pop(true),
                  },
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
    globalSearchProvider.getGlobalSearchList(
        currentUserId: userId, searchText: text, isRefresh: true);
    setState(() {});
  }

  String getGlobalSearchType({required String type}) {
    if (type == "membership") {
      return AppLocalizations.of(context)!.membership;
    } else if (type == "trainer") {
      return AppLocalizations.of(context)!.trainer;
    } else if (type == "workout") {
      return AppLocalizations.of(context)!.workout;
    }
    return "";
  }

  Widget getHighlightWord(
      {required String title, required String highLightText}) {
    var parts = title.split(highLightText);
    debugPrint("getHighlightWord : $title");
    debugPrint("getHighlightWord : $highLightText");
    debugPrint("getHighlightWord : $parts");
    return Text.rich(
      TextSpan(
        text: parts.length == 1 ? "" : parts[0],
        style: GymStyle.globalSearchTitle, // default text style
        children: <TextSpan>[
          TextSpan(
              text: highLightText, style: GymStyle.globalSearchTitleHighLight),
          TextSpan(
              text: parts.length == 1 ? parts[0] : "",
              style: GymStyle.globalSearchTitle),
          TextSpan(
              text: parts.length > 1 ? parts[1] : "",
              style: GymStyle.globalSearchTitle),
        ],
      ),
    );
  }

  Future<void> _pullRefresh() async {
    showProgressDialog.show();
    await membershipProvider.getPopularMembership(currentUserId: userId);
    await workoutProvider.getPopularWorkout();
    showProgressDialog.hide();
    setState(
      () {},
    );
  }
}
