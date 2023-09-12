import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/dashboard_screen.dart';
import 'package:sno_biz_app/screens/recover_password_screen.dart';
import 'package:sno_biz_app/screens/terms_condition_screen.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';

import '../services/localization.dart';
import '../utils/color_constants.dart';
import '../widgets/next_button.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({this.canGoBack = false});
  bool canGoBack = false;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMeCheckboxListTile = false;
  bool passenable = true; //boolean value to track password view enable disable.

  final email = TextEditingController();
  final password = TextEditingController();
  var ctime;
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
    return WillPopScope(
      onWillPop: () async {
        if (widget.canGoBack) {
          Navigator.pop(context);
          return Future.value(false);
        }

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
      child: GestureDetector(
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
                                  '${localizations!.translate('Log in')}',
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
                                  '${localizations!.translate('Enter your details to continue')}',
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
                                ' ${localizations!.translate('Enter your e-mail')}',
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
                                          fontSize:
                                              constraints.maxWidth * 0.04),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.020,
                              ),
                              Text(
                                ' ${localizations!.translate('Enter your password')}',
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
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Theme(
                                        data: ThemeData(
                                          checkboxTheme: CheckboxThemeData(
                                            side: MaterialStateBorderSide
                                                .resolveWith(
                                              (states) => const BorderSide(
                                                  width: 2.0,
                                                  color: AppColors.purpleColor),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                        child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          activeColor: AppColors.purpleColor,
                                          value: _rememberMeCheckboxListTile,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMeCheckboxListTile =
                                                  value!;
                                            });
                                          },
                                        ),
                                      ),
                                      Text(
                                        '${localizations!.translate('Remember Me')}',
                                        style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.04,
                                            color: AppColors.lightBlack),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        nextPage(
                                            context, RecoverPasswordScreen());
                                      },
                                      child: Text(
                                        '${localizations!.translate('Recover Password')}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            color: AppColors.purpleColor,
                                            fontSize:
                                                constraints.maxWidth * 0.04),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.040,
                              ),
                              NextButton(
                                  text: '${localizations!.translate('Log in')}',
                                  onTap: () async {
                                    // SharedPrefUtils.saveStr('isSkiped', "true");

                                    final RegExp emailRegex = RegExp(
                                        r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

                                    if (email.text == '') {
                                      showCustomToast(
                                          context: context,
                                          message:
                                              '${localizations!.translate("Please add email")}');
                                    } else if (emailRegex
                                            .hasMatch(email.text) ==
                                        false) {
                                      showCustomToast(
                                          context: context,
                                          message:
                                              '${localizations!.translate("Please add a valid email")}');
                                    } else if (password.text == '') {
                                      showCustomToast(
                                          context: context,
                                          message:
                                              '${localizations!.translate("Please add a password")}');
                                      // }
                                      // else if (password.text.toString().length <
                                      //     5) {
                                      //   showCustomToast(
                                      //       context: context,
                                      //       message:
                                      //           '${localizations!.translate("Password should be minimum of 5 characters")}');
                                    } else {
                                      CustomLoader.showProgressBar(context);

                                      var obj = {
                                        "email": email.text.toString(),
                                        "password": password.text.toString()
                                      };
                                      log(obj.toString());

                                      SharedPrefUtils.saveStr(
                                          'isSkiped', "true");
                                      dynamic result =
                                          await APIServices.makeApiCall(
                                              "login.php", obj);
                                      Navigator.pop(context);
                                      if (result['errorCode'] == '0000') {
                                        if (_rememberMeCheckboxListTile) {
                                          SharedPrefUtils.saveStr(
                                              'rememberMe', json.encode(obj));
                                        } else {
                                          SharedPrefUtils.removePrefStr(
                                              "rememberMe");
                                        }

                                        SharedPrefUtils.saveStr('userId',
                                            result['userId'].toString());

                                        dynamic checkTerm =
                                            await SharedPrefUtils.readPrefStr(
                                                "termConditionCheck");

                                        if (checkTerm.toString() == 'true') {
                                          nextPagewithReplacement(
                                              context, DashboardScreen());
                                        } else {
                                          nextPagewithReplacement(context,
                                              TermsAndConditionScreen());
                                        }

                                        APIServices.createFirebaseToken(
                                            result['userId']);
                                      }

                                      showCustomToast(
                                          context: context,
                                          message:
                                              '${localizations!.translate(result['errorMessage'])}');
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
      ),
    );
  }
}
