import 'package:flutter/material.dart';
import 'package:prudapp/models/theme.dart';

class PrudShowroomItem extends StatelessWidget {
  final Widget item;
  final bool isHeight;

  const PrudShowroomItem({super.key, required this.item, this.isHeight = true});

  @override
  Widget build(BuildContext context) {
    Widget space = isHeight? spacer.height : spacer.width;
    return Column(
      children: [
        item,
        space
      ],
    );
  }
}
