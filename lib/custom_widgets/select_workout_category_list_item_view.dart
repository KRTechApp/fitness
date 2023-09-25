import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class SelectWorkoutCategoryListItemView extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;
  final int index;
  final List<String> selectedCategoryList;
  final Function(String categoryId, bool selected) onCategorySelected;

  const SelectWorkoutCategoryListItemView(
      {Key? key,
      required this.documentSnapshot,
      required this.index,
      required this.selectedCategoryList,
      required this.onCategorySelected})
      : super(key: key);

  @override
  State<SelectWorkoutCategoryListItemView> createState() => _SelectWorkoutCategoryListItemViewState();
}

class _SelectWorkoutCategoryListItemViewState extends State<SelectWorkoutCategoryListItemView> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (widget.selectedCategoryList.contains(widget.documentSnapshot.id)) {
              widget.onCategorySelected(widget.documentSnapshot.id, false);
            } else {
              widget.onCategorySelected(widget.documentSnapshot.id, true);
            }
            /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddWorkoutCategory(
                  documentSnapshot: widget.documentSnapshot,
                  viewType: "view",
                ),
              ),
            );*/
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
                          url: widget.documentSnapshot[keyProfile],
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
                    width: (widget.selectedCategoryList.contains(widget.documentSnapshot.id))
                        ? width * 0.38
                        : width * 0.43,
                    child: Text(widget.documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                        maxLines: 1, style: GymStyle.listTitle, overflow: TextOverflow.ellipsis),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.selectedCategoryList.contains(widget.documentSnapshot.id)) {
                        widget.onCategorySelected(widget.documentSnapshot.id, false);
                      } else {
                        widget.onCategorySelected(widget.documentSnapshot.id, true);
                      }
                    },
                    style: (widget.selectedCategoryList.contains(widget.documentSnapshot.id))
                        ? ElevatedButton.styleFrom(
                            backgroundColor: ColorCode.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(
                                width: 1.0,
                                color: ColorCode.mainColor,
                              ),
                            ),
                          )
                        : ElevatedButton.styleFrom(
                            backgroundColor: ColorCode.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                    child: Text(
                      (widget.selectedCategoryList.contains(widget.documentSnapshot.id))
                          ? AppLocalizations.of(context)!.selected.allInCaps
                          : AppLocalizations.of(context)!.select.allInCaps,
                      style: TextStyle(
                          color: (widget.selectedCategoryList.contains(widget.documentSnapshot.id))
                              ? ColorCode.mainColor
                              : ColorCode.white,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: height * 0.015,
        ),
      ],
    );
  }
}
