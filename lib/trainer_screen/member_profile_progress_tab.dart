import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/measurement_provider.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Utils/color_code.dart';
import '../model/report_data.dart';
import '../model/start_end_date_data.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class MemberProfileProgressTab extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const MemberProfileProgressTab({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  State<MemberProfileProgressTab> createState() =>
      _MemberProfileProgressTabState();
}

class _MemberProfileProgressTabState extends State<MemberProfileProgressTab> {
  late MeasurementProvider measurementProvider;
  var selectedDurationIndex = 1;
  String? selectedDuration;
  TooltipBehavior tooltipBehavior = TooltipBehavior();

  NumberFormat formatter = NumberFormat("00");

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
    measurementProvider =
        Provider.of<MeasurementProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("widget.documentSnapshot.id${widget.documentSnapshot.id}");
      measurementProvider.getMeasurement(
          currentUser: widget.documentSnapshot.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var height = MediaQuery
        .of(context)
        .size
        .height;
    final List<String> selectDurationList = [
      "1 ${AppLocalizations.of(context)!.week}",
      "1 ${AppLocalizations.of(context)!.month}",
      "3 ${AppLocalizations.of(context)!.month}",
      "6 ${AppLocalizations.of(context)!.month}",
      "1 ${AppLocalizations.of(context)!.year}",
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
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
                  // margin: const EdgeInsets.only(left: 5, right: 20),
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
                          "1 ${AppLocalizations.of(context)!.month}",
                          style: GymStyle.settingSubTitleText,
                        ),
                        icon: const Icon(
                            Icons.arrow_drop_down_outlined, size: 35,
                            color: ColorCode.listSubTitle),
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
                                  selectDurationList.indexWhere((
                                      element) => element == selectedDuration);
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
              height: 15,
            ),
            Divider(height: 1, thickness: GymStyle.deviderThiknes),
            const SizedBox(
              height: 15,
            ),
            Consumer<MeasurementProvider>(
              builder: (context, measurementData, child) =>
              measurementData.measurementListItem.isNotEmpty
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
                          .weight
                          .allInCaps),
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
                        text: AppLocalizations.of(context)!.weight,
                      ),
                      minimum: 0,
                      isVisible: true,
                      tickPosition: TickPosition.outside),
                  tooltipBehavior: tooltipBehavior,
                  series: <LineSeries<ReportData, String>>[
                    LineSeries<ReportData, String>(
                      dataSource: getProgressReportData(
                          measurementData.measurementListItem, keyWeight),
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
                  : Padding(
                    padding: EdgeInsets.only(top: Platform.isAndroid ? height * 0.25 : height * 0.18),
                    child: Text(
                        AppLocalizations.of(context)!.no_data_available),
                  ),
            ),
            const SizedBox(
              height: 15,
            ),
            Consumer<MeasurementProvider>(
              builder: (context, measurementData, child) =>
              measurementData.measurementListItem.isNotEmpty
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
                          .height
                          .allInCaps),
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
                        text: AppLocalizations.of(context)!.height,
                      ),
                      minimum: 0,
                      isVisible: true,
                      tickPosition: TickPosition.outside),
                  tooltipBehavior: tooltipBehavior,
                  series: <LineSeries<ReportData, String>>[
                    LineSeries<ReportData, String>(
                      dataSource: getProgressReportData(
                          measurementData.measurementListItem, keyHeight),
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
                  : Container(),
            ),
            const SizedBox(
              height: 15,
            ),
            Consumer<MeasurementProvider>(
              builder: (context, measurementData, child) =>
              measurementData.measurementListItem.isNotEmpty
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
                          .chest
                          .allInCaps),
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
                        text: AppLocalizations.of(context)!.chest,
                      ),
                      minimum: 0,
                      isVisible: true,
                      tickPosition: TickPosition.outside),
                  tooltipBehavior: tooltipBehavior,
                  series: <LineSeries<ReportData, String>>[
                    LineSeries<ReportData, String>(
                      dataSource: getProgressReportData(
                          measurementData.measurementListItem, keyChest),
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
                  : Container(),
            ),
            const SizedBox(
              height: 15,
            ),
            Consumer<MeasurementProvider>(
              builder: (context, measurementData, child) =>
              measurementData.measurementListItem.isNotEmpty
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
                          .waist
                          .allInCaps),
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
                        text: AppLocalizations.of(context)!.waist,
                      ),
                      minimum: 0,
                      isVisible: true,
                      tickPosition: TickPosition.outside),
                  tooltipBehavior: tooltipBehavior,
                  series: <LineSeries<ReportData, String>>[
                    LineSeries<ReportData, String>(
                      dataSource: getProgressReportData(
                          measurementData.measurementListItem, keyWaist),
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
                  : Container(),
            ),
            const SizedBox(
              height: 15,
            ),
            Consumer<MeasurementProvider>(
              builder: (context, measurementData, child) =>
              measurementData.measurementListItem.isNotEmpty
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
                          .thigh
                          .allInCaps),
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
                        text: AppLocalizations.of(context)!.thigh,
                      ),
                      minimum: 0,
                      isVisible: true,
                      tickPosition: TickPosition.outside),
                  tooltipBehavior: tooltipBehavior,
                  series: <LineSeries<ReportData, String>>[
                    LineSeries<ReportData, String>(
                      dataSource: getProgressReportData(
                          measurementData.measurementListItem, keyThigh),
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
                  : Container(),
            ),
            const SizedBox(
              height: 15,
            ),
            Consumer<MeasurementProvider>(
              builder: (context, measurementData, child) =>
              measurementData.measurementListItem.isNotEmpty
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
                          .arms
                          .allInCaps),
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
                        text: AppLocalizations.of(context)!.arms,
                      ),
                      minimum: 0,
                      isVisible: true,
                      tickPosition: TickPosition.outside),
                  tooltipBehavior: tooltipBehavior,
                  series: <LineSeries<ReportData, String>>[
                    LineSeries<ReportData, String>(
                      dataSource: getProgressReportData(
                          measurementData.measurementListItem, keyArms),
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
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  List<ReportData> getProgressReportData(
      List<QueryDocumentSnapshot> measurementListItem, String typeKey) {
    debugPrint("measurementListItem$measurementListItem");
    switch (selectedDurationIndex) {
      case 0:
        return getWeekData(getLastWeekDates(), measurementListItem, typeKey);
      case 1:
        return getOneMonthData(
            getLastWeekMonths(), measurementListItem, typeKey);
      case 2:
        return getThreeMonthData(
            getThreeMonths(), measurementListItem, typeKey);
      case 3:
        return getSixMonthData(getSixMonths(), measurementListItem, typeKey);
      case 4:
        return getYearData(getTwelveMonths(), measurementListItem, typeKey);
    }
    return getWeekData(getLastWeekDates(), measurementListItem, typeKey);
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
      List<QueryDocumentSnapshot> measurementListItem, String typeKey) {
    List<ReportData> dateGroupData = [];
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("dd MMM").format(
          lastWeekDates[index],
        );
        List<
            QueryDocumentSnapshot> tempMeasurementListItem = measurementListItem
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameDate(
                lastWeekDates[index],
              ),
        )
            .toList();
        double totalWeight = 0;
        for (int i = 0; i < tempMeasurementListItem.length; i++) {
          totalWeight = tempMeasurementListItem[i][typeKey];
          debugPrint(
              "tempMeasurementListItem[i][typeKey]sssssssss${tempMeasurementListItem[i][typeKey]}");
          debugPrint(
              "tempMeasurementListItem[i][typeKey]ssssssssstypeKey$typeKey");
          debugPrint(
              "tempMeasurementListItem[i][typeKey]aaaaaaaaa$totalWeight");
        }
        var weight = formatter.format(totalWeight);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(weight),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getOneMonthData(List<StartEndDateData> lastWeekDates,
      List<QueryDocumentSnapshot> measurementListItem, String typeKey) {
    List<ReportData> dateGroupData = [];
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String startDate = DateFormat("dd").format(
          lastWeekDates[index].startDate,
        );
        String endDate = DateFormat("dd").format(
          lastWeekDates[index].endDate,
        );
        String outputDate = " $startDate - $endDate";
        List<
            QueryDocumentSnapshot> tempMeasurementListItem = measurementListItem
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
        double totalWeight = 0;
        for (int i = 0; i < tempMeasurementListItem.length; i++) {
          totalWeight = tempMeasurementListItem[i][typeKey];
        }
        var weight = formatter.format(totalWeight);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(weight),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getThreeMonthData(List<DateTime> lastWeekDates,
      List<QueryDocumentSnapshot> measurementListItem, String typeKey) {
    List<ReportData> dateGroupData = [];
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("LLLL").format(
          lastWeekDates[index],
        );
        List<
            QueryDocumentSnapshot> tempMeasurementListItem = measurementListItem
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                lastWeekDates[index],
              ),
        )
            .toList();
        double totalWeight = 0;
        for (int i = 0; i < tempMeasurementListItem.length; i++) {
          totalWeight = tempMeasurementListItem[i][typeKey];
        }
        var weight = formatter.format(totalWeight);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(weight),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getSixMonthData(List<DateTime> lastWeekDates,
      List<QueryDocumentSnapshot> measurementListItem, String typeKey) {
    List<ReportData> dateGroupData = [];
    lastWeekDates.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("MMM").format(
          lastWeekDates[index],
        );
        List<
            QueryDocumentSnapshot> tempMeasurementListItem = measurementListItem
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                lastWeekDates[index],
              ),
        )
            .toList();
        double totalWeight = 0;
        for (int i = 0; i < tempMeasurementListItem.length; i++) {
          totalWeight = tempMeasurementListItem[i][typeKey];
        }
        var weight = formatter.format(totalWeight);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(weight),
          ),
        );
      },
    );
    return dateGroupData;
  }

  List<ReportData> getYearData(List<DateTime> monthOfYear,
      List<QueryDocumentSnapshot> measurementListItem, String typeKey) {
    List<ReportData> dateGroupData = [];
    monthOfYear.asMap().forEach(
          (index, attachment) {
        String outputDate = DateFormat("LLL").format(monthOfYear[index]);
        List<
            QueryDocumentSnapshot> tempMeasurementListItem = measurementListItem
            .where(
              (element) =>
              DateTime.fromMillisecondsSinceEpoch(
                element[keyCreatedAt],
              ).isSameMonth(
                monthOfYear[index],
              ),
        )
            .toList();
        double totalWeight = 0;
        for (int i = 0; i < tempMeasurementListItem.length; i++) {
          totalWeight = tempMeasurementListItem[i][typeKey];
        }
        var weight = formatter.format(totalWeight);
        dateGroupData.add(
          ReportData(
            outputDate,
            int.parse(weight),
          ),
        );
      },
    );
    return dateGroupData;
  }
}
