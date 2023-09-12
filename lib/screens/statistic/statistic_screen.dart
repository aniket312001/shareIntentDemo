import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/chats/chat_screen.dart';
import 'package:sno_biz_app/screens/ticket/ticket_screen.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sno_biz_app/widgets/decimalFormatCheck.dart';

import '../../services/localization.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class DataItem {
  dynamic x;
  double y1;
  double y2;

  DataItem({
    required this.x,
    required this.y1,
    required this.y2,
  });
}

class _StatisticScreenState extends State<StatisticScreen> {
  bool isList = true;

  int? selectedIndex;
  DateTime now = DateTime.now();

  dynamic expensesDataList = [];
  dynamic allData = {};

  List<Map<String, dynamic>> allCompanies = [];
  Map<String, dynamic>? selectedCompany;
  List<Map<String, dynamic>> periodList = [];

  Map<String, dynamic>? selectedPeriod;

  final TextEditingController newIncome = TextEditingController();
  final TextEditingController newTurnover = TextEditingController();
  dynamic updatedIncome = '';
  dynamic updatedTurnover = '';
  bool canScroll = true;
  dynamic graphDataList = [];
  dynamic myIncomeListObj = {};
  dynamic totalTurnOver = "0";
  bool firstLoader = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchCompanyData();
    fetchIncome();
  }

  fetchIncome() async {
    dynamic allIncomes = await SharedPrefUtils.readPrefStr("incomes");

    if (allIncomes == null) {
      allIncomes = {};
    } else {
      allIncomes = json.decode(allIncomes);
    }

    setState(() {
      totalTurnOver = 0.00;
      myIncomeListObj = allIncomes;

      for (var entry in myIncomeListObj.entries) {
        // totalTurnOver = totalTurnOver + myIncomeListObj
        totalTurnOver = totalTurnOver + double.parse(entry.value);
      }

      totalTurnOver = totalTurnOver.toStringAsFixed(2);
    });
    // allAddress = json.encode(allAddress);
    // SharedPrefUtils.saveStr('allAddress', allAddress);
  }

  fetchData() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {
      "userId": userId,
      "companyId": selectedCompany!['companyId'],
      "period": selectedPeriod!['monthDate'],
      "mode": ""
    };
    log("my request = ${obj.toString()}");
    allData = await APIServices.makeApiCall("fetch-common-details.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        expensesDataList =
            List<Map<String, dynamic>>.from(allData['expensesDataList']);

        if (allData.containsKey('graphDataList') && graphDataList.length == 0) {
          graphDataList =
              List<Map<String, dynamic>>.from(allData['graphDataList']);

          _myData = List.generate(
              graphDataList.length,
              (index) => DataItem(
                    x: index,
                    y1: double.parse(
                        graphDataList[index]['x1value'].toString()),
                    y2: double.parse(
                        graphDataList[index]['x2value'].toString()),
                  ));
        } else {
          // _myData = List.generate(
          //     12,
          //     (index) => DataItem(
          //           x: index + 1,
          //           y1: math.Random().nextInt(20) + math.Random().nextDouble(),
          //           y2: math.Random().nextInt(20) + math.Random().nextDouble(),
          //         ));
        }
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
    }
    setState(() {
      firstLoader = false;
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
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  fetchPeriodList() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

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

    setState(() {
      selectedPeriod = periodList[6];
      log(selectedPeriod.toString() + " select");
    });

    fetchData();
  }

  String _getFormattedMonth(int month) {
    return month.toString().padLeft(2, '0');
  }

  getMonth(index) {
    return graphDataList[index]['month'];
  }

  // Generate dummy data to feed the chart
  List<DataItem> _myData = [];

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        setState(() {
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            canScroll = true;
          }
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
              decoration: const BoxDecoration(
                  color: AppColors.skyBlueColor,
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
                    '${localizations!.translate("Statistics")}',
                    style: TextStyle(
                        letterSpacing: 0.2,
                        color: AppColors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
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
                                // width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                            isExpanded: true,
                            hint: Text(
                              '${localizations!.translate('Company')}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            items: allCompanies
                                .map((Map<String, dynamic>? item) =>
                                    DropdownMenuItem<Map<String, dynamic>>(
                                      value: item,
                                      child: Text(
                                        item!['companyName'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12,
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
                                  firstLoader = true;
                                  fetchData();
                                }
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                                height: 35,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(22))),
                            menuItemStyleData: const MenuItemStyleData(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Card(
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
                                // width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                            isExpanded: true,
                            hint: Text(
                              '${localizations!.translate('Period')}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            iconStyleData: const IconStyleData(iconSize: 19),
                            items: periodList
                                .map((Map<String, dynamic>? item) =>
                                    DropdownMenuItem<Map<String, dynamic>>(
                                      value: item,
                                      child: Text(
                                        item!['formattedMonth'],
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.greyColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ))
                                .toList(),
                            value: selectedPeriod,
                            onChanged: (Map<String, dynamic>? value) {
                              setState(() {
                                selectedPeriod = value;
                                firstLoader = true;
                                fetchData();
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                                height: 35,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(22))),
                            menuItemStyleData:
                                const MenuItemStyleData(height: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  child: Text(
                    '${localizations!.translate("Annual Turnover")}',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: AppColors.faqDescriptionColor),
                  ),
                ),
                // GestureDetector(
                //   onTap: () {
                //     UpdateData(context, "turnover");
                //   },
                //   child: SvgPicture.asset(
                //     'assets/images/pencil-alt.svg',
                //     width: 15, // Adjust the width as needed
                //     height: 15, //
                //   ),
                // ),
              ],
            ),
            Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                    child: Text(
                      // updatedTurnover != ''
                      //     ? '\€' + updatedTurnover.toString()
                      //     : allData.containsKey('totalTurnover')
                      //         ? '\€' + allData['totalTurnover'].toString()
                      //         : "\€0",

                      '\€ ${double.parse(totalTurnOver).round()}',

                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                // SvgPicture.asset(
                //   'assets/images/pencil-alt.svg',
                //   width: 25, // Adjust the width as needed
                //   height: 25, //
                // ),
                // SizedBox(
                //   width: 20,
                // ),
              ],
            ),
            _myData.length != 0
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      height: 146,
                      width: _myData.length * 50,
                      color: Colors
                          .transparent, // Set the container's background color to transparent
                      child: BarChart(BarChartData(
                          gridData: FlGridData(show: false),
                          barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: AppColors.dividerColor,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '\€${rod.toY.toStringAsFixed(2)}',
                                TextStyle(color: Colors.black),
                              );
                            },
                          )),
                          titlesData: FlTitlesData(
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    "${getMonth(value.round())}",
                                    style: TextStyle(fontSize: 12),
                                  );
                                },
                              ))),
                          borderData: FlBorderData(
                              border: const Border(
                            top: BorderSide.none,
                            right: BorderSide.none,
                            left: BorderSide.none,
                            bottom: BorderSide.none,
                          )),
                          groupsSpace: 10,
                          barGroups: _myData
                              .map((dataItem) =>
                                  BarChartGroupData(x: dataItem.x, barRods: [
                                    BarChartRodData(
                                        toY: dataItem.y1,
                                        width: 8,
                                        color: AppColors.lightBlue),
                                    BarChartRodData(
                                        toY: dataItem.y2,
                                        width: 8,
                                        color: AppColors.purpleColor),
                                  ]))
                              .toList())),
                    ),
                  )
                : Container(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        UpdateData(context, "income");
                      },
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        margin: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 13.0,
                            left: 14.0,
                            bottom: 13.0,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 3, // Spread radius
                                blurRadius: 7, // Blur radius
                                offset: Offset(
                                    0, 3), // Offset in the vertical direction
                              ),
                            ],
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.lightBlue),
                                padding: const EdgeInsets.all(13),
                                child: SvgPicture.asset(
                                  'assets/images/arrow_up.svg',
                                  semanticsLabel: 'My SVG Image',
                                  height: 14,
                                  width: 14,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * .035,
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${localizations!.translate('Income')}',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              letterSpacing: 0.3,
                                              color:
                                                  AppColors.faqDescriptionColor,
                                            ),
                                          ),
                                          SvgPicture.asset(
                                            'assets/images/pencil-alt.svg',
                                            width:
                                                10, // Adjust the width as needed
                                            height: 10, //
                                          ),
                                          SizedBox(width: 10)
                                        ],
                                      ),
                                      Text(
                                        selectedPeriod == null
                                            ? '\€0'
                                            : myIncomeListObj.containsKey(
                                                    selectedPeriod!['monthDate']
                                                        .toString())
                                                ? '\€${myIncomeListObj[selectedPeriod!['monthDate']]}'
                                                : '\€0',

                                        // updatedIncome == ''
                                        //     ? allData['totalIncome'].toString()
                                        //     : '\€' + updatedIncome,
                                        style: TextStyle(
                                            fontSize: 14,
                                            letterSpacing: 0.3,
                                            color: AppColors.lightBlack,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: EdgeInsets.zero,
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 13.0,
                          left: 14.0,
                          bottom: 13.0,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.2), // Shadow color
                              spreadRadius: 3, // Spread radius
                              blurRadius: 7, // Blur radius
                              offset: Offset(
                                  0, 3), // Offset in the vertical direction
                            ),
                          ],
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.purpleColor),
                              padding: const EdgeInsets.all(13),
                              child: SvgPicture.asset(
                                'assets/images/arrow-down.svg',
                                semanticsLabel: 'My SVG Image',
                                height: 14,
                                width: 14,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .035,
                            ),
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${localizations!.translate('Expenses')}',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        letterSpacing: 0.3,
                                        color: AppColors.faqDescriptionColor,
                                      ),
                                    ),
                                    Text(
                                      allData['totalExpenses'] == null
                                          ? '\€0'
                                          : "\€${double.parse(allData['totalExpenses']).round()}",
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          letterSpacing: 0.3,
                                          color: AppColors.lightBlack,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text('${localizations!.translate("Expenses")}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
            ),
            (firstLoader == true)
                ? Expanded(
                    child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.blueColor),
                  ))
                : expensesDataList.length == 0
                    ? Expanded(
                        child: Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width / 1.3,
                              child: Image.asset(
                                "assets/images/image.png",
                                fit: BoxFit.contain,
                              )),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                        itemCount: expensesDataList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: 0, left: 15, right: 15),
                            decoration: BoxDecoration(
                              border: index != expensesDataList.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                          color: AppColors.dividerColor))
                                  : null,
                              color: AppColors.white,
                              // borderRadius: BorderRadius.circular(15)
                            ),
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 15, bottom: 15),
                            child: Row(children: [
                              Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.lightgreyColor),
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(CupertinoIcons.cart_fill,
                                      color: AppColors.greyColor, size: 15)),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: Text(
                                "${expensesDataList[index]['storeName']}",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.faqDescriptionColor),
                              )),
                              Text(
                                "\€${expensesDataList[index]['amount']}",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: index % 2 != 0
                                        ? AppColors.lightBlue
                                        : AppColors.purpleColor),
                              ),
                            ]),
                          );
                        },
                      ))
          ]),
        ),
      ),
    );
  }

  UpdateData(BuildContext context, data) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    if (data == 'income' &&
        myIncomeListObj.containsKey(selectedPeriod!['monthDate'])) {
      newIncome.text = myIncomeListObj[selectedPeriod!['monthDate']];
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Container(
                  height: 40,
                  width: screenWidth,
                  padding: const EdgeInsets.only(left: 15, right: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.purpleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                content: Container(
                    width: screenWidth,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Container(
                        child: data == 'income'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Update Income",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.faqDescriptionColor),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.textColor),
                                    ),
                                    child: Form(
                                      child: TextField(
                                        // keyboardType: TextInputType.number,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        inputFormatters: [
                                          DecimalTextInputFormatter()
                                        ],
                                        controller: newIncome,
                                        style: const TextStyle(
                                            color: AppColors.lightBlack,
                                            fontSize: 15),
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            focusColor: Colors.transparent,
                                            contentPadding: EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 5,
                                                top: 5)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            if (newIncome.text == '') {
                                              showCustomToast(
                                                  context: context,
                                                  message: "Please add Income");
                                              return;
                                            }
                                            Navigator.pop(context);

                                            // await SharedPrefUtils.saveStr(
                                            //     "income",
                                            //     newIncome.text.toString());
                                            myIncomeListObj[selectedPeriod![
                                                'monthDate']] = double.parse(
                                                    newIncome.text.toString())
                                                .toStringAsFixed(2);
                                            var newIncomeList =
                                                json.encode(myIncomeListObj);
                                            SharedPrefUtils.saveStr(
                                                'incomes', newIncomeList);

                                            fetchIncome();
                                          },
                                          child: const Text("Save"),
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: const Size(
                                                double.infinity,
                                                double.infinity),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            backgroundColor:
                                                AppColors.purpleColor,
                                          )))
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Update TurnOver",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.faqDescriptionColor),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.textColor),
                                    ),
                                    child: Form(
                                      child: TextField(
                                        // keyboardType: TextInputType.number,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        inputFormatters: [
                                          DecimalTextInputFormatter()
                                        ],
                                        controller: newTurnover,
                                        style: const TextStyle(
                                            color: AppColors.lightBlack,
                                            fontSize: 15),
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            focusColor: Colors.transparent,
                                            contentPadding: EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 5,
                                                top: 5)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            if (newTurnover.text == '') {
                                              showCustomToast(
                                                  context: context,
                                                  message:
                                                      "Please add Turnover");
                                              return;
                                            }
                                            Navigator.pop(context);

                                            await SharedPrefUtils.saveStr(
                                                "turnover",
                                                newTurnover.text.toString());
                                            fetchIncome();
                                          },
                                          child: const Text("Save"),
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: const Size(
                                                double.infinity,
                                                double.infinity),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            backgroundColor:
                                                AppColors.purpleColor,
                                          )))
                                ],
                              ))));
          });
        });
  }
}
