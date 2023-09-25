import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/class_provider.dart';
import '../../utils/firebase_interface.dart';
import '../../utils/gym_style.dart';
import '../../utils/shared_preferences_manager.dart';
import '../../utils/show_progress_dialog.dart';
import '../Utils/color_code.dart';
import '../admin_screen/admin_add_workout_screen.dart';
import '../custom_widgets/TagView/tags.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/member_selection_model.dart';
import '../providers/member_provider.dart';
import '../providers/membership_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/static_data.dart';
import 'select_member_list.dart';
import 'tag_view_item_view.dart';

// ignore: must_be_immutable
class AddClass extends StatefulWidget {
  String viewType;
  final QueryDocumentSnapshot? documentSnapshot;

  AddClass({Key? key, required this.viewType, this.documentSnapshot}) : super(key: key);

  @override
  State<AddClass> createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  List<String> days = ["S", "M", "T", "W", "T", "F", "S"];
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte;
  ImagePicker picker = ImagePicker();
  XFile? image;
  var day = "";
  var classname = TextEditingController();
  var profile = '';
  var startDateMillisecond = 0;
  var endDateMillisecond = 0;
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();
  var startTime = TextEditingController();
  var virtualClassLink = TextEditingController();
  String urlValidator = "";
  bool showWorkout = false;
  String? selectedWorkout;
  var endTime = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String classType = "inPerson";
  DateTime initialTargetDate = DateTime.now();
  DateTime initialStartDate = DateTime.now();
  FirebaseInterface firebaseInterface = FirebaseInterface();
  late ClassProvider classProvider;
  late TrainerProvider trainerProvider;
  late WorkoutProvider workoutProvider;
  late MembershipProvider membershipProvider;
  DocumentSnapshot? trainerDoc, membershipDoc, workoutDoc;
  late MemberProvider memberProvider;
  List<String> selectedMemberList = [];
  String switchRole = "";

  // List<String> workoutSelectedMember = [];
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userTrainerId = "";
  String selectWorkoutId = "";
  String userRole = "";
  var selectedDateTime = DateTime.now();
  late ShowProgressDialog progressDialog;
  late final Function(String dayId, bool selected) onDaySelected;
  List<int> selectDayList = [];

