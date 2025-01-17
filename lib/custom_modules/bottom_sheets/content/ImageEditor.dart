import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:image_painter/image_painter.dart';
import 'package:plasco/blocs/ChooseFileBloc.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';

import '../../PleaseWaitDialog.dart';

class ImageEditorWidget extends StatefulWidget {
  ImageEditorWidget({Key key, this.file, this.chooseFileBloc, this.enableEdit})
      : super(key: key);

  final Uint8List file;
  final ChooseFileBloc chooseFileBloc;
  final bool enableEdit;

  @override
  _ImageEditorWidgetState createState() =>
      _ImageEditorWidgetState(this.file, this.chooseFileBloc, this.enableEdit);
}

class _ImageEditorWidgetState extends State<ImageEditorWidget> {
  _ImageEditorWidgetState(this.file, this.chooseFileBloc, this.enableEdit);

  bool enableEdit;
  Uint8List file;
  ChooseFileBloc chooseFileBloc;
  ExtendedImage extendedImage;
  bool paintType = true;
  List<bool> isSelected;
  List<Offset> points = [];
  Path drawPath;
  ValueNotifier<List<Offset>> notifier;
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  var _imageKey = GlobalKey<ImagePainterState>();
  final _key = GlobalKey<ScaffoldState>();
  final _toggleStreamController = StreamController<List<bool>>();

  StreamSink<List<bool>> get toggle_sink => _toggleStreamController.sink;

  Stream<List<bool>> get stream__toggle => _toggleStreamController.stream;

  int _currentIndex = 0;

  PageController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifier = ValueNotifier<List<Offset>>(points);
    isSelected = enableEdit ? [true, false] : [true];
    _pageController = PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _toggleStreamController.close();
    _pageController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var saveButton = MyButton(
      text: 'ذخیره سازی',
      buttonFill: ButtonFillStyle.Yellow,
      onPressed: () async {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return PleaseWaitDialog();
            });

        if (chooseFileBloc != null) {
          if (enableEdit) {
            Uint8List _file = await _imageKey.currentState.exportImage();

            ImageEditorOption option = ImageEditorOption();

            var decodedImage = await decodeImageFromList(_file);
            var _w=decodedImage.width;
            var _h=decodedImage.height;
            var _scale=1;
            if (_w>800 || _h>800){
              _scale=(max(_w,_h)/800).round();
            }
            if(_scale>1){
              ScaleOption scaleOption=ScaleOption((_w/_scale).round() , (_h/_scale).round() );
              option.addOption(scaleOption);
            }

            option.outputFormat = OutputFormat.jpeg(40);
            _file = await ImageEditor.editImage(
              image: _file,
              imageEditorOption: option,
            );

            Navigator.pop(context);
            chooseFileBloc.addFile(_file);
          } else {
            ImageEditorOption option = ImageEditorOption();
            option.addOption(ScaleOption(128, 128));
            option.outputFormat = OutputFormat.jpeg(40);
         var   _file = await ImageEditor.editImage(
              image: file,
              imageEditorOption: option,
            );
            Navigator.pop(context);
            chooseFileBloc.addFile(_file);
          }
        }
        Navigator.of(context).pop();
      },
    );

    return Scaffold(
      backgroundColor: ColorPalette.Background,
      bottomNavigationBar: !enableEdit
          ? null
          : BottomNavigationBar(
              backgroundColor: ColorPalette.White2,
              unselectedItemColor: ColorPalette.Gray1,
              iconSize: 24,
              selectedItemColor: ColorPalette.Yellow1,
              unselectedLabelStyle: TextStyle(
                fontFamily: 'IRANSansMobile',
                color: ColorPalette.Gray1,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              selectedLabelStyle: TextStyle(
                fontFamily: 'IRANSansMobile',
                color: ColorPalette.Yellow1,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              currentIndex: _currentIndex,
              onTap: (currentIndex) {
                setState(() {
                  _currentIndex = currentIndex;
                });

                /*  _pageController.animateToPage(_currentIndex,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);*/
              },
              items: [
                if (enableEdit)
                  BottomNavigationBarItem(
                      label: 'ویرایش', icon: Icon(Icons.edit)),
                BottomNavigationBarItem(label: 'برش', icon: Icon(Icons.crop)),

              ],
            ),
      body: SafeArea(
        child: Container(
            color: Colors.transparent,

            // height: height /2,
            child: Container(
                decoration: BoxDecoration(
                  color: ColorPalette.White1,
                ),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                        bottom:
                            BorderSide(width: 1, color: ColorPalette.Black3),
                      )),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child:
                          // SizedBox(width : 268),
                          Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(child: saveButton),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              child: Icon(
                                Icons.close,
                                color: ColorPalette.Gray2,
                              ),
                              onTap: () {
                                Navigator.pop(context, true);
                              },
                            ),
                          ),
                        ],
                      )),
                  Expanded(
                      child: StreamBuilder(
                          stream: stream__toggle,
                          initialData: [true, false],
                          builder:
                              (context, AsyncSnapshot<List<bool>> snapshot) {
                            if (snapshot.hasData) {
                              return IndexedStack(
                                index: _currentIndex,
                                children: <Widget>[

                                  if (enableEdit)
                                    ImagePainter.memory(
                                      file,
                                      key: _imageKey,
                                      scalable: false,
                                      initialPaintMode: PaintMode.line,
                                    )
                                  , Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                            child: ExtendedImage.memory(
                                              file,
                                              fit: BoxFit.contain,
                                              mode: ExtendedImageMode.editor,
                                              extendedImageEditorKey: editorKey,
                                              initEditorConfigHandler: (state) {
                                                return EditorConfig(
                                                  maxScale: 8.0,
                                                  cropAspectRatio: enableEdit
                                                      ? CropAspectRatios.custom
                                                      : CropAspectRatios.ratio1_1,
                                                  cropRectPadding:
                                                  EdgeInsets.all(20.0),
                                                  hitTestSize: 20.0,
                                                );
                                              },
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: MyButton(
                                                text: 'بریدن',
                                                buttonFill:
                                                ButtonFillStyle.Yellow,
                                                onPressed: () async {
                                                  final Rect cropRect =
                                                  editorKey.currentState
                                                      .getCropRect();

                                                  ImageEditorOption option =
                                                  ImageEditorOption();

                                                  option.addOption(
                                                      ClipOption.fromRect(
                                                          cropRect));
                                                  option.outputFormat =
                                                      OutputFormat.jpeg(40);
                                                  this.file = await ImageEditor
                                                      .editImage(
                                                    image: file,
                                                    imageEditorOption: option,
                                                  );
                                                  _imageKey = GlobalKey<
                                                      ImagePainterState>();
                                                  toggle_sink
                                                      .add(this.isSelected);
                                                },
                                              )),
                                        )
                                      ]),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          }))
                ]))), /*shape: CustomShapeBorder()*/
      ),
    );
  }
}
