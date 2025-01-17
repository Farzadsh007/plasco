import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadImage {
  static Widget load(
      {String url,
      BoxFit fit,
      @optionalTypeArgs double height,
      @optionalTypeArgs double width}) {
    return Image.network(url, fit: fit, height: height, width: width,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes
              : null,
        ),
      );
    });
  }
}
