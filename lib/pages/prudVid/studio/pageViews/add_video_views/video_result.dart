import 'package:flutter/material.dart';
    
class VideoResult extends StatefulWidget {
  final bool succeeded;
  final String? errorMsg;
  final Function(dynamic) onCompleted;
  final Function onPrevious;

  const VideoResult({
    super.key, required this.onCompleted, 
    required this.onPrevious, this.succeeded = true,
    this.errorMsg
  });

  @override
  VideoResultState createState() => VideoResultState();
}

class VideoResultState extends State<VideoResult> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}