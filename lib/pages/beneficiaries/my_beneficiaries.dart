import 'package:flutter/material.dart';
import 'package:prudapp/pages/beneficiaries/tabs/existing_beneficiary.dart';
import 'package:prudapp/pages/beneficiaries/tabs/new_beneficiary.dart';

import '../../components/Translate.dart';
import '../../components/inner_menu.dart';
import '../../models/theme.dart';

class MyBeneficiaries extends StatefulWidget {
  final bool isPage;
  const MyBeneficiaries({super.key, this.isPage = true});

  @override
  MyBeneficiariesState createState() => MyBeneficiariesState();
}

class MyBeneficiariesState extends State<MyBeneficiaries> {

  final List<InnerMenuItem> tabMenus = [
    InnerMenuItem(title: "Add New", menu: const NewBeneficiary()),
    InnerMenuItem(title: "Existing", menu: const ExistingBeneficiary()),
  ];


  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar: widget.isPage? AppBar(
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
      ) : AppBar(),
      body: Container(
        height: widget.isPage? screen.height : (screen.height * 0.75),
        decoration: BoxDecoration(
          color: prudColorTheme.bgC,
          borderRadius: widget.isPage? BorderRadius.zero : prudRad
        ),
        child: ClipRRect(
          borderRadius: widget.isPage? BorderRadius.zero : prudRad,
          child: InnerMenu(menus: tabMenus, type: 0,),
        ),
      ),
    );
  }
}
