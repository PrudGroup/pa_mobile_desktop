import 'package:flutter/material.dart';

import '../../components/translate_text.dart';
import '../../components/work_in_progress.dart';
import '../../models/theme.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PolicyPageState();
  }
}

class _PolicyPageState extends State<PolicyPage> {

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
          text: "Policies",
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
