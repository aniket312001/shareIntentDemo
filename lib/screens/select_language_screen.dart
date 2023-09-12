import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/login_screen.dart';
import 'package:sno_biz_app/screens/onboarding_screen_1.dart';
import 'package:sno_biz_app/services/localization.dart';
import 'package:sno_biz_app/services/select_language.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/next_button.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String selectedLanguage = "en";
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageChange>(context);

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
                        height: MediaQuery.sizeOf(context).height * .040,
                      ),
                      const Text(
                        'Select your preferred\nlanguage',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontSize: 24,
                            color: AppColors.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .035,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                                width: 1, color: AppColors.purpleColor)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5, left: 15, right: 5),
                          child: RadioListTile(
                            fillColor: MaterialStateColor.resolveWith(
                                (states) => AppColors.purpleColor),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: const Text(
                              "English",
                              style: TextStyle(color: AppColors.textColor),
                            ),
                            value: "en",
                            groupValue: selectedLanguage,
                            onChanged: (value) {
                              setState(() {
                                selectedLanguage = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .024,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                                width: 1, color: AppColors.purpleColor)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5, left: 15, right: 5),
                          child: RadioListTile(
                            fillColor: MaterialStateColor.resolveWith(
                                (states) => AppColors.purpleColor),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: const Text(
                              "Dutch",
                              style: TextStyle(color: AppColors.textColor),
                            ),
                            value: "nl",
                            groupValue: selectedLanguage,
                            onChanged: (value) {
                              setState(() {
                                selectedLanguage = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .024,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                                width: 1, color: AppColors.purpleColor)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5, left: 15, right: 5),
                          child: RadioListTile(
                            fillColor: MaterialStateColor.resolveWith(
                                (states) => AppColors.purpleColor),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: const Text(
                              "French",
                              style: TextStyle(color: AppColors.textColor),
                            ),
                            value: "fr",
                            groupValue: selectedLanguage,
                            onChanged: (value) {
                              setState(() {
                                selectedLanguage = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .105,
                      ),
                      NextButton(
                          text: 'Next',
                          onTap: () {
                            lang.changeAppLanguage(selectedLanguage.toString());
                            SharedPrefUtils.saveStr('selectedLanguage',
                                selectedLanguage.toString());
                            AppLocalizations.of(context)!.locale =
                                Locale(selectedLanguage.toString());
                            nextPage(context, OnboardingScreen1Screen());
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
                          "Skip",
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
                              const TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                    color: AppColors.greyColor, fontSize: 16),
                              ),
                              TextSpan(
                                text: "Log in.",
                                style: TextStyle(
                                    color: AppColors.lightBlack, fontSize: 16),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextPage(context, LoginScreen());
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
