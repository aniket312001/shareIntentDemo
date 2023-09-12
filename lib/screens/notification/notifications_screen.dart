import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/chats/chat_screen.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';

import '../../services/localization.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<String> items = [
    'Opt1',
    'Opt2',
    'Opt3',
    'Opt4',
  ];
  String? selectedMonth;
  String? selectedSortBy;
  dynamic pageNo = 0;
  bool isFull = false;
  bool startLoading = true;
  bool firstLoader = true;
  ScrollController _scrollController = ScrollController();

  bool isList = true;
  dynamic _selectedIndex = 0;
  dynamic totalUnreadCount = 0;

  int? selectedIndex;

  final List<String> SortByList = [
    "Relevance",
    "Popularity",
    "Price:high to low",
    "Price:low to high"
  ];

  final selectedPayment = [];
  dynamic notifications = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
  }

  __refresh() {
    setState(() {
      pageNo = 0;

      fetchData();
    });
  }

  fetchData() async {
    if (pageNo == 0) {
      firstLoader = true;
    }

    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {
      "userId": userId,
      "mode": _selectedIndex == 0 ? "unread" : "all",
      "limit": 20,
      "pageNumber": pageNo
    };

    log(obj.toString() + " my request \n\n");

    dynamic allData =
        await APIServices.makeApiCall("fetch-notification-list.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        // assistance = List<Map<String, dynamic>>.from(allData['dataList']);
        if (pageNo != 0) {
          notifications
              .addAll(List<Map<String, dynamic>>.from(allData['dataList']));
        } else {
          notifications = List<Map<String, dynamic>>.from(allData['dataList']);
        }
        startLoading = false;
      });
    } else {
      setState(() {
        isFull = true;
        startLoading = false;

        if (pageNo == 0) {
          notifications = [];
        }
      });
      // showCustomToast(context: context, message: allData['errorMessage']);
    }

    setState(() {
      firstLoader = false;

      totalUnreadCount = int.parse(allData['totalUnreadCount']);
    });
  }

  markedAsReadNotification(localizations) async {
    log("Making read mark");
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {"userId": userId, "id": "", "mode": "", "type": "all"};
    log(obj.toString() + "request for read");
    dynamic allData =
        await APIServices.makeApiCall("read-notification.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        log(allData['errorMessage'].toString() + " after read");
        showCustomToast(
            context: context,
            message: '${localizations!.translate(allData['errorMessage'])}');
        pageNo = 0;
        fetchData();
      });
    } else {
      log(allData['errorMessage'].toString());
      // showCustomToast(context: context, message: allData['errorMessage']);
    }
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
                  '${localizations!.translate("Notifications")}',
                  style: TextStyle(
                      letterSpacing: 0.2,
                      color: AppColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                if (totalUnreadCount != 0)
                  GestureDetector(
                      onTap: () {
                        openReadAll(localizations);
                      },
                      child: Icon(
                        Icons.filter_list_alt,
                        color: AppColors.purpleColor,
                      )),
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
                        isFull = false;
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
                        '${localizations!.translate('Unread')}',
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
                        isFull = false;
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
          if (notifications.length != 0) const SizedBox(height: 15),
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
                        isFull = false;
                        fetchData();
                      });
                    } else if (details.delta.dx < 0) {
                      setState(() {
                        if (_selectedIndex == 1) {
                          return;
                        }
                        _selectedIndex = 1;
                        pageNo = 0;
                        isFull = false;
                        fetchData();
                      });
                    }
                  },
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.blueColor),
                  ),
                ))
              : notifications.length == 0
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
                              isFull = false;
                              fetchData();
                            });
                          } else if (details.delta.dx < 0) {
                            setState(() {
                              if (_selectedIndex == 1) {
                                return;
                              }
                              _selectedIndex = 1;
                              pageNo = 0;
                              isFull = false;
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
                            isFull = false;
                            fetchData();
                          });
                        } else if (details.delta.dx < 0) {
                          setState(() {
                            if (_selectedIndex == 1) {
                              return;
                            }
                            _selectedIndex = 1;
                            pageNo = 0;
                            isFull = false;
                            fetchData();
                          });
                        }
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          return false;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            return index == notifications.length
                                ? Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Center(
                                        child: isFull
                                            ? Container()
                                            : CircularProgressIndicator(
                                                color: AppColors.blueColor)),
                                  )
                                :

                                // (notifications[index]['readFlag'] == false &&
                                //             _selectedIndex == 0) ||
                                //         _selectedIndex == 1
                                //     ?
                                GestureDetector(
                                    onTap: () {
                                      if (notifications[index]['actionType'] ==
                                              'ticket' ||
                                          notifications[index]['actionType'] ==
                                              'myTicket') {
                                        var obj = notifications[index];

                                        obj["id"] =
                                            notifications[index]['actionId'];

                                        refreshPreviousPage(
                                            context,
                                            ChatScreen(
                                                data: obj,
                                                fromNotification: true,
                                                updateReadFlag:
                                                    !notifications[index]
                                                        ['readFlag']),
                                            __refresh);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 12, left: 15, right: 16),
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
                                        SvgPicture.asset(
                                          notifications[index]['readFlag'] ==
                                                  false
                                              ? 'assets/images/notifications.svg'
                                              : 'assets/images/notifications (1).svg', // Path to your SVG file
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
                                              "${notifications[index]['notification']}",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors
                                                      .faqDescriptionColor),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                                "${notifications[index]['notificationDate']}",
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors
                                                        .faqDescriptionColor)),
                                          ],
                                        )),
                                      ]),
                                    ),
                                  );
                            // : Container();
                          },
                          itemCount: notifications.length,
                        ),
                      ),
                    ))
        ]),
      ),
    );
  }

  openReadAll(localizations) {
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
                  Center(
                    child: Text(
                      '${localizations!.translate("Mark all as read")}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/notifications.svg',
                          // : 'assets/images/notifications (1).svg', // Path to your SVG file
                          width: 56, // Adjust the width as needed
                          height: 56, // Adjust the height as needed
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${localizations!.translate("It will mark all unread notification as read")}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          markedAsReadNotification(localizations);
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
                      child: Text('${localizations!.translate("Read All")}'),
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
