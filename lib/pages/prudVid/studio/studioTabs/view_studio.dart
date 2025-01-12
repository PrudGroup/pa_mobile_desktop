import 'package:flutter/material.dart';

import '../../../../components/work_in_progress.dart';

class ViewStudio extends StatefulWidget {

    const ViewStudio({super.key});

    @override
    State<ViewStudio> createState() => _ViewStudioState();
}

class _ViewStudioState extends State<ViewStudio> {

  Future<void> getStudio() async {

  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}