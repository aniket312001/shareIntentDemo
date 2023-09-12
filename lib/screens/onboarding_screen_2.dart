import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/login_screen.dart';
import 'package:sno_biz_app/screens/onboarding_screen_3.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';

import '../services/localization.dart';
import '../utils/color_constants.dart';
import '../widgets/next_button.dart';

class OnboardingScreen2Screen extends StatefulWidget {
  const OnboardingScreen2Screen({super.key});

  @override
  State<OnboardingScreen2Screen> createState() =>
      _OnboardingScreen2ScreenState();
}

class _OnboardingScreen2ScreenState extends State<OnboardingScreen2Screen> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(child: SizedBox(
        child: LayoutBuilder(builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 30.0, left: 20, right: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .011,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: AppColors.lightColor),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * .015,
                          ),
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: AppColors.lightColor),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * .015,
                          ),
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: AppColors.purpleColor),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * .015,
                          ),
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: AppColors.lightColor),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .060,
                      ),
                      const Text(
                        'Ons Gemak',
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontSize: 30,
                            color: AppColors.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .020,
                      ),
                      Image.asset(
                        'assets/images/contact_with_team.png',
                        height: MediaQuery.sizeOf(context).height * .35,
                        width: MediaQuery.sizeOf(context).width * .72,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .020,
                      ),
                      Text(
                        '${localizations!.translate('Be in touch with your Accounting Team')}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontSize: 24,
                            color: AppColors.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .045,
                      ),
                      NextButton(
                          text: '${localizations!.translate('Next')}',
                          onTap: () {
                            nextPage(context, OnboardingScreen3Screen());
                          }),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .025,
                      ),
                      GestureDetector(
                        onTap: () {
                          SharedPrefUtils.saveStr('isSkiped', "true");
                          nextPagewithReplacement(context, LoginScreen());
                        },
                        child: Text(
                          '${localizations!.translate("Skip")}',
                          style: TextStyle(
                              color: AppColors.textColor,
                              fontSize:
                                  MediaQuery.sizeOf(context).height * .018),
                        ),
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${localizations!.translate("Already have an account?")} ',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              TextSpan(
                                text: '${localizations!.translate("Log in")}.',
                                style: TextStyle(
                                    color: AppColors.lightBlack, fontSize: 16),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextPage(
                                        context, LoginScreen(canGoBack: true));
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      )),
    );
  }
}
