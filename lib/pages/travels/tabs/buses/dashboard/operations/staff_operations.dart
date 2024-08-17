import 'package:flutter/material.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/staff/existing_drivers.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/staff/existing_operators.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/staff/new_driver.dart';

import '../../../../../../components/inner_menu.dart';
import '../../../../../../components/translate_text.dart';
import '../../../../../../models/theme.dart';
import '../new_bus_brand_operator.dart';

class StaffOperations extends StatefulWidget {
  const StaffOperations({super.key});

  @override
  StaffOperationsState createState() => StaffOperationsState();
}

class StaffOperationsState extends State<StaffOperations> {

  List<InnerMenuItem> tabMenus = [];
  final GlobalKey<InnerMenuState> _key = GlobalKey();

  @override
  void dispose() {
    super.dispose();
  }

  void moveTo(int index){
    if(_key.currentState != null){
      _key.currentState!.changeWidget(_key.currentState!.widget.menus[index].menu, index);
    }
  }

  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        tabMenus = [
          InnerMenuItem(imageIcon: prudImages.addOperator, title: "Add Operator", menu: const NewBusBrandOperator(isPage: false,)),
          InnerMenuItem(imageIcon: prudImages.addDriver, title: "Add Driver", menu: const NewDriver()),
          InnerMenuItem(imageIcon: prudImages.operators, title: "Operators", menu: const ExistingOperators()),
          InnerMenuItem(imageIcon: prudImages.driver, title: "Drivers", menu: const ExistingDrivers()),
        ];
      });
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
          text: "Staff Operations",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: InnerMenu(key: _key, menus: tabMenus, type: 0, hasIcon: true,),
    );
  }
}
