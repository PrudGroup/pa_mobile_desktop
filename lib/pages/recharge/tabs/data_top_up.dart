import 'package:flutter/material.dart';
import '../../../components/recharge_component.dart';


class DataTopUp extends StatefulWidget {
  final String? affLinkId;
  final Function(int)? goToTab;
  const DataTopUp({super.key, this.affLinkId, this.goToTab});

  @override
  DataTopUpState createState() => DataTopUpState();
}

class DataTopUpState extends State<DataTopUp> {

  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }


  @override
  Widget build(BuildContext context) {
    return RechargeComponent(
      isAirtime: false,
      affLinkId: widget.affLinkId,
    );
  }
}
