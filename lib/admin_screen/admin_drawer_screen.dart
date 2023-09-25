import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/trainer_provider.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../Services/dark_theme_prefs.dart';
import '../Utils/color_code.dart';
import '../mobile_pages/admin_account_screen.dart';
import '../mobile_pages/admin_workout_list_screen.dart';
import '../mobile_pages/trainer_package_list_screen.dart';
import '../providers/dark_theme_provider.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import '../utils/gym_style.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/static_data.dart';
import 'admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_setting_screen.dart';
import 'trainer_list_screen.dart';

class AdminDrawerScreen extends StatefulWidget {
  final Function(bool) adminDrawerOpen;

  const AdminDrawerScreen({super.key, required this.adminDrawerOpen});

  @override
  AdminDrawerScreenState createState() => AdminDrawerScreenState();
}

class AdminDrawerScreenState extends State<AdminDrawerScreen> with TickerProviderStateMixin {
  final _switchController = ValueNotifier<bool>(false);
  final switchRoleController = ValueNotifier<bool>(true);

  late DarkThemeProvider themeState;
  DarkThemePrefs darkThemePrefs = DarkThemePrefs();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late TrainerProvider trainerProvider;
  String adminName = "";
  String userRole = "";
  String userId = "";
  String profile = "";
  String currentLanguage = "";

  @override
  void initState() {
    super.initState();
    _switchController.addListener(() {
      debugPrint("_switchController.value : ${_switchController.value}");
      themeState.setDarkTheme = _switchController.value;
    });
    switchRoleController.addListener(() {
      userRole = switchRoleController.value ? userRoleAdmin : userRoleTrainer;

      _preference.setValue(prefUserRole, userRole);
      _preference.setValue(keySwitchRole, userRoleAdmin);

      if (userRole == userRoleAdmin) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            ModalRoute.withName("/AdminScreen"));
      } else if (userRole == userRoleTrainer) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const TrainerDashboardScreen()),
            ModalRoute.withName("/TrainerScreen"));
      }
    });
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _switchController.value = themeState.getDarkTheme;
      adminName = await _preference.getValue(prefName, "");
      userId = await _preference.getValue(prefUserId, "");
      userRole = await _preference.getValue(prefUserRole, "");
      profile = await _preference.getValue(prefProfile, "");
      currentLanguage = await _preference.getValue(prefLanguage, "");
      setState(
        () {},
      );
    });
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
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        image: customImageProvider(url: profile),
                        placeholderFit: BoxFit.fitWidth,
                        placeholder: customImageProvider(),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return getPlaceHolder();
                        },
                      ),
                    ),
                    title: Text(
                      adminName,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Text(userRole.firstCapitalize(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF555555),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        )),
                    trailing: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                        splashColor: ColorCode.linearProgressBar,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(child: SvgPicture.asset("assets/images/ic_Drawer_Cancel.svg")),
                        )),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminProfileScreen(
                                    viewType: "view",
                                    userId: userId,
                                  )));
                    }),
                FutureBuilder(
                    future: FirebaseFirestore.instance.collection(tableGeneralSetting).get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        List<QueryDocumentSnapshot> docList = snapshot.data!.docs;
                        if (docList.isNotEmpty &&
                            (docList.first.data() as Map<String, dynamic>).containsKey(keyAdminIsTrainer) &&
                            docList.first[keyAdminIsTrainer]) {
                          return Container(
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
                                  width: 120,
                                  height: 40,
                                  activeColor: Colors.grey,
                                  inactiveColor: ColorCode.mainColor,

                                  activeChild:
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(AppLocalizations.of(context)!.trainer,style: GymStyle.whiteboldText),
                                      ),
                                  inactiveChild:
                                      Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: Text(AppLocalizations.of(context)!.admin,style: GymStyle.whiteboldText),
                                      ),
                                  controller: switchRoleController,
                                  thumb: Container(
                                    margin: const EdgeInsets.all(7),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                      return const SizedBox();
                    }),
/*                Container(
                  width: width,
                  height: height * 0.06,
                  padding: EdgeInsets.only(right: 30, left: 20),
                  color: Color(0xFFE8F7FF),
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.enable_to_dark_mode,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          )),
                      Spacer(),
                      AdvancedSwitch(
                        width: 32,
                        height: 16,
                        controller: _switchController,
                        activeColor: ColorCode.mainColor,
                      ),
                    ],
                  ),
                ),*/
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: height * 0.71,
                    width: width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => const EnvatoPurchaseVerifyScreen()));
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
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
                            title: Text(AppLocalizations.of(context)!.trainer, style: GymStyle.drawerFont),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TrainerListScreen()));
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
                              padding: const EdgeInsets.only(top: 4),
                              child: SvgPicture.asset('assets/images/MembershipPlan.svg'),
                            ),
                            title: Text(AppLocalizations.of(context)!.trainer_packages, style: GymStyle.drawerFont),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const TrainerPackageListScreen(
                                            drawerList: false,
                                          )));
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
                              child: SvgPicture.asset('assets/images/Workout.svg'),
                            ),
                            title: Text(AppLocalizations.of(context)!.workout, style: GymStyle.drawerFont),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AdminWorkoutList(
                                          /*userId: userId,
                                            userRole: userRole,*/
                                          drawerList: true,
                                          trainerId: "",
                                          viewType: "")));
                            },
                          ),
                          if(StaticData.showPaymentGateway)
                          Divider(height: 1, thickness: GymStyle.deviderThiknes),
                          /* ListTile(
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                            ),
                            contentPadding: EdgeInsets.zero,
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 20, top: 6),
                              child: SvgPicture.asset('assets/images/category.svg'),
                            ),
                            title: Text(AppLocalizations.of(context)!.workout_category, style: GymStyle.drawerFont),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdminWorkoutCategoryListScreen(
                                            userId: userId,
                                            userRole: userRole,
                                          )));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Divider(height: 1, thickness: GymStyle.deviderThiknes),
                          ),*/
                          /*ListTile(
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                            ),
                            contentPadding: EdgeInsets.zero,
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 20, top: 4),
                              child: SvgPicture.asset('assets/images/Member.svg'),
                            ),
                            title: Text('Member', style: GymStyle.drawerFont),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MemberList()));
                            },
                          ),*/
                          /*Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Divider(height: 1, thickness: GymStyle.deviderThiknes),
                          ),*/
                          if(StaticData.showPaymentGateway)
                          ListTile(
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                            ),
                            contentPadding: EdgeInsets.zero,
                            leading: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: SvgPicture.asset('assets/images/Account.svg'),
                            ),
                            title: Text(AppLocalizations.of(context)!.account, style: GymStyle.drawerFont),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminAccountScreen(),
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
                                padding: const EdgeInsets.only(top: 3),
                                child: SvgPicture.asset('assets/images/Setting.svg'),
                              ),
                              title: Text(AppLocalizations.of(context)!.settings, style: GymStyle.drawerFont),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => const AdminSettingScreen()));
                              }),
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
                            leading: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: SvgPicture.asset('assets/images/ic_Logout.svg'),
                            ),
                            title: Text(AppLocalizations.of(context)!.log_out, style: GymStyle.drawerFont),
                          ),
                          Divider(height: 1, thickness: GymStyle.deviderThiknes),
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
        )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _switchController.dispose();
  }
}
