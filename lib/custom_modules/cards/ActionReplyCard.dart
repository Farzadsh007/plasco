import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ActionWitLastReply.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ViewComment.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/models/action/answer.dart';
import 'package:plasco/views/action/RepliesToActionPageWidget.dart';

import '../../color_palette.dart';
import '../../strings.dart';
import '../CrossPlatformSvg.dart';
import '../LoadImage.dart';
import '../inputs/MyText.dart';

class ActionReplyCard extends StatelessWidget {
  final Answer answer;

final bool isFromReplyList;
  const ActionReplyCard({Key key, this.answer,this.isFromReplyList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          textDirection: TextDirection.rtl,
          children: [
            Container(
              alignment: Alignment.centerRight,
              width: 24,
              height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: answer.creator.logo != ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child: LoadImage.load(
                          url: answer.creator.logo,
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
              child: MyText(
                text:
                    answer.creator.first_name + ' ' + answer.creator.last_name,
                textAlign: TextAlign.right,
                color: ColorPalette.Gray1,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            MyText(
              text: Strings.BottomSheetWidget_ActionWithLastReply_answered,
              textAlign: TextAlign.right,
              color: ColorPalette.Black1,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            Expanded(
              child: MyText(
                text: answer.getFarsiCreateDate(),
                textAlign: TextAlign.left,
                color: ColorPalette.Gray1,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Material(
    color: Colors.transparent,
    child: InkWell(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    onTap: () {
      /*if(isFromReplyList){
        return;
      }*/
    /*  Navigator.of(context).pop();
      Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  RepliesToActionPageWidget(
                      action:
                      action)));*/

      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          //enableDrag: false,//enable drag false only for map
          builder: (context) {
            return BottomSheetWidget(
              title: Strings
                  .BottomSheetWidget_ViewComment_title +
                  '[' +
                  answer
                      .id
                      .toString() +
                  ']',
              content: ViewCommentWidget(answer:   answer),
            );
          });
    },child: Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerRight,
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: ColorPalette.Gray3,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: (answer.images != null && answer.images.length > 0)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: LoadImage.load(
                          url: answer.images[0],
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
                  text: answer.title,
                  textAlign: TextAlign.right,
                  color: ColorPalette.Black1,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,maxLines: 2,
                ),
              ),
            ),
          ],
        )))
      ],
    );
  }
}
