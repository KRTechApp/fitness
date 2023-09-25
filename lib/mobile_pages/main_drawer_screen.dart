import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';

import '../Utils/shared_preferences_manager.dart';
import '../admin_screen/admin_drawer_screen.dart';
import '../member_screen/drawer_screen.dart';
import '../trainer_screen/trainer_drawer_screen.dart';

class MainDrawerScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MainDrawerScreen({Key? key, required this.scaffoldKey}) : super(key: key);

  void onDrawerSelected(bool drawerOpen) {
    if (drawerOpen) {
      scaffoldKey.currentState!.openDrawer();
    } else {
      scaffoldKey.currentState!.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferencesManager().getValue(keyUserRole, userRoleMember),
        builder: (context, AsyncSnapshot<dynamic> asyncSnapshot) {
          return asyncSnapshot.data == userRoleAdmin
              ? AdminDrawerScreen(adminDrawerOpen: onDrawerSelected)
              : asyncSnapshot.data == userRoleTrainer
              ? TrainerDrawerScreen(trainerDrawerOpen: onDrawerSelected)
              : DrawerScreen(drawerOpen: onDrawerSelected);
        });
  }
}
