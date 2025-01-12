import 'package:flutter/material.dart';

import '../../components/work_in_progress.dart';

class PrudCuisine extends StatefulWidget {

    const PrudCuisine({super.key});

    @override
    State<PrudCuisine> createState() => _PrudCuisineState();
}

class _PrudCuisineState extends State<PrudCuisine> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
      return WorkInProgress();
     }
}