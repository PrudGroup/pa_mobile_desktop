import 'package:flutter/material.dart';

import '../../../../components/work_in_progress.dart';

class PromoteStudioChannel extends StatefulWidget {

    const PromoteStudioChannel({super.key});

    @override
    State<PromoteStudioChannel> createState() => _PromoteStudioChannelState();
}

class _PromoteStudioChannelState extends State<PromoteStudioChannel> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
      return WorkInProgress();
     }
}