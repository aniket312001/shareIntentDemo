import 'dart:async';
import 'dart:developer';
import 'dart:io';

// import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:dio/dio.dart';
// import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/models/request/uploadedDocumentListRequest.dart';
import 'package:sno_biz_app/models/selectedFiles.dart';
import 'package:sno_biz_app/screens/dashboard_screen.dart';
import 'package:sno_biz_app/screens/success_screen.dart';

import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/api_urls.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:sno_biz_app/widgets/imageViewer.dart';
import 'package:sno_biz_app/widgets/image_cropper.dart';
import 'package:sno_biz_app/widgets/next_button.dart';
import 'package:sno_biz_app/widgets/pdfImage.dart';
import 'package:sno_biz_app/widgets/pdfViewer.dart';
import 'package:sno_biz_app/widgets/purple_button.dart';

import '../../models/fileTypeEnum.dart';
import '../../services/loaderPercentage.dart';
import '../../services/localization.dart';
import '../../utils/shared_pref.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edge_detection/edge_detection.dart';
// import 'package:document_scanner_flutter/document_scanner_flutter.dart';

// import 'package:cunning_document_scanner/cunning_document_scanner.dart';
// import 'package:cuervo_document_scanner/cuervo_document_scanner.dart';

// import 'package:scan_plus/scan_plus.dart';
// import 'package:scan_plus/configs/configs.dart';

class UploadDoumentScreen extends StatefulWidget {
  UploadDoumentScreen({this.isFileUploaded = false, this.files = null});

  dynamic files = [];
  dynamic isFileUploaded = false;

  @override
  State<UploadDoumentScreen> createState() => _UploadDoumentScreenState();
}

class _UploadDoumentScreenState extends State<UploadDoumentScreen> {
  final List<String> items = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  List<SelectedFile> selectedFiles = [];
  List<Map<String, dynamic>> allCompanies = [];
  Map<String, dynamic>? selectedCompany;
  List<Map<String, dynamic>> allPeriods = [];
  Map<String, String>? selectedPeriod;
  StreamController<String> dataStreamController = StreamController<String>();

  int transactionType = 1;

  // final TextEditingController uploadedPercentage = TextEditingController();
  dynamic uploadedPercentage = 0;

  bool isUploaded = false;

  dynamic recentDocument = [];
  List<Map<String, String>> months = [];

