import 'package:flutter/material.dart';

import '../models/bus_models.dart';
import '../models/theme.dart';
import '../singletons/bus_notifier.dart';
import '../singletons/tab_data.dart';
import 'bus_seat_component.dart';
import 'loading_component.dart';

class SelectBusSeatComponent extends StatefulWidget {
  final bool onlyActive;
  final List<String>? excludeIds;
  final String busId;
  
  const SelectBusSeatComponent({
    super.key, 
    required this.onlyActive, 
    this.excludeIds, 
    required this.busId
  });

  @override
  SelectBusSeatComponentState createState() => SelectBusSeatComponentState();
}

class SelectBusSeatComponentState extends State<SelectBusSeatComponent> {
  bool loading = false;
  List<BusSeat> seats = [];
  Widget noSeats = tabData.getNotFoundWidget(
      title: "No Bus Seat",
      desc: "No bus seat was found. You can start by creating one if you own this bus."
  );

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getSeats();
    });
    super.initState();
  }

  void choose(BusSeat busSeat, BuildContext context){
    busNotifier.updateSelectedBusSeat(busSeat);
    Navigator.pop(context);
  }

  Future<void> getSeatsFromCloud() async {
    await tryAsync("getSeatsFromCloud", () async {
      List<BusSeat>? sts = await busNotifier.getBusSeatsViaId(widget.busId);
      if(sts != null && sts.isNotEmpty && mounted){
        setState(() {
          seats = getList(sts);
        });
      }
    });
  }

  Future<void> getSeats() async {
    await tryAsync("getSeats", () async {
      if(mounted) setState(() => loading = true);
      if(busNotifier.busDetails.isNotEmpty){
        BusDetail bus = busNotifier.busDetails.where((BusDetail bs) => bs.bus.id == widget.busId).first;
        if(mounted && bus.seats.isNotEmpty) {
          setState(() {
            seats = getList(bus.seats);
          });
        }else{
          await getSeatsFromCloud();
        }
      }else{
        await getSeatsFromCloud();
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  List<BusSeat> getList(List<BusSeat> sts){
    List<BusSeat> found = widget.onlyActive? sts.where((ele) => ele.status.toLowerCase() != "bad").toList() : sts;
    List<BusSeat> reversed = found.reversed.toList();
    if(widget.excludeIds != null && widget.excludeIds!.isNotEmpty){
      return reversed.where((ele) {
        return widget.excludeIds!.contains(ele.id)? false : true;
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
            seats.isEmpty?
            Center(child: noSeats,)
                :
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: seats.length,
              itemBuilder: (context, index){
                BusSeat bs = seats[index];
                return InkWell(
                  onTap: () => choose(bs, context),
                  child: BusSeatComponent(seat: bs),
                );
              }
            )
        ),
      ),
    );
  }
}
