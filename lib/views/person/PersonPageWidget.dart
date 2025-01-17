import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ApproveJoinCompany.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/NewPerson.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/Person.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class PersonPageWidget extends StatefulWidget {
  @override
  _PersonPageWidgetState createState() => _PersonPageWidgetState();
}

class _PersonPageWidgetState extends State<PersonPageWidget> with SingleTickerProviderStateMixin{
  MyBloc httpBloc = locator<Constants>().personListHttpBloc;
  MyBloc rejectHttpBloc=MyBloc();
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
      locator<Web>().post(PersonGetListEvent(httpBloc,''), context);
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

    rejectHttpBloc.stream.listen((event) async{
      if (event == true) {
        await locator<Web>().post(
            PersonGetListEvent(httpBloc, ''),
            context);


      }
    });
  }

  @override
  void dispose() {
   // httpBloc.dispose();
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    rejectHttpBloc.dispose();
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
                  if ((snapshot.data as List<User>).length > 0) {
                    return ScaleTransition(
                        scale: _hideFabAnimController,
                        child:FloatingActionButton(
                        backgroundColor: ColorPalette.Yellow1,
                        onPressed: () {
                          if (locator<Constants>()
                              .getSite_id() !=
                              '' && locator<Constants>().hasAccess(context,AccessEnum.addPerson, null,null))
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              //enableDrag: false,//enable drag false only for map
                              builder: (context) {
                                return BottomSheetWidget(
                                  title:
                                      Strings.BottomSheetWidget_NewPerson_title,
                                  content: NewPersonWidget( ),
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
                BarTopAppBarWithSearchWidget(
                  onSearch: (search) {
                    locator<Web>()
                        .post(PersonGetListEvent(httpBloc,  search), context);
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
                            text: Strings.PersonPageWidget_title,
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
                                  List<User> list =
                                      (snapshot.data as List<User>);
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
                                                      .PersonPageWidget_no_person,
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
                                                          '' && locator<Constants>().hasAccess(context,AccessEnum.addPerson, null,null))
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          //enableDrag: false,//enable drag false only for map
                                                          builder: (context) {
                                                            return BottomSheetWidget(
                                                              title: Strings
                                                                  .BottomSheetWidget_NewPerson_title,
                                                              content:
                                                                  NewPersonWidget( ),
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
                              }),

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

  Widget getListItem(User item) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerRight,
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: item.logo != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(64.0),
                              child: LoadImage.load(
                                  url: item.logo,
                                  height: 64,
                                  width: 64,
                                  fit: BoxFit.fitHeight))
                          : CrossPlatformSvg.asset(
                              assetPath:
                                  'assets/vectors/Icons/AvatarPlaceHolder.svg',
                              height: 64,
                              width: 64,
                              fit: BoxFit.fitHeight),
                    ),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              textDirection: TextDirection.rtl,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    MyText(
                                      text: item.first_name +
                                          ' ' +
                                          item.last_name,
                                      textAlign: TextAlign.right,
                                      color: ColorPalette.Black1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    SizedBox(height: 4),
                                    MyText(
                                      text: item.job_title_name,
                                      textAlign: TextAlign.right,
                                      color: ColorPalette.Gray2,
                                      fontSize: 11,
                                      fontWeight: FontWeight.normal,
                                    )
                                  ],
                                ),
                              ])),
                    ),
                    if(item.status!=null && item.status!=companyStatus.Pending)
                    item.getLabel()
                    ,item.getRequestLabel(onApprove:(){
                      if (locator<Constants>()
                          .getSite_id() !=
                          '' && locator<Constants>().hasAccess(context,AccessEnum.approveButtons, null,null))
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          //enableDrag: false,//enable drag false only for map
                          builder: (context) {
                            return BottomSheetWidget(
                              title: Strings
                                  .BottomSheetWidget__ApproveJoinCompany_title,
                              content: ApproveJoinCompanyWidget(user: item,),
                            );
                          });
                    },
                    onReject:(){
                      if (locator<Constants>()
                          .getSite_id() !=
                          '' && locator<Constants>().hasAccess(context,AccessEnum.approveButtons, null,null))
                      locator<Web>().post(
                          PersonRemoveRequestEvent(
                              rejectHttpBloc, item),
                          context);
                    }
                    )
                  ],
                ))),
        Positioned.fill(
            child: item.status==companyStatus.Pending?Container(): Padding(
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
                          title: Strings.BottomSheetWidget_Person_title,
                          content: PersonWidget(
                            user: item,
                          ),
                        );
                      });
                }),
          ),
        ))
      ],
    );
  }
}
