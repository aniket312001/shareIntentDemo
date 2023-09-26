import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/dashboard_screen.dart';

import '../services/localization.dart';
import '../utils/color_constants.dart';
import '../widgets/purple_button.dart';

class SuccessScreen extends StatefulWidget {
  SuccessScreen(
      {required this.mode, this.count = 0, this.all = true, this.status = ''});

  String mode;
  int count = 0;
  bool all = true;
  String status = "";

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.skyBlueColor,
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                'assets/images/verified.svg',
                semanticsLabel: 'My SVG Image',
                width: MediaQuery.of(context).size.width * 0.34,
                height: MediaQuery.of(context).size.height * 0.19,
              ),
            ),
          ),
          Container(
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, top: 25.0, right: 20.0, bottom: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.mode == 'ticket'
                        ? '${localizations!.translate('Ticket Submitted')}'
                        : '${localizations!.translate('Great work!')}',
                    style: TextStyle(
                        fontSize: 22,
                        color: AppColors.lightBlack,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.035,
                  ),
                  Text(
                    widget.mode == 'uploadDocument'
                        ? '${localizations!.translate('You have successfully uploaded documents')}'
                        : widget.mode == 'verified'
                            ? ' ${localizations!.translate("You have successfully verified")} ${widget.all ? 'all the' : ''} ${widget.count} ${localizations!.translate("uploaded document")}${widget.count == 1 ? '' : 's'}'
                            : widget.mode == 'ticket'
                                ? '${localizations!.translate('Our support staff will reach out to you within 24 hours')}'
                                : widget.mode == 'vender'
                                    ? '${localizations!.translate('You have successfully created a vender')}'
                                    : '${widget.count} ${localizations!.translate("Invoices marked as")} ${widget.status}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.lightBlack),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.085,
                  ),
                  PurpleButton(
                      text: '${localizations!.translate('Go Back')}',
                      onTap: () {
                        if (widget.mode == 'uploadDocument') {
                          Navigator.pop(context);
                          return;
                        }

                        if (Navigator.canPop(context)) {
                          log("first time");
                          Navigator.pop(context);
                          if (Navigator.canPop(context)) {
                            log("second time");
                            Navigator.pop(context);
                          }
                        } else {
                          nextPagewithReplacement(context, DashboardScreen(uploadedscreenView: '',));
                        }
                      }),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
