import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:sno_biz_app/services/loaderPercentage.dart';
import 'package:sno_biz_app/utils/color_constants.dart';

class CustomLoader {
  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: const Dialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: SpinKitCircle(
                  color: AppColors.blueColor,
                  size: 100,
                ),
              ),
            ));
  }

  static void showProgressBarWithPercentage(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Consumer<LoaderPercentageChange>(
                builder: (context, loaderPercentageProvider, child) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: Dialog(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // SpinKitChasingDots()
                      const SpinKitCircle(
                        color: AppColors.blueColor,
                        size: 150,
                      ),
                      Center(
                        child: Text(
                            loaderPercentageProvider.getPercentage.toString() +
                                "%",
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),

                  // SpinKitCircle(
                  //   color: AppColors.blueColor,
                  //   size: 100,
                  // ),
                ),
              );
            }));
  }
}