  dynamic cacheData = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkFileUploaded();
    fetchFromCache();
    fetchRecentUploadData();
  }

  checkFileUploaded() {
    if (widget.isFileUploaded) {
      // add file into selected file

      setState(() {
        selectedFiles = widget.files;
      });
    }
  }

  saveIntoCache(obj) {
    SharedPrefUtils.saveStr('SavedUploadData', json.encode(obj));
  }

  fetchFromCache() async {
    dynamic data = await SharedPrefUtils.readPrefStr("SavedUploadData");

    if (data.toString() != 'null') {
      data = json.decode(data);

      log(data.toString());

      setState(() {
        cacheData = data;
        // selectedCompany = data['selectedCompany'];
        // selectedPeriod = data['selectedPeriod'];
        transactionType = data['transactionType'];
      });
    } else {
      log("data not present ");
    }

    fetchCompanyData();

    getMonths();
  }

  fetchRecentUploadData() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    // dynamic obj = {
    //   "userId": userId,
    //   "search": "",
    //   "month": "",
    //   "year": "",
    //   "sort": "",
    //   "mode": "all",
    //   "pageNumber": 0,
    //   "limit": "6"
    // };

    UploadedDocumentList documentListRequest = UploadedDocumentList();

    documentListRequest.setUserId = userId;
    documentListRequest.setSearch = "";
    documentListRequest.setMonth = "";
    documentListRequest.setYear = "";
    documentListRequest.setSort = "";
    documentListRequest.setMode = "recent";
    documentListRequest.setPageNumber = 0;
    documentListRequest.setLimit = 6;

    dynamic allData = await APIServices.makeApiCall(
        "fetch-document-list.php", documentListRequest.toJson());

    if (allData['errorCode'] == '0000') {
      setState(() {
        recentDocument = List<Map<String, dynamic>>.from(allData['dataList']);
      });
    } else {
      // showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  fetchCompanyData() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {"userId": userId};
    dynamic allData =
        await APIServices.makeApiCall("fetch-companies-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        allCompanies = List<Map<String, dynamic>>.from(allData['dataList']);

        if (cacheData != null) {
          selectedCompany = allCompanies
              .where((company) =>
                  company["companyId"] ==
                  cacheData['selectedCompany']['companyId'])
              .toList()[0];
        } else {
          selectedCompany = allCompanies[0];
        }
      });
    } else {
      // showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ["png", "jpg", "jpeg", 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (final file in result.files) {
          FileType2 type;
          if (['jpg', 'jpeg', 'png'].contains(file.extension!.toLowerCase())) {
            type = FileType2.image;
          } else if (file.extension!.toLowerCase() == 'pdf') {
            type = FileType2.pdf;
          } else {
            type = FileType2.other;
          }

          selectedFiles.add(SelectedFile(
            name: file.name,
            path: file.path!,
            type: type,
          ));
        }
        isUploaded = true;
      });
    }
  }

  Future<void> _pickImage() async {
    // dynamic pickedFile = await ScanPlusDocumentScanner.launch(context,
    //     source: ScannerFileSource.CAMERA);

    String imagePath = path.join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    bool added = await EdgeDetection.detectEdge(
      imagePath,
      canUseGallery: false,
      androidScanTitle: 'Scanning', // use custom localizations for android
      androidCropTitle: 'Crop',
      androidCropBlackWhiteTitle: 'Black White',
      androidCropReset: 'Reset',
    );

    if (added == false) {
      return;
    }

    dynamic pickedFile = File(imagePath);

    log(pickedFile.toString());

    // dynamic pickedFile = await ImagePicker().pickImage(
    //   source: ImageSource.camera,
    // );

    // await EdgeDetection.detectEdge(
    //   pickedFile.path,
    //   canUseGallery: true,
    //   androidScanTitle: 'Scanning', // use custom localizations for android
    //   androidCropTitle: 'Crop',
    //   androidCropBlackWhiteTitle: 'Black White',
    //   androidCropReset: 'Reset',
    // );
    // EdgeDetection.detectEdgeFromGallery("");
    // or

    // dynamic pickedFile;
    // dynamic imagesPath = await CuervoDocumentScanner.getPictures(Source.CAMERA);
    // setState(() {
    //   pickedFile = File(imagesPath);
    // });
    // dynamic pickedFile = await CunningDocumentScanner.getPictures();
    // log(pickedFile.toString() + " pic");

    // setState(() {
    // pickedFile = File(pickedFile);
    // });
    // dynamic pickedFile = await DocumentScannerFlutter.launch(context,
    //     source: ScannerFileSource.GALLERY);
    // Or ScannerFileSource.GALLERY
    // `scannedDoc` will be the image file scanned from scanner

    if (pickedFile != null) {
      setState(() {
        // File file = File(pickedFile!.path);
        FileType2 type;
        type = FileType2.image;

        selectedFiles.add(SelectedFile(
          name: pickedFile.path.split('/').last,
          path: pickedFile.path,
          type: type,
        ));
      });
    }
  }

  __refresh() {
    setState(() {
      selectedFiles = [];
      fetchRecentUploadData();
    });
  }

  Future<void> _uploadFiles(loaderPercentageProvider, localizations) async {
    if (selectedCompany == null) {
      showCustomToast(
          context: context,
          message:
              '${localizations!.translate("Please select company name.")}');
      return;
    }

    if (selectedPeriod == null) {
      showCustomToast(
          context: context,
          message: '${localizations!.translate("Please select period.")}');
      return;
    }

    if (selectedFiles.length == 0) {
      showCustomToast(
          context: context,
          message:
              '${localizations!.translate("Please select atleast 1 document.")}');
      return;
    }

    // CustomLoader.showProgressBarWithPercentage(context);

    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic tranType = "";

    if (transactionType == 1) {
      tranType = "Bank";
    } else if (transactionType == 2) {
      tranType = "Cash";
    } else {
      tranType = 'Other';
    }

    String url = '${Urls.baseUrl}/upload-documents.php';

    dynamic obj = {
      "userId": userId,
      'period': selectedPeriod!['monthDate']!,
      'transactionType': tranType,
      'companyId': selectedCompany!['companyId']
    };

    List<MultipartFile> documentFiles = [];

    for (final file in selectedFiles) {
      documentFiles.add(
        await MultipartFile.fromFile(file.path, filename: file.name),
      );
    }

    FormData formData = FormData.fromMap({
      ...obj,
      "document[]": documentFiles,
    });

    Dio dio = Dio();
    // ignore: use_build_context_synchronously
    // showProgressBarWithPercentage(context);
    loaderPercentageProvider.changePercentage(0);
    CustomLoader.showProgressBarWithPercentage(context);

    Response response = await dio.post(
      url as String,
      data: formData,
      onSendProgress: (int sent, int total) {
        double progress = sent / total;
        print("Upload progress: ${progress * 100}");
        // Update your UI with the progress value if needed
        double p = progress * 100;
        setState(() {
          uploadedPercentage = p.toStringAsFixed(2);
          // dataStreamController.add(uploadedPercentage.toString());
          loaderPercentageProvider.changePercentage(uploadedPercentage);
          log(uploadedPercentage.toString());
        });
      },
    );

    Navigator.pop(context);
    log("Response: ${response.data.toString()}");

    var decodedResponse = json.decode(response.data);
    if (decodedResponse['errorCode'] == '0000') {
      saveIntoCache({
        "selectedCompany": selectedCompany,
        "selectedPeriod": selectedPeriod,
        "transactionType": transactionType
      });

      // ignore: use_build_context_synchronously
      refreshPreviousPage(
          context, SuccessScreen(mode: "uploadDocument"), __refresh);
      showCustomToast(
          context: context,
          message:
              '${selectedFiles.length} ${localizations!.translate("Document uploaded successful!!")}');
    } else {
      showCustomToast(
          context: context,
          message:
              '${localizations!.translate(decodedResponse['errorMessage'].toString())}');
    }
  }

  String _getFileTypeText(FileType2 type) {
    switch (type) {
      case FileType2.image:
        return 'Image';
      case FileType2.pdf:
        return 'PDF';
      default:
        return 'Other';
    }
  }

  void getMonths() {
    DateTime currentDate = DateTime.now();

    setState(() {
      for (int i = -6; i <= 3; i++) {
        DateTime month = DateTime(currentDate.year, currentDate.month + i);
        String monthDate = "${_getFormattedMonth(month.month)}-${month.year}";
        String formattedMonth = DateFormat('MMMM yyyy').format(month);
        months.add({"formattedMonth": formattedMonth, "monthDate": monthDate});
      }
    });

    selectedPeriod = months[6];
    log(months.toString());
    // return months;

    if (cacheData != null) {
      setState(() {
        selectedPeriod = months
            .where((item) =>
                item["monthDate"] == cacheData['selectedPeriod']['monthDate'])
            .toList()[0];
      });
    }
  }

  String _getFormattedMonth(int month) {
    return month.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return Consumer<LoaderPercentageChange>(
        builder: (context, loaderPercentageProvider, child) {
      return WillPopScope(
        onWillPop: () async {
          if (widget.isFileUploaded == true) {
            log("added");
            nextPagewithReplacement(context, DashboardScreen());
          } else {
            log("not added");

            Navigator.pop(context);
          }

          return true;
        },
        child: LayoutBuilder(builder: (context, constraints) {
          return Scaffold(
            backgroundColor: AppColors.skyBlueColor,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 25),
                    decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.isFileUploaded == true) {
                              nextPagewithReplacement(
                                  context, DashboardScreen());
                            } else {
                              Navigator.pop(context);
                            }
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
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            '${localizations!.translate("Upload Documents")}',
                            style: TextStyle(
                                color: AppColors.black,
                                fontSize: constraints.maxWidth * 0.054,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<Map<String, dynamic>>(
                              dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              isExpanded: true,
                              hint: Text(
                                '${localizations!.translate('Company Name')}',
                                style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.040,
                                    color: AppColors.greyColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              items: allCompanies
                                  .map((Map<String, dynamic>? item) =>
                                      DropdownMenuItem<Map<String, dynamic>>(
                                        value: item,
                                        child: Text(
                                          item!['companyName'],
                                          style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.040,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              value: selectedCompany,
                              onChanged: (Map<String, dynamic>? value) {
                                setState(() {
                                  selectedCompany = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                  height: 43,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(22))),
                              menuItemStyleData: const MenuItemStyleData(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<Map<String, String>>(
                                    dropdownStyleData: DropdownStyleData(
                                        maxHeight: 200,
                                        // width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        )),
                                    isExpanded: true,
                                    hint: Text(
                                      '${localizations!.translate('Period')}',
                                      style: TextStyle(
                                          fontSize:
                                              constraints.maxWidth * 0.040,
                                          color: AppColors.greyColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    items: months
                                        .map((Map<String, String> item) =>
                                            DropdownMenuItem<
                                                Map<String, String>>(
                                              value: item,
                                              child: Text(
                                                item['formattedMonth']!,
                                                style: TextStyle(
                                                  fontSize:
                                                      constraints.maxWidth *
                                                          0.040,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedPeriod,
                                    onChanged: (Map<String, String>? value) {
                                      setState(() {
                                        selectedPeriod = value;
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                        height: 43,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(22))),
                                    menuItemStyleData:
                                        const MenuItemStyleData(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildRadioButtonContainer(
                                  localizations!.translate('Bank'),
                                  1,
                                  constraints),
                              _buildRadioButtonContainer(
                                  localizations!.translate('Cash'),
                                  2,
                                  constraints),
                              _buildRadioButtonContainer(
                                  localizations!.translate('Other'),
                                  3,
                                  constraints),
                            ],
                          ),
                        ),
                        if (selectedFiles.length == 0)
                          const SizedBox(height: 20),
                        if (selectedFiles.length == 0)
                          // NextButton(
                          //     text:
                          //         '${localizations!.translate("Upload from Camera")}',
                          //     onTap: () {
                          //       _pickImage();
                          //       setState(() {
                          //         // isUploaded = true;
                          //       });
                          //       // nextPage(context, UploadDoumentFromFolderScreen());
                          //     }),

                          iconsButton(
                              '${localizations!.translate("Upload from Camera")}',
                              Icons.camera_alt_rounded, () {
                            setState(() {
                              _pickImage();
                            });
                            // nextPage(context, UploadDoumentFromFolderScreen());
                          }),
                        if (selectedFiles.length == 0)
                          const SizedBox(height: 15),
                        if (selectedFiles.length == 0)
                          iconsButton(
                              '${localizations!.translate("Upload from Folder")}',
                              Icons.folder, () {
                            setState(() {
                              _pickFiles();
                            });
                            // nextPage(context, UploadDoumentFromFolderScreen());
                          }),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                  (selectedFiles.length == 0)
                      ? Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                border: Border.all(
                                    color: AppColors.purpleColor, width: 0.7)),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: AppColors.skyBlueColor,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Center(
                                      child: Text(
                                        '${localizations!.translate("Recent Uploads")}',
                                        style: TextStyle(
                                            color: AppColors.black,
                                            fontSize:
                                                constraints.maxWidth * 0.048,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (recentDocument.length == 0)
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.3,
                                        child: Image.asset(
                                          "assets/images/image.png",
                                          fit: BoxFit.contain,
                                          height: 200,
                                        )),
                                  GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                3, // Number of columns
                                            mainAxisSpacing:
                                                18, // Vertical spacing between grid items
                                            crossAxisSpacing:
                                                18, // Horizontal spacing between grid items
                                            mainAxisExtent: 110),

                                    itemCount: recentDocument
                                        .length, // Total number of grid items
                                    shrinkWrap:
                                        true, // Make GridView take the space it needs
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          // if (recentDocument[index]['fileType'] !=
                                          //     'image') {
                                          //   nextPage(
                                          //       context,
                                          //       PDFScreen(
                                          //           name: "PDF",
                                          //           pdfPath: recentDocument[index]
                                          //               ['document']));
                                          // } else {
                                          //   showImage(context,
                                          //       file: recentDocument[index]
                                          //           ['document']);
                                          // }
                                        },
                                        child: Card(
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                          child: recentDocument[index]
                                                      ['fileType'] !=
                                                  'image'
                                              ? PdfPreviewWidget(
                                                  pdfLink: recentDocument[index]
                                                      ['document'])
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13),
                                                      color: AppColors
                                                          .skyBlueColor,
                                                      image: recentDocument[
                                                                      index][
                                                                  'fileType'] ==
                                                              'image'
                                                          ? DecorationImage(
                                                              image:
                                                                  CachedNetworkImageProvider(
                                                                recentDocument[
                                                                        index][
                                                                    'document'],
                                                                cacheManager:
                                                                    DefaultCacheManager(),
                                                              ),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : null),
                                                ),
                                        ),
                                      );
                                      // child: Center(
                                      //   child: Text(
                                      //     '$index',
                                      //     style: TextStyle(color: Colors.white),
                                      //   ),
                                      // ),
                                    },
                                  ),
                                  if (recentDocument.length != 0)
                                    const SizedBox(height: 20),
                                  if (recentDocument.length != 0)
                                    PurpleButton(
                                        text:
                                            '${localizations!.translate("View All")}',
                                        onTap: () {}),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                border: Border.all(
                                    color: AppColors.purpleColor, width: 0.7)),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                3, // Number of columns
                                            mainAxisSpacing:
                                                18, // Vertical spacing between grid items
                                            crossAxisSpacing:
                                                18, // Horizontal spacing between grid items

                                            // comment this line if it should be dynamic
                                            mainAxisExtent: 110),
                                    itemCount: selectedFiles
                                        .length, // Total number of grid items
                                    shrinkWrap:
                                        true, // Make GridView take the space it needs
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Disable GridView scrolling

                                    itemBuilder: (context, index) {
                                      dynamic file = selectedFiles[index];
                                      return Stack(
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                if (_getFileTypeText(
                                                        file.type) !=
                                                    'Image') {
                                                  nextPage(
                                                      context,
                                                      PDFScreen(
                                                          name: "PDF",
                                                          pdfPath: file.path,
                                                          isPath: true));
                                                } else {
                                                  showImage(context,
                                                      file: file.path,
                                                      isMyUpload: true);
                                                }
                                              },
                                              child: Card(
                                                margin: const EdgeInsets.only(
                                                    right: 5, bottom: 5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                ),
                                                child:
                                                    (_getFileTypeText(
                                                                file.type) ==
                                                            'Image')
                                                        ? Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            13),
                                                                    color: AppColors
                                                                        .skyBlueColor, // Example color
                                                                    image: _getFileTypeText(file.type) ==
                                                                            'Image'
                                                                        ? DecorationImage(
                                                                            image:
                                                                                FileImage(File(file.path)),
                                                                            fit: BoxFit.cover)
                                                                        : null),
                                                          )
                                                        : PdfPreviewWidget(
                                                            pdfLink: file.path,
                                                            fromGallery: true),
                                              )),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedFiles.removeWhere(
                                                      (obj) =>
                                                          obj.path ==
                                                          file.path);
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.zero,
                                                decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    shape: BoxShape.circle),
                                                child: SvgPicture.asset(
                                                  'assets/images/cancel.svg', // Path to your SVG file
                                                  width:
                                                      24, // Adjust the width as needed
                                                  height:
                                                      24, // Adjust the height as needed
                                                ),
                                              ),
                                            ),
                                          ),
                                          _getFileTypeText(file.type) == 'Image'
                                              ? Container()

                                              // ? Positioned(
                                              //     top: 0,
                                              //     right: 0,
                                              //     child: GestureDetector(
                                              //         onTap: () async {
                                              //           // dynamic myFile =
                                              //           //     await Image_Cropper
                                              //           //         .cropFile(
                                              //           //             File(file.path));

                                              //           // setState(() {

                                              //           //   file.path = myFile.path;
                                              //           // });
                                              //         },
                                              //         child: null
                                              //         // Icon(
                                              //         //   Icons.crop,
                                              //         //   size: 25,
                                              //         //   color: AppColors.purpleColor,
                                              //         // ),
                                              //         ),
                                              //   )
                                              : Container()
                                          // Positioned.fill(
                                          //     top: 0,
                                          //     right: 0,
                                          //     child: Icon(
                                          //       Icons.picture_as_pdf,
                                          //       size: 30,
                                          //       color: AppColors.purpleColor,
                                          //     ),
                                          //   )
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
            bottomNavigationBar: selectedFiles.length != 0
                ? Container(
                    color: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: PurpleButton(
                        text:
                            " ${localizations!.translate("Upload")} ${selectedFiles.length} ${selectedFiles.length == 1 ? localizations!.translate("Document") : localizations!.translate("Documents")}",
                        onTap: () {
                          _uploadFiles(loaderPercentageProvider, localizations);
                          // nextPage(context, SuccessScreen(mode: "uploadDocument"));
                        }),
                  )
                : null,
          );
        }),
      );
    });
  }

  Widget iconsButton(label, icon, onPressed) {
    var textSize = MediaQuery.sizeOf(context).height * 0.018;
    var mq = MediaQuery.sizeOf(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purpleColor,
          fixedSize: Size(mq.width, mq.height * .054),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textStyle: TextStyle(
              fontSize: textSize,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(label),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16), // Adjust icon padding as needed
              child: Icon(icon), // Icon as prefix
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButtonContainer(String label, int value, constraints) {
    return GestureDetector(
      onTap: () {
        setState(() {
          transactionType = value;
        });
      },
      child: Container(
        height: 43,
        width: MediaQuery.of(context).size.width / 3.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
        ),
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: constraints.maxWidth * 0.035,
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            // SizedBox(width: 1),
            Transform.scale(
              scale: 1,
              child: Radio<int>(
                visualDensity: const VisualDensity(horizontal: -4.0),
                value: value,
                activeColor: AppColors.purpleColor,
                groupValue: transactionType,
                onChanged: (value) {
                  setState(() {
                    transactionType = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void showProgressBarWithPercentage(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) => StreamBuilder<String>(
  //           stream: dataStreamController.stream,
  //           builder: (context, snapshot) {
  //             if (snapshot.hasData) {
  //               return Dialog(
  //                 elevation: 0,
  //                 backgroundColor: Colors.transparent,
  //                 child: Stack(
  //                   alignment: Alignment.center,
  //                   children: [
  //                     const SpinKitCircle(
  //                       color: AppColors.blueColor,
  //                       size: 150,
  //                     ),
  //                     Center(
  //                       child: Text('${snapshot.data}\%',
  //                           style: TextStyle(
  //                               color: AppColors.white,
  //                               fontSize: 15,
  //                               fontWeight: FontWeight.bold)),
  //                     )
  //                   ],
  //                 ),
  //               );
  //             } else {
  //               return Dialog(
  //                 elevation: 0,
  //                 backgroundColor: Colors.transparent,
  //                 child: const SpinKitCircle(
  //                   color: AppColors.blueColor,
  //                   size: 140,
  //                 ),
  //               );
  //             }
  //           }));
  // }
}
