import 'package:flutter/material.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/viewsparks/tabs/my_sparks.dart';
import 'package:prudapp/pages/viewsparks/tabs/new_spark.dart';
import 'package:prudapp/pages/viewsparks/tabs/sparks.dart';

import '../../models/images.dart';

class ViewSpark extends StatefulWidget {
  final int? tab;
  const ViewSpark({super.key, this.tab});

  @override
  ViewSparkState createState() => ViewSparkState();
}

class ViewSparkState extends State<ViewSpark> with TickerProviderStateMixin {

  late TabController tabCtrl = TabController(
      length: 3, vsync: this
  );

  @override
  void initState(){
    super.initState();
    if(widget.tab != null) tabCtrl.animateTo(widget.tab!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        controller: tabCtrl,
        children: [
          MySparks(goToTab: (int index) => tabCtrl.animateTo(index)),
          Sparks(goToTab: (int index) => tabCtrl.animateTo(index)),
          NewSpark(goToTab: (int index) => tabCtrl.animateTo(index)),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.mySparks, width: 30,),
            text: "My Sparks",
          ),
          Tab(
            icon: Image.asset(prudImages.sparks, width: 30,),
            text: "Sparks",
          ),
          Tab(
            icon: Image.asset(prudImages.newSpark, width: 30,),
            text: "New Spark",
          ),
        ],
      ),
    );
  }
}