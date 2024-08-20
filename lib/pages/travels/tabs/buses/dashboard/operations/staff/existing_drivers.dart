import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prudapp/components/dashboard_driver_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../../../../../../models/theme.dart';

class ExistingDrivers extends StatefulWidget {
  const ExistingDrivers({super.key});

  @override
  ExistingDriversState createState() => ExistingDriversState();
}

class ExistingDriversState extends State<ExistingDrivers> {
  List<DriverDetails> drivers = busNotifier.driverDetails;
  bool loading = false;
  Widget noDriver = tabData.getNotFoundWidget(
      title: "No Driver Found",
      desc: " It's either you have not registered any driver or you have only added them as operators with driver privileges."
  );

  Future<void> getDriversFromCloud() async {
    await tryAsync("getDriversFromCloud", () async {
      if(mounted) setState(() => loading = true);
      await busNotifier.getDrivers();
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  Future<void> getDrivers() async {
    if(drivers.isEmpty) await getDriversFromCloud();
  }

  Future<void> refresh() async {
    await getDriversFromCloud();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getDrivers();
    });
    super.initState();
    busNotifier.addListener((){
      if(mounted && busNotifier.driverDetails.isNotEmpty){
        setState(() => drivers = busNotifier.driverDetails);
      }
    });
  }

  @override
  void dispose() {
    busNotifier.removeListener((){});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: loading? LoadingComponent(
        shimmerType: 3,
        height: screen.height,
      )
          :
      Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spacer.height,
              if(busNotifier.driverDetails.isNotEmpty) Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: drivers.length,
                  itemBuilder: (context, index){
                    return DashboardDriverComponent(driver: drivers[index]);
                  }
                ),
              ),
              if(busNotifier.driverDetails.isEmpty) Expanded(
                child: Center(child: noDriver,)
              ),
              largeSpacer.height
            ],
          ),
          Positioned(
            right: 40,
            bottom: 80,
            child: FloatingActionButton(
              foregroundColor: prudColorTheme.bgC,
              backgroundColor: prudColorTheme.primary,
              tooltip: "Refreshes data from PrudServices",
              onPressed: refresh,
              child: const Icon(FontAwesomeIcons.arrowsRotate, size: 30,),
            )
          )
        ],
      ),
    );
  }
}
