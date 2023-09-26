import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sno_biz_app/app_route/app_route.dart';

import 'package:sno_biz_app/screens/upload_document/upload_document_screen.dart';

import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/services/localization.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/fileTypeEnum.dart';
import '../models/selectedFiles.dart';

class DashboardScreen extends StatefulWidget {
  final  String uploadedscreenView;
  const DashboardScreen({super.key, required this.uploadedscreenView});

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
  List<SelectedFile> fileList = [];
  late BuildContext _initContext;

  Timer? _timer;

  checkFile() {
  setState(() {

  });
    print("here");
  ReceiveSharingIntent.getMediaStream()
      .listen((List<SharedMediaFile> value) {
    fileList.clear();
    setState(() {
      print("Sharedlisten${value[0].path}");
    //   // _sharedFiles = value;
    //   // print("Shared:" + (_sharedFiles?.map((f) => f.path).join(",") ?? ""));
    });
    for (var sharedFile in value) {
      print(sharedFile.path.toString());
      if (sharedFile.path.toString().endsWith('.jpg') ||
          sharedFile.path.toString().endsWith('.JPG') ||
          sharedFile.path.toString().endsWith('.jpeg') ||
          sharedFile.path.toString().endsWith('.png') ||
          sharedFile.path.toString().endsWith('.pdf')) {
        fileList.add(SelectedFile(
          name: sharedFile.path.toString().split('/').last,
          path: sharedFile.path.toString(),
          type: sharedFile.path.toString().endsWith('.pdf')
              ? FileType2.pdf
              : FileType2.image,
        ));
      }
    }
    print(fileList.toString() + " added File");

    if (fileList.isNotEmpty) {
      print("not empty");
      nextPage(context,
          UploadDoumentScreen(isFileUploaded: true, files: fileList));
    } else {
      print("empty");
      // _navigate();
    }
  }, onError: (err) {
    print("getIntentDataStream error: $err");
  });
    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        // _sharedFiles = value;
        print("Shared${value}");
      });
    });
    ReceiveSharingIntent
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      fileList.clear();
      print(value);
      print(
          "Shared: getInitialMedia ${value.map((f) => f.path).join(",")}  2");
      for (var sharedFile in value) {
        log(sharedFile.path.toString());
        if (sharedFile.path.toString().endsWith('.jpg') ||
            sharedFile.path.toString().endsWith('.jpeg') ||
            sharedFile.path.toString().endsWith('.png') ||
            sharedFile.path.toString().endsWith('.pdf')) {
          fileList.add(SelectedFile(
            name: sharedFile.path.toString().split('/').last,
            path: sharedFile.path.toString(),
            type: sharedFile.path.toString().endsWith('.pdf')
                ? FileType2.pdf
                : FileType2.image,
          ));
        }
      }
      log(fileList.toString() + " added File");

      if (fileList.isNotEmpty) {
        log("not empty");
        nextPage(context,
            UploadDoumentScreen(isFileUploaded: true, files: fileList.toSet().toList()));
      } else {
        log("empty");
        // _navigate();
      }
    }).catchError((e) {
      print("Error");
      // _navigate();
    });
  }void _navigate() async {
    await SharedPrefUtils.saveStr("userId", "56");

    _timer = Timer(const Duration(seconds: 3), () {
      nextPagewithReplacement(context, DashboardScreen(uploadedscreenView: '',));
    });
  }
@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
  // checkFile();
    super.didChangeDependencies();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.uploadedscreenView.isEmpty){
      checkFile();
    }

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
              child: Column(children: [
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
                            child: Text('${localizations!.translate('View')}'),
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
          ])),
        );
      }),
    );
  }
}
