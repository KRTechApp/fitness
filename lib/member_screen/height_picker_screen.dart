import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/user_modal.dart';
import 'profile_screen.dart';
import 'weight_picker_screen.dart';

class HeightPickerScreen extends StatefulWidget {
  final UserModal userModal;

  const HeightPickerScreen({Key? key, required this.userModal}) : super(key: key);

  @override
  State<HeightPickerScreen> createState() => _HeightPickerScreenState();
}

class _HeightPickerScreenState extends State<HeightPickerScreen> {
  int _currentIntValue = 150;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // backgroundColor: ColorCode.backgroundColor,
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
                AppLocalizations.of(context)!.what_is_your_height,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.height_in_cm_do_not_worry_you_can_always,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
              ),
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.change_it_letter,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
              ),
              SizedBox(
                height: height * 0.09,
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
                  fontSize: 40,
                  color: Color(0xFF6842FF),
                ),
                itemWidth: 80,
                itemCount: 7,
                textStyle: const TextStyle(fontSize: 20),
                minValue: 80,
                maxValue: 200,
                value: _currentIntValue,
                onChanged: (value) => setState(() => _currentIntValue = value),
              ),
              const Spacer(),
              Row(
                children: [
                  SizedBox(
                    height: height * 0.08,
                    width: width * 0.40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeightPicker(
                              userModal: widget.userModal,
                            ),
                          ),
                        );
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
                          widget.userModal.userHeight = _currentIntValue.toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                userModal: widget.userModal,
                              ),
                            ),
                          );
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
              const SizedBox(
                height: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
