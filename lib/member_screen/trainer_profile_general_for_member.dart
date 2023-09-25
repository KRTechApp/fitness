import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crossfit_gym_trainer/providers/specialization_provider.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';

class TrainerProfileGeneralForMember extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const TrainerProfileGeneralForMember({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  State<TrainerProfileGeneralForMember> createState() => _TrainerProfileGeneralForMemberState();
}

class _TrainerProfileGeneralForMemberState extends State<TrainerProfileGeneralForMember> {
  late SpecializationProvider specializationProvider;

  @override
  void initState() {
    super.initState();
    specializationProvider = Provider.of<SpecializationProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {},
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
                          child: Text(AppLocalizations.of(context)!.gender.allInCaps,
                              maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.559,
                          child: Text(
                              widget.documentSnapshot[keyGender] == ""
                                  ? " - "
                                  : widget.documentSnapshot[keyGender] == "male"
                                      ? "Male"
                                      : "Female",
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
                              Text(AppLocalizations.of(context)!.dob.allInCaps, maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.559,
                          child: Text(
                              widget.documentSnapshot[keyDateOfBirth] == 0
                                  ? " - "
                                  : DateFormat(StaticData.currentDateFormat)
                                      .format(DateTime.fromMillisecondsSinceEpoch(
                                          widget.documentSnapshot[keyDateOfBirth] ?? 0))
                                      .toString(),
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
                              Text(AppLocalizations.of(context)!.role.allInCaps, maxLines: 1, style: GymStyle.boldText),
                        ),
                        SizedBox(width: width * 0.08),
                        SizedBox(
                          height: height * 0.036,
                          width: width * 0.559,
                          child: Text("${widget.documentSnapshot[keyUserRole]}".firstCapitalize(),
                              maxLines: 1, style: GymStyle.popupbox),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),

                    SizedBox(
                      height: height * 0.015,
                    ),
                    if (widget.documentSnapshot[keyAddress] != null && widget.documentSnapshot[keyAddress].isNotEmpty)
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
                              Text(AppLocalizations.of(context)!.address.allInCaps, style: GymStyle.boldText),
                              Text(widget.documentSnapshot[keyAddress] ?? "", style: GymStyle.listSubTitle)
                            ],
                          ),
                        ),
                      ),
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
                                  AppLocalizations.of(context)!.specialization_list.allInCaps,
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
