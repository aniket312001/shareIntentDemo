import 'package:flutter/material.dart';

import '../utils/color_constants.dart';

class PurpleButton extends StatelessWidget {
  final String text;
  final Function onTap;
  const PurpleButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var textSize = MediaQuery.sizeOf(context).height * .018,
        mq = MediaQuery.sizeOf(context);

    return ElevatedButton(
      onPressed: onTap as void Function()?,
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purpleColor,
          fixedSize: Size(mq.width, mq.height * .054),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: TextStyle(
              fontSize: textSize,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
      child: Text(text),
    );
  }
}

class PurpleButtonWithIcon extends StatelessWidget {
  final String text;
  final Icons myIcon;
  final Function onTap;

  const PurpleButtonWithIcon(
      {Key? key, required this.text, required this.onTap, required this.myIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textSize = MediaQuery.sizeOf(context).height * 0.018;
    var mq = MediaQuery.sizeOf(context);

    return ElevatedButton(
      onPressed: onTap as void Function()?,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 0), // No horizontal padding
        minimumSize: Size(double.infinity, 0), // Full-width button
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(text),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding:
                  EdgeInsets.only(left: 16), // Adjust icon padding as needed
              child: Icon(myIcon as IconData?), // Icon as prefix
            ),
          ),
        ],
      ),
    );
  }
}
