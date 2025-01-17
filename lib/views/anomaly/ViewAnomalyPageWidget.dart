import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ActionWitLastReply.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ChangeAnomalyStateWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ShowFile.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/models/anomaly/anomaly.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';
import 'package:plasco/views/anomaly/NewActionPageWidget.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class ViewAnomalyPageWidget extends StatefulWidget {
  final int anomalyId;


  const ViewAnomalyPageWidget({Key key, this.anomalyId }) : super(key: key);


  @override
  _ViewAnomalyPageWidgetState createState() =>
      _ViewAnomalyPageWidgetState(this.anomalyId );
}

class _ViewAnomalyPageWidgetState extends State<ViewAnomalyPageWidget> with SingleTickerProviderStateMixin{
  _ViewAnomalyPageWidgetState(this.anomalyId );

  int anomalyId;
  MyBloc httpBloc =  locator<Constants>().viewAnomalyHttpBloc;

  TextEditingController anomalyPageWidgetTitleController =
      TextEditingController();
  TextEditingController anomalyPageWidgetDetailController =
      TextEditingController();
  ScrollController _scrollController = ScrollController();
  AnimationController _hideFabAnimController;
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    Future.delayed(Duration.zero, () {
      locator<Web>()
          .post(AnomalyGetDetailsEvent(httpBloc, this.anomalyId), context);
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
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
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
                  Anomaly item = (snapshot.data
                  as Anomaly);
                  return ScaleTransition(
                      scale: _hideFabAnimController,
                      child: FloatingActionButton(
                      backgroundColor: ColorPalette.Yellow1,
                      onPressed: () {
                        if (locator<Constants>()
                            .getSite_id() !=
                            '' && locator<Constants>().hasAccess(context,AccessEnum.newAction, item.creator,item.user_site))
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => NewActionPageWidget(
                                  anomalyId: this.anomalyId,
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
                                        child: Row(
                                            textDirection: TextDirection.rtl,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                          MyText(
                                            text: Strings
                                                    .ViewAnomalyPageWidget_title +
                                                '[$anomalyId]',
                                            textAlign: TextAlign.center,
                                            color: ColorPalette.Gray1,
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          StreamBuilder(
                                              stream: httpBloc.stream,
                                              builder: (context,
                                                  AsyncSnapshot<dynamic>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  Anomaly item = (snapshot.data
                                                      as Anomaly);
                                                  return item.getLabel();
                                                } else {
                                                  return Container();
                                                }
                                              })
                                        ])),
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

                                    StreamBuilder(
                                        stream: httpBloc.stream,
                                        builder: (context,
                                            AsyncSnapshot<dynamic>
                                            snapshot) {
                                          if (snapshot.hasData) {
                                            Anomaly item = (snapshot.data
                                            as Anomaly);
                                            return   Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  color: ColorPalette.Gray2,
                                                ),
                                                onTap: () async{

                                                  if (locator<Constants>()
                                                      .getSite_id() !=
                                                      '' && locator<Constants>().hasAccess(context,AccessEnum.deleteAnomaly,item.creator,item.user_site )){
                                                    var deleted=await      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        //enableDrag: false,//enable drag false only for map
                                                        builder: (context) {
                                                          return BottomSheetWidget(
                                                            title: Strings
                                                                .ChangeAnomalyState_remove_title,
                                                            content:
                                                            ChangeAnomalyStateWidget(
                                                              changeAnomalyStateEnum:
                                                              ChangeAnomalyStateEnum
                                                                  .Delete,
                                                              anomalyId: this.anomalyId,
                                                            ),
                                                          );
                                                        });
                                                    if(deleted==true){
                                                      await locator<Web>().post(AnomalyGetListEvent(locator<Constants>().anomalyListHttpBloc,''), context);
                                                      Navigator.of(context).pop();
                                                    }
                                                  }


                                                },
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        })
                                   ,
                                  ],
                                )),
                            StreamBuilder(
                                stream: httpBloc.stream,
                                builder:
                                    (context, AsyncSnapshot<dynamic> snapshot) {
                                  if (snapshot.hasData) {
                                    Anomaly item = (snapshot.data as Anomaly);
                                    anomalyPageWidgetTitleController.text =
                                        item.title;
                                    anomalyPageWidgetDetailController.text =
                                        item.description;
                                    return Expanded(
                                      child: SingleChildScrollView( controller: _scrollController,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: ColorPalette.White1,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          child: Column(children: [
                                            item.images != null &&
                                                    item.images.length > 0
                                                ? Material(
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
                                                                      .BottomSheetWidget_ShowFile_title,
                                                                  content: ShowFileWidget(
                                                                      images: item
                                                                          .images),
                                                                );
                                                              });
                                                        },
                                                        child: Container(
                                                            height: 152,
                                                            child: Swiper(
                                                              loop: false,
                                                              viewportFraction:
                                                                  .8,
                                                              itemCount: item
                                                                  .images
                                                                  .length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          8.0),
                                                                  child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(16),
                                                                      child: Container(
                                                                          color: ColorPalette.Gray3,
                                                                          child: ExtendedImage.network(
                                                                            item.images[index],
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            mode:
                                                                                ExtendedImageMode.gesture,
                                                                            initGestureConfigHandler:
                                                                                (ExtendedImageState state) {
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
                                                                          ))),
                                                                );
                                                              },
                                                            ))))
                                                : Container(),
                                            SizedBox(
                                              height: 24,
                                            ),
                                            Row(
                                              textDirection: TextDirection.rtl,
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .start, mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  alignment: Alignment.centerRight,
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(shape: BoxShape.circle),
                                                  child: item.creator.logo != ''
                                                      ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(24.0),
                                                      child: LoadImage.load(
                                                          url: item.creator.logo,
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
                                                  child:  MyText(
                                                  text: item.creator != null
                                                      ? /*Strings
                                                              .ViewActionPageWidget_owner +*/
                                                          item.creator
                                                              .first_name +
                                                          ' ' +
                                                          item.creator.last_name
                                                      : '',
                                                  textAlign: TextAlign.right,
                                                  color: ColorPalette.Gray1,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                )),
                                      Expanded(child: Align(alignment: Alignment.centerLeft,
                                        child:   MyText(
                                                  text: item.getFarsiDate(),
                                                  textAlign: TextAlign.right,
                                                  color: ColorPalette.Gray1,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ))),
                                              ],
                                            ),
                                            SizedBox(height: 24),
                                            MyTextFormField(
                                              enabled: false,
                                              controller:
                                                  anomalyPageWidgetTitleController,
                                              text: Strings
                                                  .ViewActionPageWidget_detail,
                                              hint: Strings
                                                  .ViewActionPageWidget_detail,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                              counterFontSize: 10,
                                              textAlign: TextAlign.right,
                                              keyboardType: TextInputType.text,maxLines: 2,
                                            ),
                                            SizedBox(height: 24),
                                            MyTextFormField(
                                              enabled: false,
                                              controller:
                                                  anomalyPageWidgetDetailController,
                                              text: Strings
                                                  .ViewActionPageWidget_details,
                                              hint: Strings
                                                  .ViewActionPageWidget_details,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                              counterFontSize: 10,
                                              textAlign: TextAlign.right,
                                              keyboardType: TextInputType.text,
                                              maxLines: 4,
                                            ),
                                            SizedBox(height: 24),
                                            Row(
                                              textDirection: TextDirection.rtl,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.shopping_bag,
                                                  size: 16,
                                                  color: ColorPalette.Gray2,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Expanded(child:
                                                MyText(
                                                  text: item.sub_siteCompany
                                                          .organization_name +
                                                      '، ' +
                                                      item.sub_siteCompany
                                                          .project_name,
                                                  textAlign: TextAlign.right,
                                                  color: ColorPalette.Gray1,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                )),
                                              ],
                                            ),
                                            SizedBox(height: 16),
                                            Row(
                                              textDirection: TextDirection.rtl,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 16,
                                                  color: ColorPalette.Gray2,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Expanded(child: MyText(
                                                  text:
                                                      item.location_category_title +
                                                          '، ' +
                                                          item.location_title,
                                                  textAlign: TextAlign.right,
                                                  color: ColorPalette.Gray1,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                )),
                                              ],
                                            ),
                                            SizedBox(height: 24),
                                            Row(
                                              textDirection: TextDirection.rtl,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    MyText(
                                                      text: Strings
                                                          .ViewAnomalyPageWidget_status,
                                                      textAlign:
                                                          TextAlign.right,
                                                      color: ColorPalette.Gray1,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
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
                                                            child: item
                                                                .getLabel()),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        if (item.status ==
                                                            anomalyStatus.open)
                                                          Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              4)),
                                                                  onTap: () async{
                                                                    if (locator<Constants>()
                                                                        .getSite_id() !=
                                                                        '' && locator<Constants>().hasAccess(context,AccessEnum.closeAnomaly, item.creator,item.user_site)){

                                                                      var close=await  showModalBottomSheet(
                                                                          context:
                                                                          context,
                                                                          isScrollControlled:
                                                                          true,
                                                                          //enableDrag: false,//enable drag false only for map
                                                                          builder:
                                                                              (context) {
                                                                            return BottomSheetWidget(
                                                                              title:
                                                                              Strings.ChangeAnomalyState_send,
                                                                              content:
                                                                              ChangeAnomalyStateWidget(changeAnomalyStateEnum: ChangeAnomalyStateEnum.Close, anomalyId: this.anomalyId),
                                                                            );
                                                                          });

                                                                      if(close==true){
                                                                        await locator<Web>().post(AnomalyGetListEvent(locator<Constants>().anomalyListHttpBloc,''), context);
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
                                                                              'بسته',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          color:
                                                                              ColorPalette.Green1,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                        ),
                                                                      ))))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    MyText(
                                                      text: Strings
                                                          .ViewAnomalyPageWidget_category,
                                                      textAlign:
                                                          TextAlign.right,
                                                      color: ColorPalette.Gray1,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: ColorPalette
                                                                  .Gray1
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          4))),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 2.0,
                                                              horizontal: 8.0),
                                                      child: MyText(
                                                        text:
                                                            item.category_name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        color:
                                                            ColorPalette.Gray1,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    MyText(
                                                      text: Strings
                                                          .ViewAnomalyPageWidget_Risk,
                                                      textAlign:
                                                          TextAlign.right,
                                                      color: ColorPalette.Gray1,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    item.getRiskLabel()
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 24),
                                            Row(
                                                textDirection:
                                                    TextDirection.rtl,
                                                children: [
                                                  MyText(
                                                    text: Strings
                                                        .ViewAnomalyPageWidget_actions,
                                                    textAlign: TextAlign.right,
                                                    color: ColorPalette.Black1,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  MyText(
                                                    text: '(' +
                                                        item.actions.length
                                                            .toString() +
                                                        ')',
                                                    textAlign: TextAlign.right,
                                                    color: ColorPalette.Yellow1,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ]),
                                            SizedBox(height: 24),
                                            ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: item.actions.length,
                                                scrollDirection: Axis.vertical,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return getListItem(
                                                      item.actions[index]);
                                                }),
                                          ]),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Expanded(
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: ColorPalette.White1,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator())));
                                  }
                                })
                          ])))),
        ));
  }

  Widget getListItem(ActionItem item) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: ColorPalette.White1,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                    color: ColorPalette.Gray1.withOpacity(0.25),
                    offset: Offset(0, 0),
                    blurRadius: 4)
              ],
              border: Border.all(
                color: ColorPalette.White1,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                MyText(
                  text: item.title,
                  textAlign: TextAlign.right,
                  color: ColorPalette.Black1,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    MyText(
                      text: 'تا ' + item.getFarsiDeadLineDate(),
                      textAlign: TextAlign.right,
                      color: ColorPalette.Gray1,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    Expanded(
                        child: Row(
                      children: [
                        item.getDoneLabel(),
                        SizedBox(
                          width: 8,
                        ),
                        if (item.immediately) item.getImmediatelyLabel(),
                      ],
                    ))
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned.fill(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      //enableDrag: false,//enable drag false only for map
                      builder: (context) {
                        return BottomSheetWidget(
                          title: Strings
                              .BottomSheetWidget_ActionWithLastReply_title,
                          content: ActionWithLastReplyWidget(actionId: item.id),
                        );
                      });
                }),
          ),
        ))
      ],
    );
  }
}
