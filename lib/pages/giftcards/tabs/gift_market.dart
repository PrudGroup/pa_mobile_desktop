import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:prudapp/components/gift_product_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';

import '../../../components/Translate.dart';
import '../../../components/gift_cart_icon.dart';
import '../../../models/theme.dart';
import '../../../singletons/tab_data.dart';

class GiftMarket extends StatefulWidget {
  final Function(int)? goToTab;
  const GiftMarket({super.key, this.goToTab});

  @override
  GiftMarketState createState() => GiftMarketState();
}

class GiftMarketState extends State<GiftMarket> {
  List<GiftProduct> nigerianProducts = [];
  bool loading = true;
  bool hasLoaded = false;
  int productLength = giftCardNotifier.products.length;
  int presentPage = 1;
  int totalPages = 1;
  Widget noProductFound = tabData.getNotFoundWidget(
    title: "No Product Found",
    desc: "Products are presently unreachable in the searched Country."
  );
  Widget noSearchResultFound = tabData.getNotFoundWidget(
    title: "No Such Product",
    desc: "Search for a product name or brand name."
  );
  String? searchText;
  TextEditingController txtCtrl = TextEditingController();
  List<GiftProduct> foundProducts = giftCardNotifier.products;


  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  void showPreviousPage(){

  }

  void showNextPage(){

  }

  void refreshSearch(){
    if(mounted){
      setState(() {
        searchText = null;
        txtCtrl.text = "";
        foundProducts = giftCardNotifier.products;
      });
    }
  }

  void search(){
    if(searchText != null && giftCardNotifier.products.isNotEmpty){
      List<GiftProduct> found = giftCardNotifier.products.where((pro) =>
        (pro.productName != null && pro.productName!.toLowerCase().contains(searchText!.toLowerCase())) ||
            (pro.brand != null && pro.brand!.brandName != null && pro.brand!.brandName!.toLowerCase().contains(searchText!.toLowerCase()))).toList();
      if(mounted) setState(() => foundProducts = found);
    }
  }

  Future<void> refresh() async {

  }

  @override
  void initState(){
    Future.delayed(Duration.zero, () async {
      if(giftCardNotifier.products.isEmpty) await giftCardNotifier.getGiftsByCountry("NG");
      if(mounted){
        setState(() {
          hasLoaded = true;
          loading = false;
        });
      }
    });
    super.initState();
    giftCardNotifier.addListener(() async {
      if(mounted) {
        setState((){
          productLength = giftCardNotifier.products.length;
          foundProducts = giftCardNotifier.products;
        });
      }
    });
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
          text: "Gift Mall",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: [
          const GiftCartIcon(),
          IconButton(
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
            color: prudColorTheme.bgA,
            splashColor: prudColorTheme.bgD,
            splashRadius: 10.0,
          ),
          IconButton(
            onPressed: showPreviousPage,
            icon: const Icon(Icons.arrow_back),
            color: prudColorTheme.bgA,
            splashColor: prudColorTheme.bgD,
            splashRadius: 10.0,
          ),
          Text(
            "$presentPage",
            style: prudWidgetStyle.btnTextStyle.copyWith(
              color: prudColorTheme.textB,
              fontSize: 10,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),
          IconButton(
            onPressed: refresh,
            icon: const Icon(Icons.arrow_forward),
            color: prudColorTheme.bgA,
            splashColor: prudColorTheme.bgD,
            splashRadius: 10.0,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            spacer.height,
            if(loading) FittedBox(
              child: LoadingComponent(
                isShimmer: true,
                height: screen.height - 100,
                shimmerType: 3,
              ),
            ),
            if(hasLoaded && productLength < 1) noProductFound,
            if(hasLoaded && productLength > 0) Column(
              children: [
                if(productLength >= 10) FormBuilderTextField(
                  controller: txtCtrl,
                  name: "search",
                  style: tabData.npStyle,
                  keyboardType: TextInputType.text,
                  decoration: getDeco("Search Gifts",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.black26,
                      onPressed: refreshSearch,
                    )
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
                if(foundProducts.isNotEmpty) SizedBox(
                  height: screen.height - 150,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: foundProducts.length,
                    itemBuilder: (context, index) => GiftProductComponent(product: foundProducts[index]),
                  ),
                ),
                if(foundProducts.isEmpty) noSearchResultFound,
                spacer.height,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
