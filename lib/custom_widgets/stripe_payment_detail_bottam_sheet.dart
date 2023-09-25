import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';

class StripePaymentDetailBottomSheet extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final QueryDocumentSnapshot? subCollectionData;

  const StripePaymentDetailBottomSheet(
      {super.key, required this.queryDocumentSnapshot, required this.subCollectionData});

  @override
  State<StripePaymentDetailBottomSheet> createState() => _StripePaymentDetailBottomSheetState();
}

class _StripePaymentDetailBottomSheetState extends State<StripePaymentDetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      // height: height * 0.6,
      width: width,
      margin: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, bottom: 30),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset('assets/images/arrow-left.svg'),
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    widget.queryDocumentSnapshot[keyMembershipName] ?? "",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.invoice_id.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text(widget.queryDocumentSnapshot[keyInvoiceNo] ?? "", style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.payment_id.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text(widget.subCollectionData![keyPaymentId] ?? "", style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.date.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text(
                            DateFormat(StaticData.currentDateFormat).format(
                                DateTime.fromMillisecondsSinceEpoch(widget.queryDocumentSnapshot[keyCreatedAt] ?? 0)),
                            style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.days.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text((widget.queryDocumentSnapshot[keyPeriod] ?? "").toString(),
                            maxLines: 1, style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.amount.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text((widget.queryDocumentSnapshot[keyAmount] ?? "").toString(),
                            maxLines: 1, style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.payment_status.allInCaps,
                          maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text((widget.queryDocumentSnapshot[keyPaymentStatus] ?? "").toString().firstCapitalize(),
                            maxLines: 1, style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.payment_by.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text((widget.subCollectionData![keyPaymentBrand] ?? "").toString().firstCapitalize(),
                            maxLines: 1, style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: height * 0.08,
                    width: width * 0.9,
                    child: ElevatedButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(widget.subCollectionData![keyPaymentRecept] ?? "");
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: const Color(0xFF6842FF),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.view_recept.toUpperCase(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
