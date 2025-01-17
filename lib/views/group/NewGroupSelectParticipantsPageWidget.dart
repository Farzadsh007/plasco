import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/group/group_detail.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class NewGroupSelectParticipantsPageWidget extends StatefulWidget {
  final GroupDetail groupDetail;
  final List<User> users;

  const NewGroupSelectParticipantsPageWidget(
      {Key key, this.groupDetail, this.users})
      : super(key: key);

  @override
  _NewGroupSelectParticipantsPageWidgetState createState() =>
      _NewGroupSelectParticipantsPageWidgetState(this.groupDetail, this.users);
}

class _NewGroupSelectParticipantsPageWidgetState
    extends State<NewGroupSelectParticipantsPageWidget> {
  _NewGroupSelectParticipantsPageWidgetState(this.groupDetail, this.users);

  MyBloc httpBloc = MyBloc();

  MyBloc updateMembersHttpBloc = MyBloc();
  GroupDetail groupDetail;
  List<User> users;

  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    super.initState();
    updateMembersHttpBloc.stream.listen((event) {
      if (event as bool == true) {
        Navigator.of(context)
            .pop(users.where((e) => e.selected == true).toList());
      }
    });

    Future.delayed(Duration.zero, () {
      if (groupDetail.members == null || groupDetail.members.length == 0) {
        locator<Web>().post(GroupGetMembersForAddEvent(httpBloc), context);
      } else {
        locator<Web>().post(
            GroupGetMembersForEditEvent(httpBloc, groupDetail.members),
            context);
      }
    });
  }

  @override
  void dispose() {
    httpBloc.dispose();
    updateMembersHttpBloc.dispose();
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
                  List<User> users = snapshot.data as List<User>;
                  List<User> selected_users = users
                      .where((e) =>
                          e.selected == true && e.alreadyExistInGroup == false)
                      .toList();
                  if (selected_users.length > 0) {
                    return FloatingActionButton(
                        backgroundColor: ColorPalette.Yellow1,
                        onPressed: () {
                          locator<Web>().post(
                              GroupAddMemberEvent(updateMembersHttpBloc,
                                  groupDetail, selected_users),
                              context);
                        },
                        tooltip: 'add',
                        child: Icon(
                          Icons.arrow_forward_ios_sharp,
                          color: ColorPalette.White1,
                        ));
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              }),
          body: SafeArea(
            child: Column(
              children: [
                BarTopAppBarWithSearchWidget(),
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
                            text: Strings.GroupPageWidget_select_participants,
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
                                  List<User> users =
                                      snapshot.data as List<User>;
                                  this.users = users;
                                  return Expanded(
                                    child: SingleChildScrollView(
                                        child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: users.length,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return getListItem(users[index]);
                                            })),
                                  );
                                } else {
                                  return Container();
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
                    Stack(
                      children: [
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
                                    fit: BoxFit.fitHeight)),
                        Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                                clipBehavior: Clip.antiAlias,
                                width: 24,
                                height: 24,
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle),
                                child: item.selected
                                    ? CrossPlatformSvg.asset(
                                        assetPath: 'assets/vectors/Tick.svg',
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.fitHeight)
                                    : Container()))
                      ],
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
                    item.getLabel()
                  ],
                ))),
        Positioned.fill(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: item.alreadyExistInGroup
              ? Container()
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        item.toggleSelected();
                        locator<Web>().post(
                            GroupSelectMembersForAddEvent(httpBloc, this.users),
                            context);
                      }),
                ),
        ))
      ],
    );
  }
}
