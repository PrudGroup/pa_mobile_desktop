import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/bus_models.dart';
import '../models/images.dart';
import '../models/theme.dart';
import '../singletons/bus_notifier.dart';
import '../singletons/i_cloud.dart';
import '../singletons/shared_local_storage.dart';
import '../singletons/tab_data.dart';
import 'loading_component.dart';

class BusComponent extends StatefulWidget {
  final BusDetail bus;
  final bool isOperator;
  final bool isForSelection;
  final bool isSelected;

  const BusComponent({
    super.key,
    required this.bus,
    this.isOperator = false,
    this.isForSelection = true,
    this.isSelected = false,
  });

  @override
  BusComponentState createState() => BusComponentState();
}

class BusComponentState extends State<BusComponent> {

  Bus? bus;
  List<BusImage>? images;
  bool loading = false;
  bool unblocking = false;
  bool blocking = false;
  bool deleting = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> updateStatus(bool status) async {
    int index = busNotifier.busDetails.indexWhere((BusDetail ele) => ele.bus.id == widget.bus.bus.id);
    if(index != -1){
      BusDetail bDl = busNotifier.busDetails[index];
      bDl.bus.active = status;
      busNotifier.busDetails[index] = bDl;
      await busNotifier.saveBusDetailsToCache();
      return true;
    }else{
      return false;
    }
  }

  Future<bool> removeFromCache() async {
    int index = busNotifier.busDetails.indexWhere((BusDetail ele) => ele.bus.id == widget.bus.bus.id);
    if(index != -1){
      BusDetail drd = busNotifier.busDetails.removeAt(index);
      await busNotifier.saveBusDetailsToCache();
      debugPrint("deleted ${drd.bus.id} bus");
      return true;
    }else{
      return false;
    }
  }

  Future<void> delete() async{
    Navigator.pop(context);
    await tryAsync("delete", () async {
      if(mounted) setState(() => deleting = true);
      bool succeeded = await busNotifier.deleteBus(bus!.id!);
      if(succeeded){
        bool removed = await removeFromCache();
        if(removed){
          if(mounted) {
            iCloud.showSnackBar("Deleted", context, title: "Driver", type: 2);
            setState(() => deleting = false);
          }
        }else{
          if(mounted) {
            iCloud.showSnackBar("Unable To delete", context);
            setState(() => deleting = false);
          }
        }
      } else{
        if(mounted) {
          iCloud.showSnackBar("Unable To delete", context);
          setState(() => deleting = false);
        }
      }
    }, error: (){
      if(mounted) setState(() => deleting = false);
    });
  }


  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted) {
        setState(() {
          bus = widget.bus.bus;
          images = widget.bus.images;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10,5,10,5),
      decoration: BoxDecoration(
        color: prudColorTheme.bgA,
        border: Border(
          bottom: BorderSide(
            color: prudColorTheme.lineC,
            width: 5.0
          )
        )
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GFAvatar(
                    backgroundColor: prudColorTheme.lineC,
                    size: GFSize.SMALL,
                    child: Center(
                      child: ImageIcon(AssetImage(prudImages.bus), size: 30,),
                    ),
                  ),
                  spacer.width,
                  if(bus != null && images != null && !loading) Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          "${bus!.busType} ${bus!.busNo}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.textA,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          "${bus!.busManufacturer} ${bus!.manufacturedYear}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.iconC,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          "${bus!.plateNo} | Active: ${bus?.active}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.iconB,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(loading || bus == null || images == null) Center(
                    child: LoadingComponent(
                      defaultSpinnerType: false,
                      isShimmer: false,
                      size: 20,
                      spinnerColor: prudColorTheme.lineC,
                    ),
                  ),
                ],
              ),
              if(bus != null && images != null && !loading) Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Journeys: ${bus?.totalJourney}",
                    style: tabData.tBStyle.copyWith(
                        fontSize: 14,
                        color: prudColorTheme.secondary
                    ),
                  ),
                  spacer.width,
                  Text(
                    bus!.active? "ACTIVE" : "BLOCKED",
                    style: tabData.tBStyle.copyWith(
                        fontSize: 14,
                        color: prudColorTheme.primary
                    ),
                  ),
                  GFRating(
                    onChanged: (rate){},
                    value: bus!.votes > 0? bus!.votes/bus!.voters : 0,
                    size: 15,
                  ),
                ],
              )
            ],
          ),
          if(bus != null && !widget.isForSelection) Column(
            children: [
              Divider(
                height: 10,
                thickness: 2,
                indent: 10.0,
                endIndent: 10.0,
                color: prudColorTheme.bgC,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  deleting?
                  LoadingComponent(
                    isShimmer: false,
                    size: 20,
                    defaultSpinnerType: false,
                    spinnerColor: prudColorTheme.primary,
                  )
                      :
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: prudColorTheme.warning,
                    iconSize: 25,
                    onPressed: () => Alert(
                      context: context,
                      style: myStorage.alertStyle,
                      type: AlertType.warning,
                      title: "Delete Bus",
                      desc: "You are about to delete (${bus!.busNo}) bus from your collection.",
                      buttons: [
                        DialogButton(
                          onPressed: delete,
                          color: prudColorTheme.primary,
                          radius: BorderRadius.zero,
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        DialogButton(
                          onPressed: () => Navigator.pop(context),
                          color: prudColorTheme.primary,
                          radius: BorderRadius.zero,
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ],
                    ).show(),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
