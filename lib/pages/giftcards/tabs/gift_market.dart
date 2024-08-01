import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:prudapp/components/gift_product_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/modals/gift_card_category_modal_sheet.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../../../components/translate_text.dart';
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
  bool showCatSearch = false;
  bool showBrandSearch = false;
  bool showAll = true;
  bool showWidgets = false;

  void showCategorySearch(){
    if(mounted){
      setState(() {
        showCatSearch = !showCatSearch;
        showBrandSearch = false;
        showAll = showCatSearch? false : true;
      });
    }
  }

  void showSearch(){
    if(mounted){
      setState(() {
        showCatSearch = false;
        showBrandSearch = !showBrandSearch;
        showAll = showBrandSearch? false : true;
      });
    }
  }

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
        showCatSearch = false;
        showBrandSearch = false;
        showAll = true;
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
    Future.delayed(kTabScrollDuration).then((value) {
      if (mounted) {
        setState(() => showWidgets = true);
      }
    });
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
  void dispose() {
    txtCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: showAll? IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ) : const SizedBox(),
        title: showAll? Translate(
          text: "Gift Mall",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ) : const SizedBox(),
        actions: [
          if(showAll) const GiftCartIcon(),
          if(showAll && !showWidgets) spacer.width,
          if(showAll && showWidgets) IconButton(
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
            color: prudColorTheme.bgA,
            splashColor: prudColorTheme.bgD,
            splashRadius: 10.0,
          ),
          if(productLength >= 10 && showBrandSearch && showWidgets) Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: FormBuilderTextField(
                controller: txtCtrl,
                name: "search",
                style: tabData.npStyle.copyWith(
                  fontSize: 13,
                  color: prudColorTheme.bgA
                ),
                keyboardType: TextInputType.text,
                decoration: getDeco("Brand/Product",
                  labelStyle: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.bgA,
                    fontSize: 13,
                    fontWeight: FontWeight.w500
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    color: prudColorTheme.bgD,
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
          if(productLength >= 10 && showCatSearch && showWidgets) Expanded(
            child: InkWell(
              onTap: () => showCategory(screen.height),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: PrudPanel(
                  bgColor: prudColorTheme.primary,
                  title: "Category",
                  titleSize: 12,
                  titleColor: prudColorTheme.bgA,
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        child: Text(
                          selectedCategory != null? tabData.shortenStringWithPeriod(selectedCategory!.name!, length: 15) : 'Select Category',
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 13,
                            color: prudColorTheme.textC
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 25,
                        color: prudColorTheme.bgA,
                      )
                    ],
                  ),
                ),
              ),
            )
          ),
          if((showBrandSearch || showAll) && showWidgets) IconButton(
            onPressed: showSearch,
            icon: const Icon(Icons.search),
            color: prudColorTheme.bgA,
            splashColor: prudColorTheme.bgD,
            splashRadius: 10.0,
          ),
          if((showCatSearch || showAll) && showWidgets) IconButton(
            onPressed: showCategorySearch,
            icon: const Icon(FontAwesome.angellist),
            color: prudColorTheme.bgA,
            splashColor: prudColorTheme.bgD,
            splashRadius: 10.0,
          ),
        ],
      ),
      body: SizedBox(
        height: screen.height - 60,
        child: foundProducts.isNotEmpty?
        GridView.builder(
          controller: scrollCtrl,
          itemCount: foundProducts.length,
          padding: const EdgeInsets.only(left:10.0, right: 10.0, bottom: 60),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            mainAxisExtent: 180
          ),
          itemBuilder: (context, index){
            return GiftProductComponent(product: foundProducts[index]);
          }
        )
            :
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left:10.0, right: 10.0),
          controller: scrollCtrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(loading || !showWidgets) FittedBox(
                child: LoadingComponent(
                  isShimmer: true,
                  height: screen.height - 100,
                  shimmerType: 3,
                ),
              ),
              if(hasLoaded && productLength < 1) noProductFound,
              if(hasLoaded && productLength > 0 && showWidgets) Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // if(foundProducts.isNotEmpty) Wrap(
                  //   direction: Axis.horizontal,
                  //   runSpacing: 10.0,
                  //   spacing: 10.0,
                  //   alignment: WrapAlignment.spaceBetween,
                  //   runAlignment: WrapAlignment.center,
                  //   crossAxisAlignment: WrapCrossAlignment.center,
                  //   children: foundProducts.map((pro) => GiftProductComponent(product: pro)).toList(),
                  // ),
                  if(foundProducts.isEmpty) noSearchResultFound,
                  largeSpacer.height,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
