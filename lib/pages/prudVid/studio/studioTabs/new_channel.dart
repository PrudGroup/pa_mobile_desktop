import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

class NewChannel extends StatefulWidget {

    const NewChannel({super.key});

    @override
    State<NewChannel> createState() => _NewChannelState();
}

class _NewChannelState extends State<NewChannel> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
         return WorkInProgress();
     }
}