import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../model/exercise_data_model.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';
import 'youtube_full_screen.dart';

class ExerciseDetailsBottomSheet extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final ExerciseDataModel? exerciseDataModel;

  const ExerciseDetailsBottomSheet({
    Key? key,
    required this.queryDocumentSnapshot,
    required this.exerciseDataModel,
  }) : super(key: key);

  @override
  ExerciseDetailsBottomSheetState createState() => ExerciseDetailsBottomSheetState();
}

class ExerciseDetailsBottomSheetState extends State<ExerciseDetailsBottomSheet> {
  late YoutubePlayerController _controller;
  late ShowProgressDialog showProgressDialog;
  var set = TextEditingController();
  var reps = TextEditingController();
  var sec = TextEditingController();
  var rest = TextEditingController();

  String? videoId = "";

  @override
  void initState() {
    super.initState();
    if (widget.exerciseDataModel != null) {
      rest.text = widget.exerciseDataModel!.exerciseDataRest.toString();
      reps.text = widget.exerciseDataModel!.exerciseDataReps.toString();
      sec.text = widget.exerciseDataModel!.exerciseDataSec.toString();
      set.text = widget.exerciseDataModel!.exerciseDataSet.toString();
    }

    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    videoId = YoutubePlayer.convertUrlToId(widget.queryDocumentSnapshot[keyYoutubeLink]);
    debugPrint('videoId: $videoId');
    _controller = YoutubePlayerController(
      initialVideoId: videoId.toString(),
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        enableCaption: true,
      ),
    );
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
    return SizedBox(
      height: height * 0.8,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 5, left: 0),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/images/arrow-left.svg',
                      width: 18,
                      height: 18,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 5, right: 0, left: 0, bottom: 0),
                  child: Text(
                    widget.queryDocumentSnapshot[keyExerciseTitle] ?? "",
                    style: GymStyle.screenHeader,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: (height * 0.8) - 54,
            width: width,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  const ProgressBar(isExpanded: true),
                                  // PlayPauseButton(),
                                  const RemainingDuration(),
                                  FullScreenButton(controller: _controller, onFullScreen: onFullScreen),
                                  const PlaybackSpeedButton(),
                                ],
                              ),
                              /* child: _controller.value.isPlaying
                                    ? AspectRatio(
                                        aspectRatio: _controller.value.playerState,
                                        child: YoutubePlayer(controller: _controller,),
                                      )
                                    : Container(),*/
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (widget.exerciseDataModel != null)
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
                                          child: Text(AppLocalizations.of(context)!.exercise_goals,
                                              maxLines: 1, style: GymStyle.listTitle, overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 15),
                                        child: SizedBox(
                                          width: width * 0.183,
                                          height: height * 0.05,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            readOnly: true,
                                            controller: set,
                                            onChanged: (value) {},
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return AppLocalizations.of(context)!.please_enter_set;
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                                border: const OutlineInputBorder(),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.20))),
                                                labelText: AppLocalizations.of(context)!.set,
                                                labelStyle: GymStyle.inputText),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.03,
                                      ),
                                      SizedBox(
                                        width: width * 0.183,
                                        height: height * 0.05,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          readOnly: true,
                                          controller: reps,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return AppLocalizations.of(context)!.please_enter_reps;
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.20))),
                                              border: const OutlineInputBorder(),
                                              labelText: AppLocalizations.of(context)!.reps,
                                              labelStyle: GymStyle.inputText),
                                          onChanged: (value) {},
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.03,
                                      ),
                                      SizedBox(
                                        width: width * 0.183,
                                        height: height * 0.05,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          readOnly: true,
                                          controller: sec,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return AppLocalizations.of(context)!.please_enter_sec;
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.20))),
                                              border: const OutlineInputBorder(),
                                              labelText: AppLocalizations.of(context)!.sec,
                                              labelStyle: GymStyle.inputText),
                                          onChanged: (value) {},
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.03,
                                      ),
                                      SizedBox(
                                        width: width * 0.183,
                                        height: height * 0.05,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          readOnly: true,
                                          controller: rest,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return AppLocalizations.of(context)!.please_enter_rest;
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.20))),
                                              border: const OutlineInputBorder(),
                                              labelText: AppLocalizations.of(context)!.rest,
                                              labelStyle: GymStyle.inputText),
                                          onChanged: (value) {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
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
                                      Text(widget.queryDocumentSnapshot[keyExerciseTitle] ?? "",
                                          style: GymStyle.listTitle),
                                      /* RichText(
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
        ],
      ),
    );
  }
}
