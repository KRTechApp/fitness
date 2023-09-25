import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/providers/specialization_provider.dart';
import 'package:crossfit_gym_trainer/providers/trainer_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../mobile_pages/trainer_profile_screen_old.dart';
import '../providers/payment_history_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class TrainerListItemView extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final String currentUserId;

  const TrainerListItemView({Key? key, required this.queryDocumentSnapshot, required this.currentUserId}) : super(key: key);

  @override
  State<TrainerListItemView> createState() => _TrainerListItemViewState();
}

class _TrainerListItemViewState extends State<TrainerListItemView> {
  late TrainerProvider trainerProvider;
  late MembershipProvider membershipProvider;
  late ShowProgressDialog progressDialog;
  late SpecializationProvider specializationProvider;

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    specializationProvider = Provider.of<SpecializationProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrainerProfileScreenOld(
                    trainerId: widget.queryDocumentSnapshot.id,
                  ),
                ),
              );
            },
            child: customCard(
              blurRadius: 5,
              radius: 15,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 10, 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FadeInImage(
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: width * 0.33,
                              child: Text(
                                widget.queryDocumentSnapshot[keyName] ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GymStyle.listTitle,
                              ),
                            ),
                            if (widget.currentUserId.isNotEmpty && widget.queryDocumentSnapshot.get(keyCurrentMembership) != null)
                              FutureBuilder(
                                future: membershipProvider.getMembershipFromId(
                                  currentUserId: widget.currentUserId,
                                  membershipId: widget.queryDocumentSnapshot.get(keyCurrentMembership),
                                ),
                                builder: (context, AsyncSnapshot<String> asyncSnapshot) {
                                  if (asyncSnapshot.hasData) {
                                    var membershipList = asyncSnapshot.data != null ? asyncSnapshot.data as String : "";
                                    debugPrint("membershipList : $membershipList");
                                    return SizedBox(
                                      width: 50.w,
                                      child: Text(
                                        membershipList.isEmpty ? AppLocalizations.of(context)!.no_package_assigned : membershipList,
                                        maxLines: 1,
                                        style: GymStyle.italicText,
                                      ),
                                    );
                                  }
                                  return Text(
                                    AppLocalizations.of(context)!.assign_membership,
                                    style: GymStyle.italicText,
                                  );
                                },
                              ),
                            FutureBuilder(
                              future: specializationProvider.getSpecializationListInSingleString(
                                specializationIdList: List.castFrom(
                                  widget.queryDocumentSnapshot.get(keySpecialization),
                                ),
                              ),
                              builder: (context, AsyncSnapshot<String> asyncSnapshot) {
                                if (asyncSnapshot.hasData) {
                                  var specialization = asyncSnapshot.data != null ? asyncSnapshot.data as String : "";
                                  return SizedBox(
                                    width: 50.w,
                                    child: Text(
                                      specialization,
                                      maxLines: 1,
                                      style: GymStyle.listSubTitle,
                                    ),
                                  );
                                }
                                return Text(
                                  AppLocalizations.of(context)!.specialization_list,
                                  style: GymStyle.italicText,
                                );
                              },
                            ),
                          ],
                        ),
                        const Spacer(),
                        if(StaticData.canEditField)
                        InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(50),
                          ),
                          splashColor: ColorCode.linearProgressBar,
                          onTap: () {
                            // progressDialog.show();
                            deletePopup(widget.queryDocumentSnapshot);
                            // progressDialog.hide();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, top: 35),
                            child: SvgPicture.asset('assets/images/delete.svg'),
                          ),
                        )
                      ],
                    ),
                    if (widget.queryDocumentSnapshot.get(keyCurrentMembership) != null &&
                        widget.queryDocumentSnapshot.get(keyCurrentMembership).toString().isNotEmpty)
                      Positioned(
                        top: 10,
                        right: -13,
                        child: FutureBuilder(
                          future: Provider.of<PaymentHistoryProvider>(context, listen: false).getMyPaymentById(
                              membershipId: widget.queryDocumentSnapshot.get(keyCurrentMembership),
                              createdBy: widget.queryDocumentSnapshot.get(keyCreatedBy),
                              createdAt: widget.queryDocumentSnapshot.get(keyMembershipTimestamp),
                              createdFor: widget.queryDocumentSnapshot.id),
                          builder: (context, AsyncSnapshot<QueryDocumentSnapshot?> asyncSnapshot) {
                            if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                              var historyDoc = asyncSnapshot.data;
                              debugPrint("membershipList : ${historyDoc![keyPeriod]}");
                              int dateGap = DateTime.now()
                                  .difference(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      widget.queryDocumentSnapshot.get(keyMembershipTimestamp),
                                    ),
                                  )
                                  .inDays;
                              int extendedDays = historyDoc[keyExtendDate];
                              int leftMemberShip = (historyDoc[keyPeriod] + extendedDays) - dateGap;
                              return Container(
                                height: 30,
                                width: width * 0.33,
                                decoration: BoxDecoration(
                                  color: leftMemberShip > 0 ? ColorCode.mainColor : ColorCode.adminProfileLogoutColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 5, 5, 5),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset('assets/images/addClassWatch.svg', color: Colors.white),
                                      if (widget.currentUserId.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            leftMemberShip > 0
                                                ? '$leftMemberShip ${AppLocalizations.of(context)!.days_left}'
                                                : AppLocalizations.of(context)!.expired,
                                            style: TextStyle(color: ColorCode.white, fontSize: getFontSize(13)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.015,
          ),
        ],
      ),
    );
  }

  deletePopup(QueryDocumentSnapshot documentSnapshot) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
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
              Text(AppLocalizations.of(context)!.are_you_sure_want_to_delete, style: GymStyle.inputTextBold),
              Text((documentSnapshot[keyName] ?? "") + '?', style: GymStyle.inputTextBold),
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
                        progressDialog.show();
                        await trainerProvider.deleteTrainer(trainerId: documentSnapshot.id);
                        progressDialog.hide();
                        if(context.mounted) {
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
