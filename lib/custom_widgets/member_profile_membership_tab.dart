import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../Utils/color_code.dart';
import '../mobile_pages/trainer_package_list_screen.dart';
import '../providers/membership_provider.dart';
import '../providers/payment_history_provider.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class MemberProfileMembershipTab extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final String userRole;

  const MemberProfileMembershipTab({Key? key, required this.documentSnapshot, required this.userRole}) : super(key: key);

  @override
  State<MemberProfileMembershipTab> createState() => _MemberProfileMembershipTabState();
}

class _MemberProfileMembershipTabState extends State<MemberProfileMembershipTab> {
  late MembershipProvider membershipProvider;
  late PaymentHistoryProvider paymentHistoryProvider;
  bool sortByCreated = true;
  NumberFormat formatter = NumberFormat("00");

  @override
  void initState() {
    super.initState();
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // membershipProvider.getAssignMembershipList(membershipId: widget.documentSnapshot.id);
        await paymentHistoryProvider.getPaymentHistory(currentUserId: widget.documentSnapshot.id, sortByCreated: sortByCreated, status: "");

        debugPrint('Current Member Id : ${widget.documentSnapshot.id}');
        debugPrint('Current MembershipId: ${widget.documentSnapshot.get(keyCurrentMembership)}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                  future: membershipProvider.getMembershipDataFromId(
                      membershipId: getDocumentValue(documentSnapshot: widget.documentSnapshot, key: keyCurrentMembership),
                      createdById: widget.documentSnapshot[keyCreatedBy]),
                  builder: (context, AsyncSnapshot<QueryDocumentSnapshot?> asyncSnapshot) {
                    if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                      var queryDoc = asyncSnapshot.data;

                      DateTime tempDate = DateTime.fromMillisecondsSinceEpoch(widget.documentSnapshot[keyMembershipTimestamp]);
                      debugPrint("tempDate : $tempDate");
                      int totalDays = queryDoc![keyPeriod];
                      debugPrint("totalDays : $totalDays");

                      return FutureBuilder(
                          future: Provider.of<PaymentHistoryProvider>(context, listen: false).getMyPaymentById(
                              membershipId: widget.documentSnapshot.get(keyCurrentMembership),
                              createdBy: widget.documentSnapshot.get(keyCreatedBy),
                              createdAt: widget.documentSnapshot.get(keyMembershipTimestamp),
                              createdFor: widget.documentSnapshot.id),
                          builder: (context, AsyncSnapshot<QueryDocumentSnapshot?> snapshotHistory) {
                            if (snapshotHistory.hasData && snapshotHistory.data != null) {
                              var historyDoc = snapshotHistory.data;
                              int extendedDays = historyDoc![keyExtendDate];
                              // int extendedDays = 0;
                              var startDate = DateFormat(StaticData.currentDateFormat)
                                  .format(DateTime.fromMillisecondsSinceEpoch(widget.documentSnapshot[keyMembershipTimestamp]));
                              var newDate = DateFormat(StaticData.currentDateFormat).format(tempDate.add(Duration(days: totalDays + extendedDays)));
                              debugPrint("newDate : $newDate");
                              debugPrint("historyDoc : ${historyDoc.id}");
                              debugPrint("extendedDays : $extendedDays");
                              return Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Container(
                                        height: 159,
                                        width: width,
                                        margin: const EdgeInsets.only(
                                          top: 15,
                                        ),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                          color: ColorCode.linearProgressBar,
                                        ),
                                        child: Image.asset('assets/images/Circle.png', alignment: Alignment.centerRight, height: 150),
                                      ),
                                    ),
                                    /*Positioned(
                                      height: 168,
                                      width: 168,
                                      right: 15,
                                      top: 6,
                                      child: Image.asset('assets/images/Circle.png'),
                                    ),*/
                                    Positioned(
                                      bottom: 25,
                                      right: 40,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: FadeInImage(
                                          fit: BoxFit.cover,
                                          width: 90,
                                          height: 90,
                                          image: customImageProvider(url: queryDoc[keyProfile] ?? ""),
                                          placeholderFit: BoxFit.fitWidth,
                                          placeholder: customImageProvider(),
                                          imageErrorBuilder: (context, error, stackTrace) {
                                            return getPlaceHolder();
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(30, 25, 0, 3),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: width * 0.65,
                                            child: Text(
                                              queryDoc[keyMembershipName] ?? "",
                                              style: GymStyle.containerHeader,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: SvgPicture.asset(
                                                  color: const Color(0xFF555555),
                                                  'assets/images/Calender_Icon.svg',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4),
                                                child: Text(
                                                  "$startDate  to \n$newDate",
                                                  style: GymStyle.containerSubHeader,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4, left: 2),
                                                child: SvgPicture.asset(
                                                  color: const Color(0xFF555555),
                                                  'assets/images/ic_Watch.svg',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 6, top: 5),
                                                child: Text(
                                                  '${(queryDoc[keyPeriod] + extendedDays).toString()} ${AppLocalizations.of(context)!.days}',
                                                  style: GymStyle.containerSubHeader,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4),
                                            child: Text(
                                              '${StaticData.currentCurrency} ${formatter.format(queryDoc[keyAmount] ?? "")}.00',
                                              style: GymStyle.containerHeader,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                            return Container();
                          });
                    }
                    return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                      AppLocalizations.of(context)!.membership_not_assign,
                      textAlign: TextAlign.center,
                    ),
                        ));
                  }),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(AppLocalizations.of(context)!.membership_history, style: GymStyle.buttonTextStyle),
              ),
              const SizedBox(
                height: 15,
              ),
              Consumer<PaymentHistoryProvider>(
                builder: (context, paymentHistoryData, child) => paymentHistoryData.packagePaymentHistoryItemList.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: paymentHistoryData.packagePaymentHistoryItemList.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final QueryDocumentSnapshot paymentHistoryDoc = paymentHistoryData.packagePaymentHistoryItemList[index];
                          if (widget.documentSnapshot[keyMembershipTimestamp] != null) {
                            DateTime tempDate = DateTime.fromMillisecondsSinceEpoch(widget.documentSnapshot[keyMembershipTimestamp]);
                            debugPrint("tempDate : $tempDate");
                            int totalDays = paymentHistoryDoc[keyPeriod];
                            debugPrint("totalDays : $totalDays");
                            int extendedDays = paymentHistoryDoc[keyExtendDate];
                            // int extendedDays = 0;
                            var startDate = DateFormat(StaticData.currentDateFormat)
                                .format(DateTime.fromMillisecondsSinceEpoch(widget.documentSnapshot[keyMembershipTimestamp]));
                            var newDate = DateFormat(StaticData.currentDateFormat).format(tempDate.add(Duration(days: totalDays + extendedDays)));
                            debugPrint("newDate : $newDate");
                            debugPrint("historyDoc : ${paymentHistoryDoc.id}");
                            debugPrint("extendedDays : $extendedDays");
                            return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                child: FutureBuilder(
                                  future: membershipProvider.getMembershipDataFromId(
                                    createdById: widget.documentSnapshot[keyCreatedBy],
                                    membershipId: widget.documentSnapshot.get(keyCurrentMembership),
                                  ),
                                  builder: (context, AsyncSnapshot<QueryDocumentSnapshot?> asyncSnapshot) {
                                    var queryDoc = asyncSnapshot.data;
                                    return customCard(
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
                                                  child: FadeInImage(
                                                    fit: BoxFit.cover,
                                                    width: 60,
                                                    height: 60,
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
                                                    child: Text("$startDate to $newDate", maxLines: 1, style: GymStyle.listSubTitle),
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.46,
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: '${StaticData.currentCurrency} ${paymentHistoryDoc[keyAmount] ?? ""}',
                                                        style: GymStyle.membershipprice,
                                                        children: <TextSpan>[
                                                          const TextSpan(
                                                            text: ' / ',
                                                          ),
                                                          TextSpan(
                                                              text: '${(paymentHistoryDoc[keyPeriod] + extendedDays)} days',
                                                              style: GymStyle.drawerswitchtext),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ));
                                  },
                                ));
                          }
                          return const SizedBox();
                        },
                      )
                    : SizedBox(width: Platform.isAndroid ? width * 0.3 : width * 0.25),
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
            ],
          ),
        ),
        if (widget.userRole == userRoleTrainer)
          Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: SizedBox(
              height: height * 0.08,
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
                style: GymStyle.buttonStyle,
                child: Text(
                  AppLocalizations.of(context)!.assign_membership_plan.toUpperCase(),
                  style: GymStyle.buttonTextStyle,
                ),
              ),
            ),
          )
      ],
    );
  }
}
