import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/color_palette.dart';

import '../strings.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: ColorPalette.White1,
        body: Stack(children: [
          Center(
              child: SvgPicture.asset("assets/vectors/logo.svg",
                  height: math.min(width, height) / 3, fit: BoxFit.fitHeight)),
          (Container(
              padding: EdgeInsets.only(bottom: 32),
              alignment: Alignment.bottomCenter,
              child: Text(
                Strings.appVersionLabel + ' ' + Strings.appVersionCode,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: ColorPalette.Gray1,
                  fontFamily: 'IRANSansMobile',
                  fontSize: 12,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                ),
              )))
        ]));
  }
}
