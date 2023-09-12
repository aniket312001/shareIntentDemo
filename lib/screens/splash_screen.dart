import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/models/selectedFiles.dart';
import 'package:sno_biz_app/screens/dashboard_screen.dart';

import 'package:sno_biz_app/screens/upload_document/upload_document_screen.dart';

import 'package:sno_biz_app/services/localization.dart';
import 'package:sno_biz_app/services/select_language.dart';
import '../models/fileTypeEnum.dart';
import '../utils/color_constants.dart';
import '../utils/shared_pref.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

Size? mq;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  List<SelectedFile> fileList = [];
  late BuildContext _initContext;

  Timer? _timer;

  checkFile() {
    // For sharing images coming from outside the app while the app is closed

    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> value) {
      print(
          "Shared: getInitialMedia ${value.map((f) => f.value).join(",")}  2");
      for (var sharedFile in value) {
        log(sharedFile.value.toString());
        if (sharedFile.value.toString().endsWith('.jpg') ||
            sharedFile.value.toString().endsWith('.jpeg') ||
            sharedFile.value.toString().endsWith('.png') ||
            sharedFile.value.toString().endsWith('.pdf')) {
          fileList.add(SelectedFile(
            name: sharedFile.value.toString().split('/').last,
            path: sharedFile.value.toString(),
            type: sharedFile.value.toString().endsWith('.pdf')
                ? FileType2.pdf
                : FileType2.image,
          ));
        }
      }
      log(fileList.toString() + " added File");

      if (fileList.isNotEmpty) {
        log("not empty");
        nextPage(context,
            UploadDoumentScreen(isFileUploaded: true, files: fileList));
      } else {
        log("empty");
        _navigate();
      }
    }).catchError((e) {
      _navigate();
    });
  }

  changeLanguage(context) async {
    final lang = Provider.of<LanguageChange>(context, listen: false);

    dynamic language = await SharedPrefUtils.readPrefStr("selectedLanguage");

    if (language.toString() != 'null') {
      // AppLocalizations.of(context)!.locale = const Locale("fr");
      lang.changeAppLanguage(language);
    } else {
      lang.changeAppLanguage("en");
      // AppLocalizations.of(context)!.locale = const Locale("fr");
    }
  }

  @override
  void initState() {
    super.initState();

    changeLanguage(context);
    // changeLanguage(context);
    // _initSharingIntent();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    animationController.repeat();
    // shareIntent();
    log("run");
    checkFile();
  }

  void _navigate() async {
    await SharedPrefUtils.saveStr("userId", "56");

    _timer = Timer(const Duration(seconds: 3), () {
      nextPagewithReplacement(context, DashboardScreen());
    });
  }

  @override
  void dispose() {
    animationController.dispose();

    _timer?.cancel();
    log("dispose called on splash");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              // child: Column(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              // AnimatedBuilder(
              //   animation: animationController,
              //   child: Container(
              //       width: mq.width * 0.5,
              //       height: mq.height * 0.25,
              //       child: Image.asset(
              //         'assets/images/sno_biz_logo.png',
              //         fit: BoxFit.fill,
              //       )),
              //   builder: (context, child) {
              //     return Transform.rotate(
              //       angle: animationController.value,
              //       child: child,
              //     );
              //   },
              // ),
              child: Container(
                  width: double.infinity,
                  height: mq.height * 0.18,
                  // height: mq.height * 0.25,
                  child: Image.asset(
                    'assets/images/sno_biz_logo.png',
                    fit: BoxFit.cover,
                  )),
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.02,
              // ),
              // const Text(
              //   'Ons Gemak',
              //   style: TextStyle(
              //       fontSize: 35,
              //       letterSpacing: 0.2,
              //       color: AppColors.lightBlack,
              //       fontWeight: FontWeight.bold),
              // )
              //      ,SvgPicture.asset(
              //   'assets/images/add_circle.svg',
              //   semanticsLabel: 'My SVG Image',

              // ),
              //   ],
              // ),
            )));
  }
}
