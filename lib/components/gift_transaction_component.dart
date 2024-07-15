import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/giftcards/transaction_details.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../singletons/i_cloud.dart';
import 'Translate.dart';

class GiftTransactionComponent extends StatefulWidget{
  final GiftTransactionDetails tranDetails;
  final GiftTransaction? tran;

  const GiftTransactionComponent({
    super.key, required this.tranDetails, this.tran
  });

  @override
  GiftTransactionComponentState createState() => GiftTransactionComponentState();
}

class GiftTransactionComponentState extends State<GiftTransactionComponent> {
  GiftTransaction? tran;
  bool selected = false;
  bool loading = false;

  void navigate(){
    if(tran != null){
      iCloud.goto(context, TransactionDetails(trans: tran!, tranDetails: widget.tranDetails,));
    }
  }

  @override
  void dispose() {
    giftCardNotifier.removeListener((){});
    super.dispose();
  }

  Future<void> getTransaction() async {
    try{
      if(mounted) setState(() => loading = true);
      if(widget.tran != null){
        if(mounted){
          setState(() {
            tran = widget.tran;
            loading = false;
          });
        }
      }else{
        if(widget.tranDetails.transId != null) {
          GiftTransaction? dTran = await giftCardNotifier.getTransactionById(
              widget.tranDetails.transId!);
          if(mounted){
            setState(() {
              tran = dTran;
              loading = false;
            });
          }
        }
      }
    }catch(ex){
      if(mounted) setState(() => loading = false);
      debugPrint("GiftTransactionComponent.getTransaction Error: $ex");
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted && giftCardNotifier.selectedTransDetail != null){
        setState(() {
          selected = widget.tranDetails.transId == giftCardNotifier.selectedTransDetail!.transId;
        });
      }
      await getTransaction();
    });
    super.initState();
    giftCardNotifier.addListener((){
      if(mounted && giftCardNotifier.selectedTransDetail != null){
        setState(() {
          selected = widget.tranDetails.transId == giftCardNotifier.selectedTransDetail!.transId;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: navigate,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 35),
            padding: const EdgeInsets.fromLTRB(10,40,10,5),
            decoration: BoxDecoration(
              color: prudColorTheme.bgA,
              border: Border(
                bottom: BorderSide(
                  color: selected? prudColorTheme.primary : prudColorTheme.bgB,
                  width: 5.0
                )
              )
            ),
            child: tran != null?
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GFAvatar(
                  backgroundColor: prudColorTheme.primary,
                  child: ImageIcon(
                      AssetImage(prudImages.gift),
                    size: 30,
                    color: prudColorTheme.bgD,
                  ),
                ),
                spacer.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tabData.shortenStringWithPeriod(tran!.product?.productName?? tran!.product!.brand!.brandName!, length: 30),
                      style: prudWidgetStyle.hintStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: prudColorTheme.textA,
                      ),
                    ),
                    Text(
                      "${tran?.product?.brand?.brandName} | ${tran?.currencyCode}",
                      style: prudWidgetStyle.hintStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.textB,
                      ),
                    )
                  ],
                )
              ],
            )
                :
            SizedBox(
              height: 100,
              child: Center(
                child: LoadingComponent(
                  isShimmer: false,
                  spinnerColor: prudColorTheme.lineC,
                  defaultSpinnerType: false,
                  size: 30,
                ),
              ),
            ),
          ),
          if(tran != null) Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(tran!.status != null) Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: tabData.getTransactionStatusColor(tran!.status!),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: prudColorTheme.bgC,
                      width: 5
                    )
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Translate(
                        text: tabData.toTitleCase(tran!.status!),
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: prudColorTheme.secondary
                        ),
                        align: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    if(widget.tranDetails.selectedCurrencyCode != null) Container(
                      width: 120,
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: prudColorTheme.bgA,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: prudColorTheme.bgC,
                          width: 5
                        )
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 25, 5),
                          child: FittedBox(
                            child: Row(
                              children: [
                                Text(
                                  "${tabData.getCurrencySymbol(widget.tranDetails.selectedCurrencyCode!)}",
                                  style: tabData.tBStyle.copyWith(
                                    fontSize: 14,
                                    color: prudColorTheme.bgC
                                  ),
                                ),
                                Text(
                                  "${currencyMath.roundDouble(widget.tranDetails.transactionPaidInSelected!, 2)}",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: prudColorTheme.bgA,
                                  ),
                                ),
                                Text(
                                  widget.tranDetails.selectedCurrencyCode!,
                                  style: tabData.tBStyle.copyWith(
                                    fontSize: 12,
                                    color: prudColorTheme.bgC
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if(widget.tranDetails.beneficiary != null) Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: Container(
                        decoration: BoxDecoration(
                          color: prudColorTheme.bgA,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: prudColorTheme.bgC,
                            width: 5
                          )
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: widget.tranDetails.beneficiary!.isAvatar? GFAvatar(
                            backgroundImage: AssetImage(widget.tranDetails.beneficiary!.avatar),
                            size: GFSize.SMALL,
                          )
                              :
                          GFAvatar(
                            backgroundImage: MemoryImage(widget.tranDetails.beneficiary!.photo),
                            size: GFSize.SMALL,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
