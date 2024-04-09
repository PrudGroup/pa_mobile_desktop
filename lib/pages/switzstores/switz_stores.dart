import 'package:flutter/material.dart';

import '../../components/translate.dart';
import '../../components/work_in_progress.dart';
import '../../singletons/shared_local_storage.dart';
import '../../singletons/tab_data.dart';

class SwitzStores extends StatefulWidget {
  const SwitzStores({super.key});

  @override
  SwitzStoresState createState() => SwitzStoresState();
}

class SwitzStoresState extends State<SwitzStores> {
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
          text: "Switz Stores",
          style: tabData.eStyle.copyWith(fontSize: 16),
        ),
        actions: const [
        ],
      ),
      body: const WorkInProgress(),
    );
  }
}