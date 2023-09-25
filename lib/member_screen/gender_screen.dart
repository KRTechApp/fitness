import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/model/user_modal.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';

import 'age_picker_screen.dart';

class Gender extends StatefulWidget {
  final UserModal userModal;

  const Gender({
    Key? key,
    required this.userModal,
  }) : super(key: key);

  @override
  State<Gender> createState() => _GenderState();
}

class _GenderState extends State<Gender> {
  var gender = "male";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // backgroundColor: ColorCode.backgroundColor,
      body: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.only(right: 25, left: 25),
          child: Column(
            children: [
              SizedBox(
                height: height * 0.10,
              ),
              Text(
                AppLocalizations.of(context)!.tell_us_about_your_self,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.to_give_better_experience_and_result_to,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
              ),
              Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.your_members_we_need_to_know_your_gender,
                style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
              ),
              SizedBox(
                height: height * 0.07,
              ),
              GestureDetector(
                onTap: () {
                  setState(
                    () {
                      gender = "male";
                    },
                  );
                },
                child: Container(
                  height: 165,
                  width: 165,
                  decoration: BoxDecoration(
                    color: gender == "male" ? const Color(0xFF6842FF) : const Color(0xFF676767),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Icon(
                          Icons.male,
                          color: Colors.white,
                          size: 85,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.male,
                        style: GymStyle.formTitle,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.07,
              ),
              GestureDetector(
                onTap: () {
                  setState(
                    () {
                      gender = "female";
                    },
                  );
                },
                child: Container(
                  height: 165,
                  width: 165,
                  decoration: BoxDecoration(
                    color: gender == "female" ? const Color(0xFF6842FF) : const Color(0xFF676767),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Icon(
                          Icons.female,
                          color: Colors.white,
                          size: 85,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.female,
                        style: GymStyle.formTitle,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                height: height * 0.08,
                width: width * 0.85,
                margin: const EdgeInsets.only(bottom: 38),
                child: ElevatedButton(
                  onPressed: () {
                    widget.userModal.userGender = gender;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AgePicker(
                            userModal: widget.userModal,
                          ),
                        ));
                  },
                  style: GymStyle.buttonStyle,
                  child: Text(
                    AppLocalizations.of(context)!.continues.allInCaps,
                    style: GymStyle.buttonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
