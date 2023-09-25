import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/shared_preferences_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../custom_widgets/custom_card.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';

class TrainerProfileMembers extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const TrainerProfileMembers({
    Key? key,
    required this.documentSnapshot,
  }) : super(key: key);

  @override
  State<TrainerProfileMembers> createState() => _TrainerProfileMembersState();
}

class _TrainerProfileMembersState extends State<TrainerProfileMembers> {
  String userId = "";
  late MemberProvider memberProvider;
  late MembershipProvider membershipProvider;
  final SharedPreferencesManager _preference = SharedPreferencesManager();

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        setState(
          () {},
        );
        memberProvider.getMemberOfTrainer(createdById: widget.documentSnapshot.id, isRefresh: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15),
            height: height * 0.75,
            width: width,
            child: Consumer<MemberProvider>(
              builder: (context, memberData, child) => memberData.myMemberListItem.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: memberData.myMemberListItem.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final QueryDocumentSnapshot documentSnapshot = memberData.myMemberListItem[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: Column(
                            children: [
                              customCard(
                                blurRadius: 5,
                                radius: 15,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
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
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: width * 0.5,
                                          child: Text(
                                            documentSnapshot[keyName] ?? "",
                                            maxLines: 1,
                                            style: GymStyle.listTitle,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: width * 0.5,
                                                child: Text('+${documentSnapshot[keyCountryCode] ?? ""} ${documentSnapshot[keyPhone] ?? ""}')
                                                /*FutureBuilder(
                                                  future: membershipProvider.getMembershipDataFromId(
                                                    currentUserId: userId,
                                                    membershipId: widget.documentSnapshot.get(keyCurrentMembership),
                                                  ),
                                                  builder:
                                                      (context, AsyncSnapshot<QueryDocumentSnapshot?> asyncSnapshot) {
                                                    if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                                      var queryDoc = asyncSnapshot.data;
                                                      // var membershipList = asyncSnapshot.data != null ? asyncSnapshot.data as String : "";
                                                      debugPrint(
                                                          "keyCurrentMembership : ${widget.documentSnapshot.get(keyCurrentMembership)}");
                                                      return SizedBox(
                                                        width: width * 0.4,
                                                        child: Text(
                                                          "Beginner | ${queryDoc![keyPeriod]} Days Plan",
                                                          maxLines: 1,
                                                          style: GymStyle.listSubTitle,
                                                        ),
                                                      );
                                                    }
                                                    return Text(
                                                      AppLocalizations.of(context)!.assign_membership,
                                                      style: GymStyle.listSubTitle,
                                                    );
                                                  },
                                                ),*/
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Container(
                                        width: 50,
                                        padding: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
                                        child: CircularPercentIndicator(
                                          rotateLinearGradient: true,
                                          linearGradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomLeft,
                                            colors: [ColorCode.circleProgressBar, ColorCode.circleProgressBar],
                                          ),
                                          radius: 25.0,
                                          lineWidth: 5.5,
                                          animation: true,
                                          animationDuration: 1000,
                                          startAngle: 360,
                                          percent: 50 / 100,
                                          center: const Text(
                                            "50%",
                                            style: TextStyle(
                                                fontSize: 9.0,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Poppins',
                                                color: ColorCode.circleProgressBar),
                                          ),
                                          circularStrokeCap: CircularStrokeCap.round,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: height * 0.012,
                              ),
                            ],
                          ),
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
                              AppLocalizations.of(context)!.you_do_not_have_any_member,
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
    );
  }
}
