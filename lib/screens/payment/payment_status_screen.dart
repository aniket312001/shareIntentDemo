import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/success_screen.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/imageViewer.dart';
import 'package:sno_biz_app/widgets/pdfViewer.dart';

import '../../services/localization.dart';
import '../../widgets/custom_toaster.dart';
import '../upload_document/verify_document.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  final List<String> items = [
    'Paid',
    'Unpaid',
  ];
  String selectedStatus = "Unpaid";
  String? selectedSortBy;

  bool isList = true;
  dynamic pageNo = 0;
  bool isFull = false;
  bool startLoading = true;
  bool firstLoader = true;
  int? selectedIndex;
  List<Map<String, dynamic>> allCompanies = [];
  ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? selectedCompany;

  final List<String> SortByList = [
    "Invoice Date",
    "Name",
    "Amount",
    "Company Name"
  ];

  dynamic selectedPayment = [];

  dynamic paymentList = [];

  final TextEditingController search = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchCompanyData();
  }

  fetchCompanyData() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {"userId": userId};
    dynamic allData =
        await APIServices.makeApiCall("fetch-companies-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        allCompanies = List<Map<String, dynamic>>.from(allData['dataList']);

        selectedCompany = allCompanies[0];
        fetchData();
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  __refresh() {
    setState(() {
      selectedPayment = [];
      pageNo = 0;
      fetchCompanyData();
    });
  }

  fetchData() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic sort = '';
    if (selectedIndex == null) {
      sort = '';
    } else if (selectedIndex == 0) {
      sort = 'invoiceDate';
    } else if (selectedIndex == 1) {
      sort = 'uploadDate';
    } else if (selectedIndex == 2) {
      sort = 'amount';
    } else if (selectedIndex == 3) {
      sort = 'companyName';
    }

    dynamic obj = {
      "companyId": selectedCompany!['companyId'],
      "userId": userId,
      // "search": search.text,
      // "period": selectedPeriod == null ? "" : selectedPeriod!['fullPeriod'],
      "period": "",
      "sort": sort,
      "mode": selectedStatus == 'Unpaid' ? "unpaid" : "paid",
      "pageNumber": pageNo,
      "limit": "20"
    };

    log(obj.toString() + " my request");
    dynamic allData =
        await APIServices.makeApiCall("fetch-document-list.php", obj);

    // log(allData.toString() + "data that i get");
    if (allData['errorCode'] == '0000') {
      setState(() {
        if (pageNo != 0) {
          paymentList
              .addAll(List<Map<String, dynamic>>.from(allData['dataList']));
        } else {
          paymentList = List<Map<String, dynamic>>.from(allData['dataList']);
        }
        startLoading = false;
      });
    } else {
      setState(() {
        isFull = true;
        startLoading = false;

        if (pageNo == 0) {
          paymentList = [];
        }
      });
      // showCustomToast(context: context, message: allData['errorMessage']);
    }

    setState(() {
      firstLoader = false;
    });
  }

  onSubmit() async {
    if (selectedPayment.isEmpty) {
      showCustomToast(
          context: context, message: "Please select atleast 1 payment data");
      return;
    }

    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {
      "userId": userId,
      "documentIds": selectedPayment,
      "status": selectedStatus == 'Unpaid' ? "paid" : "unpaid"
    };
    dynamic allData =
        await APIServices.makeApiCall("update-payment-status.php", obj);

    if (allData['errorCode'] == '0000') {
      fetchData();
    }
    showCustomToast(context: context, message: allData['errorMessage']);

    refreshPreviousPage(
        context,
        SuccessScreen(
          mode: "paymentStatus",
          count: selectedPayment.length,
          status: selectedStatus == 'Unpaid' ? "paid" : "unpaid",
        ),
        __refresh);
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
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
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
                            '${localizations!.translate("Payment Status")}',
                            style: TextStyle(
                                letterSpacing: 0.2,
                                color: AppColors.black,
                                fontSize: constraints.maxWidth * 0.054,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Card(
                            margin: EdgeInsets.zero,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            child: Container(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<Map<String, dynamic>>(
                                  dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      )),
                                  isExpanded: true,
                                  hint: Text(
                                    '${localizations!.translate('Company')}',
                                    style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.03,
                                        color: AppColors.greyColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  items: allCompanies
                                      .map((Map<String, dynamic>? item) =>
                                          DropdownMenuItem<
                                              Map<String, dynamic>>(
                                            value: item,
                                            child: Text(
                                              item!['companyName'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize:
                                                      constraints.maxWidth *
                                                          0.03,
                                                  color: AppColors.greyColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedCompany,
                                  onChanged: (Map<String, dynamic>? value) {
                                    setState(() {
                                      if (selectedCompany != value) {
                                        selectedCompany = value;
                                        pageNo = 0;
                                        selectedPayment = [];

                                        fetchData();
                                      }
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                      height: 35,
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 1),
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
                        const SizedBox(width: 10),
                        Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3.9,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isDense: true,
                                dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                                isExpanded: true,
                                hint: Text(
                                  '${localizations!.translate('Status')}',
                                  style: TextStyle(
                                      fontSize: constraints.maxWidth * 0.03,
                                      color: AppColors.greyColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                iconStyleData:
                                    const IconStyleData(iconSize: 19),
                                items: items
                                    .map((String item) =>
                                        DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                                fontSize:
                                                    constraints.maxWidth * 0.03,
                                                color: AppColors.greyColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ))
                                    .toList(),
                                value: selectedStatus,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedStatus = value!;
                                    pageNo = 0;
                                    selectedPayment = [];
                                    fetchData();
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                    height: 35,
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
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showSortList(localizations);
                          },
                          child: Card(
                            elevation: 2,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            child: Container(
                                height: 35,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      '${localizations!.translate("Sort")}',
                                      style: TextStyle(
                                          fontSize: constraints.maxWidth * 0.03,
                                          color: AppColors.greyColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_drop_down_outlined,
                                      size: 19,
                                      color: AppColors.black.withOpacity(0.7),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                    ),
                  ),
                  if (paymentList.length == 0 && firstLoader == false)
                    Expanded(
                      child: Container(
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: Image.asset(
                            "assets/images/image.png",
                            fit: BoxFit.contain,
                          )),
                    ),
                  (firstLoader == true)
                      ? Expanded(
                          child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.blueColor),
                        ))
                      : Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              if (scrollNotification is ScrollEndNotification &&
                                  _scrollController.position.extentAfter == 0) {
                                if (isFull == false) {
                                  setState(() {
                                    startLoading = true;
                                    pageNo = pageNo + 1;
                                    fetchData();
                                  });
                                }
                              }
                              return false;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              itemBuilder: (context, index) {
                                return index == paymentList.length
                                    ? Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Center(
                                            child: isFull
                                                ? Container()
                                                : CircularProgressIndicator(
                                                    color:
                                                        AppColors.blueColor)),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          // if (paymentList[index]['fileType'] !=
                                          //     'image') {
                                          //   nextPage(
                                          //       context,
                                          //       PDFScreen(
                                          //           name: "PDF",
                                          //           pdfPath: paymentList[index]
                                          //               ['document']));
                                          // } else {
                                          //   showImage(context,
                                          //       file: paymentList[index]
                                          //           ['document']);
                                          // }

                                          refreshPreviousPage(
                                              context,
                                              VerifyDocumentScreen(
                                                data: paymentList[index],
                                                unverifiedDocumentCount: 0,
                                                onlyVerifyOneDocument: true,
                                              ),
                                              __refresh);
                                        },
                                        child: Container(
                                          // margin: const EdgeInsets.only(bottom: 12),
                                          margin: const EdgeInsets.only(
                                              bottom: 12, left: 16, right: 16),
                                          decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 13,
                                              bottom: 13),
                                          child: Row(children: [
                                            SvgPicture.asset(
                                              'assets/images/verified (1).svg', // Path to your SVG file
                                              width:
                                                  26, // Adjust the width as needed
                                              height:
                                                  26, // Adjust the height as needed
                                            ),
                                            const SizedBox(width: 18),
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${paymentList[index]['companyName']}",
                                                  style: TextStyle(
                                                      fontSize:
                                                          constraints.maxWidth *
                                                              0.04,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .faqDescriptionColor),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                    "${paymentList[index]['uploadDate']}",
                                                    style: TextStyle(
                                                        fontSize: constraints
                                                                .maxWidth *
                                                            0.035,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .faqDescriptionColor)),
                                              ],
                                            )),
                                            //  If want responsiveness in price and then use Expanded widget on column

                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "\€${paymentList[index]['invoiceTotal']}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.black),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                    "${paymentList[index]['transactionType']}",
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .faqDescriptionColor)),
                                              ],
                                            ),
                                            const SizedBox(width: 10),
                                            Checkbox(
                                              // value: selectedPayment
                                              //     .any((obj) => obj['id'] == index),
                                              value: selectedPayment.contains(
                                                  paymentList[index]
                                                      ['documentId']),
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value == true) {
                                                    selectedPayment.add(
                                                        paymentList[index]
                                                            ['documentId']);
                                                  } else {
                                                    selectedPayment.remove(
                                                        paymentList[index]
                                                            ['documentId']);
                                                  }
                                                });
                                              },
                                            )
                                          ]),
                                        ),
                                      );
                              },
                              itemCount: paymentList.length + 1,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            bottomNavigationBar: (paymentList.length != 0)
                ? Container(
                    width: double.infinity,
                    height: 45,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 17, vertical: 15),
                    child: ElevatedButton(
                      onPressed: () {
                        onSubmit();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purpleColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          textStyle: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      child: Text(selectedStatus == 'Unpaid'
                          ? "${localizations!.translate('Mark as')} ${localizations!.translate('paid')}"
                          : "${localizations!.translate('Mark as')} ${localizations!.translate('unpaid')}"),
                    ),
                  )
                : null);
      }),
    );
  }

  showSortList(localizations) {
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 5),
                  Text(
                    '${localizations!.translate("Sort By")}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: SortByList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${localizations!.translate(SortByList[index])}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: Radio<int>(
                                value: index,
                                activeColor: AppColors.purpleColor,
                                groupValue: selectedIndex,
                                onChanged: (dynamic value) {
                                  setState(() {
                                    selectedIndex = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          index != SortByList.length - 1
                              ? const Divider(
                                  height: 1,
                                )
                              : Container()
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          pageNo = 0;
                          selectedPayment = [];
                          fetchData();
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purpleColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          textStyle: const TextStyle(
                              fontSize: 17.5,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      child:
                          Text('${localizations!.translate("Show Results")}'),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
