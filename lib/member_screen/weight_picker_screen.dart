import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:numberpicker/numberpicker.dart';
import '../model/user_modal.dart';
import 'age_picker_screen.dart';
import 'height_picker_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeightPicker extends StatefulWidget {
  final UserModal userModal;

  const WeightPicker({Key? key, required this.userModal}) : super(key: key);

  @override
  State<WeightPicker> createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  int _currentIntValue = 50;

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
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.what_is_your_weight,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.weight_in_kg_do_not_worry_you_can_always,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
              ),
              Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.change_it_letter,
                style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
              ),
              SizedBox(
                height: height * 0.255,
              ),
              NumberPicker(
                selectedTextStyle: const TextStyle(color: Color(0xFF6842FF), fontSize: 40),
                axis: Axis.horizontal,
                itemWidth: 60,
                itemCount: 5,
                textStyle: const TextStyle(fontSize: 20),
                minValue: 10,
                maxValue: 150,
                value: _currentIntValue,
                onChanged: (value) => setState(() => _currentIntValue = value),
              ),
              const Icon(
                Icons.arrow_drop_up,
                color: Color(0xFF6842FF),
                size: 50,
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
                            builder: (context) => AgePicker(
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
                          widget.userModal.userWeight = _currentIntValue.toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HeightPickerScreen(
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
