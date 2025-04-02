import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
    
class BroadcastComponent extends StatefulWidget {
  final dynamic broadcast;
  final bool isChannel;
  final bool isOwner;
  
  const BroadcastComponent({
    super.key, this.broadcast, required this.isChannel, this.isOwner = false
  }) : assert(isChannel? broadcast is ChannelBroadcast : broadcast is StreamBroadcast);

  @override
  BroadcastComponentState createState() => BroadcastComponentState();
}

class BroadcastComponentState extends State<BroadcastComponent> {
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