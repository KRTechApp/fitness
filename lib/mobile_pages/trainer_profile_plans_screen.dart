
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_card.dart';
import '../providers/payment_history_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import 'trainer_package_list_screen.dart';

class TrainerProfilePlansScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const TrainerProfilePlansScreen({
    Key? key,
    required this.documentSnapshot,
  }) : super(key: key);

  @override
  State<TrainerProfilePlansScreen> createState() => _TrainerProfilePlansScreenState();
}

class _TrainerProfilePlansScreenState extends State<TrainerProfilePlansScreen> {
  late MembershipProvider membershipProvider;
  late PaymentHistoryProvider paymentHistoryProvider;
  bool sortByCreated = true;

  @override
  void initState() {
    super.initState();
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // membershipProvider.getAssignMembershipList(membershipId: widget.documentSnapshot.id);
        await paymentHistoryProvider.getPaymentHistory(currentUserId: widget.documentSnapshot.id, sortByCreated: sortByCreated, status: "");
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
          SizedBox(
            height: height * 0.75,
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                widget.documentSnapshot.get(keyMembershipTimestamp) != null
                    ? Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xFFEE7650).withOpacity(0.20),
                          ),
                          child: FutureBuilder(
                            future: Provider.of<PaymentHistoryProvider>(context, listen: false).getMyPaymentById(
                                membershipId: widget.documentSnapshot.get(keyCurrentMembership),
                                createdBy: widget.documentSnapshot.get(keyCreatedBy),
                                createdAt: widget.documentSnapshot.get(keyMembershipTimestamp),
                                createdFor: widget.documentSnapshot.id),
                            builder: (context, AsyncSnapshot<QueryDocumentSnapshot?> asyncSnapshot) {
                              if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                var historyDoc = asyncSnapshot.data;
                                int dateGap = DateTime.now()
                                    .difference(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        widget.documentSnapshot.get(keyMembershipTimestamp),
                                      ),
                                    )
                                    .inDays;
                                int extendedDays = historyDoc![keyExtendDate];
                                int leftMemberShip = (historyDoc[keyPeriod] + extendedDays) - dateGap;
                                int totalDays = historyDoc[keyPeriod] + extendedDays;
                                debugPrint("historyDoc[keyPeriod] : ${historyDoc[keyPeriod]}");
                                debugPrint("leftMemberShip : $leftMemberShip");
                                debugPrint("extendedDays : $extendedDays");
                                debugPrint("totalDays : $totalDays");
                                debugPrint("PER : ${leftMemberShip / totalDays * 100}");
                                return Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                        height: 62,
                                        width: 70,
                                        child: Image.asset(
                                          fit: BoxFit.cover,
                                          'assets/images/ic_Plane.png',
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10, left: 10),
                                          child: Text(
                                            '$leftMemberShip ${AppLocalizations.of(context)!.days_left_in_membership}',
                                            style: TextStyle(
                                              fontSize: getFontSize(18),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Poppins',
                                              color: const Color(0xFF181A20),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 15,
                                          ),
                                          child: Container(
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: LinearPercentIndicator(
                                              width: width - 110,
                                              animation: true,
                                              lineHeight: 35.0,
                                              animationDuration: 2500,
                                              percent: (leftMemberShip / totalDays * 100) / 100,
                                              progressColor: ColorCode.orangeHigh,
                                              backgroundColor: ColorCode.orangeHigh.withOpacity(0.20),
                                              barRadius: const Radius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                      )
                    : Center(
                        child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          AppLocalizations.of(context)!.no_package_assigned,
                          textAlign: TextAlign.center,
                        ),
                      )),
                SizedBox(
                  height: height * 0.015,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text(AppLocalizations.of(context)!.recent_packages, style: GymStyle.buttonTextStyle),
                ),
                SizedBox(
                  height: height * 0.015,
                ),
                RefreshIndicator(
                  onRefresh: _pullRefresh,
                  color: ColorCode.mainColor,
                  child: SizedBox(
                    width: width,
                    height: height * 0.47,
                    child: Consumer<PaymentHistoryProvider>(
                      builder: (context, paymentHistoryData, child) => paymentHistoryData.packagePaymentHistoryItemList.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: paymentHistoryData.packagePaymentHistoryItemList.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final QueryDocumentSnapshot paymentHistoryDoc = paymentHistoryData.packagePaymentHistoryItemList[index];
                                debugPrint('Membership Length${paymentHistoryData.packagePaymentHistoryItemList.length}');
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                  child: customCard(
                                    blurRadius: 5,
                                    radius: 15,
                                    child: FutureBuilder(
                                      future: membershipProvider.getMembershipDataFromId(
                                        createdById: widget.documentSnapshot.get(keyCreatedBy),
                                        membershipId: widget.documentSnapshot.get(keyCurrentMembership),
                                      ),
                                      builder: (context, AsyncSnapshot<QueryDocumentSnapshot?> asyncSnapshot) {
                                        var queryDoc = asyncSnapshot.data;
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: FadeInImage(
                                                    fit: BoxFit.cover,
                                                    width: 50,
                                                    height: 50,
                                                    image: customImageProvider(
                                                      url: queryDoc != null ? queryDoc[keyProfile] : "",
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
                                                    width: width * 0.46,
                                                    child: Text(paymentHistoryDoc[keyMembershipName] ?? "", maxLines: 1, style: GymStyle.listTitle),
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.46,
                                                    child: (widget.documentSnapshot[keyCurrentMembership] == paymentHistoryDoc[keyMembershipId] &&
                                                            queryDoc != null)
                                                        ? Text(
                                                            '${getDocumentValue(
                                                              documentSnapshot: queryDoc,
                                                              key: keyMemberCount,
                                                            )} ${AppLocalizations.of(context)!.member_out_of} ${getDocumentValue(documentSnapshot: queryDoc, key: keyMemberLimit)}',
                                                            maxLines: 1,
                                                            style: GymStyle.listSubTitle)
                                                        : Text(
                                                            '${paymentHistoryDoc[keyPeriod] ?? ""} ${AppLocalizations.of(context)!.days}'.toString()),
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.46,
                                                    child: Text('${StaticData.currentCurrency} ${paymentHistoryDoc[keyAmount] ?? ""}',
                                                        maxLines: 1, style: GymStyle.membershipprice),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              (widget.documentSnapshot[keyCurrentMembership] == paymentHistoryDoc[keyMembershipId]) &&
                                                      (widget.documentSnapshot[keyMembershipTimestamp] == paymentHistoryDoc[keyCreatedAt])
                                                  ? Padding(
                                                      padding: const EdgeInsets.only(right: 15, left: 15),
                                                      child: SvgPicture.asset('assets/images/ProgressIcon.svg'),
                                                    )
                                                  : Padding(
                                                      padding: const EdgeInsets.only(right: 5, left: 15),
                                                      child: SvgPicture.asset(
                                                        'assets/images/ic_Right.svg',
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
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
                                      // "You Don't have any plan",
                                      AppLocalizations.of(context)!.you_do_not_have_any_plan,
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
                ),
              ],
            ),
          ),
        Positioned(
            bottom: Platform.isAndroid
                ? height * 0.07 : height * 0.1,
            left: 15,
            right: 15,
            child: SizedBox(
              height: 50,
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TrainerPackageListScreen(
                                drawerList: false,
                              )));
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: ColorCode.mainColor,
                ),
                child: Text(AppLocalizations.of(context)!.change_plan.allInCaps, style: GymStyle.buttonTextStyle),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pullRefresh() async {
    await paymentHistoryProvider.getPaymentHistory(currentUserId: widget.documentSnapshot.id, sortByCreated: sortByCreated, status: "");
  }
}
