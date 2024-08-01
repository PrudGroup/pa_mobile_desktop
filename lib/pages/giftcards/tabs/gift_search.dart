import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/components/gift_cart_icon.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../../components/translate_text.dart';
import '../../../models/theme.dart';

class GiftSearch extends StatefulWidget {
  final Function(int)? goToTab;
  const GiftSearch({super.key, this.goToTab});

  @override
  GiftSearchState createState() => GiftSearchState();
}

class GiftSearchState extends State<GiftSearch> {
  Country? selectedBenCountry;
  Currency? selectedBenCurrency;
  Currency? selectedSenderCurrency;
  bool gettingCountries = true;
  bool searching = false;
  bool hasSearched = false;
  Widget unableToReachServer = tabData.getNotFoundWidget(
    title: "Prudapp Gift Service",
    desc: "The gift service is not reachable. Check your network and refresh."
  );
  Widget noProductFound = tabData.getNotFoundWidget(
    title: "No GiftCard Found",
    desc: "We are working on covering all countries meanwhile change the country."
  );
  List<String> countries = [];
  List<String> currencies = [];

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async {
      await initSettings();
    });
  }

  Future<void> initSettings() async {
    try{
      if(mounted) setState(() => gettingCountries = true);
      if(reloadlyGiftToken == null) await giftCardNotifier.getGiftCardToken();
      if(reloadlyGiftToken != null && giftibleCountries.isEmpty) await giftCardNotifier.getGiftCountries();
      if(reloadlyGiftToken != null && giftCategories.isEmpty) await giftCardNotifier.getGiftCategories();
      if(giftibleCountries.isNotEmpty){
        for(ReloadlyCountry cty in giftibleCountries){
          if(cty.isoName != null) countries.add(cty.isoName!);
          if(cty.currencyCode != null) currencies.add(cty.currencyCode!);
        }
        giftCardNotifier.saveGiftibleCountriesToCache();
        giftCardNotifier.saveGiftCategoriesToCache();
        if(giftCardNotifier.lastGiftSearch != null){
          selectedSenderCurrency = giftCardNotifier.lastGiftSearch!.senderCurrency;
          selectedBenCurrency = giftCardNotifier.lastGiftSearch!.beneficiaryCurrency;
          selectedBenCountry = giftCardNotifier.lastGiftSearch!.beneficiaryCountry;
        }
      }
      if(mounted) setState(() => gettingCountries = false);
    }catch(ex){
      debugPrint("GiftSearch initSettings Error: $ex");
      if(mounted) setState(() => gettingCountries = false);
    }
  }

  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  Future<void> searchNow() async {
     try{
      if(mounted && selectedBenCountry != null) {
        setState(() => searching = true);
        await giftCardNotifier.getGiftsByCountry(selectedBenCountry!.countryCode);
        setState(() {
          hasSearched = true;
          searching = false;
        });
        if(giftCardNotifier.products.isNotEmpty) {
          GiftSearchCriteria searchCriteria = GiftSearchCriteria(
            beneficiaryCountry: selectedBenCountry!,
            beneficiaryCurrency: selectedBenCurrency!,
            senderCurrency: selectedSenderCurrency!,
          );
          beneficiaryNotifier.removeAll();
          await giftCardNotifier.updateLastGiftSearch(searchCriteria);
          gotoTab(1);
        }
      }
    }catch(ex){
      debugPrint("searchNow Error: $ex");
      if(mounted) setState(() => searching = false);
    }
  }

  void getCountry(){
    showCountryPicker(
      context: context,
      countryFilter: countries,
      favorite: ["NG", "UK", "SA", "US"],
      onSelect: (Country country){
        try{
          if(mounted){
            setState(() {
              selectedBenCountry = country;
            });
          }
        }catch(ex){
          debugPrint("getCurrency Error: $ex");
        }
      }
    );
  }

  void getCurrency({bool isBen = true}){
    showCurrencyPicker(
      context: context,
      currencyFilter: currencies,
      favorite: ["NGN", "GBP", "USD", "EUR", "CAD"],
      onSelect: (Currency cur){
        try{
          if(mounted){
            setState(() {
              if(isBen) {
                selectedBenCurrency = cur;
              } else {
                selectedSenderCurrency = cur;
              }
            });
          }
        }catch(ex){
          debugPrint("getCurrency Error: $ex");
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
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
          text: "Gift Search",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: [
          const GiftCartIcon(),
          IconButton(
            onPressed: initSettings,
            icon: const Icon(Icons.refresh),
            color: prudColorTheme.bgA,
            splashColor: prudColorTheme.bgD,
            splashRadius: 10.0,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        physics: const BouncingScrollPhysics(),
        child: giftibleCountries.isNotEmpty?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            spacer.height,
            InkWell(
              onTap: getCountry,
              child: PrudPanel(
                title: "Select Benefactor's Country",
                titleColor: prudColorTheme.iconB,
                bgColor: prudColorTheme.bgC,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Row(
                        children: [
                          if(selectedBenCountry != null) Text(
                            selectedBenCountry!.flagEmoji,
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: 20.0
                            ),
                          ),
                          spacer.width,
                          Translate(
                            text: selectedBenCountry != null? selectedBenCountry!.displayName : "Select Country",
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_sharp,
                      size: 20,
                      color: prudColorTheme.lineB,
                    )
                  ],
                ),
              ),
            ),
            spacer.height,
            InkWell(
              onTap: getCurrency,
              child: PrudPanel(
                title: "Select Benefactor's Currency",
                titleColor: prudColorTheme.iconB,
                bgColor: prudColorTheme.bgC,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Row(
                        children: [
                          if(selectedBenCurrency != null) Text(
                            "${selectedBenCurrency!.flag}",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 18.0
                            ),
                          ),
                          spacer.width,
                          Translate(
                            text: selectedBenCurrency != null? selectedBenCurrency!.name : "Select Currency",
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_sharp,
                      size: 20,
                      color: prudColorTheme.lineB,
                    )
                  ],
                ),
              ),
            ),
            spacer.height,
            InkWell(
              onTap: () => getCurrency(isBen: false),
              child: PrudPanel(
                title: "Select Sender's Currency",
                titleColor: prudColorTheme.iconB,
                bgColor: prudColorTheme.bgC,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Row(
                        children: [
                          if(selectedSenderCurrency != null) Text(
                            "${selectedSenderCurrency!.flag}",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 18.0
                            ),
                          ),
                          spacer.width,
                          Translate(
                            text: selectedSenderCurrency != null? selectedSenderCurrency!.name : "Select Currency",
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_sharp,
                      size: 20,
                      color: prudColorTheme.lineB,
                    )
                  ],
                ),
              ),
            ),
            spacer.height,
            searching? const LoadingComponent(
              isShimmer: false,
              size: 35,
            ): prudWidgetStyle.getLongButton(
              onPressed: searchNow,
              text: "Search Gift Mall"
            ),
            spacer.height,
            if(hasSearched && giftCardNotifier.products.isEmpty) noProductFound,
          ],
        )
            :
        (
          gettingCountries?
          Column(
            children: [
              spacer.height,
              FittedBox(
                child: LoadingComponent(
                  isShimmer: true,
                  height: screen.height - 150,
                  shimmerType: 3,
                ),
              ),
            ],
          )
              :
          Column(
            children: [
              spacer.height,
              unableToReachServer,
            ],
          )
        ),
      ),
    );
  }
}
