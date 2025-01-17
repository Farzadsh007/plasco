import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/cards/ActionReplyCard.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/views/action/LeaveCommentForActionPageWidget.dart';
import 'package:plasco/views/action/ViewActionPageWidget.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../inputs/MyText.dart';

class ActionWithLastReplyWidget extends StatefulWidget {
  ActionWithLastReplyWidget({Key key, this.actionId}) : super(key: key);

  final int actionId;

  @override
  _ActionWithLastReplyWidgetState createState() =>
      _ActionWithLastReplyWidgetState(this.actionId);
}

class _ActionWithLastReplyWidgetState extends State<ActionWithLastReplyWidget> {
  _ActionWithLastReplyWidgetState(this.actionId);

  int actionId;
  MyBloc httpBloc = MyBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      locator<Web>()
          .post(ActionGetDetailsEvent(httpBloc, this.actionId), context);
    });
  }

  @override
  void dispose() {
    httpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: httpBloc.stream,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            ActionItem action = snapshot.data as ActionItem;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText(
                  text: action.title,
                  textAlign: TextAlign.right,
                  color: ColorPalette.Black1,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,maxLines: 2,
                ),
                if (action.answers != null && action.answers.total > 0)
                  SizedBox(
                    height: 24,
                  ),
                if (action.answers != null && action.answers.total > 0)
                  ActionReplyCard(answer: action.answers,isFromReplyList: false,),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          //alignment: Alignment.centerRight,
                          widthFactor: 1,
                          child: MyButton(
                              text: Strings
                                  .BottomSheetWidget_ActionWithLastReply_reply,
                              buttonFill: ButtonFillStyle.White,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        LeaveCommentForActionPageWidget(
                                            action: action)));
                              }),
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: FractionallySizedBox(
                            //alignment: Alignment.centerRight,
                            widthFactor: 1,
                            child: MyButton(
                                text: Strings
                                    .BottomSheetWidget_ActionWithLastReply_details,
                                buttonFill: ButtonFillStyle.Yellow,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ViewActionPageWidget(
                                            actionId: action.id,
                                          )));
                                })),
                      )
                    ],
                  ),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
