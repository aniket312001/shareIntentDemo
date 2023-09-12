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
  final Function onTap;

  const PurpleButtonWithIcon({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textSize = MediaQuery.sizeOf(context).height * 0.018;
    var mq = MediaQuery.sizeOf(context);

    return ElevatedButton(
      onPressed: onTap as void Function()?,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purpleColor,
        fixedSize: Size(mq.width, mq.height * 0.052),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4), // Add spacing between text and icon
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
