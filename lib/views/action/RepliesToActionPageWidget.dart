import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';

import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ViewComment.dart';
import 'package:plasco/custom_modules/cards/ActionReplyCard.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/models/action/answer.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';
import 'LeaveCommentForActionPageWidget.dart';

class RepliesToActionPageWidget extends StatefulWidget {
  final ActionItem action;

  const RepliesToActionPageWidget({Key key, this.action}) : super(key: key);

  @override
  _RepliesToActionPageWidgetState createState() =>
      _RepliesToActionPageWidgetState(this.action);
}

class _RepliesToActionPageWidgetState extends State<RepliesToActionPageWidget> with SingleTickerProviderStateMixin{
  ActionItem action;
  ScrollController _scrollController = ScrollController();
  AnimationController _hideFabAnimController;
  _RepliesToActionPageWidgetState(this.action);

  MyBloc httpBloc = MyBloc();

  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      locator<Web>()
          .post(ActionGetAnswersEvent(httpBloc, this.action,''), context);
    });

    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels > 0) {
          _hideFabAnimController.reverse();
        }
      } else {
        _hideFabAnimController.forward();
      }
    });
  }


  @override
  void dispose() {
    httpBloc.dispose();
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          backgroundColor: ColorPalette.Background,
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: ScaleTransition(
        scale: _hideFabAnimController,
        child:FloatingActionButton(
              backgroundColor: ColorPalette.Yellow1,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LeaveCommentForActionPageWidget(
                          action: action,listHttpBloc: httpBloc,fromAnswersPage:true
                        )));
              },
              tooltip: 'add',
              child: Icon(
                Icons.add,
                color: ColorPalette.White1,
              ))),
          body: SafeArea(
            child: Column(
              children: [
                BarTopAppBarWithSearchWidget(
                  onSearch: (search) {
                    locator<Web>()
                        .post(ActionGetAnswersEvent(httpBloc,this.action, search), context);
                  },
                ),
                Expanded(
                  child: FractionallySizedBox(
                    //alignment: Alignment.centerRight,
                    widthFactor: 1, heightFactor: 1,

                    child: Container(
                      padding: EdgeInsets.only(right: 16, left: 16, top: 16),
                      color: ColorPalette.Background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MyText(
                            text: Strings.RepliesToActionPageWidget_title +
                                '[' +
                                action.id.toString() +
                                ']',
                            textAlign: TextAlign.right,
                            color: ColorPalette.Black1,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          StreamBuilder(
                              stream: httpBloc.stream,
                              builder:
                                  (context, AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  List<Answer> answers =
                                      snapshot.data as List<Answer>;
                                  if (action != null) {
                                    return Expanded(

                                          child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount: answers.length,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    24)),
                                                        onTap: () {
                                                          showModalBottomSheet(
                                                              context: context,
                                                              isScrollControlled:
                                                                  true,
                                                              //enableDrag: false,//enable drag false only for map
                                                              builder:
                                                                  (context) {
                                                                return BottomSheetWidget(
                                                                  title: Strings
                                                                      .BottomSheetWidget_ViewComment_title + '['+ answers[index].id.toString()+']',
                                                                  content:
                                                                      ViewCommentWidget(
                                                                    answer:
                                                                        answers[
                                                                            index],
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom:
                                                                        16.0),
                                                            child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      ColorPalette
                                                                          .White1,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8)),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: ColorPalette.Gray1.withOpacity(
                                                                            0.25),
                                                                        offset: Offset(
                                                                            0,
                                                                            0),
                                                                        blurRadius:
                                                                            4)
                                                                  ],
                                                                  border: Border
                                                                      .all(
                                                                    color: ColorPalette
                                                                        .White1,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        16.0),
                                                                child:
                                                                    ActionReplyCard(
                                                                  answer:
                                                                      answers[
                                                                          index],isFromReplyList:true
                                                                )))));
                                              }),
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
