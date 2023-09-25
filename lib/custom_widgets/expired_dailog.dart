
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../providers/trainer_provider.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';


class PlanExpiredDialog {
  final String userRole;
  DocumentSnapshot? userDoc;
  String? createdBy;
  PlanExpiredDialog(BuildContext mContext, this.userRole,) {
    final SharedPreferencesManager preference = SharedPreferencesManager();
    preference.getValue(prefCreatedBy, "").then((value) => {
      createdBy = value,
      debugPrint("createdBy : $createdBy"),
    Provider.of<TrainerProvider>(mContext, listen: false).getSingleTrainer(userId: createdBy!).then((value){
      userDoc = value;
    }),
    });


    showGeneralDialog(
      context: mContext,
      barrierLabel: "Yaraa",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.2),
      // transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (popContext, anim1, anim2) {
        var width = MediaQuery.of(popContext).size.width;
        return StatefulBuilder(builder: (context, setState) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Card(
                        color: ColorCode.white,
                        elevation: 15,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: 40,
                              backgroundImage: customImageProvider(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0,right: 10,left: 10),
                              child: Text(userRole == userRoleMember ?
                                  AppLocalizations.of(context)!.your_membership_is_expired_please_contect_your_trainer
                                  : AppLocalizations.of(context)!.your_package_is_expired_please_contect_your_admin ,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: GymStyle.inputTextBold),
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                     width: width * 0.4,
                                  margin: const EdgeInsets.only(top: 25, left: 15, bottom: 15),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorCode.mainColor,
                                      textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.normal),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    ),
                                    onPressed: () {
                                      _launchWhatsapp(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/images/wp_icon.png',width: 26,height: 26),
                                          Text(
                                            AppLocalizations.of(context)!.whatsapp,
                                            style:const  TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),const Spacer(),
                                Container(
                                  height: 40,
                                  width: width * 0.4,
                                  margin: const EdgeInsets.only(top: 25, bottom: 15,right: 15),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorCode.mainColor,
                                      textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.normal),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    ),
                                    onPressed: () {
                                      launch('mailto:${userDoc![keyEmail] ?? ""}');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset('assets/images/email.svg',width: 18 ,height: 18,color: ColorCode.white),
                                          const SizedBox(
                                          width: 5,),
                                          Text(
                                            AppLocalizations.of(context)!.email,
                                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            /*Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: ColorCode.indicator,
                                onTap: () async {
                                  // LogoutDialog(context);
                                },
                                child: Text(
                                  "AppLocalizations.of(context)!.login_with_another_account",
                                  style:
                                  TextStyle(fontSize: 16, fontFamily: 'Poppins-Bold', fontWeight: FontWeight.w500, color: ColorCode.lightGreen),
                                ),
                              ),
                            ),*/

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      },
      /*transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
            scale: anim1.value,
            child: Opacity(
              opacity: anim1.value,
              child: child,
            ));
      },*/
    );
  }

  _launchWhatsapp(BuildContext context) async {
    var whatsapp = '+${userDoc![keyWpCountryCode] ?? ""}${userDoc![keyWpPhone] ?? ""}';
    var whatsappAndroid = Uri.parse("whatsapp://send?phone=$whatsapp");
    if (await canLaunchUrl(whatsappAndroid)) {
      await launchUrl(whatsappAndroid);
    } else {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("WhatsApp is not installed on the device"),
          ),
        );
      }
    }
  }
}
