import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/chats/chat_screen.dart';
import 'package:sno_biz_app/screens/ticket/ticket_screen.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/services/localization.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';

class AssistanceScreen extends StatefulWidget {
  const AssistanceScreen({super.key});

  @override
  State<AssistanceScreen> createState() => _AssistanceScreenState();
}

class _AssistanceScreenState extends State<AssistanceScreen> {
  final List<String> items = [
    'Opt1',
    'Opt2',
    'Opt3',
    'Opt4',
  ];
  String? selectedMonth;
  String? selectedSortBy;

  bool isList = true;
  dynamic _selectedIndex = 0;

  final List<String> SortByList = [
    "Relevance",
    "Popularity",
    "Price:high to low",
    "Price:low to high"
  ];

  dynamic pageNo = 0;
  bool isFull = false;
  bool startLoading = true;
  bool firstLoader = true;
  ScrollController _scrollController = ScrollController();
  final selectedPayment = [];

  dynamic assistance = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
  }

  fetchData() async {
    if (pageNo == 0) {
      firstLoader = true;
    }

    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {
      "userId": userId,
      "mode": _selectedIndex == 0 ? "open" : "all",
      "limit": 20,
      "pageNumber": pageNo
    };

    log(obj.toString());

    dynamic allData = await APIServices.makeApiCall("fetch-ticket.php", obj);
    log(allData.toString() + "allData");
    if (allData['errorCode'] == '0000') {
      setState(() {
        // assistance = List<Map<String, dynamic>>.from(allData['dataList']);
        if (pageNo != 0) {
          assistance
              .addAll(List<Map<String, dynamic>>.from(allData['dataList']));
        } else {
          assistance = List<Map<String, dynamic>>.from(allData['dataList']);

          if (assistance.length < 20) {
            isFull = true;
          }
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
          assistance = [];
        }
      });
      // showCustomToast(context: context, message: allData['errorMessage']);
    }

    setState(() {
      firstLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.skyBlueColor,
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
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
                        shape: BoxShape.circle, color: AppColors.purpleColor),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  '${localizations!.translate("Assistance")}',
                  style: TextStyle(
                      letterSpacing: 0.2,
                      color: AppColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 230, 230, 230)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedIndex == 0) {
                          return;
                        }
                        _selectedIndex = 0;
                        pageNo = 0;
                        fetchData();
                      });
                    },
                    child: Container(
                      height: 31,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: _selectedIndex == 0
                              ? AppColors.purpleColor
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${localizations!.translate('Open')}',
                        style: TextStyle(
                          color: _selectedIndex == 0
                              ? AppColors.white
                              : AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedIndex == 1) {
                          return;
                        }

                        _selectedIndex = 1;
                        pageNo = 0;
                        fetchData();
                      });
                    },
                    child: Container(
                      height: 31,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: _selectedIndex == 1
                              ? AppColors.purpleColor
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${localizations!.translate('All')}',
                        style: TextStyle(
                          color: _selectedIndex == 1
                              ? AppColors.white
                              : AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (assistance.length != 0) const SizedBox(height: 15),
          (firstLoader == true)
              ? Expanded(
                  child: GestureDetector(
                  onPanUpdate: (details) {
                    // Determine if the swipe is left-to-right or right-to-left
                    if (details.delta.dx > 0) {
                      setState(() {
                        if (_selectedIndex == 0) {
                          return;
                        }
                        _selectedIndex = 0;
                        pageNo = 0;
                        fetchData();
                      });
                    } else if (details.delta.dx < 0) {
                      setState(() {
                        if (_selectedIndex == 1) {
                          return;
                        }
                        _selectedIndex = 1;
                        pageNo = 0;
                        fetchData();
                      });
                    }
                  },
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.blueColor),
                  ),
                ))
              : assistance.length == 0
                  ? Expanded(
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          // Determine if the swipe is left-to-right or right-to-left
                          if (details.delta.dx > 0) {
                            setState(() {
                              if (_selectedIndex == 0) {
                                return;
                              }
                              _selectedIndex = 0;
                              pageNo = 0;
                              fetchData();
                            });
                          } else if (details.delta.dx < 0) {
                            setState(() {
                              if (_selectedIndex == 1) {
                                return;
                              }
                              _selectedIndex = 1;
                              pageNo = 0;
                              fetchData();
                            });
                          }
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width / 1.3,
                            child: Image.asset(
                              "assets/images/image.png",
                              fit: BoxFit.contain,
                            )),
                      ),
                    )
                  : Expanded(
                      child: GestureDetector(
                      onPanUpdate: (details) {
                        // Determine if the swipe is left-to-right or right-to-left
                        if (details.delta.dx > 0) {
                          setState(() {
                            if (_selectedIndex == 0) {
                              return;
                            }
                            _selectedIndex = 0;
                            pageNo = 0;
                            fetchData();
                          });
                        } else if (details.delta.dx < 0) {
                          setState(() {
                            if (_selectedIndex == 1) {
                              return;
                            }
                            _selectedIndex = 1;
                            pageNo = 0;
                            fetchData();
                          });
                        }
                      },
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
                            return index == assistance.length
                                ? Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Center(
                                        child: isFull
                                            ? Container()
                                            : CircularProgressIndicator(
                                                color: AppColors.blueColor)),
                                  )
                                : (_selectedIndex == 0) || _selectedIndex == 1
                                    ? GestureDetector(
                                        onTap: () {
                                          nextPage(
                                              context,
                                              ChatScreen(
                                                  data: assistance[index]));
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 12, left: 15, right: 16),
                                          decoration: BoxDecoration(
                                              color: assistance[index]
                                                          .containsKey(
                                                              'readFlag') ==
                                                      false
                                                  ? AppColors.white
                                                  : AppColors.peach,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 15,
                                              bottom: 15),
                                          child: Row(children: [
                                            assistance[index].containsKey(
                                                        'readFlag') ==
                                                    false
                                                ? SvgPicture.asset(
                                                    assistance[index]
                                                                ['status'] ==
                                                            'Processing'
                                                        ? 'assets/images/watch_later.svg'
                                                        : 'assets/images/verified (1).svg',
                                                    width:
                                                        26, // Adjust the width as needed
                                                    height:
                                                        26, // Adjust the height as needed
                                                  )
                                                : Icon(
                                                    CupertinoIcons
                                                        .envelope_fill,
                                                    color:
                                                        AppColors.purpleColor,
                                                    size: 25),
                                            const SizedBox(width: 18),
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${assistance[index]['subject']}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .faqDescriptionColor),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                    "${assistance[index]['createDate']}",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            AppColors.black)),
                                              ],
                                            )),
                                            SizedBox(width: 20),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${assistance[index]['ticketId']}",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .faqDescriptionColor),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                    "${assistance[index]['status']}",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors.black))
                                              ],
                                            ),
                                          ]),
                                        ),
                                      )
                                    : Container();
                          },
                          itemCount: assistance.length + 1,
                        ),
                      ),
                    ))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nextPage(context, TicketScreen());
        },
        backgroundColor: AppColors.purpleColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
