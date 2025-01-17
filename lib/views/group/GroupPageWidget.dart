import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/NewGroup.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/group/group.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';
import 'EditGroupPageWidget.dart';

class GroupPageWidget extends StatefulWidget {
  @override
  _GroupPageWidgetState createState() => _GroupPageWidgetState();
}

class _GroupPageWidgetState extends State<GroupPageWidget> with SingleTickerProviderStateMixin{
  MyBloc httpBloc = MyBloc();
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
      locator<Web>().post(GroupGetListEvent(httpBloc,''), context);
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
          floatingActionButton: StreamBuilder(
              stream: httpBloc.stream,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  if ((snapshot.data as List<Group>).length > 0) {
                    return ScaleTransition(
                        scale: _hideFabAnimController,
                        child:FloatingActionButton(
                        backgroundColor: ColorPalette.Yellow1,
                        onPressed: () {
                          if (locator<Constants>()
                              .getSite_id() !=
                              '' && locator<Constants>().hasAccess(context,AccessEnum.addGroup, null,null))
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              //enableDrag: false,//enable drag false only for map
                              builder: (context) {
                                return BottomSheetWidget(
                                  title: Strings
                                      .BottomSheetWidget_NewGroupWidget_title,
                                  content: NewGroupWidget(
                                    listHttpBloc: this.httpBloc,
                                  ),
                                );
                              });
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
                BarTopAppBarWithSearchWidget( onSearch: (search) {
                  locator<Web>()
                      .post(GroupGetListEvent(httpBloc,  search), context);
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
                            text: Strings.GroupPageWidget_title,
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
                                  List<Group> list =
                                      (snapshot.data as List<Group>);
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
                                                  'assets/vectors/Icons/PersonGrayScale.svg',
                                                  width: 56,
                                                  height: 56,
                                                ),
                                                SizedBox(
                                                  height: 24,
                                                ),
                                                MyText(
                                                  text: Strings
                                                      .GroupPageWidget_no_group,
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
                                                          '' && locator<Constants>().hasAccess(context,AccessEnum.addGroup, null,null))
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          //enableDrag: false,//enable drag false only for map
                                                          builder: (context) {
                                                            return BottomSheetWidget(
                                                              title: Strings
                                                                  .BottomSheetWidget_NewGroupWidget_title,
                                                              content:
                                                                  NewGroupWidget(),
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

                          /*   Expanded(
                            child: SingleChildScrollView(
                                child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: 5,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return getListItem(index);
                                    })),
                          )*/
                          ,

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
                                        'assets/vectors/Icons/PersonGrayScale.svg',
                                        width: 56,
                                        height: 56,
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                      MyText(
                                        text:
                                            Strings.GroupPageWidget_no_group,
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

  Widget getListItem(Group item) {
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
                      text: item.name,
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
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: item.total_members.toString() + ' عضو',
                          textAlign: TextAlign.right,
                          color: ColorPalette.Gray1,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                        Stack(
                            clipBehavior: Clip.none,
                            children: item.getGroupImage())
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
                      builder: (context) => EditGroupPageWidget(
                          id: item.id, listHttpBloc: httpBloc)));
                }),
          ),
        ))
      ],
    );
  }
}
