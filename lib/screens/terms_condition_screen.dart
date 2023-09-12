import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/dashboard_screen.dart';
import 'package:sno_biz_app/services/localization.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:sno_biz_app/widgets/next_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/color_constants.dart';

import 'package:permission_handler/permission_handler.dart';

class TermsAndConditionScreen extends StatefulWidget {
  TermsAndConditionScreen({this.showBackButton = false});

  bool showBackButton = false;

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  bool _termsNConditionCheckboxListTile = false;
  bool _privacyPolicyCheckboxListTile = false;
  var ctime;
  Future<bool> _checkIfPermissionsRequested() async {
    PermissionStatus cameraStatus = await Permission.camera.status;
    PermissionStatus storageStatus = await Permission.storage.status;

    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  Future<void> _requestPermissions() async {
    // Request camera and storage permissions
    await Permission.camera.request();
    await Permission.storage.request();
  }

  _launchURL(String url) async {
    await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        log("click");
        DateTime now = DateTime.now();
        if (ctime == null || now.difference(ctime) > Duration(seconds: 3)) {
          //add duration of press gap
          ctime = now;
          showCustomToast(
              context: context,
              message: localizations!.translate(
                  'Press the back button again to exit. Come back soon!'));
          return Future.value(false);
        }
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraint) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 25, bottom: 25.0, left: 20.0, right: 20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.max,
                        children: [
                          if (widget.showBackButton)
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.purpleColor),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          SizedBox(
                            height: widget.showBackButton
                                ? MediaQuery.sizeOf(context).height * .040
                                : MediaQuery.sizeOf(context).height * .020,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                '${localizations!.translate('Terms & Conditions')}',
                                style: TextStyle(
                                    color: AppColors.lightBlack,
                                    fontSize: 28,
                                    letterSpacing: 0.2,
                                    fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * .035,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              '${localizations!.translate('At SNO BV, your trust and satisfaction are our top priorities. Before you embark on this digital journey with us, it\'s essential for both parties to be on the same page.')} \n\n',
                                          style: TextStyle(
                                              letterSpacing: 0.5,
                                              fontSize: 16,
                                              color: AppColors.textColor)),
                                      TextSpan(
                                          text:
                                              '${localizations!.translate('Please take a few minutes to thoroughly review our Terms & Conditions and Privacy Policy')}',
                                          style: TextStyle(
                                              letterSpacing: 0.5,
                                              fontSize: 16,
                                              color: AppColors.textColor)),
                                      // TextSpan(
                                      //   text:
                                      //       '${localizations!.translate("")}',
                                      //   style: TextStyle(
                                      //       letterSpacing: 0.5,
                                      //       fontSize: 16,
                                      //       color: AppColors.textColor),
                                      //   // recognizer: TapGestureRecognizer()
                                      //   //   ..onTap = () {
                                      //   //     _launchURL(
                                      //   //         "https://mijnkontinu.nl/privacypolicy.php");
                                      //   //   },
                                      // ),
                                      // TextSpan(
                                      //     text:
                                      //         ' ${localizations!.translate("and")} ',
                                      //     style: TextStyle(
                                      //         letterSpacing: 0.5,
                                      //         fontSize: 16,
                                      //         color: AppColors.textColor)),
                                      // TextSpan(
                                      //   text:
                                      //       '${localizations!.translate("Privacy Policy")}',
                                      //   style: TextStyle(
                                      //       letterSpacing: 0.5,
                                      //       fontSize: 16,
                                      //       color: AppColors.textColor),
                                      //   // recognizer: TapGestureRecognizer()
                                      //   // ..onTap = () {
                                      //   //   _launchURL(
                                      //   //       "https://mijnkontinu.nl/privacypolicy.php");
                                      //   // },
                                      // ),
                                      TextSpan(
                                          text: '\n\n',
                                          style: TextStyle(
                                              letterSpacing: 0.5,
                                              fontSize: 16,
                                              color: AppColors.textColor)),
                                      TextSpan(
                                          text:
                                              '${localizations!.translate("Your understanding and consent are crucial. By proceeding, you confirm your agreement to our terms and our commitment to your privacy.")}\n\n',
                                          style: TextStyle(
                                              letterSpacing: 0.5,
                                              fontSize: 16,
                                              color: AppColors.textColor)),
                                      TextSpan(
                                          text:
                                              '${localizations!.translate("Thank you for choosing SNO BV, and we're excited to have you on board!")}\n',
                                          style: TextStyle(
                                              letterSpacing: 0.5,
                                              fontSize: 16,
                                              color: AppColors.textColor)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * .015,
                          ),
                          Theme(
                              data: ThemeData(
                                checkboxTheme: CheckboxThemeData(
                                  side: MaterialStateBorderSide.resolveWith(
                                    (states) => const BorderSide(
                                        width: 2.0,
                                        color: AppColors.purpleColor),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              child: CheckboxListTile(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                contentPadding: const EdgeInsets.all(0),
                                activeColor: AppColors.purpleColor,
                                // visualDensity: const VisualDensity(
                                //     horizontal: -4, vertical: -4),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                // title: Text(
                                //     '${localizations!.translate('I have read and accept the Terms & Conditions.')}'),
                                title: Transform.translate(
                                  offset: Offset(-10.0, 0),
                                  child: RichText(
                                      text: TextSpan(children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            '${localizations!.translate('I agree to')} ',
                                        style: TextStyle(
                                            letterSpacing: 0.2,
                                            fontSize: 16,
                                            color: AppColors.textColor)),
                                    TextSpan(
                                      text:
                                          '${localizations!.translate("Terms & Conditions")}',
                                      style: TextStyle(
                                          letterSpacing: 0.2,
                                          decoration: TextDecoration.underline,
                                          fontSize: 16,
                                          color: AppColors.purpleColor),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _launchURL(
                                              "https://mijnkontinu.nl/terms.php");
                                        },
                                    ),
                                  ])),
                                ),
                                value: _termsNConditionCheckboxListTile,
                                onChanged: (value) {
                                  setState(() {
                                    _termsNConditionCheckboxListTile = value!;
                                  });
                                },
                              )),
                          SizedBox(height: 0),
                          Theme(
                            data: ThemeData(
                              checkboxTheme: CheckboxThemeData(
                                side: MaterialStateBorderSide.resolveWith(
                                  (states) => const BorderSide(
                                      width: 2.0, color: AppColors.purpleColor),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            child: CheckboxListTile(
                              contentPadding: const EdgeInsets.all(0),
                              activeColor: AppColors.purpleColor,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Transform.translate(
                                offset: Offset(-10.0, 0),
                                child: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          '${localizations!.translate('I agree to')} ',
                                      style: TextStyle(
                                          letterSpacing: 0.2,
                                          fontSize: 16,
                                          color: AppColors.textColor)),
                                  TextSpan(
                                    text:
                                        '${localizations!.translate("Privacy Policy")}',
                                    style: TextStyle(
                                        letterSpacing: 0.2,
                                        decoration: TextDecoration.underline,
                                        fontSize: 16,
                                        color: AppColors.purpleColor),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _launchURL(
                                            "https://mijnkontinu.nl/privacypolicy.php");
                                      },
                                  ),
                                ])),
                              ),

