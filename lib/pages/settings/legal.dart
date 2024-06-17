import 'package:flutter/material.dart';

import '../../components/translate.dart';
import '../../components/work_in_progress.dart';
import '../../models/theme.dart';

class LegalPage extends StatefulWidget {
  const LegalPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return LegalPageState();
  }
}

class LegalPageState extends State<LegalPage> {

  @override
  void initState(){
    super.initState();

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
          text: "Terms & Conditions",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: const WorkInProgress(),
    );
  }
}
