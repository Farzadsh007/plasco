import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CrossPlatformSvg {
  static Widget asset(
      {String assetPath,
      BoxFit fit,
      @optionalTypeArgs double height,
      @optionalTypeArgs double width}) {
    if (kIsWeb) {
      return SvgPicture.asset(
        assetPath,
        fit: fit,
        height: height,
        width: width,
      );
    } else {
      return SvgPicture.asset(
        assetPath,
        fit: fit,
        height: height,
        width: width,
      );
    }
  }
}
