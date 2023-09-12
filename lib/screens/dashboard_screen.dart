import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sno_biz_app/app_route/app_route.dart';

import 'package:sno_biz_app/screens/upload_document/upload_document_screen.dart';

import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/services/localization.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  dynamic allData = {};
  var ctime;

  openDrawer() {
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState!.openEndDrawer();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
  }

  fetchData() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {"userId": userId, "companyId": "", "period": "", "mode": ""};

    dynamic response =
        await APIServices.makeApiCall("fetch-common-details.php", obj);

    log(response.toString() + " data");
    if (response['errorCode'] == '0000') {
      setState(() {
        allData = response;
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  __refresh() {
    fetchData();
  }

  _launchURL(String url) async {
    await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (ctime == null || now.difference(ctime) > Duration(seconds: 2)) {
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
      child: LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.skyBlueColor,
          body: SafeArea(
              child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 25.0, right: 20.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      '${localizations!.translate('Welcome')}, ${allData.containsKey('fullName') ? allData['fullName'] : 'Unknown'}!',
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontSize: constraints.maxWidth * 0.058,
                          color: AppColors.lightBlack,
                          fontWeight: FontWeight.bold),
                    )),
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        'assets/images/notifications.svg',
                        semanticsLabel: 'My SVG Image',
                        height: 30,
                        width: 30,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * .023,
                    ),
                    GestureDetector(
                      onTap: () {
                        openDrawer();
                      },
                      child: const Icon(
                        Icons.menu,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 25.0, right: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  width: MediaQuery.sizeOf(context).width,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            // nextPage(context, const UploadDoumentScreen());
                            refreshPreviousPage(
                                context, UploadDoumentScreen(), __refresh);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            width: MediaQuery.sizeOf(context).width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: AppColors.skyBlueColor),
                            child: SvgPicture.asset(
                              'assets/images/cloud_upload.svg',
                              semanticsLabel: 'My SVG Image',
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '${localizations!.translate('Upload Documents')}',
                        style: TextStyle(
                            letterSpacing: 0.5,
                            fontSize: constraints.maxWidth * 0.052,
                            color: AppColors.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, top: 15.0, right: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: AppColors.purpleColor),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .011,
                            ),
                            Expanded(
                              child: Container(
                                height: 7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: AppColors.purpleColor),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .011,
                            ),
                            Expanded(
                              child: Container(
                                height: 7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: AppColors.purpleColor),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .011,
                            ),
                            Expanded(
                              child: Container(
                                height: 7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: AppColors.purpleColor),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .011,
                            ),
                            Expanded(
                              child: Container(
                                height: 7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: AppColors.purpleColor),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, top: 15.0, right: 20.0, bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${allData.containsKey('thisMonthUploads') ? allData['thisMonthUploads'] : '0'} ${localizations!.translate("Receipts")} ',
                                    style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.048,
                                        color: AppColors.lightBlack,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${localizations!.translate('Upload this month')}',
                                    style: TextStyle(
                                      fontSize: constraints.maxWidth * 0.042,
                                      color: AppColors.lightBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // APIServices.createFirebaseToken();

                                // nextPage(context,
                                //     UploadedDoumentListScreen(mode: "all"));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purpleColor,
                                  padding: EdgeInsets.only(
                                      left: constraints.maxWidth * 0.06,
                                      right: constraints.maxWidth * 0.06),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  textStyle: TextStyle(
                                      fontSize: constraints.maxWidth * 0.04,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              child:
                                  Text('${localizations!.translate('View')}'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .030,
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 15.0, right: 20.0, bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${localizations!.translate('Menu')}',
                            style: TextStyle(
                                fontSize: constraints.maxWidth * 0.055,
                                color: AppColors.lightBlack,
                                fontWeight: FontWeight.bold),
                          ),
                          // SizedBox(
                          //   height: MediaQuery.sizeOf(context).height * .025,
                          // ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // nextPage(context,
                                    //     UploadedDoumentListScreen(mode: "unpaid"));
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.sizeOf(context)
                                                    .height *
                                                .025,
                                            right: MediaQuery.sizeOf(context)
                                                    .width *
                                                .01),
                                        padding: const EdgeInsets.only(
                                          top: 15.0,
                                          left: 12.0,
                                          right: 5.0,
                                          bottom: 15.0,
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                                width: 1,
                                                color: AppColors.skyBlueColor)),
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      AppColors.skyBlueColor),
                                              padding: const EdgeInsets.all(13),
                                              child: SvgPicture.asset(
                                                'assets/images/library_add_check.svg',
                                                semanticsLabel: 'My SVG Image',
                                                height: 19,
                                                width: 19,
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  .025,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${localizations!.translate('Verify Invoices')}',
                                                style: TextStyle(
                                                    fontSize:
                                                        constraints.maxWidth *
                                                            0.037,
                                                    letterSpacing: 0.3,
                                                    color: AppColors.lightBlack,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // if (allData['unverifiedDocumentCount'] !=
                                      //         null &&
                                      //     allData['unverifiedDocumentCount'] != 0)
                                      //   Positioned(
                                      //       right: 0,
                                      //       top: 10,
                                      //       child: Container(
                                      //         constraints:
                                      //             BoxConstraints(minWidth: 20),
                                      //         padding: EdgeInsets.symmetric(
                                      //             horizontal: 6, vertical: 6),
                                      //         decoration: BoxDecoration(
                                      //             color: AppColors.purpleColor,
                                      //             shape: BoxShape.circle),
                                      //         child: Center(
                                      //           child: Text(
                                      //             allData['unverifiedDocumentCount'] !=
                                      //                         null &&
                                      //                     allData['unverifiedDocumentCount'] !=
                                      //                         0
                                      //                 ? '${allData['unverifiedDocumentCount']}'
                                      //                 : "",
                                      //             textAlign: TextAlign.center,
                                      //             style: TextStyle(
                                      //                 color: Colors.white,
                                      //                 fontSize: 9.0,
                                      //                 fontWeight:
                                      //                     FontWeight.bold),
                                      //           ),
                                      //         ),
                                      //       ))
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * .025,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: MediaQuery.sizeOf(context).height *
                                          .025,
                                    ),
                                    padding: const EdgeInsets.only(
                                      top: 15.0,
                                      left: 12.0,
                                      right: 5.0,
                                      bottom: 15.0,
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                            width: 1,
                                            color: AppColors.skyBlueColor)),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.skyBlueColor),
                                          padding: const EdgeInsets.all(13),
                                          child: SvgPicture.asset(
                                            'assets/images/alarm.svg',
                                            semanticsLabel: 'My SVG Image',
                                            height: 19,
                                            width: 19,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .025,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${localizations!.translate('Unpaid Invoices')}',
                                            style: TextStyle(
                                                fontSize: constraints.maxWidth *
                                                    0.037,
                                                letterSpacing: 0.3,
                                                color: AppColors.lightBlack,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * .025,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 15.0,
                                      left: 12.0,
                                      right: 5.0,
                                      bottom: 15.0,
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                            width: 1,
                                            color: AppColors.skyBlueColor)),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.skyBlueColor),
                                          padding: const EdgeInsets.all(13),
                                          child: SvgPicture.asset(
                                            'assets/images/poll.svg',
                                            semanticsLabel: 'My SVG Image',
                                            height: 19,
                                            width: 19,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .025,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${localizations!.translate('View Statistics')}',
                                            style: TextStyle(
                                                fontSize: constraints.maxWidth *
                                                    0.037,
                                                letterSpacing: 0.3,
                                                color: AppColors.lightBlack,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * .035,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // nextPage(context, CashFlowScreen());

                                    showCustomToast(
                                        context: context,
                                        message:
                                            '${localizations!.translate("This page will be available soon!")}');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 15.0,
                                      left: 12.0,
                                      right: 5.0,
                                      bottom: 15.0,
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                            width: 1,
                                            color: AppColors.skyBlueColor)),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.skyBlueColor),
                                          padding: const EdgeInsets.all(13),
                                          child: SvgPicture.asset(
                                            'assets/images/cash_register.svg',
                                            semanticsLabel: 'My SVG Image',
                                            height: 19,
                                            width: 19,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .025,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${localizations!.translate('Enter Cashflow')}',
                                            style: TextStyle(
                                                fontSize: constraints.maxWidth *
                                                    0.037,
                                                letterSpacing: 0.3,
                                                color: AppColors.lightBlack,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * .025,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 15.0,
                                      left: 12.0,
                                      right: 5.0,
                                      bottom: 15.0,
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: AppColors.skyBlueColor),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          padding: const EdgeInsets.all(13),
                                          child: SvgPicture.asset(
                                            'assets/images/support_agent.svg',
                                            semanticsLabel: 'My SVG Image',
                                            height: 19,
                                            width: 19,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .025,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${localizations!.translate('Support')}',
                                            style: TextStyle(
                                                fontSize: constraints.maxWidth *
                                                    0.037,
                                                letterSpacing: 0.3,
                                                color: AppColors.lightBlack,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * .035,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // nextPage(context, ReminderScreen());

                                    showCustomToast(
                                        context: context,
                                        message:
                                            '${localizations!.translate("This page will be available soon!")}');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 15.0,
                                      left: 12.0,
                                      right: 5.0,
                                      bottom: 15.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.skyBlueColor,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          padding: const EdgeInsets.all(13),
                                          child: SvgPicture.asset(
                                            'assets/images/alarm.svg',
                                            semanticsLabel: 'My SVG Image',
                                            height: 19,
                                            width: 19,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .025,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${localizations!.translate('Reminders')}',
                                            style: TextStyle(
                                                fontSize: constraints.maxWidth *
                                                    0.037,
                                                letterSpacing: 0.3,
                                                color: AppColors.lightBlack,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
        );
      }),
    );
  }
}
