import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/Utils/color_code.dart';
import 'package:crossfit_gym_trainer/custom_widgets/custom_card.dart';
import 'package:crossfit_gym_trainer/providers/nutrition_provider.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NutritionListItemView extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;
  final NutritionProvider nutritionProvider;
  final String userRole;

  const NutritionListItemView(
      {super.key,
      required this.documentSnapshot,
      required this.nutritionProvider, required this.userRole});

  @override
  State<NutritionListItemView> createState() => _NutritionListItemViewState();
}

class _NutritionListItemViewState extends State<NutritionListItemView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: customCard(
        blurRadius: 5,
        radius: 15,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    color: const Color(0xFF6842FF).withOpacity(0.10),
                    child: SvgPicture.asset(
                      fit: BoxFit.contain,
                      'assets/images/nutrition.svg',
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.48,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.documentSnapshot[keyNutritionName] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GymStyle.listTitle,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    RichText(
                      text: TextSpan(
                        text: DateFormat(StaticData.currentDateFormat).format(
                            DateTime.fromMillisecondsSinceEpoch(
                                widget.documentSnapshot.get(keyStartDate))),
                        style: GymStyle.listSubTitle,
                        children: <TextSpan>[
                          TextSpan(
                            text: AppLocalizations.of(context)!.to,
                          ),
                          TextSpan(
                              text: DateFormat(StaticData.currentDateFormat)
                                  .format(DateTime.fromMillisecondsSinceEpoch(
                                      widget.documentSnapshot.get(keyEndDate))),
                              style: GymStyle.listSubTitle),
                        ],
                      ),
                    ),
                    /*const SizedBox(
                      height: 5,
                    ),
                    Text(getSelectedDay(widget.documentSnapshot),
                        maxLines: 1, style: GymStyle.listSubTitle),*/
                  ],
                ),
              ),
              const Spacer(),
              if(widget.userRole != userRoleMember)
              InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                splashColor: ColorCode.linearProgressBar,
                onTap: () {
                  // progressDialog.show();
                  deletePopup(widget.documentSnapshot);
                  // progressDialog.hide();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: SvgPicture.asset('assets/images/delete.svg'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getSelectedDay(QueryDocumentSnapshot documentSnapshot) {
    var dayListString = "";
    List<int> selectDayList = [];
    selectDayList =
        List.castFrom(documentSnapshot.get(keySelectedDays) as List);
    // debugPrint("selected day list : $selectDayList");
    for (var i = 0; i < selectDayList.length; i++) {
      dayListString = dayListString +
          (getDay(
            selectDayList[i],
          ).isNotEmpty
              ? "${dayListString.isNotEmpty ? " | " : ""}${getDay(
                  selectDayList[i],
                )}"
              : "");
    }
    return dayListString;
  }

  deletePopup(QueryDocumentSnapshot documentSnapshot) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    late ShowProgressDialog showProgressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
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
              Text(AppLocalizations.of(context)!.are_you_sure_want_to_delete,
                  style: GymStyle.inputTextBold),
              Text((documentSnapshot[keyNutritionName] ?? "") + '?',
                  style: GymStyle.inputTextBold),
              SizedBox(
                height: height * 0.03,
              ),
              Row(
                children: [
                  Container(
                    width: width * 0.3,
                    height: 45,
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
                        // trainerProvider.deleteTrainer(trainerId: documentSnapshot.id);
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
                    height: 45,
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
                      onPressed: () async {
                        showProgressDialog.show();
                        await widget.nutritionProvider
                            .deleteNutrition(nutritionId: documentSnapshot.id);
                        showProgressDialog.hide();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
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
