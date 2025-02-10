import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/user.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/theme.dart';
import '../singletons/i_cloud.dart';
import '../singletons/shared_local_storage.dart';

class OperatorComponent extends StatefulWidget {
  final OperatorDetails operator;
  final bool showControls;

  const OperatorComponent({super.key, required this.operator, this.showControls = false});

  @override
  OperatorComponentState createState() => OperatorComponentState();
}

class OperatorComponentState extends State<OperatorComponent> {
  bool selected = false;
  User? ben;
  BusBrandOperator? operator;
  bool getting = false;
  bool unblocking = false;
  bool blocking = false;
  bool deleting = false;


  Future<bool> updateStatus(bool status) async {
    int index = busNotifier.operatorDetails.indexWhere((OperatorDetails ele) => ele.op.id == widget.operator.op.id);
    if(index != -1){
      OperatorDetails drd = busNotifier.operatorDetails[index];
      drd.op.status = status? "ACTIVE" : "BLOCKED";
      busNotifier.operatorDetails[index] = drd;
      await busNotifier.saveOperatorDetailsToCache();
      return true;
    }else{
      return false;
    }
  }

  Future<bool> removeFromCache() async {
    int index = busNotifier.operatorDetails.indexWhere((OperatorDetails ele) => ele.op.id == widget.operator.op.id);
    if(index != -1){
      OperatorDetails drd = busNotifier.operatorDetails.removeAt(index);
      await busNotifier.saveOperatorDetailsToCache();
      debugPrint("deleted ${drd.op.id} operator");
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
        bool succeeded = await busNotifier.unblockOperator(operator!.id!);
        if(succeeded){
          bool saved = await updateStatus(true);
          if(saved){
            widget.operator.op.status = "ACTIVE";
            if(mounted) {
              iCloud.showSnackBar("Unblocked", context, title: "Operator", type: 2);
              setState(() {
                operator!.status = "ACTIVE";
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
        bool succeeded = await busNotifier.blockOperator(operator!.id!);
        if(succeeded){
          bool saved = await updateStatus(true);
          if(saved){
            widget.operator.op.status = "BLOCKED";
            if(mounted) {
              iCloud.showSnackBar("Blocked", context, title: "Operator", type: 2);
              setState(() {
                operator!.status = "BLOCKED";
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
        bool succeeded = await busNotifier.deleteOperator(operator!.id!);
        if(succeeded){
          bool removed = await removeFromCache();
          if(removed){
            if(mounted) {
              iCloud.showSnackBar("Deleted", context, title: "Operator", type: 2);
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


  @override
  void dispose() {
    busNotifier.removeListener((){});
    super.dispose();
  }

  String getImage(){
    switch(operator?.role.toLowerCase()){
      case "admin": return prudImages.account;
      case "driver": return prudImages.driver;
      default: return prudImages.operators;
    }
  }

  @override
  void initState() {
    if(mounted){
      setState(() {
        operator = widget.operator.op;
        ben = widget.operator.detail;
      });
    }
    super.initState();
    busNotifier.addListener((){
      tryOnly("BusNotifier Listens", (){
        if(mounted && busNotifier.selectedOperator != null && busNotifier.selectedOperator!.op.id != null){
          selected = busNotifier.selectedOperator!.op.id == widget.operator.op.id;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
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
            if(ben != null && !getting) Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    "${ben!.fullName}",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.textA,
                      fontSize: 14,
                    ),
                  ),
                ),
                FittedBox(
                  child: Text(
                    "${ben!.email}",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.iconC,
                      fontSize: 12,
                    ),
                  ),
                ),
                FittedBox(
                  child: Text(
                    "${ben!.phoneNo} | ${ben?.country}",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.iconB,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            if(getting || ben == null) Center(
              child: LoadingComponent(
                defaultSpinnerType: false,
                isShimmer: false,
                size: 20,
                spinnerColor: prudColorTheme.lineC,
              ),
            ),
          ],
        ),
        if(ben != null && !getting) Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${operator?.role}",
              style: tabData.tBStyle.copyWith(
                  fontSize: 14,
                  color: prudColorTheme.secondary
              ),
            ),
            spacer.width,
            Text(
              "${operator?.status}",
              style: tabData.tBStyle.copyWith(
                  fontSize: 14,
                  color: prudColorTheme.primary
              ),
            )
          ],
        )
      ],
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10,5,10,5),
      decoration: BoxDecoration(
        color: prudColorTheme.bgA,
        border: Border(
              bottom: BorderSide(
                  color: selected? prudColorTheme.primary : prudColorTheme.bgB,
                  width: 5.0
              )
          )
      ),
      child: widget.showControls? Column(
        children: [
          child,
          if(operator != null) Column(
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
                  if(operator!.status.toLowerCase() == "blocked") (
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
                        title: "Unblock Operator",
                        desc: "You are about to unblock ${ben!.fullName} as an operator.",
                        buttons: [
                          DialogButton(
                            onPressed: unblock,
                            color: prudColorTheme.primary,
                            radius: BorderRadius.zero,
                            child: const Translate(
                              text:"Unblock",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          DialogButton(
                            onPressed: () => Navigator.pop(context),
                            color: prudColorTheme.primary,
                            radius: BorderRadius.zero,
                            child: const Translate(
                              text:"Cancel",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ],
                      ).show(),
                    )
                  ),
                  if(operator!.status.toLowerCase() == "active") (
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
                          title: "Block Operator",
                          desc: "You are about to block ${ben!.fullName} as an operator.",
                          buttons: [
                            DialogButton(
                              onPressed: block,
                              color: prudColorTheme.primary,
                              radius: BorderRadius.zero,
                              child: const Translate(
                                text:"Block",
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ),
                            DialogButton(
                              onPressed: () => Navigator.pop(context),
                              color: prudColorTheme.primary,
                              radius: BorderRadius.zero,
                              child: const Translate(
                                text: "Cancel",
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
                      title: "Delete Operator",
                      desc: "You are about to delete ${ben!.fullName} as an operator.",
                      buttons: [
                        DialogButton(
                          onPressed: delete,
                          color: prudColorTheme.primary,
                          radius: BorderRadius.zero,
                          child: const Translate(
                            text: "Delete",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        DialogButton(
                          onPressed: () => Navigator.pop(context),
                          color: prudColorTheme.primary,
                          radius: BorderRadius.zero,
                          child: const Translate(
                            text: "Cancel",
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
      ) 
          : child,
    );
  }
}
