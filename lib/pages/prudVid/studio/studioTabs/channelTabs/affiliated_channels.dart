import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

class AffiliatedChannels extends StatefulWidget {

  const AffiliatedChannels({super.key});

  @override
  State<AffiliatedChannels> createState() => _AffiliatedChannelsState();
}

class _AffiliatedChannelsState extends State<AffiliatedChannels> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}