  @override
  void initState() {
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    classProvider = Provider.of<ClassProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        selectTodayDay(selectedDateTime);
        userTrainerId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        debugPrint('userTrainerId $userTrainerId');
        switchRole = await _preference.getValue(keySwitchRole, "");

        debugPrint('SwitchRole : $switchRole');
        if (widget.documentSnapshot != null) {
          userTrainerId = widget.documentSnapshot![keyCreatedBy];
        }
        workoutProvider.getWorkoutOfTrainer(currentUserId: userTrainerId);
        memberProvider.getMemberList(isRefresh: true);
        trainerDoc = await trainerProvider.getSingleTrainer(userId: userTrainerId);

        // debugPrint('trainerDoc ${trainerDoc![keyCurrentMembership] ?? ""}');
        membershipDoc =
            await membershipProvider.getSingleMembership(membershipId: trainerDoc![keyCurrentMembership] ?? "");
        debugPrint('ClassLimit ${membershipDoc![keyClassLimit]}');
        debugPrint('viewType${widget.viewType}');
        setState(() {});
        if ((widget.viewType == "edit" || widget.viewType == "view") && widget.documentSnapshot != null) {
         progressDialog.show();
        workoutDoc = await workoutProvider.getSingleWorkout(workoutId: widget.documentSnapshot!.get(keyWorkoutId));
        progressDialog.hide();
          setState(
            () {
              classname.text = widget.documentSnapshot!.get(keyClassName);
              startDateMillisecond = widget.documentSnapshot!.get(keyStartDate);
              endDateMillisecond = widget.documentSnapshot!.get(keyEndDate);
              selectedWorkout = workoutDoc![keyWorkoutTitle] ?? "";
              selectWorkoutId = workoutDoc!.id;
              startDateController.text = DateFormat(StaticData.currentDateFormat)
                  .format(DateTime.fromMillisecondsSinceEpoch(startDateMillisecond));
              endDateController.text = DateFormat(StaticData.currentDateFormat)
                  .format(DateTime.fromMillisecondsSinceEpoch(endDateMillisecond));
              startTime.text = widget.documentSnapshot!.get(keyStartTime);
              endTime.text = widget.documentSnapshot!.get(keyEndTime);
              classType = widget.documentSnapshot!.get(keyClassType);
              selectedMemberList = List.castFrom(widget.documentSnapshot!.get(keySelectedMember) as List);
              selectDayList = List.castFrom(widget.documentSnapshot!.get(keySelectedDays) as List);
              virtualClassLink.text = widget.documentSnapshot!.get(keyVirtualClassLink);
            },
          );
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(true);
      },
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
          title: Text(
            widget.viewType == "view"
                ? AppLocalizations.of(context)!.view_class
                : (widget.viewType == "edit"
                    ? AppLocalizations.of(context)!.edit_class
                    : AppLocalizations.of(context)!.add_class),
          ),
          /* actions: [
            if (widget.viewType == "view")
              InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                splashColor: ColorCode.linearProgressBar,
                onTap: () {
                  debugPrint('edit icon click');
                  setState(
                    () {
                      widget.viewType = "edit";
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                  child: SvgPicture.asset(
                    height: 20,
                    width: 20,
                    'assets/images/editIcon.svg',
                    color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                  ),
                ),
              ),
          ],*/
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Stack(
            children: [
              SizedBox(
                height: height,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: classname,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_class_name;
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
                            labelText: AppLocalizations.of(context)!.class_name,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                        Row(
                          children: [
                            Consumer<WorkoutProvider>(
                              builder: (context, workoutData, child) => SizedBox(
                                width: width * 0.69,
                                height: height * 0.1,
                                child: Container(
                                  padding: const EdgeInsets.only(top: 16),
                                  alignment: Alignment.centerLeft,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      hint: Text(
                                          workoutData.addByTrainerWorkoutList.isEmpty
                                              ? AppLocalizations.of(context)!.please_add_workout
                                              : AppLocalizations.of(context)!.select_workout,
                                          overflow: TextOverflow.ellipsis,
                                          style: GymStyle.inputText),
                                      items: workoutData.addByTrainerWorkoutList
                                          .map(
                                            (item) => DropdownMenuItem<String>(
                                              value: item[keyWorkoutTitle] ?? "",
                                              child: Text(item[keyWorkoutTitle] ?? "",
                                                  overflow: TextOverflow.ellipsis, style: GymStyle.exerciseLableText),
                                            ),
                                          )
                                          .toList(),
                                      value: selectedWorkout,
                                      onMenuStateChange: (isOpen) {
                                        setState(
                                          () {
                                            showWorkout = isOpen;
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        showWorkout
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: const Color(0xFFADAEB0),
                                      ),
                                      onChanged: widget.viewType == "view"
                                          ? null
                                          : (String? value) {
                                              setState(
                                                () {
                                                  selectedWorkout = value ?? "";
                                                  QueryDocumentSnapshot queryDoc = workoutData.addByTrainerWorkoutList
                                                      .firstWhere((element) => element[keyWorkoutTitle] == value);
                                                  selectWorkoutId = queryDoc.id;
                                                  debugPrint('A1B2$selectedWorkout : $selectWorkoutId');
                                                  selectedMemberList.clear();
                                                  if ((queryDoc.data() as Map<String, dynamic>)
                                                      .containsKey(keySelectedMember)) {
                                                    List<String> workoutSelectedMember =
                                                        List.castFrom(queryDoc.get(keySelectedMember));
                                                    for (int i = 0; i < workoutSelectedMember.length; ) {
                                                      if (!selectedMemberList.contains(workoutSelectedMember[i])) {
                                                        selectedMemberList.addAll(workoutSelectedMember);
                                                      }
                                                      return;
                                                    }
                                                  }
                                                  // debugPrint('selectedWorkout : $workoutSelectedMember');
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
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: widget.viewType == "view"
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminAddWorkoutScreen(
                                              userId: userTrainerId, userRole: userRole, viewType: ""),
                                        ),
                                      );
                                    },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: DottedBorder(
                                  color: ColorCode.mainColor,
                                  strokeWidth: 1,
                                  borderType: BorderType.Circle,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [4, 4, 4, 4],
                                  strokeCap: StrokeCap.round,
                                  padding: const EdgeInsets.all(7),
                                  child: const Icon(Icons.add, color: ColorCode.mainColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            width: width * 0.7,
                            child:
                                Divider(height: 1, color: ColorCode.backgroundColor.withOpacity(0.40), thickness: 1)),
                        /*const SizedBox(
                          height: 20,
                        ),*/
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Text(AppLocalizations.of(context)!.member, style: GymStyle.inputText),
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
                              builder: (context, AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
                                if (asyncSnapshot.hasData) {
                                  var documentSnapShot = asyncSnapshot.data as DocumentSnapshot;
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
                                    msg: AppLocalizations.of(context)!.you_have_no_access,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                return;
                              }
                              MemberSelectionModel tempSelectedMember = (await Navigator.push(
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
                                      alreadySelectedMember: [], selectedMember: [], unselectedMember: []);
                              setState(
                                () {
                                  selectedMemberList = tempSelectedMember.selectedMember!;
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
                                    return AppLocalizations.of(context)!.please_enter_start_date;
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
                                    child: SvgPicture.asset('assets/images/calendar.svg'),
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
                                              DateFormat(StaticData.currentDateFormat).format(pickedDate);
                                          startDateMillisecond = pickedDate.millisecondsSinceEpoch;
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
                                    return AppLocalizations.of(context)!.please_enter_end_date;
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
                                    child: SvgPicture.asset('assets/images/calendar.svg'),
                                  ),
                                  labelStyle: GymStyle.inputText,
                                ),
                                readOnly: true,
                                onTap: widget.viewType == "view"
                                    ? null
                                    : () async {
                                        if (startDateController.text.isEmpty) {
                                          Fluttertoast.showToast(
                                              msg: AppLocalizations.of(context)!.please_enter_end_date,
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 3,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        } else {
                                          DateTime? pickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.fromMillisecondsSinceEpoch(startDateMillisecond),
                                            firstDate: DateTime.fromMillisecondsSinceEpoch(startDateMillisecond),
                                            lastDate: DateTime(2100),
                                          );
                                          if (pickedDate != null) {
                                            if (kDebugMode) {
                                              print(pickedDate);
                                            }
                                            String formattedDate =
                                                DateFormat(StaticData.currentDateFormat).format(pickedDate);
                                            endDateMillisecond = pickedDate.millisecondsSinceEpoch;
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
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: width * 0.41,
                              height: height * 0.1,
                              child: TextFormField(
                                controller: startTime,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(context)!.please_enter_start_time;
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
                                  labelText: AppLocalizations.of(context)!.start_time,
                                  suffixIcon: Container(
                                    padding: const EdgeInsets.all(13),
                                    child: SvgPicture.asset('assets/images/addClassWatch.svg'),
                                  ),
                                  labelStyle: GymStyle.inputText,
                                ),
                                readOnly: true,
                                onTap: widget.viewType == "view"
                                    ? null
                                    : () async {
                                        TimeOfDay? pickedTime;
                                        TimeOfDay initialTime = TimeOfDay.now();
                                        pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: initialTime,
                                        );
                                        if (pickedTime != null) {
                                          DateTime tempDate =
                                              DateFormat("hh:mm").parse("${pickedTime.hour}:${pickedTime.minute}");
                                          var dateFormat = DateFormat("h:mm a");
                                          var hourOfDay = dateFormat.format(tempDate);
                                          startTime.text = hourOfDay.toString();
                                        }
                                      },
                              ),
                            ),
                            SizedBox(
                              width: width * 0.09,
                            ),
                            SizedBox(
                              height: height * 0.1,
                              width: width * 0.41,
                              child: TextFormField(
                                controller: endTime,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(context)!.please_enter_end_time;
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
                                  labelText: AppLocalizations.of(context)!.end_time,
                                  suffixIcon: Container(
                                    padding: const EdgeInsets.all(13),
                                    child: SvgPicture.asset('assets/images/addClassWatch.svg'),
                                  ),
                                  labelStyle: GymStyle.inputText,
                                ),
                                readOnly: true,
                                onTap: widget.viewType == "view"
                                    ? null
                                    : () async {
                                        if (startTime.text.isEmpty) {
                                          Fluttertoast.showToast(
                                              msg: AppLocalizations.of(context)!.please_select_start_time,
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 3,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        } else {
                                          TimeOfDay? pickedTime;
                                          TimeOfDay initialTime = TimeOfDay.now();
                                          pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: initialTime,
                                          );
                                          if (pickedTime != null) {
                                            DateTime tempDate =
                                                DateFormat("hh:mm").parse("${pickedTime.hour}:${pickedTime.minute}");
                                            var dateFormat = DateFormat("h:mm a");
                                            var hourOfDay = dateFormat.format(tempDate);
                                            endTime.text = hourOfDay.toString();
                                          }
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 10),

                        /* const SizedBox(
                          height: 10,
                        ),*/
                        Text(
                          AppLocalizations.of(context)!.class_type,
                          style: GymStyle.inputText,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (StaticData.adminVirtualClass)
                              SizedBox(
                                height: height * 0.07,
                                width: width * 0.42,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  horizontalTitleGap: -5,
                                  title: Text(
                                    AppLocalizations.of(context)!.virtual_class,
                                    style: GymStyle.inputTextBold,
                                  ),
                                  leading: Radio(
                                    activeColor: ColorCode.mainColor,
                                    hoverColor: ColorCode.mainColor,
                                    value: "virtualClass",
                                    groupValue: classType,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          if (widget.viewType != 'view') {
                                            classType = value.toString();
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (StaticData.adminVirtualClass)
                              SizedBox(width: width * 0.05),
                            SizedBox(
                              height: height * 0.07,
                              width: width * 0.43,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                horizontalTitleGap: -5,
                                title: Text(
                                  AppLocalizations.of(context)!.in_person,
                                  style: GymStyle.inputTextBold,
                                ),
                                leading: Radio(
                                  activeColor: ColorCode.mainColor,
                                  hoverColor: ColorCode.mainColor,
                                  value: "inPerson",
                                  groupValue: classType,
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        if (widget.viewType != 'view') {
                                          classType = value.toString();
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (classType == 'virtualClass')
                          TextFormField(
                            controller: virtualClassLink,
                            cursorColor: ColorCode.mainColor,
                            keyboardType: TextInputType.url,
                            readOnly: widget.viewType == "view" ? true : false,
                            validator: (String? value) {
                              if (value != null &&
                                  value.trim().isNotEmpty &&
                                  RegExp(r"(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-],)?")
                                      .hasMatch(
                                    value.trim(),
                                  )) {
                                urlValidator = value.trim();
                                return null;
                              }
                              return AppLocalizations.of(context)!.please_enter_valid_link;
                            },
                            decoration: InputDecoration(
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorCode.mainColor,
                                ),
                              ),
                              border: const UnderlineInputBorder(),
                              labelText: AppLocalizations.of(context)!.virtual_class_link,
                              labelStyle: GymStyle.inputText,
                            ),
                          ),
                        SizedBox(height: classType.isEmpty ? height * 0.02 : height * 0.01),
                        Text(
                          AppLocalizations.of(context)!.select_days,
                          style: GymStyle.inputText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
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
                        const SizedBox(
                          height: 80,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: height * 0.08,
                  width: width * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.viewType == "view") {
                        Navigator.pop(context);
                        return;
                      }
                      if (formKey.currentState!.validate()) {
                        if (selectedMemberList.isEmpty) {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.please_select_member,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          if (widget.viewType == "edit") {
                            progressDialog.show(message: 'Loading...');
                            classProvider
                                .updateClass(
                                  workoutId: selectWorkoutId,
                                  classId: widget.documentSnapshot!.id,
                                  className: classname.text.trim().firstCapitalize(),
                                  startDate: startDateMillisecond,
                                  endDate: endDateMillisecond,
                                  startTime: startTime.text.trim(),
                                  endTime: endTime.text.trim(),
                                  classType: classType.trim(),
                                  userId: userTrainerId.trim(),
                                  selectedDays: selectDayList,
                                  selectedMember: selectedMemberList,
                                  virtualClassLink: urlValidator.trim(),
                                )
                                .then(
                                  ((defaultResponseData) => {
                                        progressDialog.hide(),
                                        if (defaultResponseData.status != null && defaultResponseData.status!)
                                          {
                                            Fluttertoast.showToast(
                                                msg: defaultResponseData.message ??
                                                    AppLocalizations.of(context)!.something_want_to_wrong,
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                                fontSize: 16.0),
                                            workoutProvider.assignWorkoutToMember(
                                                workoutId: selectWorkoutId, selectedMemberList: selectedMemberList),
                                            Navigator.pop(context)
                                          }
                                        else
                                          {
                                            progressDialog.hide(),
                                            Fluttertoast.showToast(
                                                msg: defaultResponseData.message ??
                                                    AppLocalizations.of(context)!.something_want_to_wrong,
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0)
                                          }
                                      }),
                                );
                          } else {
                            progressDialog.show();
                            if (switchRole == userRoleAdmin ||
                                (membershipDoc![keyClassLimit] ?? 0) > classProvider.classListItem.length) {
                              classProvider
                                  .addClassFirebase(
                                    workoutId: selectWorkoutId,
                                    className: classname.text.trim().firstCapitalize(),
                                    startDate: startDateMillisecond,
                                    endDate: endDateMillisecond,
                                    startTime: startTime.text.trim(),
                                    endTime: endTime.text.trim(),
                                    classType: classType.trim(),
                                    userId: userTrainerId.trim(),
                                    selectedDays: selectDayList,
                                    selectedMember: selectedMemberList,
                                    virtualClassLink: urlValidator.trim(),
                                  )
                                  .then(
                                    (defaultResponseData) => {
                                      progressDialog.hide(),
                                      if (defaultResponseData.status != null && defaultResponseData.status!)
                                        {
                                          Fluttertoast.showToast(
                                              msg: defaultResponseData.message ??
                                                  AppLocalizations.of(context)!.something_want_to_wrong,
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 3,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0),
                                          workoutProvider.assignWorkoutToMember(
                                              workoutId: selectWorkoutId, selectedMemberList: selectedMemberList),
                                          Navigator.pop(context)
                                        }
                                      else
                                        {
                                          progressDialog.hide(),
                                          Fluttertoast.showToast(
                                              msg: defaultResponseData.message ??
                                                  AppLocalizations.of(context)!.something_want_to_wrong,
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 3,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0)
                                        }
                                    },
                                  );
                            } else {
                              progressDialog.hide();
                              Fluttertoast.showToast(
                                  msg: "Your Class Limit is Over",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: ColorCode.mainColor,
                    ),
                    child: Text(
                      widget.viewType == "view"
                          ? AppLocalizations.of(context)!.go_back
                          : (widget.viewType == "edit"
                              ? AppLocalizations.of(context)!.save
                              : AppLocalizations.of(context)!.create_class),
                      style: GymStyle.buttonTextStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
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
