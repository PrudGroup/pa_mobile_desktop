import 'package:flutter/material.dart';

import '../../../../../../components/translate_text.dart';
import '../../../../../../components/work_in_progress.dart';
import '../../../../../../models/theme.dart';

class StaffOperations extends StatefulWidget {
  const StaffOperations({super.key});

  @override
  StaffOperationsState createState() => StaffOperationsState();
}

class StaffOperationsState extends State<StaffOperations> {
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
      body: const WorkInProgress(),
    );
  }
}
