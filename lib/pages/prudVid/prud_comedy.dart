import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

class PrudComedy extends StatefulWidget {

    const PrudComedy({super.key});

    @override
    State<PrudComedy> createState() => _PrudComedyState();
}

class _PrudComedyState extends State<PrudComedy> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
         return WorkInProgress();
     }
}