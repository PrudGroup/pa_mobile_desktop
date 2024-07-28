import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/gift_transaction_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../../../components/translate.dart';
import '../../../models/reloadly.dart';
import '../../../models/theme.dart';
import '../../../singletons/tab_data.dart';

class GiftTransactionHistory extends StatefulWidget {
  final Function(int)? goToTab;
  const GiftTransactionHistory({super.key, this.goToTab});

  @override
  GiftTransactionHistoryState createState() => GiftTransactionHistoryState();
}

class GiftTransactionHistoryState extends State<GiftTransactionHistory> {
  bool showSearch = true;
  ScrollController scrollCtrl = ScrollController();
  List<GiftTransactionDetails> foundTransactions = giftCardNotifier.transactions;
  String? searchText;
  TextEditingController txtCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? errorMsg;
  bool loading = false;
  bool hasSearched = false;
  Widget noSearchFound = tabData.getNotFoundWidget(
    title: "No Transaction",
    desc: "There is no transaction between the searched dates. change dates and search again."
  );
  Widget noItemFound = tabData.getNotFoundWidget(
    title: "None Found",
    desc: "There is no transaction with such currency. change currency and search again."
  );

  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    giftCardNotifier.removeListener((){});
    scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> searchByDates() async {
    try{
      if(startDate != null && endDate != null){
        if(mounted) setState(() => loading = true);
        await giftCardNotifier.getTransactionsFromCloud(startDate!, endDate!);
        debugPrint("Got here: $prudApiKey");
        if(mounted) {
          setState(() {
            loading = false;
            hasSearched = true;
            if(giftCardNotifier.transactions.isNotEmpty) showSearch = false;
          });
        }
      }else{
        if(mounted) iCloud.showSnackBar("StartDate/EndDate Missing", context);
      }
    }catch(ex){
      if(mounted){
        setState(() {
          loading = false;
        });
      }
      debugPrint("searchByDates Error: $ex");
    }
  }

  void refreshSearch(){
    if(mounted){
      setState(() {
        searchText = null;
        txtCtrl.text = "";
        foundTransactions = giftCardNotifier.transactions;
      });
    }
  }

  @override
  void initState() {
    if(mounted){
      setState(() {
        foundTransactions = giftCardNotifier.transactions;
        if(foundTransactions.isNotEmpty) showSearch = false;
        endDate = DateTime.now();
        startDate = endDate!.subtract(const Duration(days: 7));
      });
    }
    super.initState();
    giftCardNotifier.addListener((){
      if(mounted){
        foundTransactions = giftCardNotifier.transactions;
      }
    });
  }

  void search(){
    if(searchText != null && giftCardNotifier.transactions.isNotEmpty){
      List<GiftTransactionDetails> found = giftCardNotifier.transactions.where((tra) =>
        tra.selectedCurrencyCode!.toLowerCase().contains(searchText!.toLowerCase())).toList();
      if(mounted) setState(() => foundTransactions = found);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Transaction History",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: showSearch? SingleChildScrollView(
        controller: scrollCtrl,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            spacer.height,
            Translate(
              text: "Search transactions for at least a week and at most a month.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: prudColorTheme.textB
              ),
              align: TextAlign.center,
            ),
            if(startDate != null && endDate != null) spacer.height,
            if(startDate != null && endDate != null) FormBuilderDateRangePicker(
              name: "dateRange",
              initialValue: DateTimeRange(start: startDate!, end: endDate!),
              firstDate: endDate!.subtract(const Duration(days: 300)),
              decoration: getDeco("Select Dates"),
              lastDate: endDate!,
              onChanged: (DateTimeRange? dateRange){
                try{
                  if(mounted && dateRange != null){
                    setState(() {
                      startDate = dateRange.start;
                      endDate = dateRange.end;
                    });
                  }
                }catch(ex){
                  debugPrint("DateTimeRange Error: $ex");
                }
              },
            ),
            spacer.height,
            loading? LoadingComponent(
              isShimmer: false,
              spinnerColor: prudColorTheme.primary,
              size: 30,
            ) : prudWidgetStyle.getLongButton(
              onPressed: searchByDates,
              text: "Search For Transactions"
            ),
            spacer.height,
            if(giftCardNotifier.transactions.isEmpty && !loading && hasSearched) noSearchFound,
            spacer.height,
            if(errorMsg != null) Translate(
              text: "$errorMsg",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: prudColorTheme.primary
              ),
              align: TextAlign.center,
            ),
            spacer.height
          ],
        ),
      )
          :
      Column(
        children: [
          spacer.height,
          if(searchText != null && foundTransactions.isNotEmpty && foundTransactions.length > 10) Column(
            children: [
              FormBuilderTextField(
                controller: txtCtrl,
                name: "search",
                style: tabData.npStyle.copyWith(
                  fontSize: 13,
                  color: prudColorTheme.textA
                ),
                keyboardType: TextInputType.text,
                decoration: getDeco("By Currency",
                  labelStyle: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.textB,
                    fontSize: 13,
                    fontWeight: FontWeight.w500
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    color: prudColorTheme.primary,
                    onPressed: refreshSearch,
                  ),
                  hintSize: 13
                ),
                onChanged: (String? value){
                  try{
                    setState(() {
                      searchText = value?.trim();
                      search();
                    });
                  }catch(ex){
                    debugPrint("Search changed Error: $ex");
                  }
                },
              ),
              spacer.height,
            ],
          ),
          if(foundTransactions.isNotEmpty && !loading) Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 30),
              itemCount: foundTransactions.length,
              itemBuilder: (context, index){
                return GiftTransactionComponent(tranDetails: foundTransactions[index]);
              }
            ),
          ),
          if(!loading && foundTransactions.isEmpty) noItemFound,
        ],
      ),
    );
  }
}
