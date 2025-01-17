import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ApproveAction.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ViewComment.dart';
import 'package:plasco/custom_modules/cards/ActionReplyCard.dart';
import 'package:plasco/custom_modules/inputs/MyDropDownFormField.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';
import 'LeaveCommentForActionPageWidget.dart';
import 'RepliesToActionPageWidget.dart';

class ViewActionPageWidget extends StatefulWidget {
  final int actionId;

  const ViewActionPageWidget({Key key, this.actionId }) : super(key: key);

  @override
  _ViewActionPageWidgetState createState() =>
      _ViewActionPageWidgetState(this.actionId );
}

class _ViewActionPageWidgetState extends State<ViewActionPageWidget>  with SingleTickerProviderStateMixin{
  int actionId;

  _ViewActionPageWidgetState(this.actionId );

  MyBloc httpBloc = locator<Constants>().actionListHttpBloc;

  TextEditingController viewActionPageWidgetTitleController =
      TextEditingController();
  TextEditingController viewActionPageWidgetDetailController =
      TextEditingController();
  ScrollController _scrollController = ScrollController();
  AnimationController _hideFabAnimController;
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    Future.delayed(Duration.zero, () {
      locator<Web>()
          .post(ActionGetDetailsEvent(httpBloc, this.actionId), context);
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
    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
   // httpBloc.dispose();
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
          floatingActionButton: StreamBuilder(
              stream: httpBloc.stream,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  ActionItem action = snapshot.data as ActionItem;
                  if (action != null &&
                      action.answers != null &&
                      action.answers.total > 0) {
                    return ScaleTransition(
                        scale: _hideFabAnimController,
                        child:FloatingActionButton(
                        backgroundColor: ColorPalette.Yellow1,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  LeaveCommentForActionPageWidget(
                                    action: action,listHttpBloc: httpBloc,fromAnswersPage: false,
                                  )));
                        },
                        tooltip: 'add',
                        child: Icon(
                          Icons.add,
                          color: ColorPalette.White1,
                        )));
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              }),
          body: SafeArea(
              child: Container(
                  color: Colors.transparent,

                  // height: height /2,
                  child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.White1,
                      ),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
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
                                        child: StreamBuilder(
                                            stream: httpBloc.stream,
                                            builder: (context,
                                                AsyncSnapshot<dynamic>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                ActionItem action =
                                                    snapshot.data as ActionItem;
                                                if (action != null) {
                                                  viewActionPageWidgetTitleController
                                                      .text = action.title;

                                                  viewActionPageWidgetDetailController
                                                          .text =
                                                      action.description;

                                                  return Row(textDirection: TextDirection.rtl,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      MyText(
                                                        text: Strings
                                                                .ViewActionPageWidget_title +
                                                            '[' +
                                                            action.id
                                                                .toString() +
                                                            ']',
                                                        textAlign:
                                                            TextAlign.center,
                                                        color:
                                                            ColorPalette.Gray1,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      if (action.immediately)
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                      if (action.immediately)
                                                        action
                                                            .getImmediatelyLabel()
                                                      ,


                                                        SizedBox(
                                                          width: 8,
                                                        ),

                                                        action
                                                            .getDoneLabel()
                                                      ,

                                                    ],
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              } else {
                                                return CircularProgressIndicator();
                                              }
                                            })),
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
                              child: SingleChildScrollView(controller: _scrollController,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorPalette.White1,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: StreamBuilder(
                                      stream: httpBloc.stream,
                                      builder: (context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        if (snapshot.hasData) {
                                          ActionItem action =
                                              snapshot.data as ActionItem;
                                          if (action != null) {
                                            return Column(children: [
                                              Row(
                                                textDirection:
                                                    TextDirection.rtl,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start, mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.centerRight,
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(shape: BoxShape.circle),
                                                    child: action.creator.logo != ''
                                                        ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(24.0),
                                                        child: LoadImage.load(
                                                            url: action.creator.logo,
                                                            height: 24,
                                                            width: 24,
                                                            fit: BoxFit.fitHeight))
                                                        : CrossPlatformSvg.asset(
                                                        assetPath: 'assets/vectors/Icons/AvatarPlaceHolder.svg',
                                                        height: 24,
                                                        width: 24,
                                                        fit: BoxFit.fitHeight),
                                                  ),

                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                    child: MyText(
                                                      text: /*Strings
                                                              .ViewActionPageWidget_owner +*/
                                                          action.creator
                                                              .first_name +
                                                          ' ' +
                                                          action
                                                              .creator.last_name,
                                                      textAlign: TextAlign.right,
                                                      color: ColorPalette.Gray1,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                 Expanded(child: Align(alignment: Alignment.centerLeft,
                                                    child: MyText(
                                                      text: action
                                                          .getFarsiCreateDate(),
                                                      textAlign: TextAlign.right,
                                                      color: ColorPalette.Gray1,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  )),
                                                ],
                                              ),
                                              SizedBox(height: 24),
                                              MyTextFormField(
                                                controller:
                                                    viewActionPageWidgetTitleController,
                                                enabled: false,
                                                text: Strings
                                                    .ViewActionPageWidget_detail,
                                                hint: Strings
                                                    .ViewActionPageWidget_detail,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                counterFontSize: 10,
                                                textAlign: TextAlign.right,
                                                keyboardType:
                                                    TextInputType.text,maxLines: 2,
                                              ),
                                              SizedBox(height: 24),
                                              MyTextFormField(
                                                controller:
                                                    viewActionPageWidgetDetailController,
                                                enabled: false,
                                                text: Strings
                                                    .ViewActionPageWidget_details,
                                                hint: Strings
                                                    .ViewActionPageWidget_details,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                counterFontSize: 10,
                                                textAlign: TextAlign.right,
                                                keyboardType:
                                                    TextInputType.text,
                                                maxLines: 4,
                                              ),
                                              SizedBox(height: 24),
                                              MyDropDownFormField(
                                                selected: DropDownItem(
                                                    action.site.id,
                                                    action
                                                        .site.organization_name,
                                                    null),
                                                text: Strings
                                                    .ViewActionPageWidget_factory,
                                                hint: Strings
                                                    .ViewActionPageWidget_choose,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                bottomSheetTitle: '',
                                              ),
                                              SizedBox(height: 24),
                                              MyDropDownFormField(
                                                selected: DropDownItem(
                                                    action.group,
                                                    action.group_title,
                                                    null),
                                                text: Strings
                                                    .ViewActionPageWidget_group,
                                                hint: Strings
                                                    .ViewActionPageWidget_choose,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                bottomSheetTitle: '',
                                              ),
                                              SizedBox(height: 24),
                                              Row(
                                                textDirection:
                                                    TextDirection.rtl,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  MyText(
                                                    text: Strings
                                                        .ViewActionPageWidget_status,
                                                    textAlign: TextAlign.right,
                                                    color: ColorPalette.Gray1,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  MyText(
                                                    text: Strings
                                                        .ViewActionPageWidget_deadline,
                                                    textAlign: TextAlign.right,
                                                    color: ColorPalette.Gray1,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        children: [
                                                          Container(
                                                              padding:
                                                              EdgeInsets.all(
                                                                  5),
                                                              decoration:
                                                              BoxDecoration(
                                                                  border:
                                                                  Border
                                                                      .all(
                                                                    color: ColorPalette
                                                                        .Yellow1,
                                                                    width: 2,
                                                                  ),
                                                                  borderRadius:
                                                                  BorderRadius.all(Radius.circular(
                                                                      8))),
                                                              child:action.getDoneLabel()),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          if (action.status ==
                                                              actionStatus
                                                                  .not_complete)
                                                            Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8)),
                                                                  onTap: ()async {

                                                                    if (locator<Constants>()
                                                                        .getSite_id() !=
                                                                        '' && locator<Constants>().hasAccess(context,AccessEnum.closeAction, action.creator,null)){
                                                                      var close=await      showModalBottomSheet(
                                                                          context:
                                                                          context,
                                                                          isScrollControlled:
                                                                          true,
                                                                          //enableDrag: false,//enable drag false only for map
                                                                          builder:
                                                                              (context) {
                                                                            return BottomSheetWidget(
                                                                              title: Strings.ApproveActionWidget_prefix +
                                                                                  '[' +
                                                                                  action.id.toString() +
                                                                                  ']',
                                                                              content:
                                                                              ApproveActionWidget(action: action),
                                                                            );
                                                                          });

                                                                      if(close==true && action.anomaly!=-1){
                                                                        await locator<Web>()
                                                                            .post(AnomalyGetDetailsEvent(locator<Constants>().viewAnomalyHttpBloc, action.anomaly), context);
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                    }


                                                                  },
                                                                  child: Container(
                                                                      padding: EdgeInsets.all(5),
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                            color:
                                                                                ColorPalette.Gray3,
                                                                            width:
                                                                                2,
                                                                          ),
                                                                          borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                      child: Container(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                2),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                ColorPalette.Green1.withOpacity(0.1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(4))),
                                                                        child:
                                                                            MyText(
                                                                          text:
                                                                              Strings.ViewActionPageWidget_approve,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          color:
                                                                              ColorPalette.Green1,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                        ),
                                                                      ))),
                                                            )
                                                        ]),
                                                    if (action.immediately)
                                                      action
                                                          .getImmediatelyLabel(),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2),
                                                      decoration: BoxDecoration(
                                                          color: ColorPalette
                                                                  .Gray1
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          4))),
                                                      child: MyText(
                                                        text: action
                                                            .getFarsiDeadLineDate(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        color:
                                                            ColorPalette.Gray1,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    )
                                                  ]),
                                              SizedBox(height: 24),
                                              Row(
                                                textDirection:
                                                    TextDirection.rtl,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  MyText(
                                                    text: Strings
                                                        .ViewActionPageWidget_comments,
                                                    textAlign: TextAlign.right,
                                                    color: ColorPalette.Black1,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  /* MyText(
                                                    text: '(' +
                                                        action.answers.total
                                                            .toString() +
                                                        ')',
                                                    textAlign: TextAlign.right,
                                                    color: ColorPalette.Yellow1,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),*/
                                                ],
                                              ),
                                              if (action.answers.total > 0)
                                                SizedBox(height: 24),
                                              if (action.answers.total > 1)
                                                Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      RepliesToActionPageWidget(
                                                                          action:
                                                                              action)));
                                                        },
                                                        child: MyText(
                                                          text: Strings
                                                                  .ViewActionPageWidget_show_all_comments +
                                                              '(' +
                                                              action
                                                                  .answers.total
                                                                  .toString() +
                                                              ')',
                                                          textAlign:
                                                              TextAlign.center,
                                                          color: ColorPalette
                                                              .Yellow1,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ))),
                                              if (action.answers.total > 1)
                                                SizedBox(height: 16),
                                              ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      action.answers.total > 0
                                                          ? 1
                                                          : 0,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            24)),
                                                            onTap: () {
                                                              showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  isScrollControlled:
                                                                      true,
                                                                  //enableDrag: false,//enable drag false only for map
                                                                  builder:
                                                                      (context) {
                                                                    return BottomSheetWidget(
                                                                      title: Strings
                                                                              .BottomSheetWidget_ViewComment_title +
                                                                          '[' +
                                                                          action
                                                                              .answers
                                                                              .id
                                                                              .toString() +
                                                                          ']',
                                                                      content: ViewCommentWidget(
                                                                          answer:
                                                                              action.answers),
                                                                    );
                                                                  });
                                                            },
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            16.0),
                                                                child:
                                                                    Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              ColorPalette.White1,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(8)),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                                color: ColorPalette.Gray1.withOpacity(0.25),
                                                                                offset: Offset(0, 0),
                                                                                blurRadius: 4)
                                                                          ],
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                ColorPalette.White1,
                                                                            width:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                16.0),
                                                                        child:
                                                                            ActionReplyCard(
                                                                          answer:
                                                                              action.answers,isFromReplyList: false,
                                                                        )))));
                                                  }),
                                              if (action.answers.total ==0)
                                                FloatingActionButton(
                                                    backgroundColor:
                                                        ColorPalette.Yellow1,
                                                    onPressed: () {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LeaveCommentForActionPageWidget(
                                                                      action:
                                                                          action,listHttpBloc: httpBloc,fromAnswersPage: false,)));
                                                    },
                                                    tooltip: 'add',
                                                    child: Icon(
                                                      Icons.add,
                                                      color:
                                                          ColorPalette.White1,
                                                    )),
                                            ]);
                                          } else {
                                            return Container();
                                          }
                                        } else {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      }),
                                ),
                              ),
                            )
                          ])))),
        ));
  }
}