                              // Text(
                              //     '${localizations!.translate('I have read and accept the Privacy Policy.')}'),
                              value: _privacyPolicyCheckboxListTile,
                              onChanged: (value) {
                                setState(() {
                                  _privacyPolicyCheckboxListTile = value!;
                                });
                              },
                            ),
                          ),
                          const Spacer(),
                          SizedBox(height: 7),
                          NextButton(
                              text: '${localizations!.translate('Continue')}',
                              onTap: () async {
                                if (_termsNConditionCheckboxListTile == false) {
                                  showCustomToast(
                                      context: context,
                                      message:
                                          '${localizations!.translate("Please agree to Terms & Conditions")}');
                                } else if (_privacyPolicyCheckboxListTile ==
                                    false) {
                                  showCustomToast(
                                      context: context,
                                      message:
                                          '${localizations!.translate("Please agree to Privacy Policy")}');
                                } else {
                                  bool hasRequestedPermissions =
                                      await _checkIfPermissionsRequested();

                                  if (!hasRequestedPermissions) {
                                    // Request necessary permissions
                                    await _requestPermissions();
                                    // await _markPermissionsAsRequested();
                                  }

                                  await SharedPrefUtils.saveStr(
                                      "termConditionCheck", "true");
                                  nextPagewithReplacement(
                                      context, const DashboardScreen());
                                }
                              })
                        ]),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
