import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTest extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final Color color;
  final FontWeight fontWeight;
  final double fontSize;

  const MyTest(
      {Key key,
      this.text,
      this.textAlign,
      this.color,
      this.fontWeight,
      this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          this.text,
          textAlign: this.textAlign != null ? this.textAlign : TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: this.color,
            fontFamily: 'IRANSansMobile',
            fontSize: this.fontSize,
            letterSpacing: 0,
            fontWeight: this.fontWeight,
          ),
        ));
  }
}
