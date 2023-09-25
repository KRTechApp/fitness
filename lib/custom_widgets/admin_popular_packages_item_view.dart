import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../admin_screen/add_trainer_package_screen.dart';
import '../main.dart';
import '../trainer_screen/trainer_add_membership.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';
import 'expired_dailog.dart';

class AdminPopularPackagesItemView extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;
  final String userRole;

  const AdminPopularPackagesItemView({Key? key, required this.documentSnapshot, required this.userRole})
      : super(key: key);

  @override
  State<AdminPopularPackagesItemView> createState() => _AdminPopularPackagesItemViewState();
}

class _AdminPopularPackagesItemViewState extends State<AdminPopularPackagesItemView> {
  final random = Random();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () {
          if(isExpired){
            PlanExpiredDialog(context,widget.userRole);
            return;
          }
          widget.userRole == userRoleAdmin
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTrainerPackageScreen(
                      documentSnapshot: widget.documentSnapshot,
                      viewType: "view",
                    ),
                  ),
                )
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrainerAddMemberShip(
                      documentSnapshot: widget.documentSnapshot,
                      viewType: "view",
                    ),
                  ),
                );
        },
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Container(
                // height: 145,
                width: width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                  color: StaticData.colorList[random.nextInt(StaticData.colorList.length)].withOpacity(0.50),
                ),
                child: Image.asset('assets/images/Circle.png',height: 150,alignment: Alignment.centerRight),
              ),
              /*Positioned(
                right: 0,
                child: Image.asset('assets/images/Circle.png',height: 140),
              ),*/
              Positioned(
                top: 45,
                right: 35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                    image: customImageProvider(url: widget.documentSnapshot[keyProfile] ?? ""),
                    placeholderFit: BoxFit.fitWidth,
                    placeholder: customImageProvider(),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return getPlaceHolder();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.65,
                      child: Text(
                        widget.documentSnapshot[keyMembershipName] ?? "",
                        style: GymStyle.containerHeader,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            color: const Color(0xFF555555),
                            'assets/images/ic_Watch.svg',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              "${widget.documentSnapshot[keyPeriod] ?? " "} ${AppLocalizations.of(context)!.days}",
                              style: GymStyle.containerSubHeader,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "${widget.userRole == userRoleAdmin ? StaticData.currentCurrency : StaticData.currentTrainerCurrency} ${widget.documentSnapshot[keyAmount] ?? " "}.00",
                        style: GymStyle.containerHeader,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.view_details,
                            style: GymStyle.containerLowarText,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: SvgPicture.asset(
                              color: const Color(0xFF181A20),
                              'assets/images/ic_arrow_right.svg',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
