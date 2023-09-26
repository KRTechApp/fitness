import 'package:blinking_text/blinking_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/providers/workout_history_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../custom_widgets/custom_card.dart';
import '../custom_widgets/youtube_full_screen.dart';
import '../model/workout_days_model.dart';
import '../utils/color_code.dart';
import '../utils/stop_watch_timer.dart';
import '../utils/utils_methods.dart';
import 'main_drawer_screen.dart';

class WorkoutExerciseDetailsScreen extends StatefulWidget {
  final Function() getRefreshExercise;
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final String workoutId;
  final DateTime selectedDateTime;
  final ExerciseDataItem exerciseDataModel;

  const WorkoutExerciseDetailsScreen({
    Key? key,
    required this.queryDocumentSnapshot,
    required this.exerciseDataModel,
    required this.workoutId,
    required this.getRefreshExercise,
    required this.selectedDateTime,
  }) : super(key: key);

  @override
  State<WorkoutExerciseDetailsScreen> createState() => _WorkoutExerciseDetailsScreenState();
}

class _WorkoutExerciseDetailsScreenState extends State<WorkoutExerciseDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late YoutubePlayerController _controller;
  var set = TextEditingController();
  var reps = TextEditingController();
  var sec = TextEditingController();
  var rest = TextEditingController();
  var weight = TextEditingController();
  late ShowProgressDialog showProgressDialog;
  late WorkoutHistoryProvider workoutHistoryProvider;
  NumberFormat formatter = NumberFormat("00");
  bool isStart = false;
  bool isTimerStart = false;
  String timerStatus = "";
  bool isPause = false;
  bool isMusicOn = true;
  String userRole = "";
  String userId = "";
  String? currentDocId;
  var refreshRequire = false;
  double totalProgress = 0.0;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  String? videoId = "";
  String displayTime = "00:00:00";
  final _isHours = true;
  final _isMin = true;
  final _isSec = true;
  int hourOfTask = 0;
  int minuteOfTask = 0;
  int secondOfTask = 0;

  @override
  void initState() {
    super.initState();

    debugPrint('Selected Date time : ${widget.selectedDateTime}');
    debugPrint('Selected Date time : ${widget.selectedDateTime.millisecondsSinceEpoch}');
    debugPrint('ImageUrl${widget.queryDocumentSnapshot[keyExerciseDetailImage]}');
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    workoutHistoryProvider = Provider.of<WorkoutHistoryProvider>(context, listen: false);
    videoId = YoutubePlayer.convertUrlToId(widget.queryDocumentSnapshot[keyYoutubeLink]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = await _preference.getValue(prefUserId, "");
      userRole = await _preference.getValue(prefUserRole, "");
      set.text = widget.exerciseDataModel.exerciseDataSet.toString();
      reps.text = widget.exerciseDataModel.exerciseDataReps.toString();
      sec.text = widget.exerciseDataModel.exerciseDataSec.toString();
      rest.text = widget.exerciseDataModel.exerciseDataRest.toString();
      weight.text = widget.exerciseDataModel.exerciseDataWeight.toString();
      debugPrint('setReps$set $reps $sec $rest');
      getExerciseData();
      setState(() {});
    });
    debugPrint('videoId: $videoId');
    _controller = YoutubePlayerController(
      initialVideoId: videoId.toString(),
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
    // debugPrint('${widget.queryDocumentSnapshot[keyExerciseDetailImage] ?? ""}');
  }

  void onFullScreen(bool isFullScreen) {
    if (isFullScreen) {
      debugPrint('isFullScreen Navigator: $isFullScreen');
      _controller.updateValue(_controller.value.copyWith(isFullScreen: !_controller.value.isFullScreen));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => YoutubeFullScreen(
                    videoId: videoId,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var descriptionList = (widget.queryDocumentSnapshot[keyDescription] ?? "").toString().split(".");
    return Scaffold(
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
              // color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
            ),
          ),
        ),
        title: Text(widget.queryDocumentSnapshot[keyExerciseTitle] ?? ""),
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.03,
              ),
              widget.queryDocumentSnapshot[keyExerciseDetailImage] != null &&
                      (widget.queryDocumentSnapshot[keyExerciseDetailImage] ?? "").toString().isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: height * 0.25,
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: FadeInImage(
                                image: customImageProvider(
                                  url: widget.queryDocumentSnapshot[keyExerciseDetailImage],
                                ),
                                placeholder: customImageProvider()),
                          )),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          height: height * 0.25,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: YoutubePlayer(
                            controller: _controller,
                            bottomActions: [
                              const CurrentPosition(),
                              const ProgressBar(
                                  isExpanded: true, colors: ProgressBarColors(backgroundColor: Colors.red)),
                              // PlayPauseButton(),
                              const RemainingDuration(),
                              FullScreenButton(controller: _controller, onFullScreen: onFullScreen),
                              const PlaybackSpeedButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // width: 130,
                    child: StreamBuilder<int>(
                      stream: _stopWatchTimer.rawTime,
                      initialData: _stopWatchTimer.rawTime.value,
                      builder: (context, snap) {
                        final value = snap.data!;
                        displayTime =
                            StopWatchTimer.getDisplayTime(value, hours: _isHours, minute: _isMin, second: _isSec);
                        debugPrint('displayTime : $displayTime');
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(9, 2, 9, 2),
                          child: isStart
                              ? BlinkText(displayTime,
                                  beginColor: ColorCode.backgroundColor,
                                  endColor: ColorCode.tabBarBackground,
                                  style: GymStyle.screenHeader)
                              : Text(displayTime, style: GymStyle.screenHeader),
                        );
                      },
                    ),
                  ),
                  Column(
                    children: [
                      if (!isTimerStart)
                        SizedBox(
                          height: 35,
                          width: 110,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isTimerStart = true;
                                timerStatus = "start";
                              });
                              _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                              setFirebaseData(onClick: "start");
                            },
                            style: GymStyle.buttonStyle,
                            child: Text(
                              AppLocalizations.of(context)!.start.allInCaps,
                              style: GymStyle.buttonTextStyle,
                            ),
                          ),
                        ),
                      if (isTimerStart)
                        Row(
                          children: [
                            SizedBox(
                              height: 35,
                              width: width * 0.29,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isPause) {
                                    setState(() {
                                      isPause = false;
                                      timerStatus = "resume";
                                    });
                                    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                                    setFirebaseData(onClick: "resume");
                                  } else {
                                    setState(() {
                                      isPause = true;
                                      timerStatus = "pause";
                                    });
                                    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                                    setFirebaseData(onClick: "pause");
                                  }
                                },
                                style: GymStyle.buttonStyle,
                                child: Text(
                                  isPause ? "Resume".allInCaps : AppLocalizations.of(context)!.pause.allInCaps,
                                  style: GymStyle.buttonTextStyleSmall,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 35,
                              width: width * 0.29,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    timerStatus = "stop";
                                    isTimerStart = false;
                                  });
                                  _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                                  setFirebaseData(onClick: "finish");
                                },
                                style: GymStyle.whiteButtonStyle,
                                child: Text(
                                  "finish".allInCaps,
                                  style: GymStyle.whitwButtonTextStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: customCard(
                  blurRadius: 5,
                  radius: 15,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 140,
                        width: width - 38,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.5,
                                    child: Text(widget.queryDocumentSnapshot[keyExerciseTitle] ?? "",
                                        maxLines: 1, style: GymStyle.listTitle, overflow: TextOverflow.ellipsis),
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 40,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        totalProgress = double.parse(set.text) /
                                            int.parse(widget.exerciseDataModel.exerciseDataSet!);
                                        setFirebaseData(onClick: "save");
                                        debugPrint('double.parse(set.text)  ${double.parse(set.text)}');
                                        debugPrint('widget.trainerDataSet ${widget.exerciseDataModel.exerciseDataSet}');
                                        debugPrint('total Progrss $totalProgress');
                                        hideKeyboard();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorCode.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          side: const BorderSide(
                                            width: 1.0,
                                            color: ColorCode.mainColor,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.save.toUpperCase(),
                                        style: const TextStyle(
                                            color: ColorCode.mainColor,
                                            fontSize: 16,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.15,
                                    height: height * 0.05,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: set,
                                      enableInteractiveSelection: false,
                                      maxLength: 3,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (value) {},
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_set;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          counterText: "",
                                          border: const OutlineInputBorder(),
                                          labelText: 'Set',
                                          labelStyle: GymStyle.inputText),
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: width * 0.15,
                                    height: height * 0.05,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: reps,
                                      enableInteractiveSelection: false,
                                      maxLength: 3,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_reps;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          counterText: "",
                                          border: const OutlineInputBorder(),
                                          labelText: 'Reps',
                                          labelStyle: GymStyle.inputText),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: width * 0.15,
                                    height: height * 0.05,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: sec,
                                      enableInteractiveSelection: false,
                                      maxLength: 3,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_sec;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          counterText: "",
                                          border: const OutlineInputBorder(),
                                          labelText: 'Sec',
                                          labelStyle: GymStyle.inputText),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: width * 0.15,
                                    height: height * 0.05,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: rest,
                                      enableInteractiveSelection: false,
                                      maxLength: 3,
                                      textInputAction: TextInputAction.done,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_rest;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          counterText: "",
                                          border: const OutlineInputBorder(),
                                          labelText: 'Rest',
                                          labelStyle: GymStyle.inputText),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: width * 0.18,
                                    height: height * 0.05,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: weight,
                                      enableInteractiveSelection: false,
                                      maxLength: 3,
                                      textInputAction: TextInputAction.done,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_your_weight;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          counterText: "",
                                          border: const OutlineInputBorder(),
                                          labelText: 'Weight',
                                          labelStyle: GymStyle.inputText),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: customCard(
                  blurRadius: 5,
                  radius: 15,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                image: customImageProvider(
                                  url: widget.queryDocumentSnapshot[keyProfile],
                                ),
                                placeholderFit: BoxFit.fitWidth,
                                placeholder: customImageProvider(),
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return getPlaceHolder();
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.queryDocumentSnapshot[keyExerciseTitle] ?? "", style: GymStyle.listTitle),
                                  /*RichText(
                                    text: TextSpan(
                                      text: 'Body Parts: ',
                                      style: GymStyle.exerciseLableText,
                                      children: [
                                        TextSpan(text: 'Triceps', style: GymStyle.Des),
                                      ],
                                    ),
                                  ),*/
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 8),
                          child: Text(AppLocalizations.of(context)!.description, style: GymStyle.desTitle),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ListView.builder(
                              padding: const EdgeInsets.only(top: 10),
                              itemCount: descriptionList.length,
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if (descriptionList[index].isEmpty) {
                                  return const Text("");
                                }
                                int number = index + 1;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 20, child: Text("$number.", style: GymStyle.des)),
                                    SizedBox(
                                        width: 72.w,
                                        child: Text(descriptionList[index].trim(),
                                            style: GymStyle.des, textAlign: TextAlign.justify)),
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    setFirebaseData(showProgress: false);
    super.dispose();
  }

  Future<void> getExerciseData() async {
    try {
      List<String> timeParts;
      workoutHistoryProvider
          .getWorkoutHistory(
              workoutId: widget.workoutId,
              exerciseId: widget.queryDocumentSnapshot.id,
              createBy: userId,
              createAt: widget.selectedDateTime.millisecondsSinceEpoch)
          .then((document) => {
                if (document != null)
                  {
                    set.text = document.get(keySet),
                    sec.text = document.get(keySec),
                    reps.text = document.get(keyReps),
                    rest.text = document.get(keyRest),
                    weight.text = document.get(keyWorkoutWeight),
                    if (set.text.trim().isEmpty)
                      {
                        set.text = widget.exerciseDataModel.exerciseDataSet.toString(),
                      },
                    if (sec.text.trim().isEmpty)
                      {
                        sec.text = widget.exerciseDataModel.exerciseDataSec.toString(),
                      },
                    if (rest.text.trim().isEmpty)
                      {
                        rest.text = widget.exerciseDataModel.exerciseDataRest.toString(),
                      },
                    if (weight.text.trim().isEmpty)
                      {
                        weight.text = widget.exerciseDataModel.exerciseDataWeight.toString(),
                      },
                    if (reps.text.trim().isEmpty)
                      {
                        reps.text = widget.exerciseDataModel.exerciseDataReps.toString(),
                      },
                    currentDocId = document.id,
                    displayTime = document.get(keyExerciseTime),
                    timerStatus = document.get(keyTimerStatus),
                    timeParts = displayTime.split(':'),
                    _stopWatchTimer.clearPresetTime(),
                    _stopWatchTimer.setPresetHoursTime(int.parse(timeParts[0])),
                    _stopWatchTimer.setPresetMinuteTime(int.parse(timeParts[1])),
                    _stopWatchTimer.setPresetSecondTime(int.parse(timeParts[2])),
                    debugPrint('document: $displayTime'),
                    if (timerStatus == "start")
                      {
                        _stopWatchTimer.onExecute.add(StopWatchExecute.start),
                        setState(() {
                          isTimerStart = true;
                        })
                      }
                  }
                else
                  {
                    currentDocId = null,
                    if (set.text.trim().isEmpty)
                      {
                        set.text = widget.exerciseDataModel.exerciseDataSet.toString(),
                        debugPrint('TrainerSet : ${set.text}'),
                      },
                    if (sec.text.trim().isEmpty)
                      {
                        sec.text = widget.exerciseDataModel.exerciseDataSec.toString(),
                        debugPrint('TrainerSec : ${sec.text}'),
                      },
                    if (rest.text.trim().isEmpty)
                      {
                        rest.text = widget.exerciseDataModel.exerciseDataRest.toString(),
                        debugPrint('TrainerRest : ${rest.text}'),
                      },
                    if (weight.text.trim().isEmpty)
                      {
                        weight.text = widget.exerciseDataModel.exerciseDataWeight.toString(),
                        debugPrint('TrainerRest : ${weight.text}'),
                      },
                    if (reps.text.trim().isEmpty)
                      {
                        reps.text = widget.exerciseDataModel.exerciseDataReps.toString(),
                        debugPrint('TrainerReps : ${reps.text}'),
                      },
                    /*set.clear(),
                  sec.clear(),
                  reps.clear(),
                  rest.clear(),*/
                  }
              });
    } catch (e) {}
  }

  void setFirebaseData({bool showProgress = true, String onClick = ""}) {
    if (currentDocId != null) {
      if (showProgress) {
        showProgressDialog.show();
      }
      workoutHistoryProvider
          .updateWorkotHistory(
        memberTrainerId: widget.queryDocumentSnapshot[keyCreatedBy] ?? "",
        exerciseProgress: totalProgress.toString(),
        currentDocId: currentDocId.toString(),
        createdBy: userId,
        sec: sec.text.trim().toString(),
        set: set.text.trim().toString(),
        reps: reps.text.trim().toString(),
        rest: rest.text.trim().toString(),
        weight: weight.text.trim().toString(),
        exerciseTime: displayTime,
        timerStatus: timerStatus,
      )
          .then((defaultResponse) {
        if (showProgress) {
          showProgressDialog.hide();
        }
        if (defaultResponse.status != null && defaultResponse.status!) {
          if (showProgress) {
            Fluttertoast.showToast(
                msg: getMessage(onClickType: onClick),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          widget.getRefreshExercise();
        } else {
          if (showProgress) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.exercise_already_exist,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        }
      });
    } else {
      if (showProgress) {
        showProgressDialog.show();
      }
      workoutHistoryProvider
          .addWorkoutHistory(
        memberTrainerId: widget.queryDocumentSnapshot[keyCreatedBy] ?? "",
        exerciseProgress: totalProgress.toString(),
        workoutId: widget.workoutId,
        workoutCategoryId: widget.queryDocumentSnapshot[keyCategoryId] ?? "",
        exerciseId: widget.queryDocumentSnapshot.id,
        createdBy: userId,
        createAt: widget.selectedDateTime.millisecondsSinceEpoch,
        set: set.text.trim().toString(),
        sec: sec.text.trim().toString(),
        reps: reps.text.trim().toString(),
        rest: rest.text.trim().toString(),
        weight: weight.text.trim().toString(),
        exerciseTime: displayTime,
        timerStatus: timerStatus,
      )
          .then((defaultResponse) {
        if (showProgress) {
          showProgressDialog.hide();
        }
        if (defaultResponse.status != null && defaultResponse.status!) {
          if (showProgress) {
            Fluttertoast.showToast(
                msg: getMessage(onClickType: onClick),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          currentDocId = defaultResponse.responseData;
          widget.getRefreshExercise();
        } else {
          if (showProgress) {
            Fluttertoast.showToast(
                msg: getMessage(onClickType: onClick),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        }
      });
    }
  }

  String getMessage({required String onClickType}) {
    String toastMessage = "";
    switch (onClickType) {
      case "save":
        toastMessage = AppLocalizations.of(context)!.exercise_data_update_successfully;
        break;
      case "start":
        toastMessage = AppLocalizations.of(context)!.exercise_started_successfully;
        break;
      case "pause":
        toastMessage = AppLocalizations.of(context)!.exercise_paused_successfully;
        break;
      case "resume":
        toastMessage = AppLocalizations.of(context)!.exercise_resume_successfully;
        break;
      case "finish":
        toastMessage = AppLocalizations.of(context)!.exercise_finished_successfully;
        break;
    }
    return toastMessage;
  }
}
