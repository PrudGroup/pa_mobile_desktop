import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:intl/intl.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/giftcards/transaction_details.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../singletons/i_cloud.dart';

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
      if(tran != null){
        if(mounted){
          setState(() {
            tran = tran;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GFAvatar(
                      size: GFSize.SMALL,
                      backgroundColor: prudColorTheme.primary,
                      child: ImageIcon(
                        AssetImage(prudImages.gift),
                        size: 25,
                        color: prudColorTheme.bgD,
                      ),
                    ),
                    spacer.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(tran!.product != null && tran!.product!.brand != null && tran!.product!.brand!.brandName != null) Text(
                          tabData.shortenStringWithPeriod(tran!.product?.productName?? tran!.product!.brand!.brandName!, length: 22),
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: prudColorTheme.textA,
                          ),
                        ),
                        Text(
                          "${tran?.product?.brand?.brandName} | ${widget.tranDetails.selectedCurrencyCode}",
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.textB,
                          ),
                        ),
                        Text(
                          "${widget.tranDetails.beneficiary?.fullName}",
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.primary,
                          ),
                        )
                      ],
                    )
                  ],
                ),
                if(tran!.transactionCreatedTime != null) Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      myStorage.ago(dDate: DateTime.parse(tran!.transactionCreatedTime!), isShort: false),
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.iconC,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(tran!.transactionCreatedTime!)),
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.iconC,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    if(tran!.status != null) Text(
                      "${tran?.status}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tabData.getTransactionStatusColor(tran!.status!),
                      ),
                      textAlign: TextAlign.end,
                    ),
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
                    color: prudColorTheme.bgE,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: prudColorTheme.bgC,
                      width: 5
                    )
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tabData.getTransactionStatusColor(tran!.status!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Text(
                              "${tabData.getCurrencySymbol(widget.tranDetails.selectedCurrencyCode!)}",
                              style: tabData.tBStyle.copyWith(
                                  fontSize: 16,
                                  color: prudColorTheme.bgC
                              ),
                            ),
                            Text(
                              "${widget.tranDetails.transactionPaidInSelected}",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: prudColorTheme.bgA,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    if(widget.tranDetails.selectedCurrencyCode != null) Container(
                      width: 120,
                      margin: const EdgeInsets.only(top: 10),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${tabData.getCurrencySymbol(tran!.product!.currencyCode!)}",
                                  style: tabData.tBStyle.copyWith(
                                    fontSize: 14,
                                    color: prudColorTheme.primary
                                  ),
                                ),
                                Text(
                                  "${currencyMath.roundDouble(tran!.product!.totalPrice!, 2)}",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: prudColorTheme.secondary,
                                  ),
                                ),
                                Text(
                                  "${tran?.product?.currencyCode}",
                                  style: tabData.tBStyle.copyWith(
                                    fontSize: 12,
                                    color: prudColorTheme.primary
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if(widget.tranDetails.beneficiary != null) Padding(
                      padding: const EdgeInsets.only(left: 100, top: 10),
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
