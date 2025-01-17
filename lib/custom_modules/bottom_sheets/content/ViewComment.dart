import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ShowFile.dart';
import 'package:plasco/models/action/answer.dart';
import 'package:plasco/services/web.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../CrossPlatformSvg.dart';
import '../../LoadImage.dart';
import '../../inputs/MyText.dart';
import '../BottomSheetWidget.dart';

class ViewCommentWidget extends StatefulWidget {
  ViewCommentWidget({Key key, this.answer}) : super(key: key);

  final Answer answer;

  @override
  _ViewCommentWidgetState createState() => _ViewCommentWidgetState(this.answer);
}

class _ViewCommentWidgetState extends State<ViewCommentWidget> {
  _ViewCommentWidgetState(this.answer);

  Answer answer;
  MyBloc httpBloc = MyBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      locator<Web>().post(ActionGetAnswerEvent(httpBloc, this.answer), context);
    });
  }

  @override
  void dispose() {
    httpBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
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
              child:
              MyText(
              text: /*Strings.ViewActionPageWidget_owner +*/
                  answer.creator.first_name +
                  ' ' +
                  answer.creator.last_name,
              textAlign: TextAlign.right,
              color: ColorPalette.Gray1,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            )),
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
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: MyText(
              text: answer.title,
              textAlign: TextAlign.right,
              color: ColorPalette.Black1,
              fontSize: 12,
              fontWeight: FontWeight.normal,
              maxLines: 4,
            )),
        if (answer.images.length > 0)
          StreamBuilder(
              stream: httpBloc.stream,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  Answer item = (snapshot.data as Answer);
                  return Material(
                      color: Colors.transparent,
                      child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          onTap: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                //enableDrag: false,//enable drag false only for map
                                builder: (context) {
                                  return BottomSheetWidget(
                                    title: Strings
                                        .BottomSheetWidget_ShowFile_title,
                                    content: ShowFileWidget(
                                      images: item.images,
                                    ),
                                  );
                                });
                          },
                          child: Container(
                              height: 256,
                              child: Swiper(
                                loop: false,
                                viewportFraction: .8,
                                itemCount: item.images.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Container(
                                              color: ColorPalette.Gray3,
                                              child: ExtendedImage.network(
                                                item.images[index],
                                                fit: BoxFit.contain,
                                                mode: ExtendedImageMode.gesture,
                                                initGestureConfigHandler:
                                                    (ExtendedImageState state) {
                                                  return GestureConfig(
                                                    //you must set inPageView true if you want to use ExtendedImageGesturePageView
                                                    inPageView: true,
                                                    initialScale: 1.0,
                                                    minScale: 1.0,
                                                    maxScale: 5.0,
                                                    animationMaxScale: 6.0,
                                                    initialAlignment:
                                                        InitialAlignment.center,
                                                  );
                                                },
                                              ))));
                                },
                              ))));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })
      ],
    );
  }
}
