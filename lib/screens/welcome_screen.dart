import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/login_screen.dart';
import 'package:sno_biz_app/screens/select_language_screen.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/next_button.dart';

import '../services/localization.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
                        height: MediaQuery.sizeOf(context).height * .050,
                      ),
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'assets/images/sno_biz_logo.png',
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: 200,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .00,
                      ),
                      const Text(
                        'Welcome to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontSize: 16,
                            color: AppColors.lightBlack),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .005,
                      ),
                      const Text(
                        'Ons Gemak',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 34,
                            letterSpacing: 0.2,
                            color: AppColors.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .005,
                      ),
                      Text("For Kontinu Consultancy BV",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 0.2,
                              fontSize: 16,
                              color: AppColors.lightBlack)),
                      // SizedBox(
                      //   height: MediaQuery.sizeOf(context).height * .010,
                      // ),
                      // Text(
                      //   '${localizations!.translate('This is our most advanced version,\nthank you for downloading it')}',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //       letterSpacing: 0.2,
                      //       fontSize: 15,
                      //       color: AppColors.greyColor),
                      // ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .099,
                      ),
                      NextButton(
                          text: '${localizations!.translate('Next')}',
                          onTap: () {
                            nextPage(context, const SelectLanguageScreen());
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
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .105,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${localizations!.translate("Already have an account?")} ',
                              style: TextStyle(
                                  color: AppColors.greyColor, fontSize: 16),
                            ),
                            TextSpan(
                              text: '${localizations!.translate("Log in.")}',
                              style: const TextStyle(
                                  color: AppColors.lightBlack, fontSize: 16),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  SharedPrefUtils.saveStr('isSkiped', "true");
                                  nextPage(
                                      context, LoginScreen(canGoBack: true));
                                },
                            ),
                          ],
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
