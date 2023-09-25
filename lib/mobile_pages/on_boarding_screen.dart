import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/gym_style.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        Timer(
          const Duration(seconds: 3),
          () => {
            /*Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnBoardingTabsScreen(),
              ),
            )*/
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splashImages/unsplash.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.welcome_to,
                    style: GymStyle.onBoarding,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Image.asset(
                      "assets/splashImages/hello_hand.png",
                      height: 30,
                      width: 30,
                    ),
                  )
                ],
              ),
              Text(
                AppLocalizations.of(context)!.gym_trainer,
                style: GymStyle.onBoardingOne,
              ),
              Text(
                AppLocalizations.of(context)!.the_best_fitness_in_this_century_to_accompany_your_sports,
                style: GymStyle.onBoardingTwo,
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
