import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/success_screen.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:sno_biz_app/widgets/decimalFormatCheck.dart';
import 'package:sno_biz_app/widgets/purple_icon_button.dart';

import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sno_biz_app/widgets/shareFileToAnother.dart';

import '../../services/localization.dart';

class VerifyDocumentScreen extends StatefulWidget {
  VerifyDocumentScreen(
      {required this.data,
      required this.unverifiedDocumentCount,
      required this.onlyVerifyOneDocument}) {}

  dynamic data = {};

  dynamic unverifiedDocumentCount = 0;
  dynamic onlyVerifyOneDocument = true;
  @override
  State<VerifyDocumentScreen> createState() => _VerifyDocumentScreenState();
}

class _VerifyDocumentScreenState extends State<VerifyDocumentScreen> {
  dynamic initDrag = 0.80;
  dynamic paymentStatus = false;
  dynamic enterVendorManually = false;
  dynamic totalDocumentCount = 1;

  final TextEditingController invoiceDate = TextEditingController();
  final TextEditingController company = TextEditingController();
  final TextEditingController period = TextEditingController();
  final TextEditingController invoiceTotal = TextEditingController();
  final TextEditingController vendorManualText = TextEditingController();
  // dynamic invoiceDate;
  // dynamic invoiceTotal;

  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> venders = [];

