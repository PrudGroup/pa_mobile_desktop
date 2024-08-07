import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:intl/intl.dart';
import 'package:prudapp/pages/recharge/recharge_transaction_detail_display.dart';
import 'package:prudapp/singletons/recharge_notifier.dart';

import '../models/images.dart';
import '../models/reloadly.dart';
import '../models/theme.dart';
import '../singletons/currency_math.dart';
import '../singletons/i_cloud.dart';
import '../singletons/shared_local_storage.dart';
import '../singletons/tab_data.dart';
import 'loading_component.dart';

class RechargeTransactionComponent extends StatefulWidget {
  final RechargeTransactionDetails tranDetails;
  final TopUpTransaction? tran;

  const RechargeTransactionComponent({
    super.key, required this.tranDetails, this.tran
  });

  @override
  RechargeTransactionComponentState createState() =>
      RechargeTransactionComponentState();
}

class RechargeTransactionComponentState extends State<RechargeTransactionComponent> {

  TopUpTransaction? tran;
  bool selected = false;
  bool loading = false;

  void navigate(){
    if(tran != null){
      iCloud.goto(context, RechargeTransactionDetailDisplay(trans: tran!, tranDetails: widget.tranDetails,));
    }
  }

  @override
  void dispose() {
    rechargeNotifier.removeListener((){});
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
          TopUpTransaction? dTran = await rechargeNotifier.getTransactionById(widget.tranDetails.transId!);
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
      debugPrint("RechargeTransactionComponent.getTransaction Error: $ex");
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted && rechargeNotifier.selectedTransDetail != null){
        setState(() {
          selected = widget.tranDetails.transId == rechargeNotifier.selectedTransDetail!.transId;
        });
      }
      await getTransaction();
    });
    super.initState();
    rechargeNotifier.addListener((){
      if(mounted && rechargeNotifier.selectedTransDetail != null){
        setState(() {
          selected = widget.tranDetails.transId == rechargeNotifier.selectedTransDetail!.transId;
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
                        AssetImage(widget.tranDetails.transactionType == "airtime"? prudImages.airtime : prudImages.dataBundle),
                        size: 25,
                        color: prudColorTheme.bgD,
                      ),
                    ),
                    spacer.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(tran!.operatorName != null) Text(
                          tabData.shortenStringWithPeriod(tran!.operatorName!, length: 22),
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: prudColorTheme.textA,
                          ),
                        ),
                        Text(
                          "${tran?.customIdentifier} | ${widget.tranDetails.selectedCurrencyCode}",
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.textB,
                          ),
                        ),
                        Text(
                          "${widget.tranDetails.beneficiaryNo}",
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
                if(tran!.transactionDate != null) Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      myStorage.ago(dDate: DateTime.parse(tran!.transactionDate!), isShort: false),
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.iconC,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(tran!.transactionDate!)),
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
                              "${tabData.getCurrencySymbol(tran!.deliveredAmountCurrencyCode!)}",
                              style: tabData.tBStyle.copyWith(
                                  fontSize: 14,
                                  color: prudColorTheme.primary
                              ),
                            ),
                            Text(
                              "${currencyMath.roundDouble(tran!.deliveredAmount!, 2)}",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: prudColorTheme.secondary,
                              ),
                            ),
                            Text(
                              "${tran?.deliveredAmountCurrencyCode}",
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
