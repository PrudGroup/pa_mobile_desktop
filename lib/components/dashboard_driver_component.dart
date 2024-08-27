import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/images.dart';
import '../models/theme.dart';
import '../models/user.dart';
import '../singletons/shared_local_storage.dart';
import 'loading_component.dart';

class DashboardDriverComponent extends StatefulWidget {
  final DriverDetails driver;
  const DashboardDriverComponent({super.key, required this.driver});

  @override
  DashboardDriverComponentState createState() => DashboardDriverComponentState();
}

class DashboardDriverComponentState extends State<DashboardDriverComponent> {
  BusBrandDriver? driver;
  User? driverDetail;
  bool loading = false;
  bool unblocking = false;
  bool blocking = false;
  bool deleting = false;


  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> updateStatus(bool status) async {
    int index = busNotifier.driverDetails.indexWhere((DriverDetails ele) => ele.dr.id == widget.driver.dr.id);
    if(index != -1){
      DriverDetails drd = busNotifier.driverDetails[index];
      drd.dr.active = status;
      busNotifier.driverDetails[index] = drd;
      await busNotifier.saveDriverDetailsToCache();
      return true;
    }else{
      return false;
    }
  }

  Future<bool> removeFromCache() async {
    int index = busNotifier.driverDetails.indexWhere((DriverDetails ele) => ele.dr.id == widget.driver.dr.id);
    if(index != -1){
      DriverDetails drd = busNotifier.driverDetails.removeAt(index);
      await busNotifier.saveDriverDetailsToCache();
      debugPrint("deleted ${drd.dr.id} driver");
      return true;
    }else{
      return false;
    }
  }

  Future<void> unblock() async{
    Navigator.pop(context);
    if(!unblocking && !blocking && !deleting){
      await tryAsync("unblock", () async {
        if(mounted) setState(() => unblocking = true);
        bool succeeded = await busNotifier.unblockDriver(driver!.id!);
        if(succeeded){
          bool saved = await updateStatus(true);
          if(saved){
            widget.driver.dr.active = true;
            if(mounted) {
              iCloud.showSnackBar("Unblocked", context, title: "Driver", type: 2);
              setState(() {
                driver!.active = true;
                unblocking = false;
              });
            }
          }else{
            if(mounted) {
              iCloud.showSnackBar("Unable To unblock", context);
              setState(() => unblocking = false);
            }
          }
        } else{
          if(mounted) {
            iCloud.showSnackBar("Unable To unblock", context);
            setState(() => unblocking = false);
          }
        }
      }, error: (){
        if(mounted) setState(() => unblocking = false);
      });
    }
  }

  Future<void> block() async{
    Navigator.pop(context);
    if(!unblocking && !blocking && !deleting){
      await tryAsync("block", () async {
        if(mounted) setState(() => blocking = true);
        bool succeeded = await busNotifier.blockDriver(driver!.id!);
        if(succeeded){
          bool saved = await updateStatus(false);
          if(saved){
            widget.driver.dr.active = false;
            if(mounted) {
              iCloud.showSnackBar("Blocked", context, title: "Driver", type: 2);
              setState(() {
                driver!.active = true;
                blocking = false;
              });
            }
          }else{
            if(mounted) {
              iCloud.showSnackBar("Unable To block", context);
              setState(() => blocking = false);
            }
          }
        } else{
          if(mounted) {
            iCloud.showSnackBar("Unable To block", context);
            setState(() => blocking = false);
          }
        }
      }, error: (){
        if(mounted) setState(() => blocking = false);
      });
    }
  }

  Future<void> delete() async{
    Navigator.pop(context);
    if(!unblocking && !blocking && !deleting){
      await tryAsync("delete", () async {
        if(mounted) setState(() => deleting = true);
        bool succeeded = await busNotifier.deleteDriver(driver!.id!);
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
  }

  String getImage(){
    switch(driver?.rank){
      case "Junior": return prudImages.busDriver;
      case "Senior": return prudImages.driver;
      default: return prudImages.bus;
    }
  }
  
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted) {
        setState(() {
          driver = widget.driver.dr;
          driverDetail = widget.driver.detail;
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
            color: prudColorTheme.primary,
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
                      child: ImageIcon(AssetImage(getImage()), size: 30,),
                    ),
                  ),
                  spacer.width,
                  if(driver != null && driverDetail != null && !loading) Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          "${driverDetail!.fullName}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.textA,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          "${driverDetail!.email}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.iconC,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          "${driverDetail!.phoneNo} | Active: ${driver?.active}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.iconB,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(loading || driver == null || driverDetail == null) Center(
                    child: LoadingComponent(
                      defaultSpinnerType: false,
                      isShimmer: false,
                      size: 20,
                      spinnerColor: prudColorTheme.lineC,
                    ),
                  ),
                ],
              ),
              if(driver != null && driverDetail != null && !loading) Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${driver?.rank}",
                    style: tabData.tBStyle.copyWith(
                        fontSize: 14,
                        color: prudColorTheme.secondary
                    ),
                  ),
                  spacer.width,
                  Text(
                    driver!.active? "ACTIVE" : "BLOCKED",
                    style: tabData.tBStyle.copyWith(
                        fontSize: 14,
                        color: prudColorTheme.primary
                    ),
                  )
                ],
              )
            ],
          ),
          if(driver != null) Column(
            children: [
              Divider(
                height: 10,
                thickness: 2,
                indent: 10.0,
                endIndent: 10.0,
                color: prudColorTheme.bgC,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(!driver!.active) (
                    unblocking?
                    LoadingComponent(
                      isShimmer: false,
                      size: 20,
                      defaultSpinnerType: false,
                      spinnerColor: prudColorTheme.primary,
                    )
                        :
                    getTextButton(
                      title: "UNBLOCK",
                      onPressed: () => Alert(
                        context: context,
                        style: myStorage.alertStyle,
                        type: AlertType.warning,
                        title: "Unblock Driver",
                        desc: "You are about to unblock a driver(${widget.driver.detail.fullName}).",
                        buttons: [
                          DialogButton(
                            onPressed: unblock,
                            color: prudColorTheme.primary,
                            radius: BorderRadius.zero,
                            child: const Text(
                              "Unblock",
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
                  ),
                  if(driver!.active) (
                    blocking?
                    LoadingComponent(
                      isShimmer: false,
                      size: 20,
                      defaultSpinnerType: false,
                      spinnerColor: prudColorTheme.primary,
                    )
                        :
                    getTextButton(
                      title: "BLOCK",
                      onPressed: () => Alert(
                        context: context,
                        style: myStorage.alertStyle,
                        type: AlertType.warning,
                        title: "Block Driver",
                        desc: "You are about to block a driver(${widget.driver.detail.fullName}).",
                        buttons: [
                          DialogButton(
                            onPressed: block,
                            color: prudColorTheme.primary,
                            radius: BorderRadius.zero,
                            child: const Text(
                              "Block",
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
                  ),
                  deleting?
                  LoadingComponent(
                    isShimmer: false,
                    size: 20,
                    defaultSpinnerType: false,
                    spinnerColor: prudColorTheme.primary,
                  )
                      :
                  getTextButton(
                    title: "DELETE",
                    onPressed: () => Alert(
                      context: context,
                      style: myStorage.alertStyle,
                      type: AlertType.warning,
                      title: "Delete Driver",
                      desc: "You are about to delete a driver(${widget.driver.detail.fullName}).",
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
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
  
}
