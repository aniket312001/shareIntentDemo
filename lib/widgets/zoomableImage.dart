import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ZoomableImage extends StatelessWidget {
  final dynamic imageUrl;
  late dynamic fit;
  late dynamic height;
  late dynamic width;
  bool isMyUpload = false;
  ZoomableImage(
      {required this.imageUrl,
      required this.height,
      required this.width,
      required this.fit,
      this.isMyUpload = false});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.1, // Minimum scale value
      maxScale: 4.0, // Maximum scale value
      child: isMyUpload == false
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              errorWidget: (context, url, error) => Icon(Icons.error),
              cacheManager: DefaultCacheManager(),
              fit: fit,
              width: width,
              height: height,
            )
          : Image.file(
              File(imageUrl),
              fit: fit,
              width: width,
              height: height,
            ),
    );
  }
}
