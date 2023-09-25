import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/Utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/custom_widgets/TagView/tags.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/mobile_pages/main_drawer_screen.dart';
import 'package:crossfit_gym_trainer/model/member_selection_model.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/providers/nutrition_provider.dart';
import 'package:crossfit_gym_trainer/trainer_screen/select_member_list.dart';
import 'package:crossfit_gym_trainer/trainer_screen/tag_view_item_view.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../utils/show_progress_dialog.dart';

class AddNutrition extends StatefulWidget {
  final QueryDocumentSnapshot? queryDocumentSnapshot;
  final String viewType;

  AddNutrition(
      {super.key, required this.queryDocumentSnapshot, required this.viewType});

  @override
  State<AddNutrition> createState() => _AddNutritionState();
}

class _AddNutritionState extends State<AddNutrition> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late MemberProvider memberProvider;
  var nutritionName = TextEditingController();
  var nutritionDetail = TextEditingController();
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();
  var breakFastController = TextEditingController();
  var midMorningSnacks = TextEditingController();
  var lunchController = TextEditingController();
  var afternoonSnacksController = TextEditingController();
  var dinnerController = TextEditingController();
  List<String> selectedMemberList = [];
  Uint8List? imageByte;
  String profile = "";
  var startDateMillisecond = 0;
  var endDateMillisecond = 0;
  bool enableBreakFast = false;
  bool enablemidMorningSnacks = false;
  bool enableLunch = false;
  bool enableAfternoonSnacks = false;
  bool enableDinner = false;
  late NutritionProvider nutritionProvider;
  late ShowProgressDialog progressDialog;
  List<int> selectDayList = [];
  List<String> days = ["S", "M", "T", "W", "T", "F", "S"];
  var selectedDateTime = DateTime.now();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);
    progressDialog =
        ShowProgressDialog(barrierDismissible: false, context: context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      selectTodayDay(selectedDateTime);
      userId = await _preference.getValue(prefUserId, "");
      if (widget.viewType == "edit" ||
          widget.viewType == "view" && widget.queryDocumentSnapshot != null) {
        nutritionName.text =
            widget.queryDocumentSnapshot!.get(keyNutritionName);
        nutritionDetail.text =
            widget.queryDocumentSnapshot!.get(keyNutritionDetail);
        selectedMemberList =
            List.castFrom(widget.queryDocumentSnapshot!.get(keySelectedMember));
        startDateMillisecond = widget.queryDocumentSnapshot!.get(keyStartDate);
        startDateController.text = DateFormat(StaticData.currentDateFormat)
            .format(DateTime.fromMillisecondsSinceEpoch(startDateMillisecond));
        endDateMillisecond = widget.queryDocumentSnapshot!.get(keyEndDate);
        endDateController.text = DateFormat(StaticData.currentDateFormat)
            .format(DateTime.fromMillisecondsSinceEpoch(endDateMillisecond));
        breakFastController.text =
            widget.queryDocumentSnapshot!.get(keyBreakFast);
        midMorningSnacks.text =
            widget.queryDocumentSnapshot!.get(keyMidMorningSnacks);
        lunchController.text = widget.queryDocumentSnapshot!.get(keyLunch);
        afternoonSnacksController.text =
            widget.queryDocumentSnapshot!.get(keyAfternoonSnacks);
        dinnerController.text = widget.queryDocumentSnapshot!.get(keyDinner);
        selectDayList =
            List.castFrom(widget.queryDocumentSnapshot!.get(keySelectedDays));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
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
        title: widget.viewType == "edit"
            ? Text(AppLocalizations.of(context)!.edit_nutrition)
            : widget.viewType == "view"
                ? Text(AppLocalizations.of(context)!.view_nutrition)
                : Text(AppLocalizations.of(context)!.add_nutrition),
      ),
      body: Form(
        key: formKey,
        child: Stack(children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 90, right: 15, left: 15),
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nutritionName,
                  cursorColor: ColorCode.mainColor,
                  readOnly: widget.viewType == "view" ? true : false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!
                          .please_enter_nutrition;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorCode.mainColor,
                      ),
                    ),
                    border: const UnderlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.nutrition_name,
                    labelStyle: GymStyle.inputText,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: nutritionDetail,
                  cursorColor: ColorCode.mainColor,
                  maxLines: null,
                  readOnly: widget.viewType == "view" ? true : false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!
                          .please_enter_nutrition_detail;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorCode.mainColor,
                      ),
                    ),
                    border: const UnderlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.nutrition_detail,
                    labelStyle: GymStyle.inputText,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(AppLocalizations.of(context)!.member,
                      style: GymStyle.inputText),
                ),
                Tags(
                  alignment: WrapAlignment.start,
                  itemCount: selectedMemberList.length,
                  itemBuilder: (index) {
                    return FutureBuilder(
                      // key: UniqueKey(),
                      future: memberProvider.getSelectedMember(
                        memberId: selectedMemberList[index],
                      ),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
                        if (asyncSnapshot.hasData) {
                          var documentSnapShot =
                              asyncSnapshot.data as DocumentSnapshot;
                          if (documentSnapShot.exists) {
                            return TagViewItemView(index, documentSnapShot);
                          } else {
                            return const SizedBox();
                          }
                        }
                        return Text(
                          AppLocalizations.of(context)!.select_member,
                          style: GymStyle.inputText,
                        );
                      },
                    );
                  }, //Selected id length
                  customWidget: InkWell(
                    onTap: () async {
                      if (widget.viewType == "view") {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!
                                .you_have_no_access,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 3,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        return;
                      }
                      MemberSelectionModel tempSelectedMember =
                          (await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectMemberList(
                                    memberSelectionModel: MemberSelectionModel(
                                        unselectedMember: [],
                                        selectedMember: selectedMemberList,
                                        alreadySelectedMember: []),
                                  ),
                                ),
                              )) ??
                              MemberSelectionModel(
                                  alreadySelectedMember: [],
                                  selectedMember: [],
                                  unselectedMember: []);
                      setState(
                        () {
                          selectedMemberList =
                              tempSelectedMember.selectedMember!;
                        },
                      );
                    },
                    child: Column(
                      children: [
                        DottedBorder(
                          color: ColorCode.mainColor,
                          strokeWidth: 1,
                          borderType: BorderType.Circle,
                          radius: const Radius.circular(10),
                          dashPattern: const [4, 4, 4, 4],
                          strokeCap: StrokeCap.round,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            height: 45,
                            width: 45,
                            child: imageByte != null || profile.isNotEmpty
                                ? CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage: getProfile(),
                                  )
                                : const Icon(
                                    Icons.add,
                                    color: Color(0Xff6842FF),
                                    size: 30,
                                  ),
                          ),
                        ),
                        const Text(''),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.1,
                      width: width * 0.41,
                      child: TextFormField(
                        controller: startDateController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!
                                .please_enter_start_date;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: ColorCode.mainColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(0),
                          //  <- you can it to 0.0 for no space
                          isDense: true,
                          border: const UnderlineInputBorder(),
                          labelText: AppLocalizations.of(context)!.start_date,
                          suffixIcon: Container(
                            padding: const EdgeInsets.all(13),
                            child:
                                SvgPicture.asset('assets/images/calendar.svg'),
                          ),
                          labelStyle: GymStyle.inputText,
                          // hintText: 'Enter Your Class'
                        ),
                        readOnly: true,
                        onTap: widget.viewType == "view"
                            ? null
                            : () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  if (kDebugMode) {
                                    print(pickedDate);
                                  }
                                  String formattedDate =
                                      DateFormat(StaticData.currentDateFormat)
                                          .format(pickedDate);
                                  startDateMillisecond =
                                      pickedDate.millisecondsSinceEpoch;
                                  if (kDebugMode) {
                                    print(formattedDate);
                                  }
                                  setState(
                                    () {
                                      startDateController.text = formattedDate;
                                    },
                                  );
                                }
                              },
                      ),
                    ),
                    SizedBox(
                      width: width * 0.09,
                    ),
                    SizedBox(
                      width: width * 0.41,
                      height: height * 0.1,
                      child: TextFormField(
                        controller: endDateController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!
                                .please_enter_end_date;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: ColorCode.mainColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(0),
                          //  <- you can it to 0.0 for no space
                          isDense: true,
                          border: const UnderlineInputBorder(),
                          labelText: AppLocalizations.of(context)!.end_date,
                          suffixIcon: Container(
                            padding: const EdgeInsets.all(13),
                            child:
                                SvgPicture.asset('assets/images/calendar.svg'),
                          ),
                          labelStyle: GymStyle.inputText,
                        ),
                        readOnly: true,
                        onTap: widget.viewType == "view"
                            ? null
                            : () async {
                                if (startDateController.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context)!
                                          .please_enter_end_date,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        DateTime.fromMillisecondsSinceEpoch(
                                            startDateMillisecond),
                                    firstDate:
                                        DateTime.fromMillisecondsSinceEpoch(
                                            startDateMillisecond),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    if (kDebugMode) {
                                      print(pickedDate);
                                    }
                                    String formattedDate =
                                        DateFormat(StaticData.currentDateFormat)
                                            .format(pickedDate);
                                    endDateMillisecond =
                                        pickedDate.millisecondsSinceEpoch;
                                    if (kDebugMode) {
                                      print(formattedDate);
                                    }
                                    setState(
                                      () {
                                        endDateController.text = formattedDate;
                                      },
                                    );
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: enableBreakFast,
                      visualDensity: VisualDensity.compact,
                      activeColor: ColorCode.mainColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(
                            () {
                              enableBreakFast = value;
                              debugPrint('Enable BrackFast $enableBreakFast');
                            },
                          );
                        }
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.break_fast_nutrition,
                      style: GymStyle.inputText,
                    )
                  ],
                ),
                if (enableBreakFast)
                  TextFormField(
                    controller: breakFastController,
                    cursorColor: ColorCode.mainColor,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!
                            .please_enter_break_fast_detail;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorCode.mainColor,
                        ),
                      ),
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.break_fast,
                      labelStyle: GymStyle.inputText,
                    ),
                  ),
                if (enableBreakFast) const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: enablemidMorningSnacks,
                      visualDensity: VisualDensity.compact,
                      activeColor: ColorCode.mainColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(
                            () {
                              enablemidMorningSnacks = value;
                              debugPrint(
                                  'Enable BrackFast $enablemidMorningSnacks');
                            },
                          );
                        }
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.mid_morning_snacks,
                      style: GymStyle.inputText,
                    )
                  ],
                ),
                if (enablemidMorningSnacks)
                  TextFormField(
                    controller: midMorningSnacks,
                    cursorColor: ColorCode.mainColor,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!
                            .please_enter_mid_morning_snacks_detail;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorCode.mainColor,
                        ),
                      ),
                      border: const UnderlineInputBorder(),
                      labelText:
                          AppLocalizations.of(context)!.mid_morning_snacks,
                      labelStyle: GymStyle.inputText,
                    ),
                  ),
                if (enablemidMorningSnacks) const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: enableLunch,
                      visualDensity: VisualDensity.compact,
                      activeColor: ColorCode.mainColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(
                            () {
                              enableLunch = value;
                              debugPrint('Enable BrackFast $enableLunch');
                            },
                          );
                        }
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.lunch,
                      style: GymStyle.inputText,
                    )
                  ],
                ),
                if (enableLunch)
                  TextFormField(
                    controller: lunchController,
                    cursorColor: ColorCode.mainColor,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!
                            .please_enter_lunch_detail;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorCode.mainColor,
                        ),
                      ),
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.lunch,
                      labelStyle: GymStyle.inputText,
                    ),
                  ),
                if (enableLunch) const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: enableAfternoonSnacks,
                      visualDensity: VisualDensity.compact,
                      activeColor: ColorCode.mainColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(
                            () {
                              enableAfternoonSnacks = value;
                              debugPrint(
                                  'Enable BrackFast $enableAfternoonSnacks');
                            },
                          );
                        }
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.afternoon_snacks,
                      style: GymStyle.inputText,
                    )
                  ],
                ),
                if (enableAfternoonSnacks)
                  TextFormField(
                    controller: afternoonSnacksController,
                    cursorColor: ColorCode.mainColor,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!
                            .please_enter_afternoon_snacks_detail;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorCode.mainColor,
                        ),
                      ),
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.afternoon_snacks,
                      labelStyle: GymStyle.inputText,
                    ),
                  ),
                if (enableAfternoonSnacks) const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: enableDinner,
                      visualDensity: VisualDensity.compact,
                      activeColor: ColorCode.mainColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(
                            () {
                              enableDinner = value;
                              debugPrint('Enable BrackFast $enableDinner');
                            },
                          );
                        }
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.dinner,
                      style: GymStyle.inputText,
                    )
                  ],
                ),
                if (enableDinner)
                  TextFormField(
                    controller: dinnerController,
                    cursorColor: ColorCode.mainColor,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!
                            .please_enter_dinner_detail;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorCode.mainColor,
                        ),
                      ),
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.dinner,
                      labelStyle: GymStyle.inputText,
                    ),
                  ),
                if (enableDinner) SizedBox(height: 15),
                SizedBox(
                  height: 50,
                  width: width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (widget.viewType != 'view') {
                                if (selectDayList.contains(index)) {
                                  onSelectedDay(index, false);
                                } else {
                                  onSelectedDay(index, true);
                                }
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                color: selectDayList.contains(index)
                                    ? ColorCode.mainColor
                                    : ColorCode.mainColor.withOpacity(0.12),
                              ),
                              height: 38,
                              width: 38,
                              child: Center(
                                child: Text(
                                  days[index].toString(),
                                  style: TextStyle(
                                      color: selectDayList.contains(index)
                                          ? ColorCode.white
                                          : ColorCode.backgroundColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 15,
            right: 15,
            child: SizedBox(
              height: height * 0.08,
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (selectedMemberList.isEmpty) {
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!
                              .please_select_member,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      if (widget.viewType == "edit") {
                        progressDialog.show(message: 'Loading...');
                        nutritionProvider
                            .updateNutrition(
                                nutritionName: nutritionName.text
                                    .trim()
                                    .toString()
                                    .firstCapitalize(),
                                nutritionDetail:
                                    nutritionDetail.text.trim().toString(),
                                memberList: selectedMemberList,
                                startDate: startDateMillisecond,
                                endDate: endDateMillisecond,
                                breakFast: enableBreakFast
                                    ? breakFastController.text.trim().toString()
                                    : "",
                                midMorningSnacks: enablemidMorningSnacks
                                    ? midMorningSnacks.text.trim().toString()
                                    : "",
                                lunch: enableLunch
                                    ? lunchController.text.trim().toString()
                                    : "",
                                afternoonSnacks: enableAfternoonSnacks
                                    ? afternoonSnacksController.text
                                        .trim()
                                        .toString()
                                    : "",
                                dinner: enableDinner
                                    ? dinnerController.text.trim().toString()
                                    : "",
                                selectedDays: selectDayList,
                                createdBy: userId,
                                nutritionId: widget.queryDocumentSnapshot!.id)
                            .then(
                              ((defaultResponseData) => {
                                    progressDialog.hide(),
                                    if (defaultResponseData.status != null &&
                                        defaultResponseData.status!)
                                      {
                                        Fluttertoast.showToast(
                                            msg: defaultResponseData.message ??
                                                AppLocalizations.of(context)!
                                                    .something_want_to_wrong,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0),
                                        Navigator.pop(context)
                                      }
                                    else
                                      {
                                        progressDialog.hide(),
                                        Fluttertoast.showToast(
                                            msg: defaultResponseData.message ??
                                                AppLocalizations.of(context)!
                                                    .something_want_to_wrong,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0)
                                      }
                                  }),
                            );
                      } else if (widget.viewType == "view") {
                        Navigator.pop(context);
                        return;
                      } else {
                        progressDialog.show();
                        nutritionProvider
                            .addNutrition(
                                nutritionName: nutritionName.text
                                    .trim()
                                    .toString()
                                    .firstCapitalize(),
                                createdBy: userId,
                                selectedDays: selectDayList,
                                nutritionDetail:
                                    nutritionDetail.text.trim().toString(),
                                memberList: selectedMemberList,
                                startDate: startDateMillisecond,
                                endDate: endDateMillisecond,
                                breakFast: enableBreakFast
                                    ? breakFastController.text.trim().toString()
                                    : "",
                                midMorningSnacks: enablemidMorningSnacks
                                    ? midMorningSnacks.text.trim().toString()
                                    : "",
                                lunch: enableLunch
                                    ? lunchController.text.trim().toString()
                                    : "",
                                afternoonSnacks: enableAfternoonSnacks
                                    ? afternoonSnacksController.text
                                        .trim()
                                        .toString()
                                    : "",
                                dinner: enableDinner
                                    ? dinnerController.text.trim().toString()
                                    : "")
                            .then(
                              (defaultResponseData) => {
                                progressDialog.hide(),
                                if (defaultResponseData.status != null &&
                                    defaultResponseData.status!)
                                  {
                                    Fluttertoast.showToast(
                                        msg: defaultResponseData.message ??
                                            AppLocalizations.of(context)!
                                                .something_want_to_wrong,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0),
                                    Navigator.pop(context)
                                  }
                                else
                                  {
                                    progressDialog.hide(),
                                    Fluttertoast.showToast(
                                        msg: defaultResponseData.message ??
                                            AppLocalizations.of(context)!
                                                .something_want_to_wrong,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0)
                                  }
                              },
                            );
                      }
                    }
                  }
                  ;
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: ColorCode.mainColor,
                ),
                child: Text(
                  widget.viewType == "edit"
                      ? AppLocalizations.of(context)!.edit_nutrition
                      : widget.viewType == "view"
                          ? AppLocalizations.of(context)!.view_nutrition
                          : AppLocalizations.of(context)!.add_nutrition,
                  style: GymStyle.buttonTextStyle,
                ),
              ),
            ),
          ),
        ]),
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  ImageProvider getProfile() {
    if (imageByte != null) {
      return MemoryImage(imageByte!);
    } else {
      return AssetImage(profile);
    }
  }

  onSelectedDay(int id, bool selected) {
    setState(
      () {
        if (selected) {
          if (!selectDayList.contains(id)) {
            selectDayList.add(id);
          }
        } else {
          selectDayList.remove(id);
        }
      },
    );
  }

  void selectTodayDay(DateTime selectedDay) {
    String formattedDate = DateFormat('EEEE').format(selectedDay);
    debugPrint('Today is $formattedDate');
    switch (formattedDate) {
      case "Sunday":
        selectDayList.add(0);
        break;
      case "Monday":
        selectDayList.add(1);
        break;
      case "Tuesday":
        selectDayList.add(2);
        break;
      case "Wednesday":
        selectDayList.add(3);
        break;
      case "Thursday":
        selectDayList.add(4);
        break;
      case "Friday":
        selectDayList.add(5);
        break;
      case "Saturday":
        selectDayList.add(6);
        break;
    }
  }
}
