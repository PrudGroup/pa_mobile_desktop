import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
    
class VidStreamDetail extends StatefulWidget {
  final VidStream? vidStream;
  final String? sid;
  final String? referralLinkId;
  
  const VidStreamDetail({super.key, this.vidStream, this.sid, this.referralLinkId});

  @override
  VidStreamDetailState createState() => VidStreamDetailState();
}

class VidStreamDetailState extends State<VidStreamDetail> {
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