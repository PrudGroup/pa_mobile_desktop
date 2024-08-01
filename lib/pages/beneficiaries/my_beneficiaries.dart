import 'package:flutter/material.dart';
import 'package:prudapp/pages/beneficiaries/tabs/existing_beneficiary.dart';
import 'package:prudapp/pages/beneficiaries/tabs/new_beneficiary.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';

import '../../components/translate_text.dart';
import '../../components/inner_menu.dart';
import '../../models/theme.dart';

class MyBeneficiaries extends StatefulWidget {
  final bool isPage;
  const MyBeneficiaries({super.key, this.isPage = true});

  @override
  MyBeneficiariesState createState() => MyBeneficiariesState();
}

class MyBeneficiariesState extends State<MyBeneficiaries> {

  int selectedTab = beneficiaryNotifier.selectedTab;
  List<InnerMenuItem> tabMenus = [];

  @override
  void dispose() {
    beneficiaryNotifier.removeListener((){});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        tabMenus = [
          InnerMenuItem(title: "Add New", menu: const NewBeneficiary()),
          InnerMenuItem(title: "Existing", menu: ExistingBeneficiary(isPage: widget.isPage,)),
        ];
      });
    }
    beneficiaryNotifier.addListener((){
      try{
        if(selectedTab != beneficiaryNotifier.selectedTab && mounted){
          Future.delayed(Duration.zero, (){
            setState(() {
              selectedTab = beneficiaryNotifier.selectedTab;
            });
          });
        }
      }catch(ex){
        debugPrint("selectedTab Error: $ex");
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    Widget inner = Container(
      height: widget.isPage? screen.height : (screen.height * 0.75),
      decoration: BoxDecoration(
        color: prudColorTheme.bgC,
        borderRadius: widget.isPage? BorderRadius.zero : prudRad
      ),
      child: ClipRRect(
        borderRadius: widget.isPage? BorderRadius.zero : prudRad,
        child: InnerMenu(menus: tabMenus, type: 0, activeTab: selectedTab),
      ),
    );
    return widget.isPage? Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "My Beneficiaries",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: inner,
    ) : inner;
  }
}
