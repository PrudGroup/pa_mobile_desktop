import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prudapp/components/bus_component.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/bus/bus_details_view.dart';

import '../../../../../../../components/loading_component.dart';
import '../../../../../../../models/bus_models.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/i_cloud.dart';
import '../../../../../../../singletons/tab_data.dart';

class ExistingBuses extends StatefulWidget {
  const ExistingBuses({super.key});

  @override
  ExistingBusesState createState() => ExistingBusesState();
}

class ExistingBusesState extends State<ExistingBuses> {

  List<BusDetail> buses = busNotifier.busDetails;
  bool loading = false;
  Widget noDriver = tabData.getNotFoundWidget(
    title: "No Bus Found",
    desc: "You have not registered any bus yet"
  );
  int selectedIndex = -1;
  bool showFloatingButton = busNotifier.showFloatingButton;

  void select(BusDetail bus, int index){
    if(mounted){
      setState(() {
        selectedIndex = index;
      });
      iCloud.goto(context, BusDetailsView(detail: bus, isOperator: true,));
    }
  }

  Future<void> getBusesFromCloud() async {
    await tryAsync("getBusesFromCloud", () async {
      if(mounted) setState(() => loading = true);
      await busNotifier.getBusesFromCloud();
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  Future<void> getBuses() async {
    if(buses.isEmpty) await getBusesFromCloud();
  }

  Future<void> refresh() async {
    await getBusesFromCloud();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getBuses();
    });
    super.initState();
    busNotifier.addListener((){
      if(mounted && busNotifier.busDetails.isNotEmpty){
        setState(() => buses = busNotifier.busDetails);
      }
      if(mounted) setState(() => showFloatingButton = busNotifier.showFloatingButton);
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
              if(buses.isNotEmpty) Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: buses.length,
                  itemBuilder: (context, index){
                    BusDetail bus = buses[index];
                    return InkWell(
                      onTap: () => select(bus, index),
                      child: BusComponent(
                        bus: buses[index],
                        isOperator: true,
                        isForSelection: false,
                        isSelected: index == selectedIndex
                      ),
                    );
                  }
                ),
              ),
              if(busNotifier.driverDetails.isEmpty) Expanded(
                child: Center(child: noDriver,)
              ),
              spacer.height
            ],
          ),
          if(showFloatingButton) Positioned(
              right: 15,
              bottom: 80,
              child: FloatingActionButton.small(
                foregroundColor: prudColorTheme.bgC,
                backgroundColor: prudColorTheme.primary,
                tooltip: "Refreshes data from PrudServices",
                onPressed: refresh,
                child: loading? LoadingComponent(
                  isShimmer: false,
                  size: 25,
                  spinnerColor: prudColorTheme.bgA,
                ) : const Icon(FontAwesomeIcons.arrowsRotate, size: 25,),
              )
          )
        ],
      ),
    );
  }
}
