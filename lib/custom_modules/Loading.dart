import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plasco/color_palette.dart';

class Loading extends StatefulWidget {
  const Loading({Key key}) : super(key: key);

  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  AnimationController controller;

  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    //controller.forward();
    controller.repeat(reverse: false);
    animation = Tween(begin: -244.0, end: 0.0).animate(controller);
  }

  @override
  void dispose() {
    if (controller != null) controller.dispose();
    super.dispose();
  }

  List<SvgPicture> _myWidget(int count) {
    return List.generate(
        count,
        (i) => SvgPicture.asset(
              'assets/vectors/loading_tile.svg',
              height: 16,
            )).toList(); // replace * with your rupee or use Icon instead
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 16,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: ColorPalette.Black2,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Stack(children: [
          AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget child) {
              return Positioned(
                  left: animation.value,
                  child: Row(
                    children: _myWidget(200),
                  ));
            },
          )
        ]));
  }
}
