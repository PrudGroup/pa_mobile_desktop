import 'package:flutter/material.dart';
    
class VideoMovie extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoMovie({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoMovieState createState() => VideoMovieState();
}

class VideoMovieState extends State<VideoMovie> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}