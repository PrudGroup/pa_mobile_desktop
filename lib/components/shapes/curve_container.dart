import 'package:flutter/material.dart';

//main_layout painter
class ArcCurveContainer extends CustomPainter {
  final Color color;
  double arcHeight;
  final String position;
  final bool equality;
  final bool clock;
  final Radius radius;
  final int type;

  ArcCurveContainer({
    required this.color,
    required this.arcHeight,
    this.position = "Bottom",
    this.equality = false,
    this.clock = false,
    this.radius = const Radius.circular(10.0),
    required this.type
  });

  @override
  void paint(Canvas canvas, Size size) {
    arcHeight = arcHeight>1? 1 : arcHeight;
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    if(position=="Bottom"){
      if(equality){
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, arcHeight*size.height);
        if(type>0){
          path.arcToPoint(
            Offset(0, arcHeight*size.height),
            clockwise: clock,
            radius: radius,
          );
        }else{
          path.quadraticBezierTo(size.width*0.5, size.height*0.8, 0, size.height*0.7);
        }
      }else{
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, arcHeight*size.height);
        if(type>0){
          path.arcToPoint(
            Offset(0, arcHeight!=1? ((arcHeight+0.50)*size.height): (0.70*size.height)),
            clockwise: clock,
            radius: radius,
          );
        }else{
          path.quadraticBezierTo(size.width*0.5, size.height*0.8, 0, size.height*0.7);
        }
      }
    }else{
      if(equality){
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, arcHeight*size.height);
        if(type>0){
          path.arcToPoint(
            Offset(0, arcHeight*size.height),
            clockwise: clock,
            radius: radius,
          );
        }else{
          path.quadraticBezierTo(size.width*0.5, size.height*0.8, 0, size.height*0.7);
        }
      }else{
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, arcHeight*size.height);
        if(type>0){
          path.arcToPoint(
            Offset(0, arcHeight!=1? ((arcHeight+0.50)*size.height): (0.70*size.height)),
            clockwise: clock,
            radius: radius,
          );
        }else{
          path.quadraticBezierTo(size.width*0.5, size.height*0.8, 0, size.height*0.7);
        }
      }
    }

    canvas.drawShadow(path.shift(Offset(-6, 6)), Colors.black38, 2, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
