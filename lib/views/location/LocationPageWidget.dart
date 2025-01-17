import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/NewLocationCategory.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/location/location_category.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';
import 'NewLocationPageWidget.dart';

class LocationPageWidget extends StatefulWidget {
  @override
  _LocationPageWidgetState createState() => _LocationPageWidgetState();
}

class _LocationPageWidgetState extends State<LocationPageWidget> with SingleTickerProviderStateMixin {
  MyBloc httpBloc = locator<Constants>().locationsHttpBloc;
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
      locator<Web>().post(LocationGetListEvent(httpBloc,''), context);
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
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    // httpBloc.dispose();
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
                  if ((snapshot.data as List<LocationCategory>).length > 0) {
                    return ScaleTransition(
                        scale: _hideFabAnimController,
                        child:FloatingActionButton(
                            backgroundColor: ColorPalette.Yellow1,
                            onPressed: () {
                              if (locator<Constants>()
                                  .getSite_id() !=
                                  '' && locator<Constants>().hasAccess(context,AccessEnum.addLocation, null,null))
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  //enableDrag: false,//enable drag false only for map
                                  builder: (context) {
                                    return BottomSheetWidget(
                                      title: Strings
                                          .BottomSheetWidget_NewLocationCategoryWidget_title,
                                      content: NewLocationCategoryWidget(),
                                    );
                                  });
                            },
                            tooltip: 'add',
                            child: Icon(
                              Icons.add,
                              color: ColorPalette.White1,
                            )))
                         ;
                  } else {
                    return Container();
                  }
                } else
                  return Container();
              }),
          body: SafeArea(
            child: Column(
              children: [
                BarTopAppBarWithSearchWidget(    onSearch: (search) {
                  locator<Web>()
                      .post(LocationGetListEvent(httpBloc,  search), context);
                },),
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
                            text: Strings.LocationPageWidget_title,
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
                                  List<LocationCategory> list =
                                      (snapshot.data as List<LocationCategory>);
                                  if (list.length > 0) {
                                    return Expanded(
                                      child: ListView.builder(
                                          controller: _scrollController,
                                          itemCount: list.length,
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (BuildContext context,
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
                                                  'assets/vectors/Icons/LocationGrayScale.svg',
                                                  width: 56,
                                                  height: 56,
                                                ),
                                                SizedBox(
                                                  height: 24,
                                                ),
                                                MyText(
                                                  text: Strings
                                                      .LocationPageWidget_no_location,
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
                                                          '' && locator<Constants>().hasAccess(context,AccessEnum.addLocation, null,null))
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          //enableDrag: false,//enable drag false only for map
                                                          builder: (context) {
                                                            return BottomSheetWidget(
                                                              title: Strings
                                                                  .BottomSheetWidget_NewLocationCategoryWidget_title,
                                                              content:
                                                                  NewLocationCategoryWidget(),
                                                            );
                                                          });
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
                              })

                          /* Expanded(
                              child: FractionallySizedBox(
                                  //alignment: Alignment.centerRight,
                                  widthFactor: 1,
                                  heightFactor: 1,
                                  child: Container(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/vectors/Icons/LocationGrayScale.svg',
                                        width: 56,
                                        height: 56,
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                      MyText(
                                        text:
                                            Strings.PersonPageWidget_no_person,
                                        textAlign: TextAlign.center,
                                        color: ColorPalette.Gray2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                      FloatingActionButton(
                                          backgroundColor: ColorPalette.Yellow1,
                                          onPressed: () {
                                           Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NewPersonPageWidget(

                    )));},
                                          tooltip: 'add',
                                          child: Icon(
                                            Icons.add,
                                            color: ColorPalette.White1,
                                          ))
                                    ],
                                  ))))*/
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

  Widget getListItem(LocationCategory item) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.rtl,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerRight,
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Center(
                                  child: SvgPicture.asset(
                                      'assets/vectors/Icons/LocationGrayScale.svg',
                                      width: 24,
                                      height: 24))),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 8.0, left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                MyText(
                                  text: item.title,
                                  textAlign: TextAlign.right,
                                  color: ColorPalette.Black1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                                SizedBox(height: 4),
                                Flexible(
                                  child: MyText(
                                    text: item.locationsTitle(),
                                    textAlign: TextAlign.right,
                                    color: ColorPalette.Black1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        item.getLocationCountLabel()
                      ],
                    ),
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
                      builder: (context) => NewLocationPageWidget(
                            locationCategory: item,
                          )));
                }),
          ),
        ))
      ],
    );
  }
}
