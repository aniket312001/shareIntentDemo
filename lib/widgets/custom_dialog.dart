import 'package:flutter/material.dart';

import '../utils/color_constants.dart';

void showCustomDialog(context, String text, String text1, Color iconColor,
    Function onTapText, Function onTapText1) {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;

  final Widget cameraOption = _buildOption(
    icon: Icons.camera,
    label: text,
    color: iconColor,
  );

  final Widget galleryOption = _buildOption(
    icon: Icons.image,
    label: text1,
    color: iconColor,
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        title: Container(
          width: screenWidth,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 4),
          decoration: const BoxDecoration(
            color: AppColors.purpleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Choose',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
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
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * .1,
            vertical: screenHeight * .03,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                      onTap: onTapText as void Function()?,
                      child: cameraOption),
                  GestureDetector(
                      onTap: onTapText1 as void Function()?,
                      child: galleryOption),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildOption({
  required IconData icon,
  required String label,
  required Color color,
}) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    ],
  );
}
