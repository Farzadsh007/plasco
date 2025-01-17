import 'dart:async';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plasco/blocs/ChooseFileBloc.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ChooseFile.dart';
import 'package:plasco/custom_modules/inputs/ChoosePhoto.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/models/action/answer.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class LeaveCommentForActionPageWidget extends StatefulWidget {
  final ActionItem action;
  final MyBloc listHttpBloc;
  final bool fromAnswersPage;
  const LeaveCommentForActionPageWidget({Key key, this.action,this.listHttpBloc,this.fromAnswersPage})
      : super(key: key);

  @override
  _LeaveCommentForActionPageWidgetState createState() =>
      _LeaveCommentForActionPageWidgetState(this.action,this.listHttpBloc,this.fromAnswersPage);
}

class _LeaveCommentForActionPageWidgetState
    extends State<LeaveCommentForActionPageWidget> {
  _LeaveCommentForActionPageWidgetState(this.action,this.listHttpBloc,this.fromAnswersPage);

  ActionItem action;

  Answer answer = Answer();
  List<Uint8List> files = [];
  TextEditingController leaveCommentForActionPageWidgetTitleController =
      TextEditingController();
  final ChooseFileBloc chooseFileBloc = ChooseFileBloc();
  MyBloc httpBloc = MyBloc();
  MyBloc listHttpBloc;
  bool fromAnswersPage;
  final _refreshFilesStreamController = StreamController<bool>.broadcast();

  StreamSink<bool> get refreshFilesSink => _refreshFilesStreamController.sink;

  Stream<bool> get streamRefreshFiles => _refreshFilesStreamController.stream;
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIOverlays([]);

    httpBloc.stream.listen((event) async{
      if (event == true) {
     if(listHttpBloc!=null && fromAnswersPage!=null)
       {
         if(fromAnswersPage==true){
           locator<Web>()
               .post(ActionGetAnswersEvent(listHttpBloc, this.action,''), context);
         }else{
           await locator<Web>()
               .post(ActionGetDetailsEvent(listHttpBloc, this.action.id), context);
         }
       }
        Navigator.of(context).pop();
      }
    });

    chooseFileBloc.streamChooseFile.listen((event) {
      this.files.add(event);
      refreshFilesSink.add(true);
    });
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    chooseFileBloc.dispose();
    httpBloc.dispose();
    _refreshFilesStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          backgroundColor: ColorPalette.Background,
          body:Form(
        key: _formKey,child: SafeArea(
              child: Container(
                  color: Colors.transparent,

                  // height: height /2,
                  child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.White1,
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        Container(
                            decoration: BoxDecoration(
                                border: Border(
                              bottom: BorderSide(
                                  width: 1, color: ColorPalette.Black3),
                            )),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child:
                                // SizedBox(width : 268),
                                Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                    child: MyText(
                                  text: Strings
                                      .LeaveCommentForActionPageWidget_title,
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
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorPalette.White1,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Column(children: [
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: MyText(
                                      text: this.action.title,
                                      textAlign: TextAlign.right,
                                      color: ColorPalette.Black1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      maxLines: 2,
                                    )),
                                SizedBox(height: 24),
                                MyTextFormField(
                                  controller:
                                      leaveCommentForActionPageWidgetTitleController,
                                  text: Strings
                                      .LeaveCommentForActionPageWidget_reply_to_action,
                                  hint: Strings
                                      .LeaveCommentForActionPageWidget_reply_to_action,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.text,
                                  maxLength: 400,
                                  maxLines: 4,validator: AnswerValidator(5),
                                ),
                                SizedBox(height: 24),
                                Center(
                                    child: Column(
                                  children: [
                                    SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: StreamBuilder(
                                            stream: streamRefreshFiles,
                                            builder: (context,
                                                AsyncSnapshot<bool> snapshot) {
                                              List<Widget> children = [];

                                              if (files.length < 2) {
                                                children
                                                    .add(addNewImageWidget());
                                              }
                                              for (Uint8List file in files) {
                                                children
                                                    .add(addImageWidget(file));
                                              }

                                              return Row(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  children: children);
                                            })),
                                    SizedBox(height: 16),
                                    MyText(
                                      text: Strings
                                          .LeaveCommentForActionPageWidget_max_pictures,
                                      textAlign: TextAlign.center,
                                      color: ColorPalette.Gray1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    )
                                  ],
                                ))
                              ]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: FractionallySizedBox(
                                  //alignment: Alignment.centerRight,
                                  widthFactor: 1,
                                  child: MyButton(
                                      text: Strings
                                          .LeaveCommentForActionPageWidget_cancel,
                                      buttonFill: ButtonFillStyle.White,
                                      onPressed: () {
                                        Navigator.pop(context, true);
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
                                        text: Strings
                                            .LeaveCommentForActionPageWidget_send,
                                        buttonFill: ButtonFillStyle.Yellow,
                                        onPressed: () {
                                          if( _formKey.currentState.validate()){
                                            this.answer.title =
                                                leaveCommentForActionPageWidgetTitleController
                                                    .text;
                                            this.answer.action_id =
                                                this.action.id;
                                            this.answer.files = this.files;
                                            locator<Web>().post(
                                                ActionAddAnswerEvent(
                                                    httpBloc, this.answer),
                                                context);
                                          }

                                        })),
                              )
                            ],
                          ),
                        )
                      ]))))),
        ));
  }

  addNewImageWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChoosePhoto(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              //enableDrag: false,//enable drag false only for map
              builder: (context) {
                return BottomSheetWidget(
                  title: Strings.BottomSheetWidget_ChooseFile_title,
                  content: ChooseFileWidget(
                    chooseFileBloc: chooseFileBloc,
                    enableEdit: true,
                  ),
                );
              });
        },
      ),
    );
  }

  addImageWidget(Uint8List file) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            //  width: 136,
            height: 136,
            child: Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ExtendedImage.memory(
                      file,
                      fit: BoxFit.cover,
                      mode: ExtendedImageMode.gesture,
                      initGestureConfigHandler: (ExtendedImageState state) {
                        return GestureConfig(
                          //you must set inPageView true if you want to use ExtendedImageGesturePageView
                          inPageView: true,
                          initialScale: 1.0,
                          minScale: 1.0,
                          maxScale: 5.0,
                          animationMaxScale: 6.0,
                          initialAlignment: InitialAlignment.center,
                        );
                      },
                    )),
                Positioned(
                    left: 0,
                    top: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            this.files.remove(file);

                            refreshFilesSink.add(true);
                          },
                          child: Container(
                              clipBehavior: Clip.antiAlias,
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: CrossPlatformSvg.asset(
                                  assetPath: 'assets/vectors/Icons/WithBG.svg',
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.fitHeight))),
                    ))
              ],
            )));
  }
}
