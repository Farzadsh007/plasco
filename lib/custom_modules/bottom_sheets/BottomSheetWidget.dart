import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';

class BottomSheetWidget extends StatefulWidget {
  BottomSheetWidget({Key key, this.title, this.content, this.dismissible})
      : super(key: key);
  final String title;
  final Widget content;
  final bool dismissible;

  @override
  _BottomSheetWidgetState createState() =>
      _BottomSheetWidgetState(this.title, this.content, this.dismissible);
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  _BottomSheetWidgetState(this.title, this.content, this.dismissible);

  String title;
  Widget content;
  bool dismissible;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
        color: Colors.transparent,

        // height: height /2,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                /*bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),*/
              ),
              color: ColorPalette.White1,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(width: 1, color: ColorPalette.Black3),
                  )),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child:
                      // SizedBox(width : 268),
                      Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                          child: MyText(
                        text: this.title,
                        textAlign: TextAlign.center,
                        color: ColorPalette.Gray1,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      )),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          child: Icon(
                            Icons.close,
                            color: ColorPalette.Gray2,
                          ),
                          onTap: () {
                            if (dismissible == null || dismissible == true)
                              Navigator.pop(context, true);
                          },
                        ),
                      ),
                    ],
                  )),
              Container(
                  decoration: BoxDecoration(
                    color: ColorPalette.White1,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: this.content)
            ])));
  }
}

enum DialogButtons { YesNo, Ok, Cancel }
