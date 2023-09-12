import 'package:flutter/material.dart';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';
import 'package:flutter/services.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';

shareImage(BuildContext context, url, localizations) async {
  try {
    CustomLoader.showProgressBar(context);
    final ByteData imageData =
        await NetworkAssetBundle(Uri.parse(url)).load('');
    Navigator.pop(context);
    await Share.file(
      'Document',
      'document.jpg',
      imageData.buffer.asUint8List(),
      'image/jpeg',
      text: 'Check out this image!',
    );
  } catch (e) {
    showCustomToast(
        context: context,
        message: '${localizations!.translate("Error sharing image")}');
    print('Error sharing image: $e');
  }
}

sharePdf(BuildContext context, url, localizations) async {
  try {
    CustomLoader.showProgressBar(context);
    final ByteData pdfData = await NetworkAssetBundle(Uri.parse(url)).load('');
    Navigator.pop(context);
    await Share.file(
      'Document PDF',
      'document.pdf',
      pdfData.buffer.asUint8List(),
      'application/pdf',
      text: 'Check out this PDF!',
    );
  } catch (e) {
    showCustomToast(
        context: context,
        message: '${localizations!.translate("Error sharing PDF")}');
    print('Error sharing PDF: $e');
  }
}
