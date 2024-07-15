import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_showroom_item.dart';

class PrudShowroom extends StatefulWidget {
  final List<Widget> items;
  final Axis direction;

  const PrudShowroom({
    super.key,
    required this.items,
    this.direction = Axis.vertical
  });

  @override
  PrudShowroomState createState() => PrudShowroomState();
}

class PrudShowroomState extends State<PrudShowroom> {

  @override
  void initState(){
    widget.items.shuffle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical?
    Column(
      children: widget.items.map((Widget item) => PrudShowroomItem(
        item: item,
        isHeight: true,
      )).toList(),
    )
        :
    ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index){
        Widget item = widget.items[index];
        return PrudShowroomItem(
          item: item,
          isHeight: false,
        );
      }
    );
  }
}