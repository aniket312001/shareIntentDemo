import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/success_screen.dart';
import 'package:sno_biz_app/utils/api_urls.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/widgets/custom_dialog.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:sno_biz_app/widgets/imageViewer.dart';
import 'package:sno_biz_app/widgets/pdfViewer.dart';

import '../../services/api_services.dart';
import '../../services/localization.dart';
import '../../utils/shared_pref.dart';
import '../../widgets/purple_button.dart';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _CreateTicketScreen();
}

class _CreateTicketScreen extends State<TicketScreen> {
  List<Map<String, dynamic>> allNature = [];
  List<Map<String, dynamic>> periodList = [];
  Map<String, dynamic>? selectedNature;
  Map<String, dynamic>? selectedPeriod;

  List<dynamic> sourceList = ['App', 'Email', 'Portal', 'Call'];
  dynamic selectedSource = "App";

  dynamic _imageFile;
  dynamic fileType = 'image';

  dynamic attachmentList = [
    {"name": "Camera", "Icon": Icons.camera_alt_rounded},
    {"name": "Gallery", "Icon": Icons.image},
    {"name": "pdf", "Icon": Icons.picture_as_pdf}
  ];
  StreamController<String> dataStreamController = StreamController<String>();
  dynamic uploadedPercentage = 0;
  final TextEditingController subject = TextEditingController();
  final TextEditingController description = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMonths();
    fetchNatureList();
  }

  void fetchNatureList() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {"userId": userId};
    dynamic allData =
        await APIServices.makeApiCall("fetch-nature-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        allNature = List<Map<String, dynamic>>.from(allData['dataList']);
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  void getMonths() {
    DateTime currentDate = DateTime.now();

    setState(() {
      for (int i = -6; i <= 3; i++) {
        DateTime month = DateTime(currentDate.year, currentDate.month + i);
        String monthDate = "${_getFormattedMonth(month.month)}-${month.year}";
        String formattedMonth = DateFormat('MMMM yyyy').format(month);
        periodList
            .add({"formattedMonth": formattedMonth, "monthDate": monthDate});
      }
    });
    log(periodList.toString());
    // return months;
  }

  String _getFormattedMonth(int month) {
    return month.toString().padLeft(2, '0');
  }

  createTicket(localizations) async {
    // log(subject.text.isEmpty.toString());
    if (selectedNature == null) {
      showCustomToast(
          context: context,
          message: localizations!.translate("Please select Nature"));
      return;
    } else if (selectedPeriod == null) {
      showCustomToast(
          context: context,
          message: localizations!.translate("Please select Period"));
      return;
    } else if (subject.text.isEmpty) {
      showCustomToast(
          context: context,
          message: localizations!.translate("Please add Subject"));
      return;
    } else if (description.text.isEmpty) {
      showCustomToast(
          context: context,
          message: localizations!.translate("Please add Description"));
      return;
    }

    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    // final uri = Uri.parse('${Urls.baseUrl}/create-ticket.php');
    CustomLoader.showProgressBar(context);

    dynamic obj = {
      "userId": userId,
      'period': selectedPeriod!['monthDate']!,
      'nature': selectedNature!['id'],
      'source': selectedSource,
      'subject': subject.text,
      'description': description.text,
      'fileType': _imageFile != null ? fileType : ""
    };

    log(obj.toString() + "  this is request");

    dynamic uploadedFile = '';
    if (_imageFile != null) {
      uploadedFile = await uploadDocument(userId);
      obj['file'] = uploadedFile;
    } else {
      obj['file'] = '';
    }

    dynamic decodedResponse =
        await APIServices.makeApiCall("create-ticket.php", obj);

    Navigator.pop(context);

    if (decodedResponse['errorCode'] == '0000') {
      nextPagewithReplacement(context, SuccessScreen(mode: "ticket"));
    } else {}

    showCustomToast(
        context: context,
        message: localizations!
            .translate(decodedResponse['errorMessage'].toString()));

    // dataStreamController.stream.listen(null).cancel();
  }

  uploadDocument(userId) async {
    File? file = File(_imageFile!.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('FileUploads/ticket/${userId}/${fileType}/$fileName.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    print(downloadUrl);

    return downloadUrl;
  }

  Future<void> _pickImage(ImageSource source, localizations) async {
    dynamic pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      File file = File(pickedFile!.path);

      int fileSizeInBytes = file.lengthSync();
      log(fileSizeInBytes.toString());

      if (fileSizeInBytes > 5000000) {
        showCustomToast(
            context: context,
            message: localizations!.translate("File is too Big in Size"));
        return;
      } else {
        setState(() {
          fileType = 'image';
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _pickFiles(localizations) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );

    log(result.toString());
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (final file in result.files) {
          FileType type;
          if (['jpg', 'jpeg', 'png'].contains(file.extension!.toLowerCase())) {
            fileType = "image";
          } else if (file.extension!.toLowerCase() == 'pdf') {
            fileType = "pdf";
          } else {
            fileType = "doc";
          }

          File sizeFile = File(file.path!);
          int fileSizeInBytes = sizeFile.lengthSync();
          log(fileSizeInBytes.toString());

          if (fileSizeInBytes > 5000000) {
            showCustomToast(
                context: context,
                message: localizations!.translate("File is too Big in Size"));
            return;
          } else {
            _imageFile = File(file.path!);
          }
          // selectedFiles.add(SelectedFile(
          //   name: file.name,
          //   path: file.path!,
          //   type: type,
          // ));
        }
      });
    }
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
      child: Scaffold(
          backgroundColor: AppColors.skyBlueColor,
          body: SafeArea(
              child: SingleChildScrollView(
                  child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
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
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.purpleColor),
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
                      '${localizations!.translate("Create a ticket")}',
                      style: TextStyle(
                          color: AppColors.black,
                          fontSize: 20,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            child: Container(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              width: MediaQuery.of(context).size.width / 4,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<Map<String, dynamic>>(
                                  isDense: true,
                                  dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      )),
                                  isExpanded: true,
                                  hint: Text(
                                    '${localizations!.translate('Nature')}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                  iconStyleData:
                                      const IconStyleData(iconSize: 19),
                                  items: allNature
                                      .map((Map<String, dynamic>? item) =>
                                          DropdownMenuItem<
                                              Map<String, dynamic>>(
                                            value: item,
                                            child: Text(
                                              item!['nature'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedNature,
                                  onChanged: (Map<String, dynamic>? value) {
                                    setState(() {
                                      selectedNature = value;
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(22))),
                                  menuItemStyleData: const MenuItemStyleData(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ])
                ])),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            child: Container(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              width: MediaQuery.of(context).size.width / 4,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<Map<String, dynamic>>(
                                  isDense: true,
                                  dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      )),
                                  isExpanded: true,
                                  hint: Text(
                                    '${localizations!.translate('Period')}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                  iconStyleData:
                                      const IconStyleData(iconSize: 19),
                                  items: periodList
                                      .map((Map<String, dynamic>? item) =>
                                          DropdownMenuItem<
                                              Map<String, dynamic>>(
                                            value: item,
                                            child: Text(
                                              item!['formattedMonth'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedPeriod,
                                  onChanged: (Map<String, dynamic>? value) {
                                    setState(() {
                                      selectedPeriod = value;
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(22))),
                                  menuItemStyleData: const MenuItemStyleData(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ])
                ])),
            // Container(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            //     child: Column(children: [
            //       Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Expanded(
            //               child: Card(
            //                 margin: EdgeInsets.zero,
            //                 shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(22)),
            //                 child: Container(
            //                   height: 45,
            //                   padding:
            //                       const EdgeInsets.symmetric(horizontal: 12),
            //                   width: MediaQuery.of(context).size.width / 4,
            //                   child: DropdownButtonHideUnderline(
            //                     child: DropdownButton2<dynamic>(
            //                       isDense: true,
            //                       dropdownStyleData: DropdownStyleData(
            //                           maxHeight: 200,
            //                           decoration: BoxDecoration(
            //                             borderRadius: BorderRadius.circular(20),
            //                           )),
            //                       isExpanded: true,
            //                       hint: Text(
            //                         '${localizations!.translate('Source')}',
            //                         style: TextStyle(
            //                           fontSize: 15,
            //                           fontWeight: FontWeight.normal,
            //                           color: AppColors.greyColor,
            //                         ),
            //                       ),
            //                       iconStyleData:
            //                           const IconStyleData(iconSize: 19),
            //                       items: sourceList
            //                           .map((dynamic item) =>
            //                               DropdownMenuItem<dynamic>(
            //                                 value: item,
            //                                 child: Text(
            //                                   item,
            //                                   style: const TextStyle(
            //                                     fontSize: 14,
            //                                   ),
            //                                 ),
            //                               ))
            //                           .toList(),
            //                       value: selectedSource,
            //                       onChanged: (dynamic value) {
            //                         setState(() {
            //                           selectedSource = value;
            //                         });
            //                       },
            //                       buttonStyleData: ButtonStyleData(
            //                           height: 40,
            //                           padding: const EdgeInsets.symmetric(
            //                               horizontal: 0),
            //                           decoration: BoxDecoration(
            //                               color: AppColors.white,
            //                               borderRadius:
            //                                   BorderRadius.circular(22))),
            //                       menuItemStyleData: const MenuItemStyleData(),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ])
            //     ])),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22)),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  child: TextField(
                                    controller: subject,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                            '${localizations!.translate('Subject')}',
                                        hintStyle: TextStyle(
                                            color: AppColors.greyColor)),
                                  ),
                                )))
                      ])
                ])),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22)),
                                child: Container(
                                  // height: 200,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 5),
                                  child: TextField(
                                    controller: description,
                                    minLines: 12,
                                    maxLines: 1000,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                            '${localizations!.translate('Description')}',
                                        hintStyle: TextStyle(
                                            color: AppColors.greyColor)),
                                  ),
                                )))
                      ]),
                  if (_imageFile != null) SizedBox(height: 10),
                  if (_imageFile != null)
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            child: Container(
                              height: 45,
                              padding: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 25, right: 15),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${localizations!.translate('File Uploaded')}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imageFile = null;
                                      });
                                    },
                                    child: Icon(Icons.delete,
                                        color: AppColors.greyColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                            width: 80,
                            child: PurpleButton(
                                text: '${localizations!.translate("View")}',
                                onTap: () {
                                  if (fileType == 'image') {
                                    showImage(context,
                                        file: _imageFile.path,
                                        isMyUpload: true);
                                  } else {
                                    nextPage(
                                        context,
                                        PDFScreen(
                                            name: "PDF",
                                            pdfPath: _imageFile.path,
                                            isPath: true));
                                  }
                                })),
                        SizedBox(width: 5),
                      ],
                    ),
                  const SizedBox(height: 15),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showAttachmentList(localizations);
                            // Navigator.pop(context);

                            // setState(() {
                            //   showCustomDialog(context, 'Camera', 'Gallery',
                            //       AppColors.blueColor, () {
                            //     _pickImage(
                            //       ImageSource.camera,
                            //     );
                            //     Navigator.pop(context);
                            //   }, () {
                            //     // _pickImage(
                            //     //   ImageSource.gallery,
                            //     // );

                            //     _pickFiles();
                            //     Navigator.pop(context);
                            //   });
                            // });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 22),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.purpleColor),
                            child: SvgPicture.asset(
                              'assets/images/attachment (1).svg',
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: PurpleButton(
                              text: '${localizations!.translate('Submit')}',
                              onTap: () {
                                createTicket(localizations);
                              }),
                        )
                      ])
                ])),
          ])))),
    );
  }

  showAttachmentList(localizations) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 5),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: attachmentList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (attachmentList[index]['name'] == 'Camera') {
                                _pickImage(ImageSource.camera, localizations);
                              } else if (attachmentList[index]['name'] ==
                                  'Gallery') {
                                _pickImage(ImageSource.gallery, localizations);
                              } else if (attachmentList[index]['name'] ==
                                  'pdf') {
                                _pickFiles(localizations);
                              }

                              Navigator.pop(context);
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                attachmentList[index]['Icon'],
                                color: AppColors.blueColor,
                              ),
                              title: Text(
                                '${localizations!.translate(attachmentList[index]['name'])}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          index != attachmentList.length - 1
                              ? const Divider(
                                  height: 1,
                                )
                              : Container()
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void showProgressBarWithPercentage(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>

            // WillPopScope(
            //       onWillPop: () {
            //         return Future.value(false);
            // },

            StreamBuilder<String>(
                stream: dataStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Dialog(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const SpinKitCircle(
                            color: AppColors.blueColor,
                            size: 150,
                          ),
                          Center(
                            child: Text('${snapshot.data}\%',
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Dialog(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      child: const SpinKitCircle(
                        color: AppColors.blueColor,
                        size: 140,
                      ),
                    );
                  }
                }));
  }
}
