import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class ExerciseListItemView extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final List<String> selectExercise;
  final Function(String selectedId, bool selected) onExerciseItemSelected;

  const ExerciseListItemView(
      {Key? key,
      required this.queryDocumentSnapshot,
      required this.selectExercise,
      required this.onExerciseItemSelected})
      : super(key: key);

  @override
  State<ExerciseListItemView> createState() => _ExerciseListItemViewState();
}

class _ExerciseListItemViewState extends State<ExerciseListItemView> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 15),
      child: Column(
        children: [
          customCard(
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
                  SizedBox(
                    width: width * 0.33,
                    child: Text(widget.queryDocumentSnapshot[keyExerciseTitle] ?? "",
                        maxLines: 1, style: GymStyle.listTitle, overflow: TextOverflow.ellipsis),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: width * 0.285,
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
                        if (widget.selectExercise.contains(widget.queryDocumentSnapshot.id)) {
                          widget.onExerciseItemSelected(widget.queryDocumentSnapshot.id, false);
                        } else {
                          widget.onExerciseItemSelected(widget.queryDocumentSnapshot.id, true);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.select.toUpperCase(),
                        style: const TextStyle(
                            color: ColorCode.white,
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
          ),
          SizedBox(
            height: height * 0.015,
          )
        ],
      ),
    );
  }
}
