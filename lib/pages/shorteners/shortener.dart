import 'package:flutter/material.dart';

import '../../components/translate.dart';
import '../../components/work_in_progress.dart';
import '../../singletons/shared_local_storage.dart';
import '../../singletons/tab_data.dart';

class Shortener extends StatefulWidget {
  const Shortener({super.key});

  @override
  ShortenerState createState() => ShortenerState();
}

class ShortenerState extends State<Shortener> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudTheme.cardColor,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        elevation: 2.0,
        title: Translate(
          text: "Shortener",
          style: tabData.eStyle.copyWith(fontSize: 16),
        ),
        actions: const [
        ],
      ),
      body: const WorkInProgress(),
    );
  }
}