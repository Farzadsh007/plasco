import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';

class MyTextFormField extends StatefulWidget {
  final String text;
  final FontWeight fontWeight;
  final double fontSize;
  final double counterFontSize;
  final TextAlign textAlign;
  final TextInputType keyboardType;
  final int maxLength;
  final String hint;
  final int maxLines;
  final TextEditingController controller;
  final bool enabled;
final Validator validator;
  const MyTextFormField(
      {Key key,
      this.text,
      this.fontWeight,
      this.fontSize,
      this.counterFontSize,
      this.textAlign,
      this.keyboardType,
      this.maxLength,
      this.hint,
      this.maxLines,
      this.controller,
      this.enabled,
      this.validator})
      : super(key: key);

  @override
  _MyTextFormFieldState createState() => _MyTextFormFieldState(
      this.text,
      this.fontWeight,
      this.fontSize,
      this.counterFontSize,
      this.textAlign,
      this.keyboardType,
      this.maxLength,
      this.hint,
      this.maxLines,
      this.controller,
      this.enabled,
      this.validator);
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  String text;
  FontWeight fontWeight;
  double fontSize;
  double counterFontSize;
  TextAlign textAlign;
  TextInputType keyboardType;
  int maxLength;
  String hint;
  int maxLines;
  TextEditingController controller;
  bool enabled;
  Validator validator;
  _MyTextFormFieldState(
      this.text,
      this.fontWeight,
      this.fontSize,
      this.counterFontSize,
      this.textAlign,
      this.keyboardType,
      this.maxLength,
      this.hint,
      this.maxLines,
      this.controller,
      this.enabled,
      this.validator);

  bool _focused = false;
bool _hasError=false;
String _error='';
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Focus(
            onFocusChange: (hasFocus) {
              // When you focus on input email, you need to notify the color change into the widget.
              setState(() => _focused = hasFocus);
            },
            child: TextFormField(
              controller: controller,
              enabled: this.enabled != null ? this.enabled : true,
              cursorHeight: 20,
              maxLines: this.maxLines != null ? this.maxLines : 1,
              textAlign: this.textAlign,
              keyboardType: this.keyboardType,
              maxLength: this.maxLength, validator: (text) {
                if(this.validator==null){
                  return null;
                }else{
                  if(this.validator.hasError(text)){
                    setState(() =>  _hasError=true);
                     _error=this.validator.getError();
                     return '';
                  }else{
                    setState(() =>  _hasError=false);
                    return null;
                  }
                }

            },
              style: TextStyle(
                  color: ColorPalette.Black1,
                  fontFamily: 'IRANSansMobile',
                  fontSize: this.fontSize,
                  letterSpacing: 0,
                  fontWeight: this.fontWeight,
                  height: this.maxLines != null ? 2 : 1),
              decoration: InputDecoration(

                labelStyle: TextStyle(
                  color: _hasError?ColorPalette.Red1 : _focused ? ColorPalette.Yellow1 : ColorPalette.Gray1,
                  fontFamily: 'IRANSansMobile',
                  fontSize: this.fontSize,
                  letterSpacing: 0,
                  fontWeight: this.fontWeight,
                  height: 1,
                ),
                hintStyle: TextStyle(
                    color: ColorPalette.Gray2,
                    fontFamily: 'IRANSansMobile',
                    fontSize: this.fontSize,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: this.fontWeight,
                    height: 1),
                counterStyle: TextStyle(
                    color: ColorPalette.Gray1,
                    fontFamily: 'IRANSansMobile',
                    fontSize: this.counterFontSize,
                    letterSpacing: 0,
                    fontWeight: this.fontWeight,
                    height: 1),

                floatingLabelBehavior: FloatingLabelBehavior.always,
                // border: OutlineInputBorder(),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: ColorPalette.Gray2,
                      width: 1.0,
                    )),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: ColorPalette.Gray2,
                      width: 1.0,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: ColorPalette.Yellow1,
                      width: 1.0,
                    )),

                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: ColorPalette.Red1,
                      width: 1.0,
                    )),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: ColorPalette.Red1,
                      width: 1.0,
                    )),
                labelText: _hasError?_error: this.text,
                hintText: this.hint,
                contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              ),
              autofocus: false,
            )));
  }
}
