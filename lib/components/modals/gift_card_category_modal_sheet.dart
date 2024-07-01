import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';

import '../../models/theme.dart';
import '../../singletons/tab_data.dart';

class GiftCardCategoryModalSheet extends StatefulWidget {
  final double height;
  final Function(GiftCategory) onChange;
  final BorderRadiusGeometry radius;

  const GiftCardCategoryModalSheet({
    super.key,
    required this.height,
    required this.radius,
    required this.onChange
  });

  @override
  GiftCardCategoryModalSheetState createState() => GiftCardCategoryModalSheetState();
}

class GiftCardCategoryModalSheetState extends State<GiftCardCategoryModalSheet> {
  List<GiftCategory> foundCats = giftCategories;

  void search(String? value){
    try{
      if(mounted){
        if(value == null || value == ""){
          setState(() =>  foundCats = giftCategories);
        }else{
          List<GiftCategory> result = foundCats.where((cat) =>
              cat.name != null && cat.name!.toLowerCase().contains(value.toLowerCase())).toList();
          setState(() => foundCats = result);
        }
      }
    }catch(ex){
      debugPrint("Gift Category Search Error: $ex");
    }
  }

  void onSelected(GiftCategory selected){
    try{
      widget.onChange(selected);
      Navigator.pop(context);
    }catch(ex){
      debugPrint("CategoryPicker State Error: $ex");
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry rad = widget.radius;
    double height = widget.height;
    return ClipRRect(
      borderRadius: rad,
      child: Container(
        height: height * 0.5,
        constraints: BoxConstraints(maxHeight: height),
        decoration: BoxDecoration(
          borderRadius: rad,
          color: prudColorTheme.bgA
        ),
        padding: const EdgeInsets.only(left: 5, right: 5, top: 30),
        child: Column(
          children: [
            FormBuilderTextField(
              initialValue: "",
              name: 'search',
              style: tabData.npStyle,
              keyboardType: TextInputType.name,
              decoration: getDeco("Search"),
              onChanged: (String? value){
                search(value);
              },
              valueTransformer: (text) => num.tryParse(text!),
            ),
            spacer.height,
            Expanded(
              child: ListView.builder(
                itemCount: foundCats.length,
                itemBuilder: (context, index){
                  GiftCategory dCat = foundCats[index];
                  return InkWell(
                    onTap: () => onSelected(dCat),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 5.6),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: prudColorTheme.bgC,
                        borderRadius: BorderRadius.circular(7.0)
                      ),
                      child: Text(
                        "${dCat.name}",
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.textA,
                          fontSize: 16,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                  );
                }
              )
            )
          ],
        ),
      ),
    );
  }
}
