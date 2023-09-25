import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../admin_screen/add_trainer_screen.dart';
import '../main.dart';
import '../providers/trainer_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'admin_workout_list_screen.dart';
import 'main_drawer_screen.dart';
import 'trainer_profile_class_schedule_screen.dart';
import 'trainer_profile_generals_screen.dart';
import 'trainer_profile_members_screen.dart';
import 'trainer_profile_plans_screen.dart';
import 'trainer_profile_report_screen.dart';

class TrainerProfileScreenOld extends StatefulWidget {
  final String trainerId;

  const TrainerProfileScreenOld({Key? key, required this.trainerId}) : super(key: key);

  @override
  State<TrainerProfileScreenOld> createState() => _TrainerProfileScreenOldState();
}

class _TrainerProfileScreenOldState extends State<TrainerProfileScreenOld> with SingleTickerProviderStateMixin {
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
    return Scaffold(
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
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: width * 0.36,
                                child: Text(
                                  documentSnapshot![keyName] ?? "",
                                  maxLines: 1,
                                  style: GymStyle.listTitle,
                                ),
                              ),
                              SizedBox(
                                width: width * 0.36,
                                child: Text(
                                  (documentSnapshot![keyUserRole] ?? "").toString().firstCapitalize(),
                                  maxLines: 1,
                                  style: GymStyle.listSubTitle2,
                                ),
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/wp_icon.png',
                                    height: 23,
                                    width: 23,
                                  ),
                                  SizedBox(
                                    width: width * 0.3,
                                    child: Text(
                                      '+${documentSnapshot![keyWpCountryCode] ?? ""} ${documentSnapshot![keyWpPhone] ?? ""}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GymStyle.listSubTitle3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            height: height * 0.06,
                            width: width * 0.23,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTrainer(
                                      key: UniqueKey(),
                                      viewType: "edit",
                                      documentSnapshot: documentSnapshot,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor: ColorCode.mainColor,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.edit.allInCaps,
                                style: GymStyle.editButton,
                              ),
                            ),
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
                            length: 5,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: width,
                                  height: 40,
                                  child: TabBar(
                                    isScrollable: true,
                                    indicatorColor: ColorCode.backgroundColor,
                                    indicatorPadding: const EdgeInsets.only(top: 37, bottom: 0, left: 10, right: 10),
                                    tabs: [
                                      Tab(
                                        child: Text(
                                          AppLocalizations.of(context)!.general.allInCaps,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      Tab(
                                        child: Text(
                                          AppLocalizations.of(context)!.class_schedule.allInCaps,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      Tab(
                                        child: Text(
                                          AppLocalizations.of(context)!.package.allInCaps,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      Tab(
                                        child: Text(
                                          AppLocalizations.of(context)!.members.allInCaps,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      Tab(
                                        child: Text(
                                          AppLocalizations.of(context)!.report.allInCaps,
                                          textAlign: TextAlign.center,
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
                                        TrainerProfileGeneral(
                                            key: UniqueKey(), documentSnapshot: documentSnapshot!, userId: userId),
                                        TrainerProfileClassSchedule(key: UniqueKey(), trainerId: widget.trainerId),
                                        TrainerProfilePlansScreen(
                                          key: UniqueKey(),
                                          documentSnapshot: documentSnapshot!,
                                        ),
                                        TrainerProfileMembers(key: UniqueKey(), documentSnapshot: documentSnapshot!),
                                        TrainerProfileReport(key: UniqueKey(), documentSnapshot: documentSnapshot!),
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
                  bottom: 8,
                  right: 15,
                  child: Row(
                    children: [
                      SizedBox(
                        height: height * 0.07,
                        width: width * 0.43,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminWorkoutList(
                                    /*   userId: documentSnapshot!.id,
                                    userRole: userRole, */
                                    drawerList: false,
                                    viewType: "ViewWorkout",
                                    trainerId: documentSnapshot!.id),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: ColorCode.mainColor,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.view_workout.allInCaps,
                            style: TextStyle(
                                color: ColorCode.white,
                                fontSize: getFontSize(16),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.05,
                      ),
                      SizedBox(
                        height: height * 0.07,
                        width: width * 0.442,
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
                                width: 30,
                                height: 30,
                                'assets/images/wp_icon.png',
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                AppLocalizations.of(context)!.whatsapp.allInCaps,
                                style: TextStyle(
                                    color: ColorCode.white,
                                    fontSize: getFontSize(16),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins'),
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
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
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
          const SnackBar(
            content: Text("WhatsApp is not installed on the device"),
          ),
        );
      }
    }
  }
}
