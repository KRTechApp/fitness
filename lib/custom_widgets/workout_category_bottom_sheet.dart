import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../providers/workout_category_provider.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class WorkoutCategoryBottomSheet extends StatefulWidget {
  final String userId;
  final String selectedCategory;

  const WorkoutCategoryBottomSheet({Key? key, required this.userId, required this.selectedCategory}) : super(key: key);

  @override
  State<WorkoutCategoryBottomSheet> createState() => _WorkoutCategoryBottomSheetState();
}

class _WorkoutCategoryBottomSheetState extends State<WorkoutCategoryBottomSheet> {
  late WorkoutCategoryProvider workoutCategoryProvider;
  String? workoutCategoryId;

  @override
  void initState() {
    super.initState();
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      workoutCategoryId = widget.selectedCategory;
      await workoutCategoryProvider.getWorkoutCategoryList(isRefresh: true, createdBy: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SizedBox(
          height: height * 0.75,
          width: width,
          child: Column(
            children: [
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
                      AppLocalizations.of(context)!.select_exercise_category,
                      style: TextStyle(fontSize: getFontSize(20), fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: height * 0.65,
                width: width,
                child: Consumer<WorkoutCategoryProvider>(
                  builder: (context, workoutCategoryData, child) =>
                      workoutCategoryProvider.workoutCategoryItem.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(top: 10, bottom: 70),
                              itemCount: workoutCategoryProvider.workoutCategoryItem.length,
                              scrollDirection: Axis.vertical,
                              // physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final QueryDocumentSnapshot documentSnapshot =
                                    workoutCategoryData.workoutCategoryItem[index];
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
                                            SizedBox(
                                              width: width * 0.45,
                                              child: Text(documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                                  maxLines: 1,
                                                  style: GymStyle.listTitle,
                                                  overflow: TextOverflow.ellipsis),
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 20),
                                              child: Radio(
                                                activeColor: ColorCode.mainColor,
                                                value: documentSnapshot.id,
                                                groupValue: workoutCategoryId,
                                                onChanged: (value) {
                                                  setState(
                                                    () {
                                                      workoutCategoryId = value.toString();
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
                                      AppLocalizations.of(context)!.you_do_not_have_any_workout_category,
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
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: SizedBox(
            height: height * 0.08,
            width: width * 0.9,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, workoutCategoryId);
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
