import 'package:flutter/material.dart';
import 'package:prudapp/models/theme.dart';
    
class PointDivider extends StatelessWidget {
  final Color? pointColor;
  final double? size;

  const PointDivider({ super.key, this.pointColor, this.size });
  
  @override
  Widget build(BuildContext context) {
    double thickness = size != null? size!/2 : 2.0;
    return SizedBox(
      height: size?? 5, 
      child: Align(
        alignment: Alignment.center, 
        child: Container(
          width: thickness, 
          height: thickness, 
          color: pointColor?? prudColorTheme.textC
        ),
      ),
    );
  }
}