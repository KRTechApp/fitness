import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/providers/trainer_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/assign_membership_trainer_item_view.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import 'add_trainer_screen.dart';

class AssignMembershipToTrainerScreen extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;

  const AssignMembershipToTrainerScreen({
    Key? key,
    required this.documentSnapshot,
  }) : super(key: key);

  @override
  State<AssignMembershipToTrainerScreen> createState() => _AssignMembershipToTrainerState();
}

class _AssignMembershipToTrainerState extends State<AssignMembershipToTrainerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TrainerProvider trainerProvider;
  late MemberProvider memberProvider;
  late ShowProgressDialog progressDialog;
  List<String> selectTrainerList = [];
  List<String> alreadySelectedTrainerList = [];
  List<String> unSelectedTrainerList = [];

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getMemberList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leadingWidth: 48,
        leading: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
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
        title: Text(widget.documentSnapshot[keyMembershipName] ?? ""),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                /*
                setState(() {
                  searchVisible = !searchVisible;
                });
             */
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  height: 25,
                  width: 25,
                  'assets/images/ic_Search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0,left: 20),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTrainer(
                        viewType: 'add',
                        documentSnapshot: null,
                        membershipId: widget.documentSnapshot.id,
                        membershipName: widget.documentSnapshot[keyMembershipName] ?? ""),
                  ),
                );
              },
              child: SvgPicture.asset(
                height: 20,
                width: 20,
                'assets/images/add_member.svg',
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            // margin: EdgeInsets.only(right: 15),
            height: height,
            width: width,
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.025,
                ),
                SizedBox(
                  height: height * 0.85,
                  width: width * 1,
                  child: RefreshIndicator(
                    onRefresh: getMemberList,
                    color: ColorCode.mainColor,
                    child: Consumer<TrainerProvider>(
                      builder: (context, trainerData, child) => trainerProvider.trainerListItem.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: trainerProvider.trainerListItem.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final QueryDocumentSnapshot documentSnapshot = trainerData.trainerListItem[index];
                                return AssignMembershipTrainerItemView(
                                    membershipId: widget.documentSnapshot.id,
                                    selectedTrainerList: selectTrainerList,
                                    index: index,
                                    documentSnapshot: documentSnapshot,
                                    onTrainerSelected: onSelectedTrainer);
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: ColorCode.tabDivider,
                                    maxRadius: 45,
                                    child: Image.asset('assets/images/empty_box.png'),
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
                                ],
                              ),
                            ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 13,
            left: 23,
            child: SizedBox(
              height: height * 0.08,
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  progressDialog.show();
                  trainerProvider
                      .assignMembershipToTrainer(
                          context: context,
                          membershipDoc: widget.documentSnapshot,
                          selectedTrainerList: selectTrainerList,
                          alreadySelectedTrainerList: alreadySelectedTrainerList,
                          unSelectedTrainerList: unSelectedTrainerList)
                      .then(
                        (defaultResponseData) => {
                      progressDialog.hide(),
                      if (defaultResponseData.status != null &&
                          defaultResponseData.status!)
                        {
                          Fluttertoast.showToast(
                              msg: defaultResponseData.message ??
                                  AppLocalizations.of(context)!.something_want_to_wrong,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0),
                          Navigator.pop(context, true),
                        }
                      else
                        {
                          progressDialog.hide(),
                          Fluttertoast.showToast(
                              msg: defaultResponseData.message ??
                                  AppLocalizations.of(context)!.something_want_to_wrong,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0)
                        }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: ColorCode.mainColor,
                ),
                child: Text(
                  AppLocalizations.of(context)!.assign_to_trainer.toUpperCase(),
                  style: GymStyle.buttonTextStyle,
                ),
              ),
            ),
          )
        ],
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  onSelectedTrainer(String id, bool selected) {
    setState(() {
      if (selected) {
        if (!selectTrainerList.contains(id)) {
          selectTrainerList.add(id);
          unSelectedTrainerList.remove(id);
        }
        if (unSelectedTrainerList.contains(id)) {
          unSelectedTrainerList.remove(id);
        }
      } else {
        selectTrainerList.remove(id);
        unSelectedTrainerList.add(id);
      }
    });
  }

  Future<void> getMemberList() async {
    progressDialog.show();
    await trainerProvider.getTrainerList(isRefresh: true);
    progressDialog.hide();
    selectTrainerList.clear();
    alreadySelectedTrainerList.clear();
    List<QueryDocumentSnapshot> trainerList = trainerProvider.trainerListItem
        .where((element) => element[keyCurrentMembership] == widget.documentSnapshot.id)
        .toList();
    for (QueryDocumentSnapshot doc in trainerList) {
      selectTrainerList.add(doc.id);
      alreadySelectedTrainerList.add(doc.id);
    }
    setState(() {});
    debugPrint("selectTrainerList : $selectTrainerList");
  }
}
