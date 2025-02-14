import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';

class PrudVideoComponent extends StatefulWidget{
  final ChannelVideo video;
  final bool isOwner;

  const PrudVideoComponent({super.key, required this.video, required this.isOwner});

  @override
  PrudVideoComponentState createState() => PrudVideoComponentState();
}

class PrudVideoComponentState extends State<PrudVideoComponent> {

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}