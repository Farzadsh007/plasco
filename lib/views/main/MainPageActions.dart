import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ActionWitLastReply.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import 'package:shamsi_date/extensions.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class MainPageActions extends StatefulWidget {
  const MainPageActions({Key key}) : super(key: key);

  @override
  _MainPageActionsState createState() => _MainPageActionsState();
}

class _MainPageActionsState extends State<MainPageActions>
    with AutomaticKeepAliveClientMixin<MainPageActions> {
  MyBloc dateBarHttpBloc = MyBloc();
  MyBloc actionsHttpBloc = MyBloc();

  var _weekDay = [
    {'id': 1, 'title': 'ش'},
    {'id': 2, 'title': 'ی'},
    {'id': 3, 'title': 'د'},
    {'id': 4, 'title': 'س'},
    {'id': 5, 'title': 'چ'},
    {'id': 6, 'title': 'پ'},
    {'id': 7, 'title': 'ج'}
  ];

  final _selectedIndexStreamController = StreamController<int>.broadcast();

  StreamSink<int> get selectedIndexSink => _selectedIndexStreamController.sink;

  Stream<int> get streamSelectedIndex => _selectedIndexStreamController.stream;
  MyBloc memberShipHttpBloc = locator<Constants>().memberShipHttpBloc;

  @override
  void initState() {
    super.initState();

    dateBarHttpBloc.stream.listen((event) {
      if (event !=null) {

          DateTime now = event;

        // first load page, show actions for first day
        if (locator<Constants>()
            .getSite_id() !=
            '') {
          Future.delayed(
              Duration.zero, () {
            selectedIndexSink
                .add(0);
            locator<Web>().post(
                ActionGetListEvent(
                    actionsHttpBloc,
                    now.toLocal()),
                context);

          });
        }
      }
    });
    memberShipHttpBloc.stream.listen((event) {
      if(event!=null){
        locator<Web>().post(GetServerTimeEvent(dateBarHttpBloc), context);
      }

    });
  /*  Future.delayed(Duration.zero, () {
      locator<Web>().post(GetServerTimeEvent(dateBarHttpBloc), context);
    });*/


  }

  @override
  void dispose() {
    dateBarHttpBloc.dispose();
    actionsHttpBloc.dispose();
    _selectedIndexStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Container(
            height: 55,
            child: StreamBuilder(
                stream: dateBarHttpBloc.stream,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    DateTime now = (snapshot.data as DateTime).toLocal();
                    Jalali jalali = Jalali.fromDateTime(now);

                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: GridView.builder(
                        itemCount: 14,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 55 / 32, crossAxisCount: 7),
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: index > 6
                                  ? Container(
                                      height: 15,
                                      child: MyText(
                                        text: jalali.weekDay + index - 7 <= 7
                                            ? _weekDay.firstWhere((element) =>
                                                element['id'] ==
                                                jalali.weekDay +
                                                    index -
                                                    7)['title']
                                            : _weekDay.firstWhere((element) =>
                                                element['id'] ==
                                                jalali.weekDay +
                                                    index -
                                                    14)['title'],
                                        textAlign: TextAlign.center,
                                        color: index == 7
                                            ? ColorPalette.Yellow1
                                            : ColorPalette.Black1,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                  : Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32)),
                                          onTap: () {
                                            if (locator<Constants>()
                                                    .getSite_id() !=
                                                '') {
                                              locator<Web>().post(
                                                  ActionGetListEvent(
                                                      actionsHttpBloc,
                                                      now.add(Duration(
                                                          days: index))),
                                                  context);

                                              selectedIndexSink.add(index);
                                            }
                                          },
                                          child: StreamBuilder(
                                              stream: streamSelectedIndex,
                                              initialData: 7,
                                              builder: (context,
                                                  AsyncSnapshot<int> snapshot) {
                                                if (snapshot.hasData) {

                                                  return Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: snapshot.data ==
                                                                index
                                                            ? ColorPalette
                                                                .Yellow1
                                                            : Colors
                                                                .transparent,
                                                        border: Border.all(
                                                          color: index == 0
                                                              ? ColorPalette
                                                                  .Yellow1
                                                              : Colors
                                                                  .transparent,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: MyText(
                                                          text:
                                                           Jalali.fromDateTime(now.add(Duration(days: index)) ).day
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          color:
                                                              snapshot.data ==
                                                                      index
                                                                  ? ColorPalette
                                                                      .White1
                                                                  : ColorPalette
                                                                      .Black1,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ));
                                                } else {
                                                  return Container();
                                                }
                                              }))));
                        },
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })),
        SizedBox(
          height: 24,
        ),
   /*     Container(
            alignment: Alignment.centerRight,
            child: MyText(
              text: Strings.MainPageWidget_actions,
              textAlign: TextAlign.right,
              color: ColorPalette.Black1,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        SizedBox(
          height: 24,
        ),*/
        StreamBuilder(
            stream: memberShipHttpBloc.stream,
            builder: (context, AsyncSnapshot<dynamic> snapshotMemberShip) {
              if (snapshotMemberShip.hasData) {

                return StreamBuilder(
                    stream: actionsHttpBloc.stream,
                    builder: (context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        List<ActionItem> list =
                            (snapshot.data as List<ActionItem>);
                        if (list.length > 0) {
                          return Expanded(
                            child: SingleChildScrollView(
                                child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return getListItem(list[index]);
                                    })),
                          );
                        } else {
                          return Expanded(
                              child: FractionallySizedBox(
                                  //alignment: Alignment.centerRight,
                                  widthFactor: 1,
                                  heightFactor: 1,
                                  child: Container(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/vectors/Icons/ActionGrayScale.svg',
                                        width: 56,
                                        height: 56,
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                      MyText(
                                        text: Strings
                                            .MainPageWidget_actions_no_actions,
                                        textAlign: TextAlign.center,
                                        color: ColorPalette.Gray2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                    ],
                                  ))));
                        }
                      } else {
                        return Expanded(
                            child: FractionallySizedBox(
                                //alignment: Alignment.centerRight,
                                widthFactor: 1,
                                heightFactor: 1,
                                child: Container(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/vectors/Icons/ActionGrayScale.svg',
                                      width: 56,
                                      height: 56,
                                    ),
                                    SizedBox(
                                      height: 24,
                                    ),
                                    MyText(
                                      text: (snapshotMemberShip
                                                      .data as DropDownItem)
                                                  .id !=
                                              -1
                                          ? Strings
                                              .MainPageWidget_actions_no_actions
                                          : Strings
                                              .MainPageWidget_actions_no_actions_no_site_id,
                                      textAlign: TextAlign.center,
                                      color: ColorPalette.Gray2,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    SizedBox(
                                      height: 24,
                                    ),
                                  ],
                                ))));
                      }
                    });
              } else {
                return Expanded(
                    child: FractionallySizedBox(
                        //alignment: Alignment.centerRight,
                        widthFactor: 1,
                        heightFactor: 1,
                        child: Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/vectors/Icons/ActionGrayScale.svg',
                              width: 56,
                              height: 56,
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            MyText(
                              text: Strings
                                  .MainPageWidget_actions_no_actions_no_site_id,
                              textAlign: TextAlign.center,
                              color: ColorPalette.Gray2,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(
                              height: 24,
                            ),
                          ],
                        ))));
              }
            }),
        SizedBox(
          height: 16,
        ),
      ],
    );
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
                      color:item.expired? ColorPalette.Red1:ColorPalette.Gray1,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    Expanded(
                        child: Row(
                      children: [
                        if (item.immediately) item.getImmediatelyLabel(),
                        if (item.immediately)  SizedBox(
                          width: 8,
                        ),
                        item.getSubSiteLabel(),
                        SizedBox(width: 8,),
                        item.getDoneLabel()
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
