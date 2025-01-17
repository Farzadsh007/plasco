import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:plasco/color_palette.dart';

class ShowFileWidget extends StatefulWidget {
  ShowFileWidget({Key key, this.images}) : super(key: key);

  final List<String> images;

  @override
  _ShowFileWidgetState createState() => _ShowFileWidgetState(this.images);
}

class _ShowFileWidgetState extends State<ShowFileWidget> {
  _ShowFileWidgetState(this.images);

  List<String> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 256,
            child: Swiper(
              loop: false,
              viewportFraction: 1,
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: ColorPalette.Gray3,
                      child: ExtendedImage.network(
                        images[index],
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (ExtendedImageState state) {
                          return GestureConfig(
                            //you must set inPageView true if you want to use ExtendedImageGesturePageView
                            inPageView: true,
                            initialScale: 1.0,
                            minScale: 1.0,
                            maxScale: 5.0,
                            animationMaxScale: 6.0,
                            initialAlignment: InitialAlignment.center,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ))
      ],
    );
  }
}
