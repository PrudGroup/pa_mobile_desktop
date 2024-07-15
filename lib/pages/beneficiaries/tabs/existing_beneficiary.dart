import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/beneficiary_component.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';

import '../../../components/Translate.dart';
import '../../../models/reloadly.dart';
import '../../../models/theme.dart';
import '../../../singletons/tab_data.dart';

class ExistingBeneficiary extends StatefulWidget {
  final bool isPage;

  const ExistingBeneficiary({super.key, required this.isPage});

  @override
  ExistingBeneficiaryState createState() => ExistingBeneficiaryState();
}

class ExistingBeneficiaryState extends State<ExistingBeneficiary> {
  bool allSelected = false;
  List<Beneficiary> foundBenes = beneficiaryNotifier.myBeneficiaries;
  Widget noBensFound = tabData.getNotFoundWidget(
    title: "No Beneficiary Found",
    desc: "You are yet to add beneficiaries. Add them for easy transactions."
  );
  Widget noSearchResultFound = tabData.getNotFoundWidget(
    title: "No Beneficiary Found",
    desc: "No beneficiary bearing any name or email like this."
  );
  String? searchText;
  TextEditingController txtCtrl = TextEditingController();
  ScrollController scrollCtrl = ScrollController();

  @override
  void initState() {
    beneficiaryNotifier.addListener((){
      try{
        if(mounted){
          setState(() {
            allSelected = beneficiaryNotifier.myBeneficiaries.length == beneficiaryNotifier.selectedBeneficiaries.length;
            foundBenes = beneficiaryNotifier.myBeneficiaries;
          });
        }
      }catch(ex){
        debugPrint("ExistingBeneficiary listener: $ex");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    beneficiaryNotifier.removeListener((){});
    super.dispose();
  }

  void refreshSearch(){
    if(mounted){
      setState(() {
        searchText = null;
        txtCtrl.text = "";
        foundBenes = beneficiaryNotifier.myBeneficiaries;
      });
    }
  }

  void search(){
    if(searchText != null && beneficiaryNotifier.myBeneficiaries.isNotEmpty){
      List<Beneficiary> found = beneficiaryNotifier.myBeneficiaries.where((ben) =>
      (ben.fullName.toLowerCase().contains(searchText!.toLowerCase())) ||
          (ben.email.toLowerCase().contains(searchText!.toLowerCase()))).toList();
      if(mounted) setState(() => foundBenes = found);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        spacer.height,
        if(beneficiaryNotifier.myBeneficiaries.isEmpty) noBensFound,
        if(foundBenes.length >= 10) Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 5),
          child: FormBuilderTextField(
            controller: txtCtrl,
            name: "search",
            style: tabData.npStyle.copyWith(
              fontSize: 13,
            ),
            keyboardType: TextInputType.text,
            decoration: getDeco("Name/Email",
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
        if(foundBenes.length >= 10) spacer.height,
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: FormBuilderCheckbox(
                initialValue: allSelected,
                name: "select_all",
                title: Translate(
                  text: "Select All",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 14,
                    color: prudColorTheme.textB,
                  ),
                ),
                onChanged: (bool? value) async {
                  try{
                    if(mounted && value != null){
                      setState(() {
                        allSelected = value;
                      });
                      if(allSelected == true){
                        await beneficiaryNotifier.selectAll();
                      }else{
                        await beneficiaryNotifier.removeAll();
                      }
                    }
                  }catch(ex){
                    debugPrint("Select_all: $ex");
                  }
                },
              ),
            ),
            Row(
              children: [
                Text(
                  "${beneficiaryNotifier.selectedBeneficiaries.length} Selected",
                  style: prudWidgetStyle.typedTextStyle.copyWith(
                      color: prudColorTheme.iconB,
                      fontSize: 13
                  ),
                ),
                if(!widget.isPage) spacer.width,
                if(!widget.isPage) prudWidgetStyle.getShortButton(
                  text: "Done",
                  isPill: false,
                  isSmall: true,
                  onPressed: () => Navigator.pop(context),
                ),
                if(!widget.isPage) spacer.width,
              ],
            ),
          ],
        ),
        Divider(
          indent: 20,
          endIndent: 20,
          height: 10,
          color: prudColorTheme.lineC,
          thickness: 1,
        ),
        if(foundBenes.isNotEmpty) Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: foundBenes.length,
            itemBuilder: (context, index){
              return BeneficiaryComponent(
                ben: foundBenes[index],
                forSelection: widget.isPage? false : true,
              );
            }
          ),
        ),
        if(foundBenes.isEmpty) noSearchResultFound,
        if(foundBenes.isEmpty) xLargeSpacer.height,
      ],
    );
  }
}
