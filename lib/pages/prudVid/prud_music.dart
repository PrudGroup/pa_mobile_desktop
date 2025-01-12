import 'package:flutter/material.dart';

import '../../components/work_in_progress.dart';

class PrudMusic extends StatefulWidget {

    const PrudMusic({super.key});

    @override
    State<PrudMusic> createState() => _PrudMusicState();
}

class _PrudMusicState extends State<PrudMusic> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
      return WorkInProgress();
     }
}