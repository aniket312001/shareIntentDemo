import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
// import 'package:pdf_render/pdf_render.dart';
import 'package:pdfx/pdfx.dart';

import 'package:http/http.dart' as http;

import '../utils/color_constants.dart';

class PdfPreviewWidget extends StatelessWidget {
  final String pdfLink;
  bool fromGallery = false;

  PdfPreviewWidget({required this.pdfLink, this.fromGallery = false});

  loadPdfImage(String pdfUrl) async {
    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode == 200) {
      final pdfDocument = await PdfDocument.openData(response.bodyBytes);
      final pdfPage = await pdfDocument.getPage(1);
      final pdfImage = await pdfPage.render(
        width: pdfPage.width.toDouble(),
        height: pdfPage.height.toDouble(),
      );
      return pdfImage!.bytes;
      // final pdfImage = MemoryImage(pdfPageImage.bytes);

      // return pdfPageImage;
    } else {
      print('Error loading PDF: Status code ${response.statusCode}');
    }
  }

  loadPdfImagefromPath(String pdf) async {
    final pdfDocument = await PdfDocument.openFile(pdf);
    final pdfPage = await pdfDocument.getPage(1);
    final pdfImage = await pdfPage.render(
      width: pdfPage.width.toDouble(),
      height: pdfPage.height.toDouble(),
    );
    return pdfImage!.bytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future:
          fromGallery ? loadPdfImagefromPath(pdfLink) : loadPdfImage(pdfLink),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.blueColor));
        } else if (snapshot.hasError) {
          log(snapshot.error.toString());
          return Center(
            child: Icon(Icons.error),
          );
        } else if (snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: AppColors.white,
                image: DecorationImage(
                  image: MemoryImage(snapshot.data!),
                  fit: BoxFit.cover,
                )),
            // child: Center(
            //   child: Icon(
            //     Icons.picture_as_pdf,
            //     size: 30,
            //     color: AppColors.purpleColor,
            //   ),
            // ),
          );
        } else {
          return Container(
            child: Center(
              child: Icon(Icons.error),
            ),
          );
        }
      },
    );
  }
}
