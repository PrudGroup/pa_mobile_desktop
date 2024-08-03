import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:intl/intl.dart';
import 'package:prudapp/models/reloadly.dart';

import '../models/images.dart';
import '../models/theme.dart';
import '../pages/recharge/recharge_and_utility_transaction_details.dart';
import '../singletons/currency_math.dart';
import '../singletons/i_cloud.dart';
import '../singletons/shared_local_storage.dart';
import '../singletons/tab_data.dart';
import '../singletons/utility_notifier.dart';
import 'loading_component.dart';

class UtilityTransactionComponent extends StatefulWidget {
  final UtilityTransactionDetails tranDetails;
  final UtilityTransaction? tran;

  const UtilityTransactionComponent({
    super.key, required this.tranDetails, this.tran
  });

  @override
  UtilityTransactionComponentState createState() =>
      UtilityTransactionComponentState();
}


class UtilityTransactionComponentState extends State<UtilityTransactionComponent> {

  UtilityTransaction? tran;
  bool selected = false;
  bool loading = false;

  void navigate(){
    if(tran != null){
      iCloud.goto(context, RechargeAndUtilityTransactionDetails(trans: tran!, tranDetails: widget.tranDetails,));
    }
  }

  String getUtilityTypeIcon(){
    if(
      tran != null &&
      tran!.transaction != null &&
      tran!.transaction!.billDetails != null &&
      tran!.transaction!.billDetails!.type != null
    ){
      BillerType bType = utilityNotifier.translateToType(tran!.transaction!.billDetails!.type!);
      switch(bType){
        case BillerType.electricity: return prudImages.power1;
        case BillerType.water: return prudImages.water;
        case BillerType.tv: return prudImages.smartTv1;
        default: return prudImages.internet;
      }
    }else{
      return prudImages.prudIcon;
    }
  }

  @override
  void dispose() {
    utilityNotifier.removeListener((){});
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
          UtilityTransaction? dTran = await utilityNotifier.getTransactionById(widget.tranDetails.transId!);
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
      debugPrint("UtilityTransactionComponent.getTransaction Error: $ex");
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted && utilityNotifier.selectedTransDetail != null){
        setState(() {
          selected = widget.tranDetails.transId == utilityNotifier.selectedTransDetail!.transId;
        });
      }
      await getTransaction();
    });
    super.initState();
    utilityNotifier.addListener((){
      if(mounted && utilityNotifier.selectedTransDetail != null){
        setState(() {
          selected = widget.tranDetails.transId == utilityNotifier.selectedTransDetail!.transId;
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
                        AssetImage(getUtilityTypeIcon()),
                        size: 25,
                        color: prudColorTheme.bgD,
                      ),
                    ),
                    spacer.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(tran!.transaction!.billDetails!.billerName != null) Text(
                          tabData.shortenStringWithPeriod(tran!.transaction!.billDetails!.billerName!, length: 22),
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: prudColorTheme.textA,
                          ),
                        ),
                        Text(
                          "${tran?.transaction?.referenceId} | ${widget.tranDetails.selectedCurrencyCode}",
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.textB,
                          ),
                        ),
                        Text(
                          "${tran?.transaction?.billDetails?.subscriberNumber}",
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
                if(tran!.transaction != null && tran!.transaction!.submittedAt != null) Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      myStorage.ago(dDate: DateTime.parse(tran!.transaction!.submittedAt!), isShort: false),
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.iconC,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(tran!.transaction!.submittedAt!)),
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.iconC,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    if(tran!.transaction != null && tran!.transaction!.status != null) Text(
                      "${tran!.transaction!.status}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tabData.getTransactionStatusColor(tran!.transaction!.status!),
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
                if(tran!.transaction != null && tran!.transaction!.status != null) Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: tabData.getTransactionStatusColor(tran!.transaction!.status!),
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
                            if(tran!.transaction != null && tran!.transaction!.deliveryAmountCurrencyCode != null) Text(
                              "${tabData.getCurrencySymbol(tran!.transaction!.deliveryAmountCurrencyCode!)}",
                              style: tabData.tBStyle.copyWith(
                                fontSize: 14,
                                color: prudColorTheme.primary
                              ),
                            ),
                            if(tran!.transaction != null && tran!.transaction!.deliveryAmount != null) Text(
                              "${currencyMath.roundDouble(tran!.transaction!.deliveryAmount!, 2)}",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: prudColorTheme.secondary,
                              ),
                            ),
                            if(tran!.transaction != null && tran!.transaction!.deliveryAmountCurrencyCode != null) Text(
                              "${tran!.transaction!.deliveryAmountCurrencyCode}",
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
