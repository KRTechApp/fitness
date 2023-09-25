import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/providers/exercise_provider.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';

import '../admin_screen/admin_add_exercise.dart';
import 'custom_card.dart';
import 'exercise_details_bottom_sheet.dart';
import '../providers/workout_category_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/utils_methods.dart';

class TrainerExerciseListItemView extends StatefulWidget {
  final String userRole;
  final QueryDocumentSnapshot queryDocumentSnapshot;

  const TrainerExerciseListItemView({
    Key? key,
    required this.queryDocumentSnapshot,
    required this.userRole,
  }) : super(key: key);

  @override
  State<TrainerExerciseListItemView> createState() => _TrainerExerciseListItemViewState();
}

class _TrainerExerciseListItemViewState extends State<TrainerExerciseListItemView> {
  late ExerciseProvider exerciseProvider;
  late ShowProgressDialog progressDialog;
  late WorkoutCategoryProvider workoutCategoryProvider;

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);

    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 15),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                enableDrag: true,
                useRootNavigator: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                builder: (context) => ExerciseDetailsBottomSheet(
                    exerciseDataModel: null, queryDocumentSnapshot: widget.queryDocumentSnapshot),
              );
            },
            child: customCard(
              blurRadius: 5,
              radius: 15,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: FadeInImage(
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
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
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: width * 0.5,
                          child: Text(widget.queryDocumentSnapshot[keyExerciseTitle] ?? "",
                              maxLines: 1, style: GymStyle.listTitle, overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(
                          width: width * 0.5,
                          child: FutureBuilder(
                            // key: UniqueKey(),
                            future: workoutCategoryProvider.findWorkoutById(
                                createdBy: widget.queryDocumentSnapshot[keyCreatedBy],
                                categoryId: widget.queryDocumentSnapshot[keyCategoryId] ?? ""),
                            builder: (context, AsyncSnapshot<QueryDocumentSnapshot?> asyncSnapshot) {
                              if (asyncSnapshot.hasData && asyncSnapshot.data != null && asyncSnapshot.data!.exists) {
                                var documentSnapShot = asyncSnapshot.data as DocumentSnapshot;
                                debugPrint(
                                    'category ID And Created By${widget.queryDocumentSnapshot[keyCreatedBy] ?? ""}  ${widget.queryDocumentSnapshot[keyCategoryId] ?? ""}');
                                debugPrint('Category Title ${documentSnapShot[keyWorkoutCategoryTitle]}');
                                return SizedBox(
                                    width: width * 0.5,
                                    child: Text(documentSnapShot[keyWorkoutCategoryTitle] ?? "",
                                        maxLines: 1, style: GymStyle.listSubTitle, overflow: TextOverflow.ellipsis));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (widget.userRole == userRoleTrainer)
                      PopupMenuButton(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        onSelected: (selection) async {
                          switch (selection) {
                            case 1:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminAddExercise(
                                    selectedCategoryId: const [],
                                    viewType: 'edit',
                                    documentSnapshot: widget.queryDocumentSnapshot,
                                  ),
                                ),
                              );
                              break;
                            case 2:
                              deletePopup(widget.queryDocumentSnapshot);
                              break;
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 1,
                            padding: const EdgeInsets.only(
                              left: 17,right: 17
                            ),
                            child: Text(AppLocalizations.of(context)!.edit.firstCapitalize(), style: GymStyle.popupbox),
                          ),
                          PopupMenuItem(
                            value: 2,
                            padding: const EdgeInsets.only(
                              left: 17,right: 17
                            ),
                            child: Text(AppLocalizations.of(context)!.delete.firstCapitalize(),
                                style: GymStyle.popupboxdelate),
                          ),
                        ],
                        child: Container(
                          height: 35,
                          width: 30,
                          margin: const EdgeInsets.only(right: 20),
                          alignment: Alignment.center,
                          child: const Icon(Icons.more_vert, color: ColorCode.grayLight),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.015,
          )
        ],
      ),
    );
  }

  deletePopup(QueryDocumentSnapshot documentSnapshot) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: height * 0.01,
              ),
              Container(
                padding: const EdgeInsets.all(30),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF000E).withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset('assets/images/delete.svg'),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text(AppLocalizations.of(context)!.are_you_sure_want_to_delete, style: GymStyle.inputTextBold),
              Text((documentSnapshot[keyExerciseTitle] ?? "") + '?', style: GymStyle.inputTextBold),
              SizedBox(
                height: height * 0.03,
              ),
              Row(
                children: [
                  Container(
                    width: width * 0.3,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: ColorCode.mainColor,
                        width: 2,
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel.toUpperCase(),
                        style: TextStyle(
                            color: ColorCode.mainColor,
                            fontSize: getFontSize(17),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.04,
                  ),
                  Container(
                    width: width * 0.3,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        progressDialog.show(message: 'Loading...');
                        exerciseProvider.deleteMyExercise(exerciseId: documentSnapshot.id).then(
                              (value) => {
                                progressDialog.hide(),
                                Navigator.pop(context),
                              },
                            );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.delete.toUpperCase(),
                        style: TextStyle(
                            color: ColorCode.white,
                            fontSize: getFontSize(17),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
