import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/gift_product_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/modals/gift_card_category_modal_sheet.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

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
  GiftCategory? selectedCategory;
  ScrollController scrollCtrl = ScrollController();


  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  void showPreviousPage(){

  }

  void showNextPage(){

  }

  void showCategory(double height){
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgA,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: prudRad,
      ),
      builder: (BuildContext context) {
        return GiftCardCategoryModalSheet(
          radius: prudRad,
          height: height,
          onChange: (GiftCategory? selected) {
            try{
              if(selected != null) {
                Future.delayed(Duration.zero, (){
                  if(mounted) {
                    setState(() => selectedCategory = selected);
                    List<GiftProduct> fod = giftCardNotifier.products.where(
                      (GiftProduct pro) => pro.category != null &&
                      pro.category!.name == selectedCategory!.name).toList();
                    if(fod.isNotEmpty){
                      txtCtrl.text = "";
                      setState(() {
                        searchText = null;
                        foundProducts = fod;
                      });
                      iCloud.scrollTop(scrollCtrl);
                      txtCtrl.clear();
                    }
                  }
                });
              }
            }catch(ex){
              if(mounted) setState(() => loading = false);
              debugPrint("CategoryPicker Error: $ex");
            }
          },
        );
      },
    );
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
      if(mounted) {
        setState(() => selectedCategory = null);
      }
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
      iCloud.scrollTop(scrollCtrl);
    });
    super.initState();
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
        controller: scrollCtrl,
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
                if(productLength >= 10) PrudPanel(
                  title: "Search Criteria",
                  bgColor: prudColorTheme.bgC,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 9.0),
                            child: FormBuilderTextField(
                              controller: txtCtrl,
                              name: "search",
                              style: tabData.npStyle.copyWith(
                                fontSize: 13,
                              ),
                              keyboardType: TextInputType.text,
                              decoration: getDeco("Brand/Product",
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.refresh),
                                    color: Colors.black26,
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
                          ),
                        ),
                        if(giftCategories.isNotEmpty) spacer.width,
                        if(giftCategories.isNotEmpty) Expanded(
                            child: InkWell(
                              onTap: () => showCategory(screen.height),
                              child: PrudPanel(
                                bgColor: prudColorTheme.bgC,
                                title: "Category",
                                titleSize: 12,
                                titleColor: prudColorTheme.textB,
                                child: Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        selectedCategory != null? tabData.shortenStringWithPeriod(selectedCategory!.name!, length: 15) : 'Select Category',
                                        style: prudWidgetStyle.tabTextStyle.copyWith(
                                          fontSize: 13,
                                          color: prudColorTheme.textA
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down, size: 25,)
                                  ],
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                if(foundProducts.isNotEmpty) SizedBox(
                  height: screen.height + 50,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: foundProducts.length,
                    itemBuilder: (context, index) => GiftProductComponent(product: foundProducts[index]),
                  ),
                ),
                if(foundProducts.isEmpty) noSearchResultFound,
                xLargeSpacer.height,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
