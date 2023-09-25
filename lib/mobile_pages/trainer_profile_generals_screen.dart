import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/providers/specialization_provider.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/member_provider.dart';
import '../providers/payment_history_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';

class TrainerProfileGeneral extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final String userId;

  const TrainerProfileGeneral({Key? key, required this.documentSnapshot, required this.userId}) : super(key: key);

  @override
  State<TrainerProfileGeneral> createState() => _TrainerProfileGeneralState();
}

class _TrainerProfileGeneralState extends State<TrainerProfileGeneral> {
  late SpecializationProvider specializationProvider;
  late MembershipProvider membershipProvider;
  late MemberProvider memberProvider;

  @override
  void initState() {
    super.initState();
    specializationProvider = Provider.of<SpecializationProvider>(context, listen: false);
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await memberProvider.getMemberOfTrainer(createdById: widget.documentSnapshot.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    debugPrint('spe_list : ${widget.documentSnapshot.get(keySpecialization)}');
    List<String> specializationList = List.castFrom(widget.documentSnapshot.get(keySpecialization) as List);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: SizedBox(
          width: width,
          height: height * 0.75,
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  children: [
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.23,
                          child: Text(AppLocalizations.of(context)!.email.allInCaps,
                              maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        customMarquee(
                          width: width * 0.559,
                          text: widget.documentSnapshot[keyEmail] ?? "",
                          textStyle: GymStyle.popupbox,
                          height: height * 0.036,
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                    Row(
                      children: [
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.23,
                          child:
                              Text(AppLocalizations.of(context)!.dob.allInCaps, maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.559,
                          child: Text(
                              widget.documentSnapshot[keyDateOfBirth] != null
                                  ? DateFormat(StaticData.currentDateFormat).format(
                                      DateTime.fromMillisecondsSinceEpoch(widget.documentSnapshot[keyDateOfBirth]))
                                  : "-",
                              maxLines: 1,
                              style: GymStyle.popupbox),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                    Row(
                      children: [
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.23,
                          child: Text(AppLocalizations.of(context)!.gender.allInCaps,
                              maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.559,
                          child: Text(
                              widget.documentSnapshot[keyGender] == "male"
                                  ? "Male"
                                  : widget.documentSnapshot[keyGender] == "female"
                                      ? "Female"
                                      : "",
                              maxLines: 1,
                              style: GymStyle.popupbox),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                    Row(
                      children: [
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.23,
                          child: Text(AppLocalizations.of(context)!.mobile.allInCaps,
                              maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.559,
                          child: Text(
                              '+${widget.documentSnapshot[keyCountryCode] ?? ""} ${widget.documentSnapshot[keyPhone] ?? ""}',
                              maxLines: 1,
                              style: GymStyle.popupbox),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                    Row(
                      children: [
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.23,
                          child:
                              Text(AppLocalizations.of(context)!.plan.allInCaps, maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        if(widget.documentSnapshot.get(keyMembershipTimestamp) != null)
                        SizedBox(
                            height: height * 0.036,
                            width: width * 0.559,
                            child: FutureBuilder(
                              future: Provider.of<PaymentHistoryProvider>(context, listen: false).getMyPaymentById(
                                  membershipId: widget.documentSnapshot.get(keyCurrentMembership),
                                  createdBy: widget.documentSnapshot.get(keyCreatedBy),
                                  createdAt: widget.documentSnapshot.get(keyMembershipTimestamp),
                                  createdFor: widget.documentSnapshot.id),
                              builder: (context, AsyncSnapshot<QueryDocumentSnapshot?> asyncSnapshot) {
                                if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                  var historyDoc = asyncSnapshot.data;
                                  int extendedDays = historyDoc![keyExtendDate];
                                  return Text(
                                      '${(historyDoc[keyPeriod] + extendedDays)} ${AppLocalizations.of(context)!.days}',
                                      maxLines: 1,
                                      style: GymStyle.popupbox);
                                }
                                return Container();
                              },
                            )
                            // Text('1 Year Plan', maxLines: 1, style: GymStyle.popupbox),
                            ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                    Row(
                      children: [
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.23,
                          child: Text(AppLocalizations.of(context)!.members.allInCaps,
                              maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.559,
                          child: Consumer<MemberProvider>(builder: (context, memberData, child) =>
                           Text('${memberData.myMemberListItem.length} Members', maxLines: 1, style: GymStyle.popupbox))
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Container(
                      width: width,
                      height: height * 0.13,
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorCode.tabDivider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.specialization.allInCaps, style: GymStyle.boldText),
                            FutureBuilder(
                              future: specializationProvider.getSpecializationListInSingleString(
                                specializationIdList: specializationList,
                              ),
                              builder: (context, AsyncSnapshot<String> asyncSnapshot) {
                                if (asyncSnapshot.hasData) {
                                  var specialization = asyncSnapshot.data != null ? asyncSnapshot.data as String : "";
                                  return Text(
                                    specialization,
                                    style: GymStyle.listSubTitle,
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
