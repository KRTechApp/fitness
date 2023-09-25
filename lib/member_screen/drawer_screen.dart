import 'package:crossfit_gym_trainer/trainer_screen/nutrition_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../Services/dark_theme_prefs.dart';
import '../../providers/dark_theme_provider.dart';
import '../../utils/color_code.dart';
import '../../utils/gym_style.dart';
import '../../utils/shared_preferences_manager.dart';
import '../../utils/static_data.dart';
import '../custom_widgets/expired_dailog.dart';
import '../main.dart';
import '../mobile_pages/admin_request_screen.dart';
import '../mobile_pages/membership_package_screen.dart';
import '../mobile_pages/setting_screen.dart';
import '../mobile_pages/trainer_class_list_screen.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'account_member_screen.dart';
import 'dashboard_screen.dart';
import 'measurement_screen.dart';
import 'member_detail_profile_screen.dart';
import 'member_my_exercise_screen.dart';
import 'member_workout_screen.dart';
import 'trainer_profile_screen_for_member.dart';

class DrawerScreen extends StatefulWidget {
  final Function(bool) drawerOpen;

  const DrawerScreen({super.key, required this.drawerOpen});

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> with TickerProviderStateMixin {
  final _switchController = ValueNotifier<bool>(false);
  late DarkThemeProvider themeState;
  DarkThemePrefs darkThemePrefs = DarkThemePrefs();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String memberName = "";
  String memberCurrentDate = "";
  String memberProfile = "";
  String userId = "";
  String createdBy = "";
  String userRole = "";
  String currentLanguage = "";
bool isRtl = false;
  @override
  void initState() {
    super.initState();
    _switchController.addListener(
      () {
        debugPrint("_switchController.value : ${_switchController.value}");
        themeState.setDarkTheme = _switchController.value;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _switchController.value = themeState.getDarkTheme;
        userRole = await _preference.getValue(prefUserRole, "");
        memberProfile = await _preference.getValue(prefProfile, "");
        memberName = await _preference.getValue(prefName, "");
        memberCurrentDate = await _preference.getValue(prefCurrentDate, "");
        userId = await _preference.getValue(prefUserId, "");
        createdBy = await _preference.getValue(prefCreatedBy, "");
        currentLanguage = await _preference.getValue(prefLanguage, "");
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    themeState = Provider.of<DarkThemeProvider>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.8,
      child: ClipRRect(
        borderRadius:
         BorderRadius.only(
          topRight: checkRtl(currentLanguage: currentLanguage) ? const Radius.circular(0) : const Radius.circular(35),
          bottomRight: checkRtl(currentLanguage: currentLanguage) ? const Radius.circular(0) : const Radius.circular(35),
           bottomLeft: checkRtl(currentLanguage: currentLanguage) ? const Radius.circular(35) : const Radius.circular(0),
           topLeft: checkRtl(currentLanguage: currentLanguage) ? const Radius.circular(35) : const Radius.circular(0),
        ),
        child: Drawer(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  SizedBox(height: height * 0.08),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberDetailProfileScreen(
                            userId: userId,
                            viewType: "view",
                          ),
                        ),
                      );
                    },
                    tileColor: const Color(0xFFE8F7FF),
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        image: customImageProvider(url: memberProfile),
                        placeholderFit: BoxFit.fitWidth,
                        placeholder: customImageProvider(),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return getPlaceHolder();
                        },
                      ),
                    ),
                    title: Text(
                      memberName,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.member_since}:$memberCurrentDate',
                          style: GymStyle.listSubTitle3,
                        )
                      ],
                    ),
                    trailing: InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50),
                      ),
                      splashColor: ColorCode.linearProgressBar,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        child: SvgPicture.asset("assets/images/ic_Drawer_Cancel.svg"),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
/*                  Container(
                    width: width,
                    height: height * 0.06,
                    color: const Color(0xFFE8F7FF),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.enable_dark_mode,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.29,
                        ),
                        AdvancedSwitch(
                          width: 32,
                          height: 16,
                          controller: _switchController,
                        ),
                      ],
                    ),
                  ),*/
                  SizedBox(
                    height: height * 0.013,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SizedBox(
                      height: height * 0.71,
                      width: width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: SvgPicture.asset('assets/images/ic_Home.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.home, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DashboardScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Image.asset(
                                  'assets/images/member_trainer.png',
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              title: Text(AppLocalizations.of(context)!.trainer, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                MaterialPageRoute(
                                    builder: (context) => TrainerProfileScreenForMember(
                                      trainerId: createdBy,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: SvgPicture.asset('assets/images/Trainer.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.my_exercises, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberMyExerciseScreen(userId: userId,viewType: "filter"),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: SvgPicture.asset('assets/images/Trainer.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.nutrition_plan, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NutritionScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: SvgPicture.asset('assets/images/ic_measurement.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.measurement, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MeasurementScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SvgPicture.asset('assets/images/Workout.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.my_workout, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberWorkoutScreen(
                                      userId: userId,
                                      userRole: userRole,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if(StaticData.showPaymentGateway)
                            const Divider(height: 1),
                            if(StaticData.showPaymentGateway)
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: SvgPicture.asset('assets/images/MembershipPlan.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.my_membership_plan, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MembershipPackageScreen(userRole: userRole),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: SvgPicture.asset('assets/images/class_schedule.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.class_schedule, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrainerClassListScreen(),
                                  ),
                                );
                              },
                            ),
                            if(StaticData.showPaymentGateway)
                            const Divider(height: 1),
                               /*ListTile(
                            visualDensity: VisualDensity(
                              horizontal: -4,
                            ),
                            contentPadding: EdgeInsets.zero,
                            leading: Padding(
                              padding: EdgeInsets.only(left: 20, top: 2),
                              child: SvgPicture.asset('assets/images/message.svg'),
                            ),
                            title: Text('Messages', style: GymStyle.drawerFont),
                          ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Divider(height: 1),
                            ),*/
                            if(StaticData.showPaymentGateway)
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: SvgPicture.asset('assets/images/Account.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.account, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AccountMemberScreen()),
                                );
                              },
                            ),
                            const Divider(height: 1),

                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: SvgPicture.asset('assets/images/Setting.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.settings, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,userRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                logoutDialog(context: context);
                              },
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: SvgPicture.asset('assets/images/ic_Logout.svg'),
                              title: Text(AppLocalizations.of(context)!.log_out, style: GymStyle.drawerFont),
                            ),
                            const Divider(height: 1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Text(
                    "${AppLocalizations.of(context)!.version} ${StaticData.version}",
                    style: GymStyle.drawerFont,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _switchController.dispose();
  }

}
