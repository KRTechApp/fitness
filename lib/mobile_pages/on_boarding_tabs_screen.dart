import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';

import 'login_screen.dart';
import 'social_login_screen.dart';

class OnBoardingTabsScreen extends StatefulWidget {
  const OnBoardingTabsScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingTabsScreen> createState() => _OnBoardingTabsScreenState();
}

class _OnBoardingTabsScreenState extends State<OnBoardingTabsScreen> {
  List<String> tabImages = [
    "assets/splashImages/unsplash_one.png",
    "assets/splashImages/unsplash_two.png",
    "assets/splashImages/unsplash_three.png"
  ];

  List<String> tabText = [
    "Find the right \nworkout for what \nyou need",
    "Make suitable \nworkout and great \nresult",
    "Let’s do a workout \nand live healthy \nwith us",
  ];

  var _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: height * 0.83,
            width: width,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(
                  () {
                    _selectedIndex = index;
                  },
                );
              },
              itemCount: 3,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      height: height * 0.60,
                      width: width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            tabImages[index],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Text(
                      tabText[index],
                      textAlign: TextAlign.center,
                      style: GymStyle.onBoardingTabsText,
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                3,
                (index) => Indicator(isActive: _selectedIndex == index ? true : false),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.03,
          ),
          SizedBox(
            height: height * 0.08,
            width: width * 0.85,
            child: ElevatedButton(
              onPressed: () {
                setState(
                  () {
                    if (_selectedIndex < 2) {
                      _selectedIndex++;
                      _pageController.animateToPage(_selectedIndex,
                          duration: const Duration(seconds: 1), curve: Curves.easeOutSine);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                );
              },
              style: GymStyle.buttonStyle,
              child: Text(
                AppLocalizations.of(context)!.next.toUpperCase(),
                style: GymStyle.buttonTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final bool isActive;

  const Indicator({Key? key, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      width: isActive ? 25 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? ColorCode.mainColor : ColorCode.indicator,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
