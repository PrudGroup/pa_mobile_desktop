import 'package:prudapp/models/locale.dart';
import 'package:flutter/material.dart';

import '../../components/translate_text.dart';
import '../../components/work_in_progress.dart';
import '../../models/theme.dart';

class Settings extends StatefulWidget {

  const Settings({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

enum SettingsState{
  user,
  unauthorized,
  authorized
}

class _SettingsState extends State<Settings> {
  final List locale = locales;
  bool hasAuthority = false;

  @override
  void initState() {
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
          text: "Settings",
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
