import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
    
class ThrillerDetail extends StatefulWidget {
  final VideoThriller? thriller;
  final ChannelVideo? video;
  final String? thrillerId;
  final String? referralLinkId;
  
  const ThrillerDetail({super.key, this.thriller, this.video, this.thrillerId, this.referralLinkId});

  @override
  ThrillerDetailState createState() => ThrillerDetailState();
}

class ThrillerDetailState extends State<ThrillerDetail> {
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(),
    );
  }
}