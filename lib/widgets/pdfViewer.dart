import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:sno_biz_app/utils/color_constants.dart';

class PDFScreen extends StatefulWidget {
  PDFScreen({required this.name, required this.pdfPath, this.isPath = false}) {}

  String name = "";
  String pdfPath = "";
  bool isPath = false;

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  // final String pdfPath =
  //     'path_to_your_pdf_file.pdf'; // Replace with the actual path to your PDF file

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.isPath == true
          ? PDF().fromPath(widget.pdfPath)
          : PDF().cachedFromUrl(widget.pdfPath,
              placeholder: (progress) => Center(
                  child: CircularProgressIndicator(color: AppColors.blueColor)),
              errorWidget: (error) => Center(
                    child: Icon(Icons.error),
                  )),
    );
  }
}
