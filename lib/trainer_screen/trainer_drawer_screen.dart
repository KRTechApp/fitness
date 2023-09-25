import 'package:crossfit_gym_trainer/trainer_screen/nutrition_Screen.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../Services/dark_theme_prefs.dart';
import '../../providers/dark_theme_provider.dart';
import '../../utils/color_code.dart';
import '../../utils/gym_style.dart';
import '../../utils/shared_preferences_manager.dart';
import '../../utils/static_data.dart';
import '../admin_screen/admin_dashboard_screen.dart';
import '../admin_screen/admin_workout_category_list_screen.dart';
import '../custom_widgets/expired_dailog.dart';
import '../main.dart';
import '../mobile_pages/admin_workout_list_screen.dart';
import '../mobile_pages/membership_package_screen.dart';
import '../mobile_pages/setting_screen.dart';
import '../mobile_pages/trainer_class_list_screen.dart';
import '../mobile_pages/trainer_package_list_screen.dart';
import '../providers/trainer_provider.dart';
import '../utils/utils_methods.dart';
import 'member_list.dart';
import 'trainer_account_screen.dart';
import 'trainer_dashboard_screen.dart';
import 'trainer_exercise_screen.dart';
import 'trainer_profile_screen.dart';

class TrainerDrawerScreen extends StatefulWidget {
  final Function(bool) trainerDrawerOpen;

  const TrainerDrawerScreen({Key? key, required this.trainerDrawerOpen}) : super(key: key);

  @override
  State<TrainerDrawerScreen> createState() => _TrainerDrawerScreenState();
}

class _TrainerDrawerScreenState extends State<TrainerDrawerScreen> {
  final _switchController = ValueNotifier<bool>(false);
  final switchRoleController = ValueNotifier<bool>(false);
  late DarkThemeProvider themeState;
  DarkThemePrefs darkThemePrefs = DarkThemePrefs();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late TrainerProvider trainerProvider;
  String trainerName = "";
  String trainerRole = "";
  String userId = "";
  String switchRole = "";
  String trainerProfile = "";
  String currentLanguage = "";

  @override
  void initState() {
    super.initState();
    _switchController.addListener(
      () {
        themeState.setDarkTheme = _switchController.value;
      },
    );
    switchRoleController.addListener(
      () {
        trainerRole = switchRoleController.value ? userRoleAdmin : userRoleTrainer;

        _preference.setValue(prefUserRole, trainerRole);
        _preference.setValue(keySwitchRole, userRoleTrainer);
        if (trainerRole == userRoleAdmin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
            ModalRoute.withName("/AdminScreen"),
          );
        } else if (trainerRole == userRoleTrainer) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const TrainerDashboardScreen(),
            ),
            ModalRoute.withName("/TrainerScreen"),
          );
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _switchController.value = themeState.getDarkTheme;
        switchRole = await _preference.getValue(keySwitchRole, "");
        trainerName = await _preference.getValue(prefName, "");
        trainerRole = await _preference.getValue(prefUserRole, "");
        trainerProfile = await _preference.getValue(prefProfile, "");
        userId = await _preference.getValue(prefUserId, "");
        currentLanguage = await _preference.getValue(prefLanguage, "");
        setState(
          () {},
        );
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
        borderRadius: BorderRadius.only(
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
                    tileColor: const Color(0xFFE8F7FF),
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: FadeInImage(
                        key: UniqueKey(),
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        image: customImageProvider(url: trainerProfile),
                        placeholderFit: BoxFit.fitWidth,
                        placeholder: customImageProvider(),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return getPlaceHolder();
                        },
                      ),
                    ),
                    title: Text(
                      trainerName,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Text(
                      trainerRole.firstCapitalize(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF555555),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    trailing: InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50),
                      ),
                      splashColor: ColorCode.linearProgressBar,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          child: SvgPicture.asset("assets/images/ic_Drawer_Cancel.svg"),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainerProfileScreen(
                            viewType: "view",
                            trainerId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                  switchRole == userRoleAdmin
                      ? Container(
                          padding: const EdgeInsets.only(left: 20, right: 30, bottom: 20, top: 20),
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.switch_to,
                                style: GymStyle.drawerswitchtext,
                              ),
                              const Spacer(),
                              AdvancedSwitch(
                                borderRadius: BorderRadius.circular(30),
                                width: 110,
                                height: 40,
                                activeColor: Colors.grey,
                                inactiveColor: ColorCode.mainColor,
                                activeChild: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(AppLocalizations.of(context)!.trainer.toUpperCase(),
                                      style: GymStyle.whiteboldText),
                                ),
                                inactiveChild: Padding(
                                  padding: const EdgeInsets.only(right:12),
                                  child: Text(AppLocalizations.of(context)!.admin.toUpperCase(),
                                      style: GymStyle.whiteboldText),
                                ),
                                controller: switchRoleController,
                                thumb: Container(
                                  margin: const EdgeInsets.all(7),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: height * 0.02,
                        ),
/*                  Container(
                    width: width,
                    height: height * 0.06,
                    padding: const EdgeInsets.only(right: 30, left: 20),
                    color: const Color(0xFFE8F7FF),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.enable_dark_mode,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: switchRole == userRoleAdmin ? height * 0.64 : height * 0.71,
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
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrainerDashboardScreen(),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: SvgPicture.asset('assets/images/Member.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.member, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MemberList(),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: SvgPicture.asset('assets/images/Workout.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.workout, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AdminWorkoutList(
                                        /*userId: userId,
                                        userRole: trainerRole,*/
                                        viewType: "",
                                        trainerId: "",
                                        drawerList: true),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: SvgPicture.asset('assets/images/category.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.workout_category, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminWorkoutCategoryListScreen(
                                      userId: userId,
                                      userRole: trainerRole,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: SvgPicture.asset('assets/images/Trainer.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.exercises, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrainerExerciseScreen(workoutCategoryName: "Exercise",viewType: "filter"),
                                  ),
                                );
                              },
                            ),
                            if(StaticData.showPaymentGateway)
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
                            if(StaticData.showPaymentGateway)
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: SvgPicture.asset('assets/images/Trainer.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.nutrition_plan, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
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
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: SvgPicture.asset('assets/images/MembershipPlan.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.membership_plan, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrainerPackageListScreen(drawerList: true),
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
                              title: Text(AppLocalizations.of(context)!.my_packages, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                if(isExpired){
                                  PlanExpiredDialog(context,trainerRole);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MembershipPackageScreen(userRole: trainerRole),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
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
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
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
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
                            if(StaticData.showPaymentGateway)
                            ListTile(
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: SvgPicture.asset('assets/images/Account.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.account, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrainerAccountScreen(),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
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
                                if (isExpired) {
                                  PlanExpiredDialog(context, trainerRole);
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
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
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
                            Divider(height: 1, thickness: GymStyle.deviderThiknes),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Spacer(),
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