  Map<String, dynamic>? selectedVenders;
  dynamic status6;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    log(widget.data.toString() + " data that got");
    setState(() {
      if (widget.data['invoiceTotal'] != '') {
        invoiceTotal.text = widget.data['invoiceTotal'];
      }

      if (widget.data['invoiceDate'] != '') {
        try {
          dynamic date = widget.data['invoiceDate'].toString();
          _selectedDate = DateTime(int.parse(date.split('-')[2]),
              int.parse(date.split('-')[1]), int.parse(date.split('-')[0]));
        } catch (e) {
          log(e.toString());
        }

        invoiceDate.text = widget.data['invoiceDate'];
      }

      if (widget.onlyVerifyOneDocument == false) {
        fetchVendorData("");
      } else {
        if (widget.data['storeId'] != '') {
          enterVendorManually = false;
          fetchVendorData(widget.data['storeId']);
        } else {
          if (widget.data['storeName'] != '') {
            enterVendorManually = true;
            vendorManualText.text = widget.data['storeName'];
          } else {
            enterVendorManually = false;
          }
          log("aghoieahgui aeh uiaeg iea");
          fetchVendorData('');
        }
      }

      if (widget.data['payMode'] == 'unpaid') {
        paymentStatus = false;
      } else {
        paymentStatus = true;
      }

      if (widget.data['period'] != '') {
        period.text = widget.data['period'];
      }

      if (widget.data['companyName'] != '') {
        company.text = widget.data['companyName'];
      }
    });
  }

  fetchVendorData(id) async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");
    log("company - ${widget.data['companyId']}");
    dynamic obj = {"userId": userId, "companyId": widget.data['companyId']};
    dynamic allData =
        await APIServices.makeApiCall("fetch-stores-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        venders = List<Map<String, dynamic>>.from(allData['dataList']);

        if (id != '') {
          selectedVenders =
              venders.where((item) => item['storeId'] == id).toList()[0];
        }
      });
    } else {
      setState(() {
        // enterVendorManually = true;
      });
      // showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  //Date Picker for picking date of birth
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        log(_selectedDate.toString());

        dynamic dateSplit = _selectedDate.toString().split(' ')[0].split('-');
        invoiceDate.text =
            dateSplit[2] + "-" + dateSplit[1] + "-" + dateSplit[0];
      });
    }
  }

  verifyDetails() async {
    if (invoiceDate.text.toString() == 'null' ||
        invoiceDate.text.toString() == '') {
      showCustomToast(
          context: context, message: "Please Select Date of Invoice");
      return;
    } else if (selectedVenders == null && enterVendorManually == false) {
      showCustomToast(context: context, message: "Please Select Vendor");
      return;
    } else if ((vendorManualText.text.toString() == 'null' ||
            vendorManualText.text.toString() == '') &&
        enterVendorManually == true) {
      showCustomToast(context: context, message: "Please write Vendor name");
      return;
    } else if (invoiceTotal.text.toString() == 'null' ||
        invoiceTotal.text.toString() == '') {
      showCustomToast(context: context, message: "Please add Total Invoice");
      return;
    }

    CustomLoader.showProgressBar(context);
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic dateSplit = invoiceDate.text.split("-");

    dynamic obj = {
      "userId": userId,
      "documentId": widget.data['documentId'],
      "invoiceDate": dateSplit[2] + "-" + dateSplit[1] + "-" + dateSplit[0],
      "storeId":
          enterVendorManually == false ? selectedVenders!['storeId'] : "",
      "storeName": enterVendorManually ? vendorManualText.text : "",
      "invoiceTotal": invoiceTotal.text,
      "paymentStatus": paymentStatus ? "paid" : "unpaid"
    };
    log(obj.toString());
    dynamic allData = await APIServices.makeApiCall("verify-invoice.php", obj);

    Navigator.pop(context);
    if (allData['errorCode'] == '0000') {
      // if (widget.onlyVerifyOneDocument == false) {
      //   showCustomToast(context: context, message: allData['errorMessage']);
      // }
      setState(() {
        // venders = List<Map<String, dynamic>>.from(allData['dataList']);

        if (allData['documentId'] != '0' &&
            widget.onlyVerifyOneDocument == false) {
          showCustomToast(context: context, message: allData['errorMessage']);
          totalDocumentCount = totalDocumentCount + 1;
          widget.data['documentId'] = allData['documentId'];
          widget.data['document'] = allData['document'];
          widget.data['fileType'] = allData['documentType'];

          vendorManualText.clear();

          if (widget.onlyVerifyOneDocument == false) {
            selectedVenders = null;
          } else {
            if (allData['storeId'] != '') {
              enterVendorManually = false;
              selectedVenders = {
                "storedId": allData['storeId'],
                "storeName": widget.data['storeId']
              };
            } else {
              if (allData['storeName'] != '') {
                enterVendorManually = true;
                vendorManualText.text = allData['storeName'];
              } else {
                enterVendorManually = false;
              }
            }
          }

          _selectedDate = DateTime.now();
          paymentStatus = false;

          if (allData['invoiceTotal'] != '') {
            invoiceTotal.text = allData['invoiceTotal'];
          } else {
            invoiceTotal.clear();
          }
          if (allData['invoiceDate'] != '') {
            try {
              dynamic date = allData['invoiceDate'].toString();

              _selectedDate = DateTime(int.parse(date.split('-')[2]),
                  int.parse(date.split('-')[1]), int.parse(date.split('-')[0]));
            } catch (e) {
              log(e.toString());
            }

            invoiceDate.text = allData['invoiceDate'];
          } else {
            invoiceDate.clear();
          }
          selectedVenders = null;
        } else {
          nextPage(
              context,
              SuccessScreen(
                  mode: "verified",
                  count: totalDocumentCount,
                  all: widget.onlyVerifyOneDocument ? false : true));
        }
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (widget.onlyVerifyOneDocument == false && totalDocumentCount > 1) {
          nextPagewithReplacement(
              context,
              SuccessScreen(
                  mode: "verified", count: totalDocumentCount - 1, all: false));
        } else {
          Navigator.pop(context);
        }

        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.lightColor,
        body: SafeArea(
          child: Stack(
            children: [
              widget.data['fileType'] == 'image'
                  ? InteractiveViewer(
                      minScale: 0.1, // Minimum scale value
                      maxScale: 4.0, // Maximum scale value
                      child: CachedNetworkImage(
                        imageUrl: widget.data['document'],
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        cacheManager: DefaultCacheManager(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : PDF().cachedFromUrl(
                      widget.data['document'],
                      placeholder: (progress) => Center(
                          child: CircularProgressIndicator(
                              color: AppColors.blueColor)),
                      errorWidget: (error) => Center(
                        child: Icon(Icons.error),
                      ),
                    ),
              DraggableScrollableSheet(
                initialChildSize:
                    initDrag, // Default open height as a fraction of the screen height
                minChildSize: 0.05, // Minimum height when fully closed
                maxChildSize: initDrag, // Maximum height when fully opened
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.skyBlueColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        padding: EdgeInsets.only(top: 2),
                        child: Container(
                          padding: const EdgeInsets.only(top: 0),
                          decoration: const BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        bottom: 16.0,
                                        top: 0),
                                    child: Column(
                                      children: [
                                        // Container(
                                        //   padding:
                                        //       const EdgeInsets.only(top: 30),
                                        // ),

                                        const Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 8.0, top: 2),
                                            child: Icon(
                                                Icons.keyboard_arrow_down,
                                                size: 40),
                                          ),
                                        ),

                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: AppColors.skyBlueColor,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Center(
                                            child: Text(
                                              '${localizations!.translate("Verify Details")}',
                                              style: TextStyle(
                                                  color: AppColors.black,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.lightgreyColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: AppColors.skyBlueColor,
                                                  width: 1)),
                                          child: TextField(
                                            controller: company,
                                            keyboardType: TextInputType.text,
                                            enabled: false,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText:
                                                    "${localizations!.translate('Company name')} *",
                                                hintStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.greyColor),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20)),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.lightgreyColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: AppColors.skyBlueColor,
                                                  width: 1)),
                                          child: TextField(
                                            controller: period,
                                            keyboardType: TextInputType.text,
                                            enabled: false,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText:
                                                    "${localizations!.translate('Period')} *",
                                                hintStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.greyColor),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20)),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: AppColors.skyBlueColor,
                                                  width: 1)),
                                          child: TextField(
                                            controller: invoiceDate,
                                            readOnly: true,
                                            onTap: () {
                                              _selectDate(context);
                                            },
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText:
                                                    "${localizations!.translate('Date of Invoice')} *",
                                                hintStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.greyColor),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20)),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            enterVendorManually
                                                ? Expanded(
                                                    child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        border: Border.all(
                                                            color: AppColors
                                                                .skyBlueColor,
                                                            width: 1)),
                                                    child: TextField(
                                                      controller:
                                                          vendorManualText,
                                                      decoration: InputDecoration(
                                                          border: InputBorder
                                                              .none,
                                                          hintText:
                                                              "${localizations!.translate('Vendor Name')} *",
                                                          hintStyle: TextStyle(
                                                              fontSize: 16,
                                                              color: AppColors
                                                                  .greyColor),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          20)),
                                                    ),
                                                  ))
                                                : Expanded(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton2<
                                                            Map<String,
                                                                dynamic>>(
                                                          dropdownStyleData:
                                                              DropdownStyleData(
                                                                  maxHeight:
                                                                      200,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  )),
                                                          isExpanded: true,
                                                          hint: Text(
                                                            '${localizations!.translate("Vendor Name")} *',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .greyColor),
                                                          ),
                                                          items: venders
                                                              .map((dynamic
                                                                      item) =>
                                                                  DropdownMenuItem<
                                                                      Map<String,
                                                                          dynamic>>(
                                                                    value: item,
                                                                    child: Text(
                                                                      item[
                                                                          'storeName'],
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ))
                                                              .toList(),
                                                          value:
                                                              selectedVenders,
                                                          onChanged: (Map<
                                                                  String,
                                                                  dynamic>?
                                                              value) {
                                                            setState(() {
                                                              selectedVenders =
                                                                  value;
                                                            });
                                                          },
                                                          buttonStyleData:
                                                              ButtonStyleData(
                                                                  // height: 43,
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          3),
                                                                  decoration: BoxDecoration(
                                                                      color: AppColors
                                                                          .white,
                                                                      border: Border.all(
                                                                          color: AppColors
                                                                              .skyBlueColor,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15))),
                                                          menuItemStyleData:
                                                              const MenuItemStyleData(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            SizedBox(width: 8),
                                            Text(
                                              '${localizations!.translate("OR")}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (enterVendorManually) {
                                                    enterVendorManually = false;
                                                  } else {
                                                    enterVendorManually = true;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.skyBlueColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                width: 80,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 7),
                                                child: Text(
                                                    textAlign: TextAlign.center,
                                                    enterVendorManually
                                                        ? '${localizations!.translate("Select Vendor")}'
                                                        : '${localizations!.translate("Enter Manunally")}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            AppColors.black)),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: AppColors.skyBlueColor,
                                                  width: 1)),
                                          child: TextField(
                                            controller: invoiceTotal,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            // keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              DecimalTextInputFormatter()
                                            ],
                                            // inputFormatters: [
                                            //   FilteringTextInputFormatter.allow(
                                            //       RegExp(r'[0-9]')),
                                            // ],
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText:
                                                    "${localizations!.translate("Invoice Total")} *",
                                                hintStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.greyColor),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20)),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: AppColors.skyBlueColor,
                                                  width: 1)),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${localizations!.translate("Payment Status")}',
                                                  style: TextStyle(
                                                      fontSize: 16.5,
                                                      color:
                                                          AppColors.greyColor),
                                                ),
                                                FlutterSwitch(
                                                  height: 29.0,
                                                  width: 65.0,
                                                  activeColor:
                                                      AppColors.purpleColor,
                                                  valueFontSize: 10.0,
                                                  toggleSize: 15.0,
                                                  value: paymentStatus,
                                                  borderRadius: 15.0,
                                                  padding: 4.0,
                                                  showOnOff: true,
                                                  onToggle: (val) {
                                                    setState(() {
                                                      paymentStatus = val;
                                                    });
                                                  },
                                                  activeText: " Paid",
                                                  inactiveText: "Unpaid",
                                                )
                                              ]),
                                        ),

                                        const SizedBox(height: 25.0),
                                        PurpleButton(
                                            text: widget.onlyVerifyOneDocument ==
                                                    false
                                                ? '${localizations!.translate('Save & Next')}'
                                                : '${localizations!.translate("Save")}',
                                            onTap: () {
                                              verifyDetails();
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                top: 25.6,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    if (widget.onlyVerifyOneDocument == false &&
                        totalDocumentCount > 1) {
                      nextPagewithReplacement(
                          context,
                          SuccessScreen(
                            mode: "verified",
                            count: totalDocumentCount,
                            all: false,
                          ));
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.purpleColor),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (widget.onlyVerifyOneDocument == false)
                Positioned(
                    top: 25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.purpleColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "${totalDocumentCount} / ${widget.unverifiedDocumentCount}",
                          style: TextStyle(
                              fontSize: 15.5,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )),
              Positioned(
                top: 25.6,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    if (widget.data['fileType'] == 'image') {
                      shareImage(
                          context, widget.data['document'], localizations);
                    } else {
                      sharePdf(context, widget.data['document'], localizations);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.purpleColor),
                    child: const Icon(
                      Icons.share_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
