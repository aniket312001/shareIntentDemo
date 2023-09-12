import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/upload_document/upload_document_screen.dart';
import 'package:sno_biz_app/screens/upload_document/verify_document.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sno_biz_app/widgets/pdfImage.dart';

import '../../services/localization.dart';

class UploadedDoumentListScreen extends StatefulWidget {
  UploadedDoumentListScreen({this.mode = "all"});

  String mode = 'all';

  @override
  State<UploadedDoumentListScreen> createState() =>
      _UploadedDoumentListScreenState();
}

class _UploadedDoumentListScreenState extends State<UploadedDoumentListScreen> {
  String? selectedSortBy;

  bool isList = true;
  dynamic unverifiedDocumentCount = 0;

  int? selectedIndex = 1;

  final List<String> SortByList = [
    "Invoice Date",
    "Upload Date",
    "Amount",
    "Company Name"
  ];

  final TextEditingController search = TextEditingController();
  ScrollController _scrollController = ScrollController();
  dynamic allDocuments = [];
  dynamic pageNo = 0;
  bool isFull = false;
  bool startLoading = true;
  bool firstLoader = true;

  List<Map<String, dynamic>> allCompanies = [];
  List<Map<String, dynamic>> periodList = [];
  Map<String, dynamic>? selectedCompany;
  Map<String, dynamic>? selectedPeriod;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchCompanyData();
  }

  __refresh() {
    setState(() {
      pageNo = 0;
      fetchData();
    });
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

        fetchPeriodList();
      });
    } else {
      fetchPeriodList();
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  fetchData() async {
    if (pageNo == 0) {
      firstLoader = true;
    }
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
      "search": search.text,
      "period": selectedPeriod == null ? "" : selectedPeriod!['halfPeriod'],
      // "year": selectedYear,
      "sort": sort,
      "mode": widget.mode,
      "pageNumber": pageNo,
      "limit": "20"
    };
    log(obj.toString() + " request");
    dynamic allData =
        await APIServices.makeApiCall("fetch-document-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        if (pageNo != 0) {
          allDocuments
              .addAll(List<Map<String, dynamic>>.from(allData['dataList']));
        } else {
          unverifiedDocumentCount = allData['unverifiedDocumentCount'];
          allDocuments = List<Map<String, dynamic>>.from(allData['dataList']);
          // allDocuments = allDocuments[1];
        }

        if (allData['dataList'].length < 20) {
          log("stop loader ${allData['dataList'].length}");
          isFull = true;
          startLoading = false;
        } else {
          log("load more ${allData['dataList'].length}");
        }

        startLoading = false;
      });
    } else {
      setState(() {
        isFull = true;
        startLoading = false;

        if (pageNo == 0) {
          allDocuments = [];
        }
      });
      // showCustomToast(context: context, message: allData['errorMessage']);
    }

    setState(() {
      firstLoader = false;
    });
  }

  fetchPeriodList() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {
      "userId": userId,
      "companyId": selectedCompany!['companyId'],
    };
    dynamic allData =
        await APIServices.makeApiCall("fetch-period-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        // log(allData['dataList'].toString() + " periodList");

        // unverifiedDocumentCount = allData['unverifiedDocumentCount'];
        periodList = List<Map<String, dynamic>>.from(allData['dataList']);
        // selectedPeriod = {
        //   "fullPeriod": allData['fullPeriod'],
        //   "halfPeriod": allData['halfPeriod']
        // };
        selectedPeriod = periodList
            .where((item) => item['fullPeriod'] == allData['fullPeriod'])
            .toList()[0];

        // log(selectedPeriod.toString() + " selected period");

        fetchData();
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
      fetchData();
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
      child: LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.skyBlueColor,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
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
                          '${localizations!.translate("Uploaded Documents")}',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Row(
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedCompany,
                                    onChanged: (Map<String, dynamic>? value) {
                                      setState(() {
                                        if (selectedCompany != value) {
                                          selectedCompany = value;
                                          pageNo = 0;
                                          selectedPeriod = null;
                                          fetchData();
                                          fetchPeriodList();
                                        }
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                        height: 35,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
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
                          ),
                          const SizedBox(width: 7),
                          Card(
                            margin: EdgeInsets.zero,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<Map<String, dynamic>>(
                                  isDense: true,
                                  dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      )),
                                  isExpanded: true,
                                  hint: Text(
                                    '${localizations!.translate('Month')}',
                                    style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.03,
                                        color: AppColors.greyColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  iconStyleData:
                                      const IconStyleData(iconSize: 19),
                                  items: periodList
                                      .map((Map<String, dynamic>? item) =>
                                          DropdownMenuItem<
                                              Map<String, dynamic>>(
                                            value: item,
                                            child: Text(
                                              item!['fullPeriod'],
                                              style: TextStyle(
                                                fontSize:
                                                    constraints.maxWidth * 0.03,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedPeriod,
                                  onChanged: (Map<String, dynamic>? value) {
                                    setState(() {
                                      selectedPeriod = value;
                                      pageNo = 0;
                                      fetchData();
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                      height: 35,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(22))),
                                  menuItemStyleData:
                                      const MenuItemStyleData(height: 40),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
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
                                      const EdgeInsets.only(left: 8, right: 2),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${localizations!.translate("Sort")}',
                                        style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.03,
                                            color: AppColors.greyColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.arrow_drop_down_outlined,
                                        size: 19,
                                        color: AppColors.black.withOpacity(0.7),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          const SizedBox(width: 7),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isList = !isList;
                              });
                            },
                            child: Container(
                                height: 35,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 10),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.purpleColor),
                                child: Icon(
                                    isList
                                        ? CupertinoIcons.circle_grid_3x3_fill
                                        : CupertinoIcons.list_bullet,
                                    color: AppColors.white,
                                    size: 15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
                    ],
                  ),
                ),
                if (allDocuments.length == 0 && firstLoader == false)
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
                    : (allDocuments.length == 0)
                        ? Container()
                        : Expanded(
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (scrollNotification) {
                                if (scrollNotification
                                        is ScrollEndNotification &&
                                    _scrollController.position.extentAfter ==
                                        0) {
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
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: isList
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 17),
                                        child: Column(
                                          children: List.generate(
                                              allDocuments.length + 1, (index) {
                                            return index == allDocuments.length
                                                ? Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5),
                                                    child: Center(
                                                        child: isFull
                                                            ? Container()
                                                            : CircularProgressIndicator(
                                                                color: AppColors
                                                                    .blueColor)),
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      refreshPreviousPage(
                                                          context,
                                                          VerifyDocumentScreen(
                                                            data: allDocuments[
                                                                index],
                                                            unverifiedDocumentCount:
                                                                unverifiedDocumentCount,
                                                            onlyVerifyOneDocument:
                                                                widget.mode ==
                                                                        "all"
                                                                    ? true
                                                                    : false,
                                                          ),
                                                          __refresh);
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              AppColors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15,
                                                              right: 25,
                                                              top: 15,
                                                              bottom: 15),
                                                      child: Row(children: [
                                                        SvgPicture.asset(
                                                          allDocuments[index]
                                                                  ['isVerify']
                                                              ? 'assets/images/verified (1).svg'
                                                              : 'assets/images/watch_later.svg', // Path to your SVG file
                                                          width:
                                                              26, // Adjust the width as needed
                                                          height:
                                                              26, // Adjust the height as needed
                                                        ),
                                                        const SizedBox(
                                                            width: 18),
                                                        Expanded(
                                                            child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              allDocuments[
                                                                          index]
                                                                      [
                                                                      'isVerify']
                                                                  ? "${allDocuments[index]['storeName']}"
                                                                  : "${allDocuments[index]['companyName']}",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppColors
                                                                      .faqDescriptionColor),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                                "${allDocuments[index]['uploadDate']}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColors
                                                                        .faqDescriptionColor)),
                                                          ],
                                                        )),
                                                        allDocuments[index]
                                                                ['isVerify']
                                                            ? Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    "\€${allDocuments[index]['invoiceTotal']}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          2),
                                                                  Text(
                                                                      "${localizations!.translate(allDocuments[index]['transactionType'])}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              AppColors.faqDescriptionColor)),
                                                                ],
                                                              )
                                                            : Container()
                                                      ]),
                                                    ),
                                                  );
                                          }).toList(),
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 17),
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      3, // Number of columns
                                                  mainAxisSpacing:
                                                      18, // Vertical spacing between grid items
                                                  crossAxisSpacing:
                                                      18, // Horizontal spacing between grid items
                                                  mainAxisExtent: 110),
                                          itemCount: allDocuments
                                              .length, // Total number of grid items
                                          shrinkWrap:
                                              true, // Make GridView take the space it needs
                                          physics:
                                              const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                refreshPreviousPage(
                                                    context,
                                                    VerifyDocumentScreen(
                                                      unverifiedDocumentCount:
                                                          unverifiedDocumentCount,
                                                      data: allDocuments[index],
                                                      onlyVerifyOneDocument:
                                                          widget.mode == "all"
                                                              ? true
                                                              : false,
                                                    ),
                                                    __refresh);
                                              },
                                              child: Stack(
                                                children: [
                                                  Card(
                                                    margin: EdgeInsets.zero,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13),
                                                    ),
                                                    child: allDocuments[index]
                                                                ['fileType'] !=
                                                            'image'
                                                        ? PdfPreviewWidget(
                                                            pdfLink:
                                                                allDocuments[
                                                                        index][
                                                                    'document'])
                                                        : Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            13),
                                                                    color: AppColors
                                                                        .white,
                                                                    image: allDocuments[index]['fileType'] ==
                                                                            'image'
                                                                        ? DecorationImage(
                                                                            image:
                                                                                CachedNetworkImageProvider(
                                                                              allDocuments[index]['document'],
                                                                              cacheManager: DefaultCacheManager(),
                                                                            ),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          )
                                                                        : null),
                                                          ),
                                                  ),
                                                  if (allDocuments[index]
                                                          ['isVerify'] ==
                                                      true)
                                                    Positioned(
                                                      right: 5,
                                                      top: 5,
                                                      child: SvgPicture.asset(
                                                        'assets/images/verified (1).svg', // Path to your SVG file
                                                        width:
                                                            24, // Adjust the width as needed
                                                        height:
                                                            24, // Adjust the height as needed
                                                      ),
                                                    )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ),
                          ),
                const SizedBox(height: 10)
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              refreshPreviousPage(
                  context,
                  UploadDoumentScreen(isFileUploaded: false, files: null),
                  __refresh);
            },
            child: const Icon(Icons.add),
            backgroundColor: AppColors.purpleColor,
          ),
        );
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
                                log(selectedIndex.toString());
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
                                    log(selectedIndex.toString() + " radio");
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
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          pageNo = 0;
                          fetchData();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purpleColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      child:
                          Text('${localizations!.translate("Show Results")}'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
