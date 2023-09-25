import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crossfit_gym_trainer/providers/exercise_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../Utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class WorkoutExerciseBottomSheet extends StatefulWidget {
  final String userId;
  final String workoutCategoryId;
  final String exerciseId;

  const WorkoutExerciseBottomSheet(
      {Key? key, required this.userId, required this.workoutCategoryId, required this.exerciseId})
      : super(key: key);

  @override
  State<WorkoutExerciseBottomSheet> createState() => _WorkoutExerciseBottomSheetState();
}

class _WorkoutExerciseBottomSheetState extends State<WorkoutExerciseBottomSheet> {
  String? exerciseId;
  late ExerciseProvider exerciseProvider;

  @override
  void initState() {
    super.initState();
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      exerciseId = widget.exerciseId;
      debugPrint("exerciseId : $exerciseId");
      debugPrint("workoutCategoryId : ${widget.workoutCategoryId}");
      await exerciseProvider.getCategoryExercise(
          createdBy: widget.userId, categoryId: widget.workoutCategoryId, isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SizedBox(
          width: width,
          height: height * 0.75,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset('assets/images/arrow-left.svg'),
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    AppLocalizations.of(context)!.select_exercise,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: height * 0.64,
              width: width,
              child: Consumer<ExerciseProvider>(
                builder: (context, exerciseData, child) => exerciseData.myExerciseListItem.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 70),
                        itemCount: exerciseData.myExerciseListItem.length,
                        scrollDirection: Axis.vertical,
                        // physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final QueryDocumentSnapshot documentSnapshot = exerciseData.myExerciseListItem[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: customCard(
                                  blurRadius: 5,
                                  radius: 15,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: FadeInImage(
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                            image: customImageProvider(
                                              url: documentSnapshot[keyProfile],
                                            ),
                                            placeholderFit: BoxFit.fitWidth,
                                            placeholder: customImageProvider(),
                                            imageErrorBuilder: (context, error, stackTrace) {
                                              return getPlaceHolder();
                                            },
                                          ),
                                        ),
                                      ),
                                      customMarquee(
                                          text: documentSnapshot[keyExerciseTitle] ?? "",
                                          textStyle: GymStyle.listTitle,
                                          width: 48.w,
                                          height: 25),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 20),
                                        child: Radio(
                                          activeColor: ColorCode.mainColor,
                                          value: documentSnapshot.id,
                                          groupValue: exerciseId,
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                exerciseId = value.toString();
                                              },
                                            );
                                          },
                                        ),
                                      )
                                    ],
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
                            CircleAvatar(
                              backgroundColor: ColorCode.tabDivider,
                              maxRadius: 45,
                              child: Image.asset('assets/images/empty_box.png'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                              child: Text(
                                AppLocalizations.of(context)!.you_do_not_have_any_exercise,
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
                          ],
                        ),
                      ),
              ),
            ),
          ]),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: SizedBox(
            height: height * 0.08,
            width: width * 0.9,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, exerciseId);
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: ColorCode.mainColor,
              ),
              child: Text(AppLocalizations.of(context)!.done, style: GymStyle.buttonTextStyle),
            ),
          ),
        ),
      ],
    );
  }
}
