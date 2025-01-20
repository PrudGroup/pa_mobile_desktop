import 'package:flutter/material.dart';

import '../../../../../components/work_in_progress.dart';

class MyChannels extends StatefulWidget {

  const MyChannels({super.key});

  @override
  State<MyChannels> createState() => _MyChannelsState();
}

class _MyChannelsState extends State<MyChannels> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}