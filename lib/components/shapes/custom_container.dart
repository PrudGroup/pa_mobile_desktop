import 'package:flutter/material.dart';

import 'curve_container.dart';

//main_layout painter
class CustomContainer extends StatelessWidget {
  final Color color;
  final Color frontColor;
  final double arcHeight;
  final String position;
  final bool equality;
  final Widget child;
  final double width;
  final double height;
  final bool clock;
  final Radius radius;
  final int type;
  final double space;
  final String? bgImage;

  const CustomContainer({
    super.key,
    required this.color,
    required this.frontColor,
    required this.arcHeight,
    required this.child,
    this.radius = const Radius.circular(10),
    this.position = "Bottom",
    this.equality = false,
    this.width = double.infinity,
    this.height = double.infinity,
    this.clock = false,
    this.type = 1,
    this.space = 0.10,
    this.bgImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: width,
          height: height,
          decoration:BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: AssetImage(bgImage?? "assets/images/gh.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: ArcCurveContainer(
              color: color,
              arcHeight: arcHeight,
              position: position,
              equality: equality,
              clock: clock,
              radius: radius,
              type: type
            ),
          ),
        ),
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: ArcCurveContainer(
              color: frontColor,
              arcHeight: (arcHeight+space),
              position: position,
              equality: equality,
              clock: clock,
              radius: radius,
              type: type
            ),
            child: Padding(
              padding: EdgeInsets.only(top: height - (height*arcHeight)),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(width/2),
                  topLeft: Radius.circular(width/2),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
