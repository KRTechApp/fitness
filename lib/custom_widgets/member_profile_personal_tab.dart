import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';

class MemberProfilePersonalTab extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const MemberProfilePersonalTab({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  State<MemberProfilePersonalTab> createState() => _MemberProfilePersonalTabState();
}

class _MemberProfilePersonalTabState extends State<MemberProfilePersonalTab> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.36,
                  child: Text(
                    AppLocalizations.of(context)!.member_id.allInCaps,
                    style: GymStyle.boldText,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: width * 0.455,
                  child: Text(
                    widget.documentSnapshot[keyMemberId] ?? "",
                    style: const TextStyle(color: ColorCode.tabBarText),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            color: ColorCode.tabDivider,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.36,
                  child: Text(
                    AppLocalizations.of(context)!.name.allInCaps,
                    style: GymStyle.boldText,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: width * 0.455,
                  child: Text(
                    widget.documentSnapshot[keyName] ?? "",
                    style: const TextStyle(color: ColorCode.tabBarText),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            color: ColorCode.tabDivider,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.36,
                  child: Text(
                    AppLocalizations.of(context)!.mobile_number.allInCaps,
                    style: GymStyle.boldText,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: width * 0.455,
                  child: Text(
                    '+${widget.documentSnapshot[keyCountryCode] ?? ""} ${widget.documentSnapshot[keyPhone] ?? ""}',
                    style: const TextStyle(color: ColorCode.tabBarText),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            color: ColorCode.tabDivider,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.36,
                  child: Text(
                    AppLocalizations.of(context)!.email.allInCaps,
                    style: GymStyle.boldText,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: width * 0.455,
                  child: Text(
                    widget.documentSnapshot[keyEmail] ?? "",
                    style: const TextStyle(color: ColorCode.tabBarText),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            color: ColorCode.tabDivider,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.36,
                  child: Text(
                    AppLocalizations.of(context)!.dob.allInCaps,
                    style: GymStyle.boldText,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: width * 0.455,
                  child: Text(
                    widget.documentSnapshot[keyDateOfBirth] != null
                        ? DateFormat(StaticData.currentDateFormat)
                            .format(DateTime.fromMillisecondsSinceEpoch(widget.documentSnapshot[keyDateOfBirth] ?? ""))
                        : "-",
                    style: const TextStyle(color: ColorCode.tabBarText),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            color: ColorCode.tabDivider,
          ),
          /* Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.36,
                  child: Text(
                    AppLocalizations.of(context)!.package.allInCaps,
                    style: GymStyle.boldText,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: width * 0.455,
                  child: const Text(
                    'Beginner',
                    style: TextStyle(color: ColorCode.tabBarText),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            color: ColorCode.tabDivider,
          ),*/
          const Spacer(),
          SizedBox(
            height: height * 0.08,
            width: width * 0.9,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: const Color(0xff2AA81A),
              ),
              onPressed: () {
                _launchWhatsapp();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    width: 50,
                    height: 50,
                    'assets/images/whatsapp.png',
                  ),
                  Text(
                    AppLocalizations.of(context)!.open_whatsapp_chat.allInCaps,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _launchWhatsapp() async {
    var whatsapp = '+${widget.documentSnapshot[keyWpCountryCode] ?? ""}${widget.documentSnapshot[keyWpPhone] ?? ""}';
    var whatsappAndroid = Uri.parse("whatsapp://send?phone=$whatsapp");
    if (await canLaunchUrl(whatsappAndroid)) {
      await launchUrl(whatsappAndroid);
    } else {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.whatsapp_is_not_installed_on_the_device),
          ),
        );
      }
    }
  }
}
