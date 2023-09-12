import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/dashboard_screen.dart';
import 'package:sno_biz_app/screens/login_screen.dart';
import 'package:sno_biz_app/screens/recover_password_screen.dart';
import 'package:sno_biz_app/screens/terms_condition_screen.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';

import '../services/localization.dart';
import '../utils/color_constants.dart';
import '../widgets/next_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({required this.token});

  dynamic token = '';

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _rememberMeCheckboxListTile = false;
  bool passenable = true; //boolean value to track password view enable disable.
  bool passenable2 =
      true; //boolean value to track password view enable disable.

  final email = TextEditingController();
  final password = TextEditingController();
  final password2 = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log("opend password change page");

    getEmail();
  }

  getEmail() {
    List<int> bytes = base64Decode(widget.token);
    email.text = utf8.decode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.blueColor,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .030,
                ),
                Image.asset(
                  'assets/images/sno_biz_logo.png',
                  color: Colors.white,
                  height: 140,
                  width: 140,
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .020,
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        color: Colors.white),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, top: 45.0, right: 20.0, bottom: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                '${localizations!.translate('Change Password')}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: 0.2,
                                    color: AppColors.lightBlack,
                                    fontSize: constraints.maxWidth * 0.074,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015,
                            ),
                            Center(
                              child: Text(
                                '${localizations!.translate('Enter your new password to continue')}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  letterSpacing: 0.2,
                                  fontSize: constraints.maxWidth * 0.044,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.045,
                            ),
                            Text(
                              ' ${localizations!.translate('Enter new password')}',
                              style: TextStyle(
                                  color: AppColors.lightBlack,
                                  fontSize: constraints.maxWidth * 0.045,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.012,
                            ),
                            TextField(
                              controller: password,
                              style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.04,
                                  color: Colors.black),
                              obscureText:
                                  passenable, //if passenable == true, show **, else show password character
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                      width: 0.5, color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 18.0, right: 0, top: 0, bottom: 0),
                                hintText:
                                    '${localizations!.translate("Password")}',
                                hintStyle: TextStyle(
                                    fontSize: constraints.maxWidth * 0.04),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.purpleColor,
                                        width: 0.5),
                                    borderRadius: BorderRadius.circular(30.0)),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      passenable = !passenable;
                                    });
                                  },
                                  child: Icon(
                                    passenable == true
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 20,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015,
                            ),
                            Text(
                              '${localizations!.translate('Enter confirm password')}',
                              style: TextStyle(
                                  color: AppColors.lightBlack,
                                  fontSize: constraints.maxWidth * 0.045,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.012,
                            ),
                            TextField(
                              controller: password2,
                              style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.04,
                                  color: Colors.black),
                              obscureText:
                                  passenable2, //if passenable == true, show **, else show password character
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                      width: 0.5, color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 18.0, right: 0, top: 0, bottom: 0),
                                hintText:
                                    '${localizations!.translate("Password")}',
                                hintStyle: TextStyle(
                                    fontSize: constraints.maxWidth * 0.04),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.purpleColor,
                                        width: 0.5),
                                    borderRadius: BorderRadius.circular(30.0)),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      passenable2 = !passenable2;
                                    });
                                  },
                                  child: Icon(
                                    passenable2 == true
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 20,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   height: MediaQuery.of(context).size.height * 0.020,
                            // ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.040,
                            ),
                            NextButton(
                                text: '${localizations!.translate('Reset')}',
                                onTap: () async {
                                  // SharedPrefUtils.saveStr('isSkiped', "true");

                                  if (password.text == '') {
                                    showCustomToast(
                                        context: context,
                                        message:
                                            '${localizations!.translate("Please enter a password")}');
                                  } else if (password2.text == '') {
                                    showCustomToast(
                                        context: context,
                                        message:
                                            '${localizations!.translate("Please enter confirmed password")}');
                                  } else if (password2.text.toString() !=
                                      password.text.toString()) {
                                    showCustomToast(
                                        context: context,
                                        message:
                                            '${localizations!.translate("Both Passwords should be match")}');
                                  } else {
                                    var obj = {
                                      "email": email.text.toString(),
                                      "newPassword": password.text.toString()
                                    };

                                    dynamic result =
                                        await APIServices.makeApiCall(
                                            "change-password.php", obj);

                                    if (result['errorCode'] == '0000') {
                                      nextPagewithReplacement(
                                          context, LoginScreen());

                                      showCustomToast(
                                          context: context,
                                          message:
                                              '${localizations!.translate('Password Updated Successfully!')}');
                                    } else {
                                      showCustomToast(
                                          context: context,
                                          message:
                                              '${localizations!.translate(result['errorMessage'])}');
                                    }
                                  }
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
