import 'package:flutter/material.dart';

import '../../components/work_in_progress.dart';

class PrudLearn extends StatefulWidget {

    const PrudLearn({super.key});

    @override
    State<PrudLearn> createState() => _PrudLearnState();
}

class _PrudLearnState extends State<PrudLearn> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
      return WorkInProgress();
     }
}