// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/color_code.dart';
import '../utils/tables_keys_values.dart';

class CustomCalendarApp extends StatefulWidget {
  final CalendarViews currentView;
  final Function(DateTime, QueryDocumentSnapshot?)? onDateChange;
  final List<QueryDocumentSnapshot> measurementList;
  final bool disableFutureDate;

  const CustomCalendarApp(
      {super.key,
      required this.measurementList,
      this.currentView = CalendarViews.month,
      this.onDateChange,
      this.disableFutureDate = false});

  @override
  _CustomCalendarAppState createState() => _CustomCalendarAppState();
}

class _CustomCalendarAppState extends State<CustomCalendarApp> {
  // number of days in month [JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC]
  final List<int> _monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  DateTime _currentDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _selectedDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<Calendar> _sequentialDates = [];
  int _currentWeekPos = 0;
  int _currentDayPos = 0;
  int midYear = DateTime.now().year;
  final List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (widget.currentView == CalendarViews.week) {
          setState(
            () {
              _currentWeekPos = 0;
              _currentDayPos = 0;
              for (int i = 0; i < _sequentialDates.length; i++) {
                if (_sequentialDates[i].date!.month == DateTime.now().month &&
                    _sequentialDates[i].date!.isSameDate(DateTime.now())) {
                  _currentWeekPos = (i / 7).floor() * 7;
                  break;
                }
              }
            },
          );
          debugPrint("_currentWeekPos : $_currentWeekPos");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: widget.currentView == CalendarViews.week
          ? const BoxDecoration()
          : const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
      padding: widget.currentView == CalendarViews.week ? EdgeInsets.zero : const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // header
          if (widget.currentView != CalendarViews.week)
            Row(
              children: <Widget>[
                const Spacer(),
                // prev month button
                _toggleBtn(false),
                // month and year
                SizedBox(
                  width: width * 0.71,
                  child: Center(
                    child: Text(
                      '${_monthNames[_currentDateTime.month - 1]} ${_currentDateTime.year}',
                      style: GymStyle.containerHeader,
                    ),
                  ),
                ),
                // next month button
                _toggleBtn(true),
                const Spacer(),
              ],
            ),
          if (widget.currentView == CalendarViews.month)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: _weekDayTitle(),
            ),
          if (widget.currentView == CalendarViews.month)
            Flexible(
              child: _calendarBodyMonth(),
            ),
          if (widget.currentView == CalendarViews.week)
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return _calendarBodyWeek(constraints);
              },
            ),
        ],
      ),
    );
  }

  // calendar month
  Widget _calendarBodyMonth() {
    _getCalendar();
    if (_sequentialDates.isEmpty) return Container();
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 15, bottom: 2),
      itemCount: _sequentialDates.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1, crossAxisCount: 7, crossAxisSpacing: 3, mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        // if (_sequentialDates[index].date == _selectedDateTime) return _selector(_sequentialDates[index], index);
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return _calendarDates(_sequentialDates[index], index, constraints);
          },
        );
      },
    );
  }

  // calendar week
  Widget _calendarBodyWeek(BoxConstraints mainConstraints) {
    _getCalendar();
    if (_sequentialDates.isEmpty) return Container();
    return Column(
      children: [
        Row(
          children: List.generate(
            7,
            (index) => _calendarWeekDayTitle(_sequentialDates[_currentWeekPos + index], mainConstraints),
          ),
        ),
      ],
    );
  }

  // calendar header month
  Widget _weekDayTitle() {
    if (_sequentialDates.isEmpty) return Container();
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 2.6,
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            _weekDays[index],
            style: GymStyle.listTitle,
          ),
        );
      },
    );
  }

  Widget _calendarDates(Calendar calendarDate, int index, BoxConstraints constraints) {
    // debugPrint ("Grid width  : "+constraints.maxWidth.toString(),);
    // debugPrint ("Grid height  : "+constraints.maxHeight.toString(),);
    return InkWell(
      onTap: () {
        if ((widget.disableFutureDate && calendarDate.date!.isAfter(DateTime.now()))) {
          debugPrint("Disable future date");
          return;
        }
        if (widget.onDateChange != null) {
          setState(
            () {
              _selectedDateTime = calendarDate.date!;
            },
          );
          QueryDocumentSnapshot? snapshot =
              calendarDate.measurementList != null && calendarDate.measurementList!.isNotEmpty
                  ? calendarDate.measurementList!.first
                  : null;
          widget.onDateChange!(_selectedDateTime, snapshot);
        }
      },
      child: Column(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: (calendarDate.thisMonth)
                  ? (calendarDate.date == _selectedDateTime
                      ? ColorCode.mainColor
                      : (widget.disableFutureDate && calendarDate.date!.isAfter(DateTime.now()))
                          ? ColorCode.calendarDisableDate
                          : ColorCode.mainColor1)
                  : (calendarDate.date == _selectedDateTime ? ColorCode.mainColor : Colors.transparent),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${calendarDate.date!.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins-Bold',
                color: (calendarDate.thisMonth)
                    ? calendarDate.date == _selectedDateTime
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF777777)
                    : calendarDate.date == _selectedDateTime
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF777777),
              ),
            ),
          ),
          if (calendarDate.measurementList != null && calendarDate.measurementList!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 5),
              height: 5,
              width: 5,
              decoration: const BoxDecoration(
                color: ColorCode.mainColor,
                shape: BoxShape.circle,
              ),
            )
        ],
      ),
    );
  }

  Widget _calendarWeekDayTitle(Calendar calendarDate, BoxConstraints mainConstrain) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: (mainConstrain.maxWidth) / 7,
        height: 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('E').format(calendarDate.date!)[0],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ColorCode.backgroundColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              splashColor: const Color(0xFFB7C8FF),
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                if (widget.onDateChange != null) {
                  setState(
                    () {
                      _selectedDateTime = calendarDate.date!;
                    },
                  );
                  widget.onDateChange!(_selectedDateTime, null);
                }
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                width: 40,
                decoration: BoxDecoration(
                  color: (calendarDate.thisMonth)
                      ? calendarDate.date == _selectedDateTime
                              ? ColorCode.mainColor
                              : ColorCode.mainColor1
                      : calendarDate.date == _selectedDateTime
                              ? ColorCode.mainColor
                              : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${calendarDate.date!.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: (calendarDate.thisMonth)
                        ? calendarDate.date == _selectedDateTime
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF777777)
                        : calendarDate.date == _selectedDateTime
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF777777),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(bool next) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(18),
        ),
        splashColor: const Color(0xFFB7C8FF),
        onTap: () {
          if (widget.currentView == CalendarViews.month) {
            setState(
              () => (next) ? _getNextMonth() : _getPrevMonth(),
            );
          } else if (widget.currentView == CalendarViews.week) {
            if (next) {
              int tempWeekPos = _currentWeekPos + 7;
              debugPrint("tempWeekPos : $tempWeekPos");
              debugPrint("_sequentialDates.length : ${_sequentialDates.length}");
              if (tempWeekPos >= _sequentialDates.length) {
                _currentWeekPos = 0;
                _getNextMonth();
              } else {
                _currentWeekPos = tempWeekPos;
              }
            } else {
              int tempWeekPos = _currentWeekPos - 7;
              debugPrint("tempWeekPos : $tempWeekPos");
              debugPrint("_sequentialDates.length : ${_sequentialDates.length}");
              if (tempWeekPos < 0) {
                _currentWeekPos = 0;
                _getPrevMonth();
                _getCalendar();
                _currentWeekPos = (_sequentialDates.length - 7);
              } else {
                _currentWeekPos = tempWeekPos;
              }
            }
            setState(
              () {},
            );
          } else if (widget.currentView == CalendarViews.day) {
            if (next) {
              int tempDayPos = _currentDayPos + 1;
              debugPrint("_tempDayPos : $tempDayPos");
              debugPrint("_sequentialDates.length : ${_sequentialDates.length}");
              if (tempDayPos >= _sequentialDates.length ||
                  _sequentialDates[tempDayPos].nextMonth ||
                  _sequentialDates[tempDayPos].prevMonth) {
                _currentDayPos = 0;
                _getNextMonth();
                _getCalendar();
                for (int i = 0; i < _sequentialDates.length; i++) {
                  if (_sequentialDates[i].thisMonth) {
                    _currentDayPos = i;
                    break;
                  }
                }
              } else {
                _currentDayPos = tempDayPos;
              }
            } else {
              int tempDayPos = _currentDayPos - 1;
              debugPrint("_tempDayPos : $tempDayPos");
              debugPrint("_sequentialDates.length : ${_sequentialDates.length}");
              if (tempDayPos < 0 || _sequentialDates[tempDayPos].nextMonth || _sequentialDates[tempDayPos].prevMonth) {
                _currentDayPos = 0;
                _getPrevMonth();
                _getCalendar();
                for (int i = (_sequentialDates.length - 1); i >= 0; i--) {
                  if (_sequentialDates[i].thisMonth) {
                    _currentDayPos = i;
                    break;
                  }
                }
              } else {
                _currentDayPos = tempDayPos;
              }
            }
            setState(
              () {},
            );
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: 25,
          height: 25,
          child: Icon(
            (next) ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
            size: 32,
            weight: 40.0,
            color: ColorCode.backgroundColor,
          ),
        ),
      ),
    );
  }

  // get next month calendar
  void _getNextMonth() {
    if (_currentDateTime.month == 12) {
      _currentDateTime = DateTime(_currentDateTime.year + 1, 1);
    } else {
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month + 1);
    }
    // _getCalendar();
  }

  // get previous month calendar
  void _getPrevMonth() {
    if (_currentDateTime.month == 1) {
      _currentDateTime = DateTime(_currentDateTime.year - 1, 12);
    } else {
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month - 1);
    }
    // _getCalendar();
  }

  // get calendar for current month
  void _getCalendar() {
    _sequentialDates =
        getMonthCalendar(_currentDateTime.month, _currentDateTime.year, startWeekDay: StartWeekDay.sunday);
  }

  bool _isLeapYear(int year) {
    if (year % 4 == 0) {
      if (year % 100 == 0) {
        if (year % 400 == 0) return true;
        return false;
      }
      return true;
    }
    return false;
  }

  /// get the month calendar
  /// month is between from 1-12 (1 for January and 12 for December)
  List<Calendar> getMonthCalendar(int month, int year, {StartWeekDay startWeekDay = StartWeekDay.sunday}) {
    // validate
    if (month < 1 || month > 12) throw ArgumentError('Invalid year or month');

    List<Calendar> calendar = [];

    // used for previous and next month's calendar days
    int otherYear;
    int otherMonth;
    int leftDays;

    // get no. of days in the month
    // month-1 because _monthDays starts from index 0 and month starts from 1
    int totalDays = _monthDays[month - 1];
    // if this is a leap year and the month is february, increment the total days by 1
    if (_isLeapYear(year) && month == DateTime.february) totalDays++;

    // get this month's calendar days
    for (int i = 0; i < totalDays; i++) {
      DateTime currentDate = DateTime(year, month, i + 1);
      List<QueryDocumentSnapshot> tempMeasurementList = [];
      for (var tempMeasurementItem in widget.measurementList) {
        if (currentDate.isSameDate(DateTime.fromMillisecondsSinceEpoch(tempMeasurementItem.get(keyCreatedAt)))) {
          tempMeasurementList.add(tempMeasurementItem);
        }
      }
      calendar.add(
        Calendar(date: currentDate, thisMonth: true, measurementList: tempMeasurementList),
      );
    }

    // fill the unfilled starting weekdays of this month with the previous month days
    if ((startWeekDay == StartWeekDay.sunday && calendar.first.date!.weekday != DateTime.sunday) ||
        (startWeekDay == StartWeekDay.monday && calendar.first.date!.weekday != DateTime.monday)) {
      // if this month is january, then previous month would be decemeber of previous year
      if (month == DateTime.january) {
        otherMonth = DateTime.december; // _monthDays index starts from 0 (11 for december)
        otherYear = year - 1;
      } else {
        otherMonth = month - 1;
        otherYear = year;
      }
      // month-1 because _monthDays starts from index 0 and month starts from 1
      totalDays = _monthDays[otherMonth - 1];
      if (_isLeapYear(otherYear) && otherMonth == DateTime.february) totalDays++;

      leftDays = totalDays - calendar.first.date!.weekday + ((startWeekDay == StartWeekDay.sunday) ? 0 : 1);

      for (int i = totalDays; i > leftDays; i--) {
        DateTime currentDate = DateTime(otherYear, otherMonth, i);
        List<QueryDocumentSnapshot> tempMeasurementList = [];
        for (var tempMeasurementItem in widget.measurementList) {
          if (currentDate.isSameDate(DateTime.fromMillisecondsSinceEpoch(tempMeasurementItem.get(keyCreatedAt)))) {
            tempMeasurementList.add(tempMeasurementItem);
          }
        }
        calendar.insert(
          0,
          Calendar(date: currentDate, prevMonth: true, measurementList: tempMeasurementList),
        );
      }
    }

    // fill the unfilled ending weekdays of this month with the next month days
    if ((startWeekDay == StartWeekDay.sunday && calendar.last.date!.weekday != DateTime.saturday) ||
        (startWeekDay == StartWeekDay.monday && calendar.last.date!.weekday != DateTime.sunday)) {
      // if this month is december, then next month would be january of next year
      if (month == DateTime.december) {
        otherMonth = DateTime.january;
        otherYear = year + 1;
      } else {
        otherMonth = month + 1;
        otherYear = year;
      }
      // month-1 because _monthDays starts from index 0 and month starts from 1
      totalDays = _monthDays[otherMonth - 1];
      if (_isLeapYear(otherYear) && otherMonth == DateTime.february) totalDays++;

      leftDays = 7 - calendar.last.date!.weekday - ((startWeekDay == StartWeekDay.sunday) ? 1 : 0);
      if (leftDays == -1) leftDays = 6;

      for (int i = 0; i < leftDays; i++) {
        DateTime currentDate = DateTime(otherYear, otherMonth, i + 1);
        List<QueryDocumentSnapshot> tempMeasurementList = [];
        for (var tempMeasurementItem in widget.measurementList) {
          if (currentDate.isSameDate(DateTime.fromMillisecondsSinceEpoch(tempMeasurementItem.get(keyCreatedAt)))) {
            tempMeasurementList.add(tempMeasurementItem);
          }
        }
        calendar.add(
          Calendar(
            date: currentDate,
            nextMonth: true,
          ),
        );
      }
    }

    return calendar;
  }
}

class Calendar {
  final DateTime? date;
  final bool thisMonth;
  final bool prevMonth;
  final bool nextMonth;
  final List<QueryDocumentSnapshot>? measurementList;

  Calendar({
    this.date,
    this.thisMonth = false,
    this.prevMonth = false,
    this.nextMonth = false,
    this.measurementList,
  });
}

enum CalendarViews { month, week, day }

enum StartWeekDay { sunday, monday }
