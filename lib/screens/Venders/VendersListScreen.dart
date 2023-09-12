import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/success_screen.dart';
import 'package:sno_biz_app/screens/upload_document/upload_document_screen.dart';
import 'package:sno_biz_app/screens/upload_document/verify_document.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sno_biz_app/widgets/pdfImage.dart';
import 'package:sno_biz_app/widgets/pdfViewer.dart';
import 'package:sno_biz_app/widgets/purple_icon_button.dart';

import '../../services/localization.dart';
import '../../widgets/imageViewer.dart';

class VenderScreen extends StatefulWidget {
  VenderScreen();

  @override
  State<VenderScreen> createState() => _VenderScreenState();
}

class _VenderScreenState extends State<VenderScreen> {
  String? selectedSortBy;

  bool isList = true;
  dynamic unverifiedDocumentCount = 0;

  int? selectedIndex;

  final List<String> SortByList = [
    "Name",
    "Credit Period",
  ];

  final TextEditingController search = TextEditingController();
  ScrollController _scrollController = ScrollController();
  dynamic venderList = [];
  dynamic pageNo = 0;
  bool isFull = false;
  bool startLoading = true;
  bool firstLoader = true;
  List<Map<String, dynamic>> creditList = [];
  List<Map<String, dynamic>> categoryList = [];
  Map<String, dynamic>? selectedCredit;
  Map<String, dynamic>? selectedCategory;
  List<Map<String, dynamic>> allCompanies = [];
  List<Map<String, dynamic>> periodList = [];
  Map<String, dynamic>? selectedCompany;
  Map<String, dynamic>? selectedPeriod;
  final TextEditingController venderName = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
    fetchCreditPeriod();
    fetchCategory();
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
      sort = 'name';
    } else if (selectedIndex == 1) {
      sort = 'creditPeriod';
    }

    dynamic obj = {
      "userId": userId,
      "searchByName": search.text,
      "sort": sort,
    };
    // log(obj.toString() + " request");
    dynamic allData =
        await APIServices.makeApiCall("fetch-stores-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        // if (pageNo != 0) {
        //   allDocuments
        //       .addAll(List<Map<String, dynamic>>.from(allData['dataList']));
        // } else {
        venderList = List<Map<String, dynamic>>.from(allData['dataList']);

        // }
        startLoading = false;
      });
    } else {
      setState(() {
        isFull = true;
        startLoading = false;

        // if (pageNo == 0) {
        venderList = [];
        // }
      });
      // showCustomToast(context: context, message: allData['errorMessage']);
    }

    setState(() {
      firstLoader = false;
    });
  }

  void fetchCreditPeriod() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {"userId": userId};
    dynamic allData =
        await APIServices.makeApiCall("fetch-credit-period-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        creditList = List<Map<String, dynamic>>.from(allData['dataList']);
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  void fetchCategory() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {"userId": userId};
    dynamic allData =
        await APIServices.makeApiCall("fetch-vendor-category-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        categoryList = List<Map<String, dynamic>>.from(allData['dataList']);
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  createVender(localizations, context) async {
    // log(venderName.text.isEmpty.toString());
    if (venderName.text.isEmpty) {
      showCustomToast(
          context: context,
          message: localizations!.translate("Please add Vendor Name"));
      return;
    } else if (selectedCredit == null) {
      showCustomToast(
          context: context,
          message: localizations!.translate("Please select Credit Period"));
      return;
    }

    CustomLoader.showProgressBar(context);
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {
      "userId": userId,
      'categoryId':
          selectedCategory == null ? '' : selectedCategory!['categoryId']!,
      'vendorName': venderName.text,
      'creditPeriod': selectedCredit!['germanCredit'],
    };

    log(obj.toString() + "  this is request");

    dynamic allData = await APIServices.makeApiCall("add-store.php", obj);

    Navigator.pop(context);
    if (allData['errorCode'] == '0000') {
      setState(() {
        search.clear();
        venderName.clear();
        fetchData();
        selectedCategory = null;
        selectedCredit = null;
      });
      Navigator.pop(context);
      // nextPagewithReplacement(context, SuccessScreen(mode: "vender"));
    } else {}

    showCustomToast(
        context: context,
        message: localizations!.translate(allData['errorMessage'].toString()));
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
          child: Stack(
            children: [
              Column(
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
                        Text(
                          '${localizations!.translate("Vendor's List")}',
                          style: TextStyle(
                              color: AppColors.black,
                              fontSize: 20,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
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
                                  height: 36,
                                  child: TextField(
                                    style: TextStyle(fontSize: 14.0),
                                    controller: search,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                            "${localizations!.translate("Search by Name")} ",
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.greyColor,
                                            fontWeight: FontWeight.bold),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 9.5)),
                                    onChanged: (value) {
                                      fetchData();
                                    },
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
                                    padding: const EdgeInsets.only(
                                        left: 18, right: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${localizations!.translate("Sort")}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.greyColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_drop_down_outlined,
                                          size: 19,
                                          color:
                                              AppColors.black.withOpacity(0.7),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            const SizedBox(width: 7),
                          ],
                        ),
                        const SizedBox(height: 0),
                      ],
                    ),
                  ),
                  if (venderList.length == 0 && firstLoader == false)
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
                      : (venderList.length == 0)
                          ? Container()
                          : Expanded(
                              child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17),
                                    child: Column(
                                      children: List.generate(venderList.length,
                                          (index) {
                                        return GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            decoration: BoxDecoration(
                                                color: AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                top: 15,
                                                bottom: 15),
                                            child: Row(children: [
                                              Image.asset(
                                                "assets/images/store.png",
                                                height: 20,
                                              ),
                                              const SizedBox(width: 30),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${venderList[index]['storeName']}",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .faqDescriptionColor),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                          "${venderList[index]['categoryName']}",
                                                          style: TextStyle(
                                                              fontSize: 12.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: AppColors
                                                                  .faqDescriptionColor)),
                                                    ],
                                                  )),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "${venderList[index]['creditPeriod']} ",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                            ]),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )),
                            ),
                  const SizedBox(height: 10)
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _openBottomSheet(context, localizations);
            // nextPage(context, CreateVenderScreen());
          },
          child: const Icon(Icons.add),
          backgroundColor: AppColors.purpleColor,
        ),
      ),
    );
  }

  void _openBottomSheet(BuildContext context, localizations) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(// Wrap the content with StatefulBuilder
            builder: (BuildContext context, StateSetter setState) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: Container(
              // height: 300,

              color: Colors.white,
              padding: EdgeInsets.only(
                  top: 30,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.skyBlueColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text(
                            '${localizations!.translate("Create Vendor")}',
                            style: TextStyle(
                                color: AppColors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: AppColors.skyBlueColor, width: 1)),
                      child: TextField(
                        controller: venderName,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                '${localizations!.translate('Vendor Name')} *',
                            hintStyle: TextStyle(
                                fontSize: 16, color: AppColors.greyColor),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<Map<String, dynamic>>(
                                dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    )),
                                isExpanded: true,
                                hint: Text(
                                  '${localizations!.translate('Credit Period')} *',
                                  // '${localizations!.translate("Vendor Name")} *',
                                  style: TextStyle(
                                      fontSize: 16, color: AppColors.greyColor),
                                ),
                                items: creditList
                                    .map((dynamic item) =>
                                        DropdownMenuItem<Map<String, dynamic>>(
                                          value: item,
                                          child: Text(
                                            item!['englishCredit'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: selectedCredit,
                                onChanged: (Map<String, dynamic>? value) {
                                  setState(() {
                                    selectedCredit = value;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                    // height: 43,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    decoration: BoxDecoration(
                                        color: AppColors.white,
                                        border: Border.all(
                                            color: AppColors.skyBlueColor,
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                menuItemStyleData: const MenuItemStyleData(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<Map<String, dynamic>>(
                                dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    )),
                                isExpanded: true,
                                hint: Text(
                                  // "Category",
                                  '${localizations!.translate("Vendor Category")} *',
                                  style: TextStyle(
                                      fontSize: 16, color: AppColors.greyColor),
                                ),
                                items: categoryList
                                    .map((dynamic item) =>
                                        DropdownMenuItem<Map<String, dynamic>>(
                                          value: item,
                                          child: Text(
                                            item!['categoryName'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: selectedCategory,
                                onChanged: (Map<String, dynamic>? value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                    // height: 43,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    decoration: BoxDecoration(
                                        color: AppColors.white,
                                        border: Border.all(
                                            color: AppColors.skyBlueColor,
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                menuItemStyleData: const MenuItemStyleData(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    PurpleButton(
                        text: '${localizations!.translate("Save")}',
                        onTap: () {
                          createVender(localizations, context);
                        }),
                    const SizedBox(height: 25.0),
                  ],
                ),
              ),
            ),
          );
        });
      },
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
