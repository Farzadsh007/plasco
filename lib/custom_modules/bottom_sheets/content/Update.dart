import 'dart:io';

//import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/models/update/update.dart';
import 'package:plasco/services/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../inputs/MyText.dart';

class UpdateWidget extends StatefulWidget {
  final Update update;

  UpdateWidget({Key key, this.update}) : super(key: key);

  @override
  _UpdateWidgetState createState() => _UpdateWidgetState(this.update);
}

class _UpdateWidgetState extends State<UpdateWidget> {
  _UpdateWidgetState(this.update);

  Update update;
  Future<bool> _willPopCallback() async {

      return update.needs_update != 'yes';

  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child:Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            alignment: Alignment.centerRight,
            child: MyText(
              text: Strings.BottomSheetWidget_Update_details,
              color: ColorPalette.Black1,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            )),
        SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: FractionallySizedBox(
                  //alignment: Alignment.centerRight,
                  widthFactor: 1,
                  child: MyButton(
                      text: Strings.BottomSheetWidget_Update_cancel,
                      buttonFill: ButtonFillStyle.White,
                      onPressed: () {
                        if (update.needs_update != 'yes')
                          Navigator.of(context).pop();
                      }),
                ),
              ),
              SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: FractionallySizedBox(
                    //alignment: Alignment.centerRight,
                    widthFactor: 1,
                    child: MyButton(
                        text: Strings.BottomSheetWidget_Update_send,
                        buttonFill: ButtonFillStyle.Yellow,
                        onPressed: () async {
                          if (update.needs_update != 'yes')
                            Navigator.of(context).pop();

                        //  var dir = await _findLocalPath();
                          // await Urll('file://firebasestorage.googleapis.com/v0/b/pixz-92afa.appspot.com/o/PostVideos%2F0xb159d1586689312896%2F0xb159d15866893128961586846213136_video?alt=media&token=af6b076b-405e-4763-abb4-69a83f92d15b'); // your URL
                          await launch(locator<Constants>().ImageServerIP+ update.file);
                          if (update.needs_update == 'yes') {
                            //close app
                            SystemNavigator.pop();
                          }
                          /* await FlutterDownloader.enqueue(
                            url: 'https://www.dl.farsroid.com/ap/Duolingo-Full-5.28.3(FarsRoid.Com).apk',
                            savedDir: dir,
                            showNotification: true, // show download progress in status bar (for Android)
                            openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                          );*/
                        })),
              )
            ],
          ),
        )
      ],
    ));
  }

  /*Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath =
            await ExtStorage.getExternalStoragePublicDirectory(
                ExtStorage.DIRECTORY_DOWNLOADS);
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }*/
}
