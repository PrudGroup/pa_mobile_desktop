import 'package:flutter/material.dart';
import 'package:prudapp/components/recharge_component.dart';

class Airtime extends StatefulWidget {
  final String? affLinkId;
  final Function(int)? goToTab;
  const Airtime({super.key, this.affLinkId, this.goToTab});

  @override
  AirtimeState createState() => AirtimeState();
}

class AirtimeState extends State<Airtime> {

  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  @override
  Widget build(BuildContext context) {
    return RechargeComponent(
      isAirtime: true,
      affLinkId: widget.affLinkId,
    );
  }
}
