import 'package:flutter/material.dart';
import 'package:prudapp/models/bus_models.dart';

import '../models/theme.dart';
import '../singletons/bus_notifier.dart';
import '../singletons/tab_data.dart';
import 'bus_component.dart';

class SelectBusComponent extends StatefulWidget {
  final bool onlyActive;
  final List<String>? excludeIds;
  const SelectBusComponent({super.key, required this.onlyActive, this.excludeIds});

  @override
  SelectBusComponentState createState() => SelectBusComponentState();
}

class SelectBusComponentState extends State<SelectBusComponent> {
  bool loading = false;
  List<BusDetail> buses = [];
  Widget noOperators = tabData.getNotFoundWidget(
    title: "No Bus",
    desc: "No bus found. You can start by creating one."
  );
  
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getBuses();
    });
    super.initState();
  }

  void choose(BusDetail busDetail, BuildContext context){
    busNotifier.updateSelectedBus(busDetail);
    Navigator.pop(context);
  }

  Future<void> getBuses() async {
    await tryAsync("getBuses", () async {
      if(mounted) setState(() => loading = true);
      if(busNotifier.busDetails.isNotEmpty){
        if(mounted) {
          setState(() {
            buses = getList();
          });
        }
      }else{
        await busNotifier.getBusesFromCloud();
        if(busNotifier.busDetails.isNotEmpty && mounted){
          setState(() {
            buses = getList();
          });
        }
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  List<BusDetail> getList(){
    List<BusDetail> found = widget.onlyActive? busNotifier.busDetails.where((ele) => ele.bus.active == true).toList() : busNotifier.busDetails;
    List<BusDetail> reversed = found.reversed.toList();
    if(widget.excludeIds != null && widget.excludeIds!.isNotEmpty){
      return reversed.where((ele) {
        return widget.excludeIds!.contains(ele.bus.id)? false : true;
      }).toList();
    }else{
      return reversed;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.35,
      decoration: BoxDecoration(
        borderRadius: prudRad,
        color: prudColorTheme.bgC,
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: buses.isEmpty?
        Center(child: noOperators,)
            :
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: buses.length,
          itemBuilder: (context, index){
            BusDetail op = buses[index];
            return InkWell(
              onTap: () => choose(op, context),
              child: BusComponent(bus: op, isOperator: true,),
            );
          }
        ),
      ),
    );
  }
}
