import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/user.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';

class OperatorComponent extends StatefulWidget {
  final BusBrandOperator operator;

  const OperatorComponent({super.key, required this.operator});

  @override
  OperatorComponentState createState() => OperatorComponentState();
}

class OperatorComponentState extends State<OperatorComponent> {
  bool selected = false;
  User? ben;
  bool getting = false;

  Future<void> getOperatorDetails() async {
    await tryAsync("getOperatorDetails", () async{
      if(mounted) setState(() => getting = true);
      User? found = await influencerNotifier.getInfluencerById(widget.operator.affId);
      if(mounted) {
        setState(() {
          ben = found;
          getting = false;
        });
      }
    }, error: (){
      if(mounted) setState(() => getting = false);
    });
  }

  @override
  void dispose() {
    busNotifier.removeListener((){});
    super.dispose();
  }

  String getImage(){
    switch(widget.operator.role.toLowerCase()){
      case "admin": return prudImages.account;
      case "driver": return prudImages.driver;
      default: return prudImages.operators;
    }
  }

  @override
  void initState() {
    super.initState();
    busNotifier.addListener((){
      tryOnly("BusNotifier Listens", (){
        if(mounted && busNotifier.selectedOperator != null && busNotifier.selectedOperator!.id != null){
          selected = busNotifier.selectedOperator!.id == widget.operator.id;
        }
      });
    });
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
                  color: selected? prudColorTheme.primary : prudColorTheme.bgB,
                  width: 5.0
              )
          )
      ),
      child: Row(
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
                        fontSize: 13,
                      ),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      "${ben!.email}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        color: prudColorTheme.iconC,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      "${ben!.phoneNo} | ${ben?.status}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        color: prudColorTheme.iconB,
                        fontSize: 9,
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
                widget.operator.role,
                style: tabData.tBStyle.copyWith(
                    fontSize: 14,
                    color: prudColorTheme.secondary
                ),
              ),
              spacer.width,
              Text(
                widget.operator.status,
                style: tabData.tBStyle.copyWith(
                    fontSize: 14,
                    color: prudColorTheme.primary
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
