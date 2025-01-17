import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:plasco/color_palette.dart';

class SnackBarWidget {
  SnackBarWidget._();

  static buildErrorSnackBar(BuildContext context, String message) {
    double width = MediaQuery.of(context).size.width;
    showFlash(
        context: context,
        duration: Duration(seconds: 3),
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Flash(
              controller: controller,
              backgroundColor: ColorPalette.Black1.withOpacity(0.8),
              borderRadius: BorderRadius.all(Radius.circular(8)),
              position: FlashPosition.bottom,
              behavior: FlashBehavior.fixed,
              child: FlashBar(
                content: Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: ColorPalette.Gray2,
                      ),
                      onTap: () {
                        controller.dismiss();
                      },
                    ),
                    Container(
                        alignment: Alignment.centerRight,
                        height: 18,
                        width: width * 3 / 4,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("$message",
                                textAlign: TextAlign.right,textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    color: ColorPalette.Gray3,
                                    fontFamily: 'IRANSansMobile',
                                    fontSize: 14,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1)))),
                  ],
                )),
              ),
            ),
          );
        });
/*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Icon(
                Icons.close,
                color: ColorPalette.Gray2,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            Text("$message",
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: ColorPalette.Gray3,
                    fontFamily: 'IRANSansMobile',
                    fontSize: 14,
                    letterSpacing:
                        0 */ /*percentages not used in flutter. defaulting to zero*/ /*,
                    fontWeight: FontWeight.normal,
                    height: 1)),
          ],
        ),
      ),
    );*/
  }
}
