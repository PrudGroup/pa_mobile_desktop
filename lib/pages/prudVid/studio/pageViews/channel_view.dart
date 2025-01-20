import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

import '../../../../models/prud_vid.dart';

class ChannelView extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;

  const ChannelView({super.key, required this.channel, required this.isOwner});

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     return WorkInProgress();
  }
}