import 'package:flutter/material.dart';

import '../models/bus_models.dart';
import '../models/theme.dart';
import '../singletons/bus_notifier.dart';
import '../singletons/tab_data.dart';
import 'bus_feature_component.dart';
import 'loading_component.dart';

class SelectBusFeatureComponent extends StatefulWidget {
  final bool onlyActive;
  final List<String>? excludeIds;
  final String busId;
  
  const SelectBusFeatureComponent({
    super.key, required this.onlyActive, 
    this.excludeIds, required this.busId
  });

  @override
  SelectBusFeatureComponentState createState() => SelectBusFeatureComponentState();
}

class SelectBusFeatureComponentState extends State<SelectBusFeatureComponent> {
  bool loading = false;
  List<BusFeature> features = [];
  Widget noFeatures = tabData.getNotFoundWidget(
      title: "No Bus Feature",
      desc: "No bus feature was found. You can start by creating one if you own this bus."
  );

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getFeatures();
    });
    super.initState();
  }

  void choose(BusFeature busFeature, BuildContext context){
    busNotifier.updateSelectedBusFeature(busFeature);
    Navigator.pop(context);
  }

  Future<void> getFeaturesFromCloud() async {
    await tryAsync("getFeaturesFromCloud", () async {
      List<BusFeature>? sts = await busNotifier.getBusFeaturesViaId(widget.busId);
      if(sts != null && sts.isNotEmpty && mounted){
        setState(() {
          features = getList(sts);
        });
      }
    });
  }

  Future<void> getFeatures() async {
    await tryAsync("getFeatures", () async {
      if(mounted) setState(() => loading = true);
      if(busNotifier.busDetails.isNotEmpty){
        BusDetail bus = busNotifier.busDetails.where((BusDetail bs) => bs.bus.id == widget.busId).first;
        if(mounted && bus.features.isNotEmpty) {
          setState(() {
            features = getList(bus.features);
          });
        }else{
          await getFeaturesFromCloud();
        }
      }else{
        await getFeaturesFromCloud();
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  List<BusFeature> getList(List<BusFeature> sts){
    List<BusFeature> found = widget.onlyActive? sts.where((ele) => ele.status.toLowerCase() != "bad").toList() : sts;
    List<BusFeature> reversed = found.reversed.toList();
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
            features.isEmpty?
            Center(child: noFeatures,)
                :
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: features.length,
              itemBuilder: (context, index){
                BusFeature bf = features[index];
                return InkWell(
                  onTap: () => choose(bf, context),
                  child: BusFeatureComponent(feature: bf),
                );
              }
            )
        ),
      ),
    );
  }
}
