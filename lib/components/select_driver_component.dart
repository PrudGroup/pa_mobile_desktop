import 'package:flutter/material.dart';
import 'package:prudapp/models/bus_models.dart';

import '../models/theme.dart';
import '../singletons/bus_notifier.dart';
import '../singletons/tab_data.dart';
import 'dashboard_driver_component.dart';
import 'loading_component.dart';

class SelectDriverComponent extends StatefulWidget {
  final bool onlyActive;
  final List<String>? excludeIds;
  const SelectDriverComponent({super.key, required this.onlyActive, this.excludeIds});

  @override
  SelectDriverComponentState createState() => SelectDriverComponentState();
}

class SelectDriverComponentState extends State<SelectDriverComponent> {

  bool loading = false;
  List<DriverDetails> drivers = [];
  Widget noDrivers = tabData.getNotFoundWidget(
      title: "No Driver",
      desc: "No driver found. You can start by creating one."
  );

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getDrivers();
    });
    super.initState();
  }

  void choose(DriverDetails driverDetail, BuildContext context){
    busNotifier.updateSelectedDriver(driverDetail);
    Navigator.pop(context);
  }

  Future<void> getDrivers() async {
    await tryAsync("getDrivers", () async {
      if(mounted) setState(() => loading = true);
      if(busNotifier.driverDetails.isNotEmpty){
        if(mounted) {
          setState(() {
            drivers = getList();
          });
        }
      }else{
        await busNotifier.getDrivers();
        if(busNotifier.driverDetails.isNotEmpty && mounted){
          setState(() {
            drivers = getList();
          });
        }
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  List<DriverDetails> getList(){
    List<DriverDetails> found = widget.onlyActive? busNotifier.driverDetails.where((DriverDetails ele) => ele.dr.active == true).toList() : busNotifier.driverDetails;
    List<DriverDetails> reversed = found.reversed.toList();
    if(widget.excludeIds != null && widget.excludeIds!.isNotEmpty){
      return reversed.where((ele) {
        return widget.excludeIds!.contains(ele.dr.id)? false : true;
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
        child: loading? Center(
          child: LoadingComponent(
            isShimmer: false,
            spinnerColor: prudColorTheme.primary,
            size: 40,
          ),
        )
            :
        (
            drivers.isEmpty?
            Center(child: noDrivers,)
                :
            ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: drivers.length,
                itemBuilder: (context, index){
                  DriverDetails op = drivers[index];
                  return InkWell(
                    onTap: () => choose(op, context),
                    child: DashboardDriverComponent(driver: op),
                  );
                }
            )
        ),
      ),
    );
  }
}
