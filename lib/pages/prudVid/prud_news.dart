import 'package:flutter/material.dart';

import '../../components/work_in_progress.dart';

class PrudNews extends StatefulWidget {

    const PrudNews({super.key});

    @override
    State<PrudNews> createState() => _PrudNewsState();
}

class _PrudNewsState extends State<PrudNews> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
      return WorkInProgress();
     }
}