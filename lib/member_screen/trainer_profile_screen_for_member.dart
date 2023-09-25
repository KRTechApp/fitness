import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../mobile_pages/main_drawer_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/tables_keys_values.dart';
import '../main.dart';
import '../providers/trainer_provider.dart';
import '../utils/utils_methods.dart';
import 'dashboard_screen.dart';
import 'trainer_profile_class_schedule_for_member.dart';
import 'trainer_profile_general_for_member.dart';

class TrainerProfileScreenForMember extends StatefulWidget {
  final String trainerId;

  const TrainerProfileScreenForMember({Key? key, required this.trainerId}) : super(key: key);

  @override
  State<TrainerProfileScreenForMember> createState() => _TrainerProfileScreenForMemberState();
}

class _TrainerProfileScreenForMemberState extends State<TrainerProfileScreenForMember> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TrainerProvider trainerProvider;
  DocumentSnapshot? documentSnapshot;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";
  String userRole = "";

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        documentSnapshot = await trainerProvider.getSingleTrainer(userId: widget.trainerId);
        userId = await _preference.getValue(prefUserId, "");
        _preference.getValue(prefUserRole, "").then(
              (memberRole) => {
                setState(
                  () {
                    userRole = memberRole;
                  },
                ),
              },
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (Route<dynamic> route) => false);

        return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 48,
          leading: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
            splashColor: ColorCode.linearProgressBar,
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
              child: SvgPicture.asset(
                'assets/images/appbar_menu.svg',
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),
          ),
          title: Text(AppLocalizations.of(context)!.trainer_profile),
        ),
        body: documentSnapshot == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15, left: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                image: customImageProvider(
                                  url: documentSnapshot![keyProfile],
                                ),
                                placeholderFit: BoxFit.fitWidth,
                                placeholder: customImageProvider(),
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return getPlaceHolder();
                                },
                              ),
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: width - 130,
                                  child: Text(
                                    documentSnapshot![keyName] ?? "",
                                    maxLines: 1,
                                    style: GymStyle.listTitle,
                                  ),
                                ),
                                SizedBox(
                                  width: width - 130,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/contact.svg',
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          '+${documentSnapshot![keyCountryCode] ?? ""} ${documentSnapshot![keyWpPhone] ?? ""}',
                                          maxLines: 1,
                                          style: GymStyle.listSubTitle2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: width - 130,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/icemail.svg',
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          documentSnapshot![keyEmail] ?? "",
                                          maxLines: 1,
                                          style: GymStyle.listSubTitle3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.tabBarBackground),
                            child: DefaultTabController(
                              initialIndex: 0,
                              length: 2,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: width,
                                    height: 40,
                                    child: TabBar(
                                      indicatorColor: ColorCode.backgroundColor,
                                      indicatorPadding: const EdgeInsets.only(top: 37, left: 10, right: 10),
                                      tabs: [
                                        Tab(
                                          child: Text(
                                            AppLocalizations.of(context)!.general.allInCaps,
                                            style: const TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            AppLocalizations.of(context)!.class_schedule.allInCaps,
                                            style: const TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SizedBox(
                                      width: width,
                                      height: height * 0.65,
                                      child: TabBarView(
                                        children: <Widget>[
                                          TrainerProfileGeneralForMember(
                                              key: UniqueKey(), documentSnapshot: documentSnapshot!),
                                          TrainerProfileClassScheduleForMember(
                                              key: UniqueKey(), trainerId: documentSnapshot!.id),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    right: 15,
                    left: 15,
                    child: SizedBox(
                      height: height * 0.07,
                      width: width,
                      child: ElevatedButton(
                        onPressed: () {
                          _launchWhatsapp();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: ColorCode.green,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              width: 45,
                              height: 45,
                              'assets/images/whatsapp.png',
                            ),
                            Text(
                              AppLocalizations.of(context)!.open_whatsapp_chat.allInCaps,
                              style: GymStyle.startButton,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  _launchWhatsapp() async {
    var whatsapp = '+${documentSnapshot![keyWpCountryCode] ?? ""}${documentSnapshot![keyWpPhone] ?? ""}';
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
