import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plasco/blocs/ChooseFileBloc.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ImageEditor.dart';

import '../../../strings.dart';
import '../../inputs/MyText.dart';

class ChooseFileWidget extends StatefulWidget {
  ChooseFileWidget({Key key, this.chooseFileBloc, this.enableEdit})
      : super(key: key);

  final ChooseFileBloc chooseFileBloc;
  final bool enableEdit;

  @override
  _ChooseFileWidgetState createState() =>
      _ChooseFileWidgetState(this.chooseFileBloc, this.enableEdit);
}

class _ChooseFileWidgetState extends State<ChooseFileWidget> {
  _ChooseFileWidgetState(this.chooseFileBloc, this.enableEdit);

  ChooseFileBloc chooseFileBloc;
  bool enableEdit;

  @override
  Widget build(BuildContext context) {

    return Row(
      textDirection: TextDirection.rtl,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: FractionallySizedBox(
          //alignment: Alignment.centerRight,
          widthFactor: 1,
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () async {
                    final ImagePicker _picker = ImagePicker();
                    // Pick an image

                    final XFile photo = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 40);

                    Uint8List file = await photo.readAsBytes();
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ImageEditorWidget(
                              file: file,
                              chooseFileBloc: chooseFileBloc,
                              enableEdit: this.enableEdit,
                            )));
                  },
                  child: Column(
                    children: [
                      Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: ColorPalette.Yellow1,
                            borderRadius: BorderRadius.circular(56),
                          ),
                          child: Icon(
                            Icons.image,
                            color: ColorPalette.White1,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: MyText(
                          text: Strings.BottomSheetWidget_ChooseFile_gallery,
                          textAlign: TextAlign.center,
                          color: ColorPalette.Black2,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ))),
        )),
        Expanded(
            child: FractionallySizedBox(
          //alignment: Alignment.centerRight,
          widthFactor: 1,
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () async {
                    final ImagePicker _picker = ImagePicker();
                    // Pick an image

                    final XFile photo = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 40);

                    Uint8List file = await photo.readAsBytes();
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ImageEditorWidget(
                              file: file,
                              chooseFileBloc: chooseFileBloc,
                              enableEdit: this.enableEdit,
                            )));
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ColorPalette.Green1,
                          borderRadius: BorderRadius.circular(56),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: ColorPalette.White1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: MyText(
                          text: Strings.BottomSheetWidget_ChooseFile_camera,
                          textAlign: TextAlign.center,
                          color: ColorPalette.Black2,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ))),
        ))
      ],
    );
  }
}
