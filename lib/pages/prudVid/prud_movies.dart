import 'package:flutter/material.dart';

import '../../components/work_in_progress.dart';

class PrudMovies extends StatefulWidget {

    const PrudMovies({super.key});

    @override
    State<PrudMovies> createState() => _PrudMoviesState();
}

class _PrudMoviesState extends State<PrudMovies> {

    @override
    void initState() {
      super.initState();
    }

    @override
     Widget build(BuildContext context) {
      return WorkInProgress();
     }
}