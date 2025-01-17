import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/Account.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ChooseCompany.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/NewPerson.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/Update.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/update/update.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';
import 'package:plasco/views/anomaly/NewAnomalyPageWidget.dart';
import 'package:plasco/views/main/MainPageActions.dart';
import 'package:plasco/views/main/MainPagePlans.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class MainPageWidget extends StatefulWidget {
  @override
  _MainPageWidgetState createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget>
    with SingleTickerProviderStateMixin {
  MyBloc memberShipHttpBloc = locator<Constants>().memberShipHttpBloc;
  MyBloc profileHttpBloc = locator<Constants>().profileHttpBloc;
  MyBloc updateHttpBloc = MyBloc();
  MyBloc fireBaseHttpBloc = MyBloc();
  Future<bool> _willPopCallback() async {
    if (_addMenuIsClicked) {
      onEndIconPress();
      _animateIconController.animateToStart();
      return false;
    } else {
      return true;
    }
  }

  bool _addMenuIsClicked = false;
  AnimateIconController _animateIconController;

  int _currentIndex = 1;
  final List<Widget> _tabList = [
    MainPagePlans(),
    MainPageActions(),
  ];

  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(
      initialPage: _currentIndex,
    );

    _animateIconController = AnimateIconController();

    updateHttpBloc.stream.listen((event) async {

      if (event is Update) {
        Update _update = event;
        if (_update.needs_update != 'no') {

             showModalBottomSheet(
                context: context,
                isDismissible: _update.needs_update != 'yes',
                isScrollControlled: true,enableDrag: false,
                //enableDrag: false,//enable drag false only for map
                builder: (context) {
                  return BottomSheetWidget(
                    dismissible: _update.needs_update != 'yes',
                    title: Strings.BottomSheetWidget_Update_title,
                    content: UpdateWidget(update: _update),
                  );
                });


        }
      }
    });


    Future.delayed(Duration.zero, () {

      locator<Web>().post(AuthGetMemberShipEvent(memberShipHttpBloc), context);
      locator<Web>().post(AuthGetProfileEvent(profileHttpBloc, null), context);
      locator<Web>().post(FireBaseEvent(fireBaseHttpBloc), context);
    });

    Future.delayed( Duration(seconds: 3), () {
      locator<Web>().post(CheckUpdateEvent(updateHttpBloc), context);

    });
    locator<Constants>()
        .checkPermission(PermissionDialogEnum.location)
        .then((value) {
      if (value == false) {
        locator<Constants>().requestPermission(PermissionDialogEnum.location);
      }
    });


    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    updateHttpBloc.dispose();
    fireBaseHttpBloc.dispose();
    //  memberShipHttpBloc.dispose();

    // profileHttpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          backgroundColor: ColorPalette.Background,
          body: SafeArea(
              child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    color: ColorPalette.White2,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        StreamBuilder(
                            stream: profileHttpBloc.stream,
                            builder:
                                (context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasData) {
                                User user = snapshot.data as User;
                                return Material(
                                    color: Colors.transparent,
                                    shape: CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            //enableDrag: false,//enable drag false only for map
                                            builder: (context) {
                                              return BottomSheetWidget(
                                                title: Strings
                                                    .BottomSheetWidget_Account_title,
                                                content: AccountWidget(),
                                              );
                                            });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: user.image != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(56.0),
                                                child: Image.memory(user.image,
                                                    height: 56,
                                                    width: 56,
                                                    fit: BoxFit.fitHeight))
                                            : user.logo != ''
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            56.0),
                                                    child: LoadImage.load(
                                                        url: user.logo,
                                                        height: 56,
                                                        width: 56,
                                                        fit: BoxFit.fitHeight))
                                                : CrossPlatformSvg.asset(
                                                    assetPath:
                                                        'assets/vectors/Icons/AvatarPlaceHolder.svg',
                                                    height: 56,
                                                    width: 56,
                                                    fit: BoxFit.fitHeight),
                                      ),
                                    ));
                              } else {
                                return Container(
                                  alignment: Alignment.center,
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: CrossPlatformSvg.asset(
                                      assetPath:
                                          'assets/vectors/Icons/AvatarPlaceHolder.svg',
                                      height: 56,
                                      width: 56,
                                      fit: BoxFit.fitHeight),
                                );
                              }
                            }),
                        SizedBox(
                          width: 8.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StreamBuilder(
                                stream: profileHttpBloc.stream,
                                builder:
                                    (context, AsyncSnapshot<dynamic> snapshot) {
                                  if (snapshot.hasData) {
                                    User user = snapshot.data as User;
                                    return MyText(
                                      text: user.first_name +
                                          ' ' +
                                          user.last_name,
                                      textAlign: TextAlign.right,
                                      color: ColorPalette.Black1,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                            SizedBox(
                              height: 9.0,
                            ),
                            Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24)),
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          //enableDrag: false,//enable drag false only for map
                                          builder: (context) {
                                            int _id = locator<Constants>()
                                                        .getSite_id() !=
                                                    ''
                                                ? int.parse(locator<Constants>()
                                                    .getSite_id())
                                                : -1;
                                            String _name = locator<Constants>()
                                                .getSite_name();

                                            return BottomSheetWidget(
                                              title: Strings
                                                  .BottomSheetWidget_ChooseCompany_title,
                                              content: ChooseCompanyWidget(
                                                selectedItemBloc:
                                                    memberShipHttpBloc,
                                                selected: DropDownItem(
                                                    _id, _name, null),
                                              ),
                                            );
                                          });
                                    },
                                    child: StreamBuilder(
                                        stream: memberShipHttpBloc.stream,
                                        builder: (context,
                                            AsyncSnapshot<dynamic> snapshot) {
                                          if (snapshot.hasData) {
                                            DropDownItem item =
                                                snapshot.data as DropDownItem;

                                            return Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 2.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(24)),
                                                  border: Border.all(
                                                    color: item.id == -1
                                                        ? ColorPalette.Yellow3
                                                        : ColorPalette.Gray1
                                                            .withOpacity(0.1),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  children: [
                                                    MyText(
                                                      text: item.value,
                                                      textAlign:
                                                          TextAlign.right,
                                                      color: item.id == -1
                                                          ? ColorPalette.Yellow1
                                                          : ColorPalette.Black2,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 8.0),
                                                        child: Icon(
                                                            Icons
                                                                .keyboard_arrow_down,
                                                            size: 24,
                                                            color: item.id == -1
                                                                ? ColorPalette
                                                                    .Yellow1
                                                                : ColorPalette
                                                                    .Black1))
                                                  ],
                                                ));
                                          } else
                                            return Container();
                                        })))
                          ],
                        ),
                       /* Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Material(
                                    shape: CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    color: Colors.transparent,
                                    child: IconButton(
                                      icon: Icon(Icons.notifications_none,
                                          size: 24, color: ColorPalette.Black1),
                                      onPressed: () {
                                        var ff = '';
                                      },
                                    ))))*/
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: PageView(
                            controller: _pageController,
                            children: _tabList,
                            onPageChanged: (newPage) {
                              setState(() {
                                this._currentIndex = newPage;
                              });
                            })),
                  ),
                  /*    Expanded(child: IndexedStack(
                      index: 0,
                      children: <Widget> [
                        MainPageActions(),
MainPagePlans()
                      ],
                    )),*/
                ],
              ),
              if (_addMenuIsClicked)
                Positioned.fill(
                    left: -48,
                    child: Container(
                        color: ColorPalette.White1.withOpacity(0.98),
                        child: FractionallySizedBox(
                            alignment: Alignment.centerRight,
                            widthFactor: .5,
                            child: Container(
                                padding:
                                    EdgeInsets.only(right: 8.0, bottom: 72),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: () {
    if (locator<Constants>()
        .getSite_id() !=
    '' && locator<Constants>().hasAccess(context,AccessEnum.addPerson, null,null))

    showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    //enableDrag: false,//enable drag false only for map
                                                    builder: (context) {
                                                      return BottomSheetWidget(
                                                        title: Strings
                                                            .BottomSheetWidget_NewPerson_title,
                                                        content:
                                                            NewPersonWidget(),
                                                      );
                                                    });
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          ColorPalette.White1,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: ColorPalette
                                                                    .Gray1
                                                                .withOpacity(
                                                                    0.25),
                                                            offset:
                                                                Offset(0, 0),
                                                            blurRadius: 4)
                                                      ]),
                                                  child: Center(
                                                      child: SvgPicture.asset(
                                                          'assets/vectors/Icons/Person.svg',
                                                          width: 24,
                                                          height: 24)),
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                FittedBox(
                                                  child: MyText(
                                                    text: Strings
                                                        .MainPageWidget_plans_person,
                                                    textAlign: TextAlign.center,
                                                    color: ColorPalette.Black1,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ))),
                                    SizedBox(
                                      height: 24,
                                    ),
                                    Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: () {
                                              if (locator<Constants>()
                                                      .getSite_id() !=
                                                  '' && locator<Constants>().hasAccess(context,AccessEnum.newAnomaly, null,null))
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewAnomalyPageWidget()));
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          ColorPalette.White1,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: ColorPalette
                                                                    .Gray1
                                                                .withOpacity(
                                                                    0.25),
                                                            offset:
                                                                Offset(0, 0),
                                                            blurRadius: 4)
                                                      ]),
                                                  child: Center(
                                                      child: SvgPicture.asset(
                                                          'assets/vectors/Icons/Anomaly.svg',
                                                          width: 24,
                                                          height: 24)),
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                FittedBox(
                                                  child: MyText(
                                                    text: Strings
                                                        .MainPageWidget_plans_anomaly,
                                                    textAlign: TextAlign.center,
                                                    color: ColorPalette.Black1,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            )))
                                  ],
                                )))))
            ],
          )),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorPalette.Yellow1,
            /*  onPressed: () {
              if(_addMenuIsClicked){
                _animationController.forward();
              }else{
                _animationController.reverse();
              }
              _addMenuIsClicked=!_addMenuIsClicked;
            },*/
            tooltip: 'add',
            child: AnimateIcons(
              startIcon: Icons.add,
              endIcon: Icons.close,
              size: 24.0,
              controller: _animateIconController,
              // add this tooltip for the start icon
              startTooltip: 'Icons.add_circle',
              // add this tooltip for the end icon
              endTooltip: 'Icons.add_circle_outline',

              onStartIconPress: () {
                setState(() {
                  _addMenuIsClicked = true;
                });

                return true;
              },
              onEndIconPress: () => onEndIconPress(),
              duration: Duration(milliseconds: 500),
              startIconColor: ColorPalette.White1,
              endIconColor: ColorPalette.White1,
              clockwise: false,
            ),
            elevation: 2.0,
          ),
          bottomNavigationBar: _addMenuIsClicked
              ? Container(
                  height: 56,
                  color: ColorPalette.White1.withOpacity(0.98),
                )
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
                    // /* setState(() {
                    _currentIndex = currentIndex;
                    //  });*/

                    _pageController.animateToPage(_currentIndex,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  items: [
                    BottomNavigationBarItem(
                        label: Strings.MainPageWidget_plans,
                        icon: Icon(Icons.apps)),
                    BottomNavigationBarItem(
                        label: Strings.MainPageWidget_home,
                        icon: Icon(Icons.home_outlined)),
                  ],
                ),
        ));
  }

  bool onEndIconPress() {
    setState(() {
      _addMenuIsClicked = false;
    });

    return true;
  }
}
