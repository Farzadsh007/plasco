import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/group/group_detail.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';
import 'NewGroupSelectParticipantsPageWidget.dart';

class EditGroupPageWidget extends StatefulWidget {
  final int id;
  final MyBloc listHttpBloc;

  const EditGroupPageWidget({Key key, this.id, this.listHttpBloc})
      : super(key: key);

  @override
  _EditGroupPageWidgetState createState() =>
      _EditGroupPageWidgetState(this.id, this.listHttpBloc);
}

class _EditGroupPageWidgetState extends State<EditGroupPageWidget> {
  int id;
  MyBloc httpBloc = MyBloc();
  MyBloc listHttpBloc;
  GroupDetail groupDetail = GroupDetail();
  TextEditingController editGroupPageWidgetNameController =
      TextEditingController();

  _EditGroupPageWidgetState(this.id, this.listHttpBloc);

  Future<bool> _willPopCallback() async {
    bool ret = true;
    await locator<Web>().post(GroupGetListEvent(listHttpBloc, ''), context);

    return ret;
  }

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIOverlays([]);

    if (this.id != null) {
      Future.delayed(Duration.zero, () {
        locator<Web>()
            .post(GroupGetParticipantsListEvent(httpBloc, id), context);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    httpBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*final groupPageWidgetCancel = MyButton(
        text: Strings.GroupPageWidget_cancel,
        buttonFill: ButtonFillStyle.White,
        onPressed: () {
          Navigator.pop(context, true);
        });*/
    /*  final groupPageWidgetSend = MyButton(
        text: Strings.GroupPageWidget_send,
        buttonFill: ButtonFillStyle.Yellow,
        onPressed: () {
        locator<Web>().post(GroupAddMemberEvent(httpBloc, groupDetail), context);});*/
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
          backgroundColor: ColorPalette.Background,
          body: SafeArea(
              child: Container(
                  color: Colors.transparent,

                  // height: height /2,
                  child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.White1,
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
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
                                    child: this.id == null
                                        ? MyText(
                                            text:
                                                Strings.GroupPageWidget_Create,
                                            textAlign: TextAlign.center,
                                            color: ColorPalette.Gray1,
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                          )
                                        : StreamBuilder(
                                            stream: httpBloc.stream,
                                            builder: (context,
                                                AsyncSnapshot<dynamic>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                GroupDetail item = snapshot.data
                                                    as GroupDetail;
                                                this.groupDetail = item;
                                                return MyText(
                                                  text: Strings
                                                          .GroupPageWidget_title_prefix +
                                                      item.name,
                                                  textAlign: TextAlign.center,
                                                  color: ColorPalette.Gray1,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                );
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
                                    onTap: () async {
                                      await locator<Web>().post(
                                          GroupGetListEvent(listHttpBloc, ''),
                                          context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                /*  StreamBuilder(
                                    stream: httpBloc.stream,
                                    builder: (context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      if (snapshot.hasData) {
                                        GroupDetail item =
                                            snapshot.data as GroupDetail;
                                        editGroupPageWidgetNameController.text =
                                            item.name;
                                        return MyTextFormField(
                                          controller:
                                              editGroupPageWidgetNameController,
                                          text: Strings.GroupPageWidget_Name,
                                          hint: Strings.GroupPageWidget_Name,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          counterFontSize: 10,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.name,
                                          maxLength: 8,
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),*/
                                SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: MyText(
                                    text: Strings.GroupPageWidget_Members,
                                    textAlign: TextAlign.right,
                                    color: ColorPalette.Black1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 24),
                                StreamBuilder(
                                    stream: httpBloc.stream,
                                    builder: (context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      if (snapshot.hasData) {
                                        GroupDetail item =
                                            snapshot.data as GroupDetail;
                                        if (item.members.length > 0) {
                                          return Expanded(
                                              child: SingleChildScrollView(
                                                  child: ListView.builder(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          item.members.length,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return getListItem(item
                                                            .members[index]);
                                                      })));
                                        } else {
                                          return Expanded(child: Container());
                                        }
                                      } else {
                                        return Expanded(child: Container());
                                      }
                                    }),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FloatingActionButton(
                                      backgroundColor: ColorPalette.Yellow1,
                                      onPressed: () async {
                                        if (locator<Constants>().getSite_id() !=
                                                '' &&
                                            locator<Constants>().hasAccess(
                                                context,
                                                AccessEnum.editGroup,
                                                null,null)) {
                                          List<User> users = await Navigator.of(
                                                  context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewGroupSelectParticipantsPageWidget(
                                                        groupDetail:
                                                            this.groupDetail,
                                                        users: this
                                                            .groupDetail
                                                            .members,
                                                      )));
                                          if (users != null) {
                                            //
                                            setState(() {
                                              this.groupDetail.members = users;
                                            });
                                          }
                                        }
                                      },
                                      tooltip: 'add',
                                      child: Icon(
                                        Icons.add,
                                        color: ColorPalette.White1,
                                      )),
                                ),
                                /*   Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Expanded(
                                        child: FractionallySizedBox(
                                          //alignment: Alignment.centerRight,

                                          widthFactor: 1,

                                          child: groupPageWidgetCancel,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8.0,
                                      ),
                                      Expanded(
                                        child: FractionallySizedBox(

                                            //alignment: Alignment.centerRight,

                                            widthFactor: 1,
                                            child: groupPageWidgetSend),
                                      )
                                    ],
                                  ),
                                )*/
                              ],
                            ),
                          ),
                        )
                      ]))))),
    );
  }

  Widget getListItem(User item) {
    return Padding(
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
                              fit: BoxFit.fitHeight),
                    ),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                if (locator<Constants>().getSite_id() != '' &&
                                    locator<Constants>().hasAccess(
                                        context, AccessEnum.editGroup, null,null))
                                  locator<Web>().post(
                                      GroupRemoveMemberEvent(
                                          httpBloc, this.groupDetail, item),
                                      context);
                              },
                              child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  width: 24,
                                  height: 24,
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle),
                                  child: CrossPlatformSvg.asset(
                                      assetPath:
                                          'assets/vectors/Icons/WithBG.svg',
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.fitHeight))),
                        ))
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
                                  text: item.first_name + ' ' + item.last_name,
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
            )));
  }
}
