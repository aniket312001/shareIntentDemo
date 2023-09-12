import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/change_password_screen.dart';
import 'package:sno_biz_app/screens/dashboard_screen.dart';
import 'package:sno_biz_app/screens/login_screen.dart';
import 'package:sno_biz_app/screens/terms_condition_screen.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';

import '../services/localization.dart';
import '../utils/color_constants.dart';
import '../widgets/next_button.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
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

    checkAlreadyRememberMe();
  }

  checkAlreadyRememberMe() async {
    dynamic data = await SharedPrefUtils.readPrefStr("rememberMe");

    log(data.toString() + " data");
    if (data.toString() != 'null') {
      data = json.decode(data);

      setState(() {
        email.text = data['email'];
        password.text = data['password'];
        _rememberMeCheckboxListTile = true;
      });
    } else {
      log("data not present ");
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return GestureDetector(onTap: () {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }, child: LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: AppColors.blueColor,
        body: SafeArea(
          child: Column(children: [
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
              height: MediaQuery.sizeOf(context).height * .030,
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
                              '${localizations!.translate('Recover Password')}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  letterSpacing: 0.2,
                                  color: AppColors.lightBlack,
                                  fontSize: constraints.maxWidth * 0.074,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015,
                          ),
                          Center(
                            child: Text(
                              '${localizations!.translate('Enter your email to receive an reset password link on your email id')}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: 0.2,
                                fontSize: constraints.maxWidth * 0.045,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.045,
                          ),
                          Text(
                            ' ${localizations!.translate('Enter your e-mail')}',
                            style: TextStyle(
                                color: AppColors.lightBlack,
                                fontSize: constraints.maxWidth * 0.045,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.012,
                          ),
                          TextField(
                              controller: email,
                              style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.04,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 15.0,
                                      top: 5.0,
                                      bottom: 5.0),
                                  suffixIcon: const Icon(
                                    Icons.email,
                                    size: 20,
                                    color: AppColors.greyColor,
                                  ),
                                  hintText:
                                      '${localizations!.translate("Email")}',
                                  hintStyle: TextStyle(
                                      fontSize: constraints.maxWidth * 0.04),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(
                                        width: 0.5, color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppColors.purpleColor,
                                          width: 0.5),
                                      borderRadius:
                                          BorderRadius.circular(30.0)))),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.020,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  nextPage(context, LoginScreen());
                                },
                                child: Text(
                                  '${localizations!.translate('Login page')}',
                                  style: TextStyle(
                                      color: AppColors.purpleColor,
                                      fontSize: constraints.maxWidth * 0.04),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.050,
                          ),
                          NextButton(
                              text: '${localizations!.translate('Submit')}',
                              onTap: () async {
                                // SharedPrefUtils.saveStr('isSkiped', "true");

                                final RegExp emailRegex = RegExp(
                                    r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

                                if (email.text == '') {
                                  showCustomToast(
                                      context: context,
                                      message:
                                          '${localizations!.translate("Please add email")}');
                                } else if (emailRegex.hasMatch(email.text) ==
                                    false) {
                                  showCustomToast(
                                      context: context,
                                      message:
                                          '${localizations!.translate("Please add a valid email")}');
                                } else {
                                  var obj = {
                                    "email": email.text.toString(),
                                  };

                                  // nextPage(context, ChangePasswordScreen());
                                  dynamic result =
                                      await APIServices.makeApiCall(
                                          "verify-email.php", obj);

                                  showCustomToast(
                                      context: context,
                                      message:
                                          '${localizations!.translate(result['errorMessage'])}');
                                }
                              }),
                        ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    }));
  }
}
