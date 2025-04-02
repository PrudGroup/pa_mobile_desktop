import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
    
class AddBroadcast extends StatefulWidget {
  final VidChannel channel;
  
  const AddBroadcast({super.key, required this.channel});

  @override
  AddBroadcastState createState() => AddBroadcastState();
}

class AddBroadcastState extends State<AddBroadcast> {
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