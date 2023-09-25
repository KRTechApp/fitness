import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Utils/color_code.dart';
import '../model/report_data.dart';
import '../model/start_end_date_data.dart';
import '../providers/member_provider.dart';
import '../providers/payment_history_provider.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';

class TrainerProfileReport extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const TrainerProfileReport({
    Key? key,
    required this.documentSnapshot,
  }) : super(key: key);

  @override
  State<TrainerProfileReport> createState() => _TrainerProfileReportState();
}

class _TrainerProfileReportState extends State<TrainerProfileReport> {

  var selectedDurationIndex = 1;
  String? selectedType;
  String? selectedDuration;
  late MemberProvider memberProvider;
  TooltipBehavior tooltipBehavior = TooltipBehavior();
  List<ReportData> dateGroupData = [];
  List<StartEndDateData> getWeekOfDays = [];
  NumberFormat formatter = NumberFormat("00");
  late PaymentHistoryProvider paymentHistoryProvider;
  bool sortByCreated = true;

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

      weeks.add({
        'first': currentDay,
        'last': lastDayOfWeek,
      });

      currentDay = lastDayOfWeek.add(
        const Duration(days: 1),
      );
    }

    return weeks;
  }

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    paymentHistoryProvider =
        Provider.of<PaymentHistoryProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
        selectedType = AppLocalizations.of(context)!.new_member_arrived;
        setState(
              () {
            paymentHistoryProvider.getCreatedPaymentHistory(
                currentUserId: widget.documentSnapshot.id,
                sortByCreated: sortByCreated,
                status: paymentPaid);
          },
        );
        memberProvider.getMemberOfTrainer(
            createdById: widget.documentSnapshot.id, isRefresh: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
    final List<String> selectTypeList = [
      AppLocalizations.of(context)!.new_member_arrived,
      AppLocalizations.of(context)!.earning,
    ];
    final List<String> selectDurationList = [
      "1 ${AppLocalizations.of(context)!.week}",
      "1 ${AppLocalizations.of(context)!.month}",
      "3 ${AppLocalizations.of(context)!.month}",
      "6 ${AppLocalizations.of(context)!.month}",
      "1 ${AppLocalizations.of(context)!.year}",
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 15),
          height: height * 0.75,
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.select,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: ColorCode.backgroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                    ),

                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ColorCode.whites, width: 1),
                      ),
                      width: width - 128,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          buttonWidth: width,
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hint: Text(
                            AppLocalizations.of(context)!.new_member_arrived,
                            style: GymStyle.settingSubTitleText,
                          ),
                          icon: const Icon(Icons.arrow_drop_down_outlined,
                              size: 35, color: ColorCode.listSubTitle),
                          items: selectTypeList
                              .map(
                                (item) =>
                                DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: GymStyle.settingSubTitleText,
                                  ),
                                ),
                          )
                              .toList(),
                          value: selectedType,
                          onChanged: (value) {
                            setState(
                                  () {
                                selectedType = value;
                              },
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
                    Text(
                      AppLocalizations.of(context)!.duration,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: ColorCode.backgroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ColorCode.whites, width: 1),
                      ),
                      width: width - 128,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          buttonWidth: width,
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hint: Text(
                            "1 ${AppLocalizations.of(context)!.month}",
                            style: GymStyle.settingSubTitleText,
                          ),
                          icon: const Icon(Icons.arrow_drop_down_outlined,
                              size: 35, color: ColorCode.listSubTitle),
                          items: selectDurationList
                              .map(
                                (item) =>
                                DropdownMenuItem<String>(
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
                                    selectDurationList.indexWhere((element) =>
                                    element == selectedDuration);
                              },
                            );
                          },
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
                if (selectedType ==
                    AppLocalizations.of(context)!.new_member_arrived)
                  Consumer<MemberProvider>(
                    builder: (context, memberData, child) =>
                    memberData.myMemberListItem.isNotEmpty
                        ? Container(
                      // margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: ColorCode.tabBarBackground,
                      ),
                      child: SfCartesianChart(
                        title: ChartTitle(
                          textStyle: GymStyle.globalSearchTitleHighLight,
                          alignment: ChartAlignment.near,
                          text: AppLocalizations
                              .of(context)!
                              .progress
                              .allInCaps,
                        ),
                        primaryXAxis: CategoryAxis(
                          // majorGridLines: const MajorGridLines(width: 0),
                          // axisLine: AxisLine(width: 0),
                            title: AxisTitle(
                                text: getProgressReportBottomText(),
                                alignment: ChartAlignment.center,
                                textStyle: const TextStyle(
                                    color: ColorCode.listSubTitle,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))),
                        primaryYAxis: CategoryAxis(
                          // majorGridLines: const MajorGridLines(width: 0),
                          // axisLine: AxisLine(width: 0),
                            title: AxisTitle(
                              text: AppLocalizations.of(context)!
                                  .new_member_arrived,
                            ),
                            minimum: 0,
                            isVisible: true,
                            tickPosition: TickPosition.outside),
                        tooltipBehavior: tooltipBehavior,
                        series: <LineSeries<ReportData, String>>[
                          LineSeries<ReportData, String>(
                            dataSource: getProgressReportData(
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
                                isVisible: true,
                                showZeroValue: false,
                                color: ColorCode.mainColor),
                          )
                        ],
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: SizedBox(
                              height: height,
                              child: Text(AppLocalizations.of(context)!
                                  .no_data_available),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (selectedType == "Earning")
                  Consumer<PaymentHistoryProvider>(
                    builder: (context, paymentData, child) =>
                    paymentData.paymentHistoryItemList.isNotEmpty
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
                            text: 'EARNING'),
                        primaryXAxis: CategoryAxis(
                            title: AxisTitle(
                                text: getProgressReportBottomText(),
                                alignment: ChartAlignment.center,
                                textStyle: const TextStyle(
                                    color: ColorCode.listSubTitle,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))),
                        primaryYAxis: CategoryAxis(
                          title: AxisTitle(
                            text: "${AppLocalizations.of(context)!
                                .total_income}(${StaticData.currentCurrency})",
                          ),
                          minimum: 0,
                        ),
                        tooltipBehavior: tooltipBehavior,
                        series: <LineSeries<ReportData, String>>[
                          LineSeries<ReportData, String>(
                            dataSource: getEarningReportData(
                              paymentData.paymentHistoryItemList,
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
                                isVisible: true,
                                showZeroValue: false,
                                color: ColorCode.mainColor),
                          )
                        ],
                      ),
                    )
                        : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                        ),
                        Text("No Data Available."),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ReportData> getProgressReportData(
      List<QueryDocumentSnapshot> myMemberListItem,) {
    switch (selectedDurationIndex) {
      case 0:
        return getWeekData(getLastWeekDates(), myMemberListItem);
      case 1:
        return getOneMonthData(getLastWeekMonths(), myMemberListItem);
      case 2:
        return getThreeMonthData(getThreeMonths(), myMemberListItem);
      case 3:
        return getSixMonthData(getSixMonths(), myMemberListItem);
      case 4:
        return getYearData(getTwelveMonths(), myMemberListItem);
    }
    return getWeekData(getLastWeekDates(), myMemberListItem);
  }

  List<ReportData> getEarningReportData(
      List<QueryDocumentSnapshot> paymentHistoryItemList,) {
    switch (selectedDurationIndex) {
      case 0:
        return getEarningWeekData(getLastWeekDates(), paymentHistoryItemList);
      case 1:
        return getEarningOneMonthData(
            getLastWeekMonths(), paymentHistoryItemList);
      case 2:
        return getEarningThreeMonthData(
            getThreeMonths(), paymentHistoryItemList);
      case 3:
        return getEarningSixMonthData(getSixMonths(), paymentHistoryItemList);
      case 4:
        return getEarningYearData(getTwelveMonths(), paymentHistoryItemList);
    }
    return getWeekData(getLastWeekDates(), paymentHistoryItemList);
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

  List<ReportData> getWeekData(List<DateTime> lastWeekDates,
      List<QueryDocumentSnapshot> myMemberListItem,) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("dd MMM").format(
          lastWeekDates[index],
        );
        int totalMember = myMemberListItem
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
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

  List<ReportData> getEarningWeekData(List<DateTime> lastWeekDates,
      List<QueryDocumentSnapshot> paymentHistoryItemList,) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("dd MMM").format(
          lastWeekDates[index],
        );
        List<QueryDocumentSnapshot> tempPaymentHistory = paymentHistoryItemList
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameDate(
                lastWeekDates[index],
              ),
        )
            .toList();

        var totalAmount = 0;
        for (int i = 0; i < tempPaymentHistory.length; i++) {
          debugPrint(
              "tempPaymentHistory[i][keyAmount]${tempPaymentHistory[i][keyAmount]}");
          debugPrint(
              "tempPaymentHistory[i][keyAmount]${tempPaymentHistory[i].id}");
          if (tempPaymentHistory[i][keyPaymentStatus] == paymentPaid) {
            totalAmount = tempPaymentHistory[i][keyAmount] + totalAmount;
          }
        }
        dateGroupData.add(
          ReportData(
            outputDate,
            totalAmount,
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getOneMonthData(List<StartEndDateData> lastWeekDates,
      List<QueryDocumentSnapshot> myMemberListItem,) {
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
          (DateTime.fromMillisecondsSinceEpoch(
            element[keyCreatedAt],
          ).isAfter(
            lastWeekDates[index].startDate,
          ) &&
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isBefore(
                lastWeekDates[index].endDate,
              )) ||
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameDate(
                lastWeekDates[index].startDate,
              ) ||
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameDate(
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

  List<ReportData> getEarningOneMonthData(List<StartEndDateData> lastWeekDates,
      List<QueryDocumentSnapshot> paymentHistoryItemList,) {
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

        List<QueryDocumentSnapshot> tempPaymentHistory = paymentHistoryItemList
            .where(
              (element) =>
          (DateTime.fromMillisecondsSinceEpoch(
            element[keyCreatedAt],
          ).isAfter(
            lastWeekDates[index].startDate,
          ) &&
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isBefore(
                lastWeekDates[index].endDate,
              )) ||
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameDate(
                lastWeekDates[index].startDate,
              ) ||
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameDate(
                lastWeekDates[index].endDate,
              ),
        )
            .toList();
        var totalAmount = 0;
        for (int i = 0; i < tempPaymentHistory.length; i++) {
          if (tempPaymentHistory[i][keyPaymentStatus] == paymentPaid) {
            totalAmount = tempPaymentHistory[i][keyAmount] + totalAmount;
          }
        }
        dateGroupData.add(
          ReportData(
            outputDate,
            totalAmount,
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getThreeMonthData(List<DateTime> lastWeekDates,
      List<QueryDocumentSnapshot> myMemberListItem,) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("LLLL").format(
          lastWeekDates[index],
        );
        int totalMember = myMemberListItem
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
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

  List<ReportData> getEarningThreeMonthData(List<DateTime> lastWeekDates,
      List<QueryDocumentSnapshot> paymentHistoryItemList,) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("LLLL").format(
          lastWeekDates[index],
        );
        List<QueryDocumentSnapshot> tempPaymentHistory = paymentHistoryItemList
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                lastWeekDates[index],
              ),
        )
            .toList();
        var totalAmount = 0;
        for (int i = 0; i < tempPaymentHistory.length; i++) {
          debugPrint(
              "tempPaymentHistory[i][keyAmount]${tempPaymentHistory[i][keyAmount]}");
          debugPrint(
              "tempPaymentHistory[i][keyAmount]${tempPaymentHistory[i].id}");
          if (tempPaymentHistory[i][keyPaymentStatus] == paymentPaid) {
            totalAmount = tempPaymentHistory[i][keyAmount] + totalAmount;
          }
        }
        dateGroupData.add(
          ReportData(
            outputDate,
            totalAmount,
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getSixMonthData(List<DateTime> lastWeekDates,
      List<QueryDocumentSnapshot> myMemberListItem,) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("MMM").format(
          lastWeekDates[index],
        );
        int totalMember = myMemberListItem
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
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

  List<ReportData> getEarningSixMonthData(List<DateTime> lastWeekDates,
      List<QueryDocumentSnapshot> paymentHistoryItemList,) {
    dateGroupData.clear();
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("MMM").format(
          lastWeekDates[index],
        );
        List<QueryDocumentSnapshot> tempPaymentHistory = paymentHistoryItemList
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                lastWeekDates[index],
              ),
        )
            .toList();
        var totalAmount = 0;
        for (int i = 0; i < tempPaymentHistory.length; i++) {
          debugPrint(
              "tempPaymentHistory[i][keyAmount]${tempPaymentHistory[i][keyAmount]}");
          debugPrint(
              "tempPaymentHistory[i][keyAmount]${tempPaymentHistory[i].id}");
          if (tempPaymentHistory[i][keyPaymentStatus] == paymentPaid) {
            totalAmount = tempPaymentHistory[i][keyAmount] + totalAmount;
          }
        }
        dateGroupData.add(
          ReportData(
            outputDate,
            totalAmount,
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getYearData(List<DateTime> monthOfYear,
      List<QueryDocumentSnapshot> myMemberListItem,) {
    dateGroupData.clear();
    monthOfYear.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("LLL").format(monthOfYear[index]);
        int totalMember = myMemberListItem
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
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

  List<ReportData> getEarningYearData(List<DateTime> monthOfYear,
      List<QueryDocumentSnapshot> paymentHistoryItemList,) {
    dateGroupData.clear();
    monthOfYear.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("LLL").format(monthOfYear[index]);
        List<QueryDocumentSnapshot> tempPaymentHistory = paymentHistoryItemList
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                monthOfYear[index],
              ),
        )
            .toList();
        var totalAmount = 0;
        for (int i = 0; i < tempPaymentHistory.length; i++) {
          debugPrint(
              "tempPaymentHistory[i][keyAmount]${tempPaymentHistory[i][keyAmount]}");
          debugPrint(
              "tempPaymentHistory[i][keyAmount]${tempPaymentHistory[i].id}");
          if (tempPaymentHistory[i][keyPaymentStatus] == paymentPaid) {
            totalAmount = tempPaymentHistory[i][keyAmount] + totalAmount;
          }
        }
        dateGroupData.add(
          ReportData(
            outputDate,
            totalAmount,
          ),
        );
      },
    );
    return dateGroupData;
  }
}
