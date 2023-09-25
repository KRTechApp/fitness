// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../../providers/class_provider.dart';
import '../Utils/shared_preferences_manager.dart';
import '../admin_screen/admin_dashboard_screen.dart';
import '../custom_widgets/custom_calendar_app_demo.dart';
import '../custom_widgets/custom_card.dart';
import '../member_screen/dashboard_screen.dart';
import '../member_screen/join_virtual_class_bottom_sheet_screen.dart';
import '../trainer_screen/add_class_screen.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import 'main_drawer_screen.dart';

class TrainerClassListScreen extends StatefulWidget {
  const TrainerClassListScreen({Key? key}) : super(key: key);

  @override
  State<TrainerClassListScreen> createState() => _TrainerClassListScreenState();
}

class _TrainerClassListScreenState extends State<TrainerClassListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late ClassProvider classProvider;
  bool searchVisible = false;
  var textSearchController = TextEditingController();
  late ShowProgressDialog progressDialog;
  NumberFormat formatter = NumberFormat("00");
  var selectedDateTime = DateTime.now();
  late final QueryDocumentSnapshot queryDocumentSnapshot;
  String userRole = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";

  //drawer open-close
  void onDrawerSelected(bool drawerOpen) {
    if (drawerOpen) {
      scaffoldKey.currentState!.openDrawer();
    } else {
      scaffoldKey.currentState!.openEndDrawer();
    }
  }

  @override
  void initState() {
    super.initState();
    classProvider = Provider.of<ClassProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        setState(
          () {},
        );
        progressDialog.show();
        if (userRole == userRoleMember) {
          await classProvider.getClassByUser(userId: userId);
        } else {
          await classProvider.getSearchTrainerClassList(currentUserId: userId, isRefresh: true);
        }
        progressDialog.hide();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        userRole == userRoleTrainer
            ? Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const TrainerDashboardScreen()),
                (Route<dynamic> route) => false)
            : userRole == userRoleAdmin
            ? Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                (Route<dynamic> route) => false)
            : Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (Route<dynamic> route) => false);

        return Future.value(true);
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 48,
          leading: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
            splashColor: const Color(0xFFB7C8FF),
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
              child: SvgPicture.asset(
                'assets/images/appbar_menu.svg',
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),
          ),
          title: Text(AppLocalizations.of(context)!.class_schedule),
          actions: [
            InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                setState(
                  () {
                    searchVisible = !searchVisible;
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  height: 23,
                  width: 23,
                  'assets/images/search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                ),
              ),
            ),
            if (userRole != userRoleMember)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                  splashColor: ColorCode.linearProgressBar,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddClass(
                          viewType: "",
                          documentSnapshot: null,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      'assets/images/ic_add.svg',
                      height: 21,
                      width: 21,
                      color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            if (searchVisible)
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Card(
                  // elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFD9E1ED),
                    ),
                  ),
                  child: TextField(
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.center,
                    controller: textSearchController,
                    cursorColor: ColorCode.mainColor,
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) {
                        onSearchTextChanged(
                          value.trim(),
                        );
                      } else {
                        onSearchTextChanged("");
                      }
                    },
                    decoration: InputDecoration(
                      hintStyle: GymStyle.searchbox,
                      hintText: AppLocalizations.of(context)!.search_class_list,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        child: SvgPicture.asset(
                          "assets/images/SearchIcon.svg",
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
              child: SizedBox(
                height: 120,
                width: width,
                child: CustomCalendarAppDemo(
                  currentView: CalendarViews.week,
                  onDateChange: onDateChange,
                  measurementList: const [],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: SizedBox(
                height: searchVisible ? height * 0.71 - 70 : height * 0.71,
                width: width,
                child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  color: ColorCode.mainColor,
                  child: userRole == userRoleTrainer
                      ? Consumer<ClassProvider>(
                          builder: (context, classData, child) => getAllTodayClassList(classData.classListItem).isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.only(top: 15),
                                  itemCount: getAllTodayClassList(classData.classListItem).length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final QueryDocumentSnapshot documentSnapshot =
                                        getAllTodayClassList(classData.classListItem)[index];
                                    debugPrint("documentSnapshot list :${documentSnapshot.id}");
                                    debugPrint("${documentSnapshot[keyClassType]}");
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AddClass(
                                                  viewType: "edit",
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
                                                          'assets/images/Member.svg',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        width: width * 0.4,
                                                        child:
                                                        documentSnapshot[keyClassName].length > 16 ?
                                                        SizedBox(
                                                          width: width * 0.52,
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
                                                        ):
                                                        Text(
                                                          documentSnapshot[keyClassName] ?? "",
                                                          style: GymStyle.listTitle,
                                                        ),
                                                        /*Text(documentSnapshot[keyClassName] ?? "",
                                                            maxLines: 1, style: GymStyle.listTitle),*/
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.01,
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.38,
                                                        child: RichText(
                                                          text: TextSpan(
                                                            text: documentSnapshot[keyStartTime] ?? "",
                                                            style: GymStyle.listSubTitle,
                                                            children: <TextSpan>[
                                                              const TextSpan(
                                                                text: '-',
                                                              ),
                                                              TextSpan(
                                                                  text: documentSnapshot[keyEndTime] ?? 0,
                                                                  style: GymStyle.listSubTitle),
                                                              const TextSpan(
                                                                text: ' | ',
                                                              ),
                                                              TextSpan(
                                                                text: formatter.format(
                                                                    List.castFrom(documentSnapshot.get(keySelectedMember))
                                                                        .length),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  SizedBox(
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
                                                            : "View".allInCaps,
                                                        style: GymStyle.startButton,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.015,
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (userRole != userRoleMember) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddClass(
                                                viewType: "",
                                                documentSnapshot: null,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: ColorCode.tabDivider,
                                        maxRadius: 45,
                                        child: SvgPicture.asset(
                                          'assets/images/ic_add.svg',
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                      child: Text(
                                        AppLocalizations.of(context)!.you_do_not_have_any_class,
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
                                      AppLocalizations.of(context)!.tap_to_add.firstCapitalize(),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: ColorCode.listSubTitle,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )),
                        )
                      : Consumer<ClassProvider>(
                          builder: (context, classData, child) => getAllTodayClassList(classData.classListItem).isNotEmpty
                              ? ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: getAllTodayClassList(classData.classListItem).length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final QueryDocumentSnapshot documentSnapshot =
                                        getAllTodayClassList(classData.classListItem)[index];
                                    debugPrint("documentSnapshot list :${documentSnapshot.id}");
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: height * 0.015,
                                        ),
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
                                                        'assets/images/Member.svg',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      width: width * 0.34,
                                                      child: documentSnapshot[keyClassName].length > 12 ?
                                                      SizedBox(
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
                                                      ):
                                                      Text(
                                                        documentSnapshot[keyClassName] ?? "",
                                                        style: GymStyle.listTitle,
                                                      ),
                                                      /*Text(documentSnapshot[keyClassName] ?? "",
                                                          maxLines: 1, style: GymStyle.listTitle),*/
                                                    ),
                                                    SizedBox(
                                                      height: height * 0.01,
                                                    ),
                                                    SizedBox(
                                                      width: width * 0.38,
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
                                                           /* const TextSpan(
                                                              text: '|',
                                                            ),*/
                                                            /* TextSpan(
                                                              text: documentSnapshot[keySelectedMember].length,
                                                            ),*/
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                SizedBox(
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
                                                          : "View".allInCaps,
                                                      style: GymStyle.startButton,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : userRole == userRoleMember
                                  ? Center(
                                      child: Column(
                                        children: [
                                          const Spacer(),
                                          CircleAvatar(
                                            backgroundColor: ColorCode.tabDivider,
                                            maxRadius: 45,
                                            child: Image.asset('assets/images/empty_box.png'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                            child: Text(
                                              AppLocalizations.of(context)!.you_do_not_have_any_class,
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
                                          const Spacer(),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (userRole != userRoleMember) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddClass(
                                                    viewType: "",
                                                    documentSnapshot: null,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: ColorCode.tabDivider,
                                            maxRadius: 45,
                                            child: SvgPicture.asset(
                                              'assets/images/ic_add.svg',
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                          child: Text(
                                            AppLocalizations.of(context)!.you_do_not_have_any_class,
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
                                          AppLocalizations.of(context)!.tap_to_add.firstCapitalize(),
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            color: ColorCode.listSubTitle,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    )),
                        ),
                ),
              ),
            ),
          ],
        ),
        drawer: MainDrawerScreen(scaffoldKey: scaffoldKey),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    classProvider.classListItem.clear();
    if (userRole == userRoleMember) {
      classProvider.getClassByUser(userId: userId,searchText: text,isRefresh: true);
    } else {
      classProvider.getSearchTrainerClassList(currentUserId: userId, isRefresh: true);
    }  }

  Future<void> _pullRefresh() async {
    progressDialog.show();
    if (userRole == userRoleMember) {
      classProvider.getClassByUser(userId: userId);
    } else {
      classProvider.getSearchTrainerClassList(currentUserId: userId, isRefresh: true);
    }    progressDialog.hide();
  }

  void onDateChange(DateTime tempDate, QueryDocumentSnapshot? document) {
    setState(
      () {
        selectedDateTime = tempDate;
      },
    );
  }

  List<QueryDocumentSnapshot> getAllTodayClassList(List<QueryDocumentSnapshot> tempDocList) {
    List<QueryDocumentSnapshot> allTodayClassList = [];

    for (var classItem in tempDocList) {
      List<int> selectDayList = List.castFrom(classItem[keySelectedDays] as List);
      debugPrint('selectDayList ${selectDayList.toString()}');
      debugPrint('selectTodayDay ${selectTodayDay.toString()}');
      if (selectedDateTime.isAfter(
            DateTime.fromMillisecondsSinceEpoch(classItem[keyStartDate]),
          ) &&
          selectedDateTime.isBefore(
            DateTime.fromMillisecondsSinceEpoch(
              classItem[keyEndDate],
            ),
          ) &&
          selectDayList.contains(
            selectTodayDay(selectedDateTime),
          )) {
        allTodayClassList.add(classItem);
      } else if ((selectedDateTime.isSameDate(DateTime.fromMillisecondsSinceEpoch(
                classItem[keyStartDate],
              )) ||
              selectedDateTime.isSameDate(DateTime.fromMillisecondsSinceEpoch(
                classItem[keyEndDate],
              ))) &&
          selectDayList.contains(
            selectTodayDay(selectedDateTime),
          )) {
        allTodayClassList.add(classItem);
      }
    }
    return allTodayClassList;
  }

  int selectTodayDay(DateTime selectedDay) {
    String formattedDate = DateFormat('EEEE').format(selectedDay);
    debugPrint('Today is $formattedDate');
    switch (formattedDate) {
      case "Sunday":
        return 0;
      case "Monday":
        return 1;
      case "Tuesday":
        return 2;
      case "Wednesday":
        return 3;
      case "Thursday":
        return 4;
      case "Friday":
        return 5;
      case "Saturday":
        return 6;
    }
    return 0;
  }
}
