import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sno_biz_app/widgets/zoomableImage.dart';

import '../utils/color_constants.dart';

// showImage(BuildContext context, {required file, isMyUpload = false}) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 4),
//       backgroundColor: AppColors.greyColor,
//       titlePadding: EdgeInsets.zero,
//       contentPadding: EdgeInsets.zero,
//       content: Stack(
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width / 1.2,
//             height: MediaQuery.of(context).size.height - 100,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   height: MediaQuery.of(context).size.height / 2.5,
//                   color: AppColors.white,
//                   padding: EdgeInsets.symmetric(vertical: 25),
//                   child: ZoomableImage(
//                       imageUrl: file,
//                       height: 240.0,
//                       width: MediaQuery.of(context).size.width,
//                       fit: BoxFit.contain,
//                       isMyUpload: isMyUpload),
//                 )
//               ],
//             ),
//           ),
//           Positioned(
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Icon(
//                 CupertinoIcons.xmark,
//                 color: AppColors.white,
//                 size: 30,
//               ),
//             ),
//             top: 15,
//             right: 15,
//           )
//         ],
//       ),
//     ),
//   );
// }

showImage(BuildContext context, {required file, isMyUpload = false}) {
  final double screenWidth = MediaQuery.of(context).size.width;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 25),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: screenWidth,
              margin: const EdgeInsets.only(left: 0.0, right: 0.0),
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    margin: const EdgeInsets.only(top: 15.0, right: 8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius: BorderRadius.circular(10),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 0.0,
                            offset: Offset(0.0, 0.0),
                          ),
                        ]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 20),
                          child: ClipRRect(
                              // borderRadius: BorderRadius.circular(10),
                              child: ZoomableImage(
                            imageUrl: file,
                            height: 240.0,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.contain,
                            isMyUpload: isMyUpload,
                          )),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: AppColors.purpleColor,
                                shape: BoxShape.circle),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            ));
      });
}
