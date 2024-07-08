import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';


class BeneficiaryComponent extends StatefulWidget {
  final bool forSelection;
  final Beneficiary ben;

  const BeneficiaryComponent({
    super.key,
    this.forSelection = true,
    required this.ben,
  });

  @override
  BeneficiaryComponentState createState() => BeneficiaryComponentState();
}

class BeneficiaryComponentState extends State<BeneficiaryComponent> {
  bool selected = false;
  Beneficiary? ben;

  @override
  void dispose() {
    beneficiaryNotifier.removeListener((){});
    super.dispose();
  }

  bool containsBen(){
    bool yes = false;
    try{
      int found = beneficiaryNotifier.selectedBeneficiaries.indexWhere((b) =>
        b.email == widget.ben.email && b.fullName == widget.ben.fullName
      );
      if(found > -1) yes = true;
    }catch(ex){
      yes = false;
    }
    return yes;
  }

  @override
  void initState() {
    if(mounted){
      setState(() {
        ben = widget.ben;
        selected = containsBen();
        debugPrint("Ben_selected: $selected");
      });
    }
    beneficiaryNotifier.addListener((){
      try{
        if(ben != null && mounted){
          selected = containsBen();
        }
      }catch(ex){
        debugPrint("beneficiaryNotifier Listener Error: $ex");
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
              if(widget.forSelection) Checkbox(
                value: selected,
                onChanged: (bool? value) async {
                  try{
                    if(mounted && value != null && ben != null){
                      if(value == true){
                        if(!containsBen()) beneficiaryNotifier.addBeneficiary(ben!);
                      }else{
                        beneficiaryNotifier.removeBeneficiary(ben!);
                      }
                    }
                  }catch(ex){
                    debugPrint("Select Ben: $ex");
                  }
                },
                activeColor: prudColorTheme.primary,
                focusColor: prudColorTheme.buttonB,
                checkColor: prudColorTheme.bgA,
              ),
              if(widget.forSelection) spacer.width,
              ben!.isAvatar? GFAvatar(
                backgroundImage: AssetImage(ben!.avatar),
                size: GFSize.SMALL,
              )
                  :
              GFAvatar(
                backgroundImage: MemoryImage(ben!.photo),
                size: GFSize.SMALL,
              ),
              spacer.width,
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      ben!.fullName,
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        color: prudColorTheme.textA,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      ben!.email,
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        color: prudColorTheme.iconC,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      "${ben!.phoneNo} | ${ben?.gender}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        color: prudColorTheme.iconB,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    "${tabData.getCurrencySymbol(ben!.currencyCode)}",
                    style: tabData.tBStyle.copyWith(
                        fontSize: 14,
                        color: prudColorTheme.secondary
                    ),
                  ),
                  Text(
                    ben!.currencyCode,
                    style: tabData.tBStyle.copyWith(
                        fontSize: 18,
                        color: prudColorTheme.primary
                    ),
                  )
                ],
              ),
              Text(
                "${tabData.getCountryFlag(ben!.countryCode)}",
                style: prudWidgetStyle.hintStyle.copyWith(
                    fontSize: 15.0
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
