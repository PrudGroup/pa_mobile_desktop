import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/models/bus_models.dart';

import '../models/theme.dart';
import '../singletons/bus_notifier.dart';
import '../singletons/tab_data.dart';
import 'loading_component.dart';

class SelectBusImageComponent extends StatefulWidget {
  final bool onlyActive;
  final List<String>? excludeIds;
  final String busId;

  const SelectBusImageComponent({
    super.key,
    required this.onlyActive,
    this.excludeIds,
    required this.busId
  });

  @override
  SelectBusImageComponentState createState() => SelectBusImageComponentState();
}

class SelectBusImageComponentState extends State<SelectBusImageComponent> {
  bool loading = false;
  List<BusImage> images = [];
  Widget noImages = tabData.getNotFoundWidget(
      title: "No Bus Photo",
      desc: "No bus photo was found. You can start by creating one if you own this bus."
  );

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getImages();
    });
    super.initState();
  }

  void choose(BusImage busImage, BuildContext context){
    busNotifier.updateSelectedBusImage(busImage);
    Navigator.pop(context);
  }

  Future<void> getImagesFromCloud() async {
    await tryAsync("getImagesFromCloud", () async {
      List<BusImage>? imgs = await busNotifier.getBusImagesViaId(widget.busId);
      if(imgs != null && imgs.isNotEmpty && mounted){
        setState(() {
          images = getList(imgs);
        });
      }
    });
  }

  Future<void> getImages() async {
    await tryAsync("getImages", () async {
      if(mounted) setState(() => loading = true);
      if(busNotifier.busDetails.isNotEmpty){
        BusDetail? bus = busNotifier.busDetails.where((BusDetail bs) => bs.bus.id == widget.busId).first;
        if(mounted && bus.images.isNotEmpty) {
          setState(() {
            images = getList(bus.images);
          });
        }else{
          await getImagesFromCloud();
        }
      }else{
        await getImagesFromCloud();
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  List<BusImage> getList(List<BusImage> imgs){
    List<BusImage> found = widget.onlyActive? imgs.where((ele) => ele.id != null).toList() : imgs;
    List<BusImage> reversed = found.reversed.toList();
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
    double modalHeight = height * 0.35;
    double displayContainerHeight = modalHeight - 60;
    return Container(
      height: modalHeight,
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
          images.isEmpty?
          Center(child: noImages,)
              :
          SizedBox(
            height: displayContainerHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: images.length,
              itemBuilder: (context, index){
                BusImage bi = images[index];
                return InkWell(
                  onTap: () => choose(bi, context),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: PrudNetworkImage(
                      url: bi.imgUrl,
                      height: displayContainerHeight - 5,
                    ),
                  ),
                );
              }
            ),
          )
        ),
      ),
    );
  }
}
