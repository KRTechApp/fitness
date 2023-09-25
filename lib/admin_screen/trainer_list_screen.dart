import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/model/trainer_modal.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:provider/provider.dart';

import '../Utils/shared_preferences_manager.dart';
import '../custom_widgets/trainer_list_item_view.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../providers/payment_history_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/tables_keys_values.dart';
import 'add_trainer_screen.dart';
import 'admin_dashboard_screen.dart';

class TrainerListScreen extends StatefulWidget {
  const TrainerListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends State<TrainerListScreen> {
  late TrainerModal trainerModal;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TrainerProvider trainerProvider;
  bool searchVisible = false;
  var textSearchController = TextEditingController();
  late ShowProgressDialog progressDialog;
  final SharedPreferencesManager _preference = SharedPreferencesManager();

  String currentUserId = "";

  @override
  void initState() {
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    Provider.of<PaymentHistoryProvider>(context, listen: false).createdByPaymentHistory.clear();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        progressDialog.show(message: 'Loading...');
        currentUserId = await _preference.getValue(prefUserId, "");
        await trainerProvider.getTrainerList(isRefresh: true);
        progressDialog.hide();
        setState(
          () {},
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                (Route<dynamic> route) => false);

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
          title: Text(AppLocalizations.of(context)!.trainer),
          actions: [
            InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                setState(
                  () {
                    searchVisible = !searchVisible;
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  height: 23,
                  width: 23,
                  'assets/images/ic_Search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                  allowDrawingOutsideViewBox: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                splashColor: ColorCode.linearProgressBar,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTrainer(viewType: 'add', documentSnapshot: null),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(
                    height: 20,
                    width: 20,
                    'assets/images/add_member.svg',
                    color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          /*mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,*/
          children: [
            if (searchVisible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Card(
                  // elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFD9E1ED),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.center,
                      controller: textSearchController,
                      cursorColor: ColorCode.mainColor,
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          onSearchTextChanged(
                            value.trim(),
                          );
                        } else {
                          onSearchTextChanged("");
                        }
                      },
                      decoration: InputDecoration(
                        hintStyle: GymStyle.searchbox,
                        hintText: AppLocalizations.of(context)!.search_trainer_list,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          child: SvgPicture.asset(
                            "assets/images/SearchIcon.svg",
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 5, 0),
                      ),
                    ),
                  ),
                ),
              ),
            /*SizedBox(
              height: height * 0.025,
            ),*/
            SizedBox(
              height: searchVisible ? height * 0.85 - 58 : height * 0.85,
              width: width,
              child: RefreshIndicator(
                onRefresh: _pullRefresh,
                color: ColorCode.mainColor,
                child: Consumer<TrainerProvider>(
                  builder: (context, trainerData, child) => trainerData.trainerListItem.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80, top: 10),
                          itemCount: trainerData.trainerListItem.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final QueryDocumentSnapshot documentSnapshot = trainerData.trainerListItem[index];
                            return TrainerListItemView(queryDocumentSnapshot: documentSnapshot, currentUserId: currentUserId);
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddTrainer(viewType: 'add', documentSnapshot: null),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: ColorCode.tabDivider,
                                  maxRadius: 45,
                                  child: SvgPicture.asset('assets/images/add_member.svg', height: 30),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                child: Text(
                                  AppLocalizations.of(context)!.you_do_not_have_any_trainer,
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
                              Text(
                                AppLocalizations.of(context)!.tap_to_add,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.listSubTitle,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
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

  onSearchTextChanged(String text) async {
    debugPrint("onSearchTextChanged : $text");
    trainerProvider.trainerListItem.clear();
    trainerProvider.getTrainerList(searchText: text, isRefresh: text.isEmpty);
  }

  Future<void> _pullRefresh() async {
    progressDialog.show(message: 'Loading...');
    await trainerProvider.getTrainerList(isRefresh: true);
    progressDialog.hide();
  }
}
