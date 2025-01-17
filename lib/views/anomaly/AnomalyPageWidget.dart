import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/anomaly/anomaly.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';
import 'NewAnomalyPageWidget.dart';
import 'ViewAnomalyPageWidget.dart';

class AnomalyPageWidget extends StatefulWidget {

  @override
  _AnomalyPageWidgetState createState() => _AnomalyPageWidgetState();
}

class _AnomalyPageWidgetState extends State<AnomalyPageWidget> with SingleTickerProviderStateMixin{
  MyBloc httpBloc =locator<Constants>().anomalyListHttpBloc;
  ScrollController _scrollController = ScrollController();
  AnimationController _hideFabAnimController;
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      locator<Web>().post(AnomalyGetListEvent(httpBloc,''), context);
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
  //  httpBloc.dispose();
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
                  if ((snapshot.data as List<Anomaly>).length > 0) {
                    return ScaleTransition(
                        scale: _hideFabAnimController,
                        child:FloatingActionButton(
                        backgroundColor: ColorPalette.Yellow1,
                        onPressed: () {
                          if (locator<Constants>()
                              .getSite_id() !=
                              '' && locator<Constants>().hasAccess(context,AccessEnum.newAnomaly, null,null))
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NewAnomalyPageWidget()));
                        },
                        tooltip: 'add',
                        child: Icon(
                          Icons.add,
                          color: ColorPalette.White1,
                        )));
                  } else {
                    return Container();
                  }
                } else
                  return Container();
              }),
          body: SafeArea(
            child: Column(
              children: [
                BarTopAppBarWithSearchWidget(
                  onSearch: (search) {
                    locator<Web>()
                        .post(AnomalyGetListEvent(httpBloc,  search), context);
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
                            text: Strings.AnomalyPageWidget_title,
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
                                  List<Anomaly> list =
                                      (snapshot.data as List<Anomaly>);
                                  if (list.length > 0) {
                                    return Expanded(

                                          child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount: list.length,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return getListItem(list[index]);
                                              }),
                                    );
                                  } else {
                                    return Expanded(
                                        child: FractionallySizedBox(
                                            //alignment: Alignment.centerRight,
                                            widthFactor: 1,
                                            heightFactor: 1,
                                            child: Container(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/vectors/Icons/AnomalyGrayScale.svg',
                                                  width: 56,
                                                  height: 56,
                                                ),
                                                SizedBox(
                                                  height: 24,
                                                ),
                                                MyText(
                                                  text: Strings
                                                      .AnomalyPageWidget_no_anomaly,
                                                  textAlign: TextAlign.center,
                                                  color: ColorPalette.Gray2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                SizedBox(
                                                  height: 24,
                                                ),
                                                FloatingActionButton(
                                                    backgroundColor:
                                                        ColorPalette.Yellow1,
                                                    onPressed: () {
                                                      if (locator<Constants>()
                                                          .getSite_id() !=
                                                          '' && locator<Constants>().hasAccess(context,AccessEnum.newAnomaly, null,null))
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  NewAnomalyPageWidget()));
                                                    },
                                                    tooltip: 'add',
                                                    child: Icon(
                                                      Icons.add,
                                                      color:
                                                          ColorPalette.White1,
                                                    ))
                                              ],
                                            ))));
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

  Widget getListItem(Anomaly item) {
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerRight,
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              color: ColorPalette.Gray3,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: (item.images != null && item.images.length > 0)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: LoadImage.load(
                                      url: item.images[0],
                                      height: 64,
                                      width: 64,
                                      fit: BoxFit.cover))
                              : Center(
                                  child: Icon(
                                  Icons.image_outlined,
                                  size: 24,
                                  color: ColorPalette.Gray2,
                                )),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: MyText(
                            text: item.title,
                            textAlign: TextAlign.right,
                            color: ColorPalette.Black1,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,maxLines: 2,
                          ),
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: item.getFarsiDate(),
                          textAlign: TextAlign.right,
                          color: ColorPalette.Gray1,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),

                        Row( textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          item.getSubSiteLabel(),
                            SizedBox(width: 8,),
                          item.getLabel()
                        ],)
                      ],
                    )
                  ],
                ))),
        Positioned.fill(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ViewAnomalyPageWidget( anomalyId: item.id)));
                }),
          ),
        ))
      ],
    );
  }
}
