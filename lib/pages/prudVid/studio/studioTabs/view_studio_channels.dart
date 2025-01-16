import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

class ViewStudioChannels extends StatefulWidget {
  const ViewStudioChannels({super.key});

  @override
  State<ViewStudioChannels> createState() => _ViewStudioChannelsState();
}

class _ViewStudioChannelsState extends State<ViewStudioChannels> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
         return WorkInProgress();
     }
}