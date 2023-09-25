import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/Utils/color_code.dart';
import 'package:crossfit_gym_trainer/Utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/custom_widgets/custom_calendar_app_demo.dart';
import 'package:crossfit_gym_trainer/custom_widgets/nutrition_list_item_view.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/member_screen/view_nutrition_bottom_sheet.dart';
import 'package:crossfit_gym_trainer/mobile_pages/main_drawer_screen.dart';
import 'package:crossfit_gym_trainer/providers/nutrition_provider.dart';
import 'package:crossfit_gym_trainer/trainer_screen/add_nutrition_screen.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String userRole = "";
  String userId = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  var selectedDateTime = DateTime.now();
  late NutritionProvider nutritionProvider;
  bool searchVisible = false;
  var textSearchController = TextEditingController();
  late ShowProgressDialog showProgressDialog;

  @override
  void initState() {
    super.initState();
    nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);
    showProgressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userRole = await _preference.getValue(prefUserRole, "");
      userId = await _preference.getValue(prefUserId, "");
      await pullRefresh();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
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
              color: isDarkTheme
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF181A20),
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.nutrition_plan),
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
              padding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
              child: SvgPicture.asset(
                height: 25,
                width: 25,
                'assets/images/ic_Search.svg',
                color: isDarkTheme
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF181A20),
              ),
            ),
          ),
          if (userRole == userRoleTrainer)
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
                      builder: (context) => AddNutrition(
                          queryDocumentSnapshot: null, viewType: ""),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(
                    'assets/images/ic_add.svg',
                    height: 21,
                    width: 21,
                    color: isDarkTheme
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF181A20),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: RefreshIndicator(
          onRefresh: pullRefresh,
          child: Column(
            children: [
              if (searchVisible)
                Card(
                  // elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFD9E1ED),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        hintText:
                            AppLocalizations.of(context)!.search_nutrition,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          child: SvgPicture.asset(
                            "assets/images/SearchIcon.svg",
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 5, 0),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: height * 0.025,
              ),
              SizedBox(
                height: 120,
                width: width,
                child: CustomCalendarAppDemo(
                  currentView: CalendarViews.week,
                  onDateChange: onDateChange,
                  measurementList: const [],
                ),
              ),
              SizedBox(
                  height: searchVisible ? height * 0.7 - 70 : height * 0.7,
                  width: width,
                  child: Consumer<NutritionProvider>(
                    builder: (context, nutritionData, child) =>
                        getAllTodayNutritionList(
                                    nutritionData.nutritionListItem)
                                .isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.only(top: 15),
                                itemCount: getAllTodayNutritionList(
                                        nutritionData.nutritionListItem)
                                    .length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final QueryDocumentSnapshot documentSnapshot =
                                      getAllTodayNutritionList(nutritionData
                                          .nutritionListItem)[index];
                                  debugPrint(
                                      "documentSnapshot list :${documentSnapshot.id}");
                                  return GestureDetector(
                                    onTap: () {
                                      if (userRole == userRoleTrainer) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddNutrition(
                                                queryDocumentSnapshot:
                                                    documentSnapshot,
                                                viewType: "edit"),
                                          ),
                                        );
                                      } else {
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
                                          builder: (context) =>
                                              ViewNutritionBottomSheet(
                                                  documentSnapshot:
                                                      documentSnapshot),
                                        );
                                      }
                                    },
                                    child: NutritionListItemView(
                                        documentSnapshot: documentSnapshot,
                                        nutritionProvider: nutritionProvider,
                                        userRole: userRole),
                                  );
                                })
                            : userRole == userRoleMember
                                ? Center(
                                    child: Column(
                                      children: [
                                        const Spacer(),
                                        CircleAvatar(
                                          backgroundColor: ColorCode.tabDivider,
                                          maxRadius: 45,
                                          child: Image.asset(
                                              'assets/images/empty_box.png'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 17.0, right: 17, top: 15),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .you_do_not_have_any_nutrition,
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddNutrition(
                                                      viewType: "",
                                                      queryDocumentSnapshot:
                                                          null),
                                            ),
                                          );
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
                                        padding: const EdgeInsets.only(
                                            left: 17.0, right: 17, top: 15),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .you_do_not_have_any_nutrition,
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
                                        AppLocalizations.of(context)!
                                            .tap_to_add
                                            .firstCapitalize(),
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
                  ))
            ],
          ),
        ),
      ),
      drawer: MainDrawerScreen(scaffoldKey: scaffoldKey),
    );
  }

  void onDateChange(DateTime tempDate, QueryDocumentSnapshot? document) {
    setState(
      () {
        selectedDateTime = tempDate;
      },
    );
  }

  List<QueryDocumentSnapshot> getAllTodayNutritionList(
      List<QueryDocumentSnapshot> tempDocList) {
    List<QueryDocumentSnapshot> allTodayNutritionList = [];

    for (var nutritionItem in tempDocList) {
      List<int> selectDayList =
          List.castFrom(nutritionItem[keySelectedDays] as List);
      debugPrint('selectDayList ${selectDayList.toString()}');
      debugPrint('selectTodayDay ${selectTodayDay.toString()}');
      if (selectedDateTime.isAfter(
            DateTime.fromMillisecondsSinceEpoch(nutritionItem[keyStartDate]),
          ) &&
          selectedDateTime.isBefore(
            DateTime.fromMillisecondsSinceEpoch(
              nutritionItem[keyEndDate],
            ),
          ) &&
          selectDayList.contains(
            selectTodayDay(selectedDateTime),
          )) {
        allTodayNutritionList.add(nutritionItem);
      } else if ((selectedDateTime
                  .isSameDate(DateTime.fromMillisecondsSinceEpoch(
                nutritionItem[keyStartDate],
              )) ||
              selectedDateTime.isSameDate(DateTime.fromMillisecondsSinceEpoch(
                nutritionItem[keyEndDate],
              ))) &&
          selectDayList.contains(
            selectTodayDay(selectedDateTime),
          )) {
        allTodayNutritionList.add(nutritionItem);
      }
    }
    return allTodayNutritionList;
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

  onSearchTextChanged(String text) async {
    nutritionProvider.nutritionListItem.clear();
    showProgressDialog.show();
    if (userRole == userRoleTrainer) {
      await nutritionProvider.getNutritionByUser(createdBy: userId);
    } else {
      await nutritionProvider.getNutritionForSelectedUser(
          userId: userId, isRefresh: true, searchText: text);
    }
    showProgressDialog.hide();
  }

  Future<void> pullRefresh() async {
    showProgressDialog.show();
    if (userRole == userRoleTrainer) {
      await nutritionProvider.getNutritionByUser(createdBy: userId);
    } else {
      await nutritionProvider.getNutritionForSelectedUser(
          userId: userId, isRefresh: true);
    }
    showProgressDialog.hide();
  }
}
