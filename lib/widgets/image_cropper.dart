import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';

class Image_Cropper {
  static cropFile(dynamic _pickedFile) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: _pickedFile!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(title: 'Crop'),
      ],
    );

    return cropped;
  }
}
