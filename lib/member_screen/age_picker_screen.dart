import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/model/user_modal.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gender_screen.dart';
import 'weight_picker_screen.dart';

class AgePicker extends StatefulWidget {
  final UserModal userModal;

  const AgePicker({
    Key? key,
    required this.userModal,
  }) : super(key: key);

  @override
  State<AgePicker> createState() => _AgePickerState();
}

class _AgePickerState extends State<AgePicker> {
  int _currentIntValue = 18;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            children: [
              SizedBox(
                height: height * 0.10,
              ),
              Text(
                AppLocalizations.of(context)!.how_old_are_you,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.age_in_years_this_will_help_you_to_personalize,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
              ),
              Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.an_exercise_program_plan_that_suits_you,
                style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
              ),
              SizedBox(
                height: height * 0.10,
              ),
              NumberPicker(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: ColorCode.mainColor,
                      width: 4,
                    ),
                    bottom: BorderSide(
                      color: ColorCode.mainColor,
                      width: 4,
                    ),
                  ),
                ),
                selectedTextStyle: const TextStyle(
                  color: Color(0xFF6842FF),
                  fontSize: 40,
                ),
                itemWidth: 80,
                itemCount: 7,
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
                minValue: 1,
                maxValue: 100,
                value: _currentIntValue,
                onChanged: (value) => setState(() => _currentIntValue = value),
              ),
              const Spacer(),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.08,
                    width: width * 0.40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Gender(userModal: widget.userModal),
                            ));
                      },
                      style: GymStyle.backButtonStyle,
                      child: Text(
                        AppLocalizations.of(context)!.back.allInCaps,
                        style: GymStyle.buttonTextStyle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: SizedBox(
                      height: height * 0.08,
                      width: width * 0.40,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.userModal.userAge = _currentIntValue.toString();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeightPicker(
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
                  ),
                ],
              ),
              const SizedBox(height: 38),
            ],
          ),
        ),
      ),
    );
  }
}
