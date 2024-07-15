import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/theme.dart';
import '../singletons/tab_data.dart';
import 'Translate.dart';

class GiftCartItemComponent extends StatefulWidget {
  final CartItem item;
  final int index;

  const GiftCartItemComponent({super.key, required this.item, required this.index});

  @override
  GiftCartItemComponentState createState() => GiftCartItemComponentState();
}

class GiftCartItemComponentState extends State<GiftCartItemComponent> {
  bool selected = false;
  int quantity = 1;

  @override
  void dispose() {
    giftCardNotifier.removeListener((){});
    super.dispose();
  }

  void delete(){
    Alert(
      context: context,
      type: AlertType.warning,
      style: myStorage.alertStyle,
      title: "Delete Cart Item",
      desc: "You are about to delete an item. Delete?",
      buttons: [
        DialogButton(
          onPressed: () async {
            await giftCardNotifier.removeItemFromCart(widget.item);
            giftCardNotifier.removeItemFromSelectedItems(widget.item);
            if(mounted) Navigator.pop(context);
          },
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
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }

  void checkboxClicked(){
    try{
      if(selected){
        //check value is deselected [remove]
        //if(mounted) setState(() => selected = false);
        giftCardNotifier.removeItemFromSelectedItems(widget.item);
      }else{
        giftCardNotifier.addToSelectedItems(widget.item);
      }
    }catch(ex){
      debugPrint("CheckboxClicked Error: $ex");
    }
  }

  bool containsItem(){
    bool yes = false;
    try{
      int found = giftCardNotifier.selectedItems.indexWhere((b) =>
      b.product.productId == widget.item.product.productId && b.beneficiary?.fullName == widget.item.beneficiary?.fullName
      );
      if(found > -1) yes = true;
    }catch(ex){
      yes = false;
    }
    return yes;
  }

  Future<void> reduce() async {
    try{
      if(mounted && quantity > 1) {
        setState(() => quantity-=1);
        await giftCardNotifier.changeCartItem(quantity, widget.index);
      }
    }catch(ex){
      debugPrint("Decrease Error: $ex");
    }
  }

  Future<void> increase() async {
    try{
      if(mounted) {
        setState(() => quantity+=1);
        await giftCardNotifier.changeCartItem(quantity, widget.index);
      }
    }catch(ex){
      debugPrint("Increase Error: $ex");
    }
  }

  @override
  void initState(){
    if(mounted){
      setState(() {
        selected = containsItem();
        quantity = widget.item.quantity;
      });
    }
    super.initState();
    giftCardNotifier.addListener((){
      try{
        if(mounted){
          selected = containsItem();
        }
      }catch(ex){
        debugPrint("GiftCartItemComponent Listener Error: $ex");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: prudColorTheme.bgA,
        border: Border(
          bottom: BorderSide(color: selected? prudColorTheme.primary : prudColorTheme.lineC, width: 5.0),
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: checkboxClicked,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: selected,
                      onChanged: (bool? value) async {
                        try{
                          if(mounted && value != null){
                            if(value == true){
                              if(!containsItem()) giftCardNotifier.addToSelectedItems(widget.item);
                            }else{
                              giftCardNotifier.removeItemFromSelectedItems(widget.item);
                            }
                          }
                        }catch(ex){
                          debugPrint("Select Cart Item: $ex");
                        }
                      },
                      activeColor: prudColorTheme.primary,
                      focusColor: prudColorTheme.buttonB,
                      checkColor: prudColorTheme.bgA,
                    ),
                    spacer.width,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.item.beneficiary!.isAvatar? GFAvatar(
                          backgroundImage: AssetImage(widget.item.beneficiary!.avatar),
                          size: GFSize.SMALL,
                        )
                            :
                        GFAvatar(
                          backgroundImage: MemoryImage(widget.item.beneficiary!.photo),
                          size: GFSize.SMALL,
                        ),
                        spacer.width,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: Text(
                                widget.item.beneficiary!.fullName,
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.textA,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                widget.item.beneficiary!.email,
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.iconC,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                "${widget.item.product.productName}",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.iconB,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                indent: 5,
                endIndent: 5,
                height: 10,
                color: prudColorTheme.textB,
                thickness: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: delete,
                    iconSize: 20,
                    color: prudColorTheme.primary,
                    icon: const Icon(FontAwesomeIcons.trashCan),
                  ),
                  spacer.width,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${tabData.getCurrencySymbol(widget.item.benCur)}",
                                style: tabData.tBStyle.copyWith(
                                    fontSize: 12,
                                    color: prudColorTheme.textB
                                ),
                              ),
                              Text(
                                "${currencyMath.roundDouble(widget.item.benSelectedDeno * quantity, 2)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: prudColorTheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Translate(
                              text: "Beneficiary",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: prudColorTheme.primary
                              ),
                              align: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      spacer.width,
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${tabData.getCurrencySymbol(widget.item.senderCur)}",
                                style: tabData.tBStyle.copyWith(
                                    fontSize: 12,
                                    color: prudColorTheme.textB
                                ),
                              ),
                              Text(
                                "${currencyMath.roundDouble(widget.item.totalDiscount, 2)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: prudColorTheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Translate(
                              text: "Discount",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: prudColorTheme.primary
                              ),
                              align: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      spacer.width,
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${tabData.getCurrencySymbol(widget.item.senderCur)}",
                                style: tabData.tBStyle.copyWith(
                                    fontSize: 12,
                                    color: prudColorTheme.textB
                                ),
                              ),
                              Text(
                                "${widget.item.charges}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: prudColorTheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Translate(
                              text: "Total Charges",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 6,
                                  fontWeight: FontWeight.w600,
                                  color: prudColorTheme.primary
                              ),
                              align: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            child: Center(
              child: Wrap(
                direction:  Axis.vertical,
                spacing: -5.0,
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FittedBox(
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${tabData.getCurrencySymbol(widget.item.benCur)}",
                              style: tabData.tBStyle.copyWith(
                                  fontSize: 13,
                                  color: prudColorTheme.textB
                              ),
                            ),
                            Text(
                              "${widget.item.benSelectedDeno}",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: prudColorTheme.buttonA,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Translate(
                            text: "Beneficiary",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: prudColorTheme.primary
                            ),
                            align: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FittedBox(
                    child: Wrap(
                      direction:  Axis.horizontal,
                      spacing: -5.0,
                      runAlignment: WrapAlignment.center,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        IconButton(
                          onPressed: reduce,
                          icon: const Icon(Icons.arrow_back_ios),
                          color: prudColorTheme.iconC,
                          iconSize: 15,
                        ),
                        Text(
                          "$quantity",
                          style: tabData.npStyle,
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          onPressed: increase,
                          icon: const Icon(Icons.arrow_forward_ios),
                          color: prudColorTheme.iconC,
                          iconSize: 15,
                        )
                      ],
                    ),
                  ),
                  FittedBox(
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${tabData.getCurrencySymbol(widget.item.senderCur)}",
                              style: tabData.tBStyle.copyWith(
                                  fontSize: 14,
                                  color: prudColorTheme.success
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                "${currencyMath.roundDouble(widget.item.grandTotal, 2)}",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: prudColorTheme.primary,
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Translate(
                            text: "You Pay",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: prudColorTheme.success
                            ),
                            align: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
