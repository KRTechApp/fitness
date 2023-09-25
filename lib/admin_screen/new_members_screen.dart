import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../mobile_pages/main_drawer_screen.dart';
import '../model/report_data.dart';
import '../model/report_member_data.dart';
import '../model/start_end_date_data.dart';
import '../model/trainer_data.dart';
import '../providers/member_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class NewMemberScreen extends StatefulWidget {
  const NewMemberScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<NewMemberScreen> createState() => _NewMemberScreenState();
}

class _NewMemberScreenState extends State<NewMemberScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TrainerProvider trainerProvider;
  late MemberProvider memberProvider;
  List<ReportData> dateGroupData = [];
  List<ReportMemberData> allDateGroupData = [];
  List<TrainerData> trainerModalData = [];
  var selectedDurationIndex = 0;
  final List<String> selectDurationList = [
    "1 Week",
    "1 Month",
    "3 Month",
    "6 Month",
    "1 Year",
  ];
  NumberFormat formatter = NumberFormat("00");
  String? selectedDuration;
  bool showType = false;
  var selectedTrainerId = '';
  String selectedTrainerName = "All";

  List<DateTime> getLastWeekDates() {
    List<DateTime> dates = [];
    DateTime now = DateTime.fromMillisecondsSinceEpoch(
      getCurrentDateOnly(),
    );
    debugPrint("now$now");
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(
        Duration(days: i),
      );
      var inputDate = DateTime.parse(
        date.toString(),
      );
      dates.add(inputDate);
    }
    debugPrint("dates$dates");
    return dates;
  }

  List<DateTime> getLastWeekMembers() {
    List<DateTime> dates = [];
    DateTime now = DateTime.fromMillisecondsSinceEpoch(
      getCurrentDateOnly(),
    );
    debugPrint("now$now");
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(
        Duration(days: i),
      );
      var inputDate = DateTime.parse(
        date.toString(),
      );
      dates.add(inputDate);
    }
    debugPrint("dates$dates");
    return dates;
  }

  List<DateTime> getThreeMonths() {
    List<DateTime> lastThreeMonths = [];
    DateTime now = DateTime.now();
    for (int i = 2; i >= 0; i--) {
      DateTime monthAgo = DateTime(now.year, now.month - i, 1);
      lastThreeMonths.add(monthAgo);
    }
    debugPrint("lastThreeMonths$lastThreeMonths");
    return lastThreeMonths;
  }

  List<DateTime> getSixMonths() {
    List<DateTime> lastThreeMonths = [];
    DateTime now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      DateTime monthAgo = DateTime(now.year, now.month - i, 1);
      lastThreeMonths.add(monthAgo);
    }
    debugPrint("lastSixMonths$lastThreeMonths");
    return lastThreeMonths;
  }

  List<DateTime> getTwelveMonths() {
    List<DateTime> lastThreeMonths = [];
    DateTime now = DateTime.now();
    for (int i = 11; i >= 0; i--) {
      DateTime monthAgo = DateTime(now.year, now.month - i, 1);
      lastThreeMonths.add(monthAgo);
    }
    debugPrint("lastThreeMonths$lastThreeMonths");
    return lastThreeMonths;
  }

  List<StartEndDateData> getLastWeekMonths() {
    List<StartEndDateData> dates = [];
    DateTime now = DateTime.fromMillisecondsSinceEpoch(
      getCurrentDateOnly(),
    );
    final weeksInMonth = getWeeksInMonth(now);

    // Print the first and last dates of each week
    for (final week in weeksInMonth) {
      debugPrint('${week['first']} - ${week['last']}');
      dates.add(
        StartEndDateData(week['first']!, week['last']!),
      );
    }
    return dates;
  }

  List<Map<String, DateTime>> getWeeksInMonth(DateTime date) {
    final List<Map<String, DateTime>> weeks = [];

    // Get the first and last days of the month
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    // Find the first day of the first week
    var firstDayOfFirstWeek = firstDayOfMonth;
    if (firstDayOfMonth.weekday != DateTime.monday) {
      firstDayOfFirstWeek = firstDayOfMonth.subtract(
        Duration(days: firstDayOfMonth.weekday - DateTime.monday),
      );
    }

    // Iterate over the weeks in the month
    var currentDay = firstDayOfFirstWeek;
    while (currentDay.isBefore(lastDayOfMonth)) {
      final lastDayOfWeek = currentDay
              .add(
                const Duration(days: 6),
              )
              .isBefore(lastDayOfMonth)
          ? currentDay.add(
              const Duration(days: 6),
            )
          : lastDayOfMonth;

      weeks.add(
        {
          'first': currentDay,
          'last': lastDayOfWeek,
        },
      );

      currentDay = lastDayOfWeek.add(
        const Duration(days: 1),
      );
    }

    return weeks;
  }

  TooltipBehavior tooltipBehavior = TooltipBehavior();

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        selectedTrainerId = "0";
        setState(() {});
        trainerProvider.getTrainerList(isRefresh: true);
        memberProvider.getMemberList(isRefresh: true);
        // memberProvider.getMemberOfTrainer(currentUserId: selectedTrainerId, isRefresh: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    getAllMemberList();
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
        title: Text(AppLocalizations.of(context)!.new_members),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 15),
          height: height * 0.75,
          width: width,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      AppLocalizations.of(context)!.trainer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: ColorCode.backgroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ColorCode.whites, width: 1),
                    ),
                    width: width - 128,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Consumer<TrainerProvider>(
                        builder: (context, trainerData, child) {
                          trainerModalData.clear();
                          trainerModalData.add(
                            TrainerData("0", "All"),
                          );
                          for (int i = 0; i < trainerData.trainerListItem.length; i++) {
                            debugPrint("tempTrainer $selectedTrainerName");
                            var id = i + 1;
                            trainerModalData.add(
                              TrainerData(trainerData.trainerListItem[i].id,
                                  "$id. ${trainerData.trainerListItem[i][keyName] ?? " "}"),
                            );
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              hint:
                                  Text(selectedTrainerName, overflow: TextOverflow.ellipsis, style: GymStyle.inputText),
                              items: trainerModalData
                                  .map(
                                    (item) => DropdownMenuItem<String>(
                                      value: item.trainerName,
                                      child: Text(item.trainerName,
                                          overflow: TextOverflow.ellipsis, style: GymStyle.exerciseLableText),
                                    ),
                                  )
                                  .toList(),
                              value: selectedTrainerName,
                              onMenuStateChange: (isOpen) {
                                setState(
                                  () {
                                    showType = isOpen;
                                  },
                                );
                              },
                              icon: const Icon(Icons.arrow_drop_down_outlined, size: 35, color: ColorCode.listSubTitle),
                              onChanged: (value) {
                                setState(
                                  () {
                                    selectedTrainerName = value ?? "";
                                    if (selectedTrainerName != trainerModalData[0].trainerName) {
                                      debugPrint("trainer name :$selectedTrainerName");
                                      trainerModalData.asMap().forEach(
                                        (key, tempTrainer) {
                                          if (selectedTrainerName == tempTrainer.trainerName) {
                                            var singleTrainer = trainerModalData.firstWhere(
                                                (element) => element.trainerName == tempTrainer.trainerName);
                                            selectedTrainerId = singleTrainer.id;
                                          }
                                        },
                                      );
                                      memberProvider.getMemberOfTrainer(
                                          createdById: selectedTrainerId, isRefresh: true);
                                    } else {
                                      var tempTrainer =
                                          trainerModalData.firstWhere((element) => element.trainerName == value);
                                      selectedTrainerId = tempTrainer.id;
                                      debugPrint('selectedMembershipId: $selectedTrainerId');
                                      memberProvider.getMemberList(isRefresh: true);
                                    }
                                  },
                                );
                              },
                              buttonHeight: 40,
                              buttonWidth: width,
                              itemHeight: 40,
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      AppLocalizations.of(context)!.duration,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: ColorCode.backgroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(left: 5, right: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ColorCode.whites, width: 1),
                    ),
                    width: width - 128,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          buttonWidth: width,
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hint: Text(
                            "1 Week",
                            style: GymStyle.settingSubTitleText,
                          ),
                          icon: const Icon(Icons.arrow_drop_down_outlined, size: 35, color: ColorCode.listSubTitle),
                          items: selectDurationList
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: GymStyle.settingSubTitleText,
                                  ),
                                ),
                              )
                              .toList(),
                          value: selectedDuration,
                          onChanged: (value) {
                            setState(
                              () {
                                selectedDuration = value;
                                selectedDurationIndex =
                                    selectDurationList.indexWhere((element) => element == selectedDuration);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Divider(height: 1, thickness: GymStyle.deviderThiknes),
              const SizedBox(
                height: 20,
              ),
              if (selectedTrainerName != "All")
                Consumer<MemberProvider>(
                  builder: (context, memberData, child) => memberData.myMemberListItem.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: ColorCode.tabBarBackground,
                          ),
                          child: SfCartesianChart(
                            title: ChartTitle(
                                textStyle: GymStyle.globalSearchTitleHighLight,
                                alignment: ChartAlignment.near,
                                text: 'Members'),
                            primaryXAxis: CategoryAxis(
                                title: AxisTitle(
                                    text: "Date",
                                    // text: getProgressReportBottomText(),
                                    alignment: ChartAlignment.center,
                                    textStyle: const TextStyle(
                                        color: ColorCode.listSubTitle, fontSize: 14, fontWeight: FontWeight.bold))),
                            primaryYAxis: CategoryAxis(
                              title: AxisTitle(
                                text: AppLocalizations.of(context)!.new_member_arrived,
                              ),
                              minimum: 0,
                            ),
                            tooltipBehavior: tooltipBehavior,
                            series: <LineSeries<ReportData, String>>[
                              LineSeries<ReportData, String>(
                                dataSource: getMemberReportData(
                                  memberData.myMemberListItem,
                                ),
                                color: ColorCode.mainColor,
                                markerSettings: const MarkerSettings(
                                    shape: DataMarkerType.circle,
                                    color: Colors.white,
                                    height: 5,
                                    width: 5,
                                    isVisible: true),
                                xValueMapper: (ReportData sales, _) => sales.date,
                                yValueMapper: (ReportData sales, _) => sales.member,
                                dataLabelSettings: const DataLabelSettings(
                                    isVisible: true, showZeroValue: false, color: ColorCode.mainColor),
                              )
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 120,
                            ),
                            Text(AppLocalizations.of(context)!.no_data_available),
                          ],
                        ),
                ),
              if (selectedTrainerName == "All")
                Consumer<MemberProvider>(
                  builder: (context, memberData, child) => memberData.memberListItem.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: ColorCode.tabBarBackground,
                          ),
                          child: SfCartesianChart(
                            title: ChartTitle(
                                textStyle: GymStyle.globalSearchTitleHighLight,
                                alignment: ChartAlignment.near,
                                text: 'Members'),
                            primaryXAxis: CategoryAxis(
                                associatedAxisName: "name",
                                title: AxisTitle(
                                    text: "Trainer",
                                    // text: getProgressReportBottomText(),
                                    alignment: ChartAlignment.center,
                                    textStyle: const TextStyle(
                                        color: ColorCode.listSubTitle, fontSize: 14, fontWeight: FontWeight.bold))),
                            primaryYAxis: CategoryAxis(
                              title: AxisTitle(
                                text: AppLocalizations.of(context)!.new_member_arrived,
                              ),
                              minimum: 0,
                            ),
                            tooltipBehavior: tooltipBehavior,
                            series: <LineSeries<ReportMemberData, String>>[
                              LineSeries<ReportMemberData, String>(
                                dataSource: getAllReportData(
                                  memberData.memberListItem,
                                ),
                                color: ColorCode.mainColor,
                                markerSettings: const MarkerSettings(
                                    shape: DataMarkerType.circle,
                                    color: Colors.white,
                                    height: 5,
                                    width: 5,
                                    isVisible: true),
                                xValueMapper: (ReportMemberData sales, _) => sales.memberName,
                                yValueMapper: (ReportMemberData sales, _) => sales.member,
                                dataLabelSettings: const DataLabelSettings(
                                    isVisible: true, showZeroValue: false, color: ColorCode.mainColor),
                              )
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 120,
                            ),
                            Text(AppLocalizations.of(context)!.no_data_available),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  getProgressReportBottomText() {
    DateTime nowDate = DateTime.now();
    int currYear = nowDate.year;
    DateTime currentMonth = DateTime.now();
    String monthName = DateFormat('MMMM').format(currentMonth);
    switch (selectedDurationIndex) {
      case 0:
        return "Week";
      case 1:
        return monthName;
      case 2:
        return "3 Month";
      case 3:
        return "6 Month";
      case 4:
        return "Year ${currYear - 1} - $currYear";
    }
    return "Date";
  }

  List<ReportData> getMemberReportData(
    List<QueryDocumentSnapshot> myMemberListItem,
  ) {
    switch (selectedDurationIndex) {
      case 0:
        return getMemberWeekData(getLastWeekDates(), myMemberListItem);
      case 1:
        return getMemberOneMonthData(getLastWeekMonths(), myMemberListItem);
      case 2:
        return getMemberThreeMonthData(getThreeMonths(), myMemberListItem);
      case 3:
        return getMemberSixMonthData(getSixMonths(), myMemberListItem);
      case 4:
        return getMemberYearData(getTwelveMonths(), myMemberListItem);
    }
    return getMemberWeekData(getLastWeekDates(), myMemberListItem);
  }

  List<ReportMemberData> getAllReportData(
    List<QueryDocumentSnapshot> myMemberListItem,
  ) {
    switch (selectedDurationIndex) {
      case 0:
        return getAllWeekData(getLastWeekDates(), getAllMemberList(), myMemberListItem);
      /*case 1:
        return getMemberOneMonthData(getLastWeekMonths(), myMemberListItem);
      case 2:
        return getMemberThreeMonthData(getThreeMonths(), myMemberListItem);
      case 3:
        return getMemberSixMonthData(getSixMonths(), myMemberListItem);
      case 4:
        return getMemberYearData(getTwelveMonths(), myMemberListItem);*/
    }
    return getAllWeekData(getLastWeekDates(), getAllMemberList(), myMemberListItem);
  }

  List<ReportData> getMemberWeekData(
    List<DateTime> lastWeekDates,
    List<QueryDocumentSnapshot> myMemberListItem,
  ) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
      (index, attachment) {
        String outputDate = DateFormat("dd MMM").format(
          lastWeekDates[index],
        );
        int totalMember = myMemberListItem
            .where(
              (element) => DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameDate(
                lastWeekDates[index],
              ),
            )
            .toList()
            .length;
        var member = formatter.format(totalMember);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(member),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportMemberData> getAllWeekData(
    List<DateTime> lastWeekDates,
    List<String> lastWeekMembers,
    List<QueryDocumentSnapshot> myMemberListItem,
  ) {
    allDateGroupData.clear();
    lastWeekMembers.asMap().forEach(
      (index, attachment) {
        String outputName = lastWeekMembers[index];
        int totalMember = myMemberListItem
            .where(
              (element) => DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameDate(
                lastWeekDates[index],
              ),
            )
            .toList()
            .length;
        var member = formatter.format(totalMember);
        allDateGroupData.add(
          ReportMemberData(
            outputName,
            int.parse(member),
          ),
        );
      },
    );
    return allDateGroupData;
  }

  List<ReportData> getMemberOneMonthData(
    List<StartEndDateData> lastWeekDates,
    List<QueryDocumentSnapshot> myMemberListItem,
  ) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
      (index, attachment) {
        String startDate = DateFormat("dd").format(
          lastWeekDates[index].startDate,
        );
        String endDate = DateFormat("dd").format(
          lastWeekDates[index].endDate,
        );

        String outputDate = " $startDate - $endDate";

        int totalMember = myMemberListItem
            .where(
              (element) =>
                  DateTime.fromMillisecondsSinceEpoch(
                    element[keyCreatedAt],
                  ).isAfter(
                    lastWeekDates[index].startDate,
                  ) &&
                  DateTime.fromMillisecondsSinceEpoch(
                    element[keyCreatedAt],
                  ).isBefore(
                    lastWeekDates[index].endDate,
                  ),
            )
            .toList()
            .length;
        var member = formatter.format(totalMember);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(member),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getMemberThreeMonthData(
    List<DateTime> lastWeekDates,
    List<QueryDocumentSnapshot> myMemberListItem,
  ) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
      (index, attachment) {
        String outputDate = DateFormat("LLLL").format(
          lastWeekDates[index],
        );
        int totalMember = myMemberListItem
            .where(
              (element) => DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                lastWeekDates[index],
              ),
            )
            .toList()
            .length;
        var member = formatter.format(totalMember);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(member),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getMemberSixMonthData(
    List<DateTime> lastWeekDates,
    List<QueryDocumentSnapshot> myMemberListItem,
  ) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
      (index, attachment) {
        String outputDate = DateFormat("MMM").format(
          lastWeekDates[index],
        );
        int totalMember = myMemberListItem
            .where(
              (element) => DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                lastWeekDates[index],
              ),
            )
            .toList()
            .length;
        var member = formatter.format(totalMember);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(member),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getMemberYearData(
    List<DateTime> monthOfYear,
    List<QueryDocumentSnapshot> myMemberListItem,
  ) {
    dateGroupData.clear();
    monthOfYear.asMap().forEach(
      (index, attachment) {
        String outputDate = DateFormat("LLL").format(
          monthOfYear[index],
        );
        int totalMember = myMemberListItem
            .where(
              (element) => DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                monthOfYear[index],
              ),
            )
            .toList()
            .length;
        var member = formatter.format(totalMember);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(member),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<String> getAllMemberList() {
    List<String> allTrainerName = [];
    for (int i = 0; i < trainerProvider.trainerListItem.length; i++) {
      allTrainerName.add(trainerProvider.trainerListItem[i][keyName]);
    }
    debugPrint("allTrainerName${allTrainerName.length}");
    return allTrainerName;
  }
}
