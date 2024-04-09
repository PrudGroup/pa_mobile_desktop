import 'package:prudapp/models/locale.dart';
import 'package:flutter/material.dart';

import '../../components/translate.dart';
import '../../components/work_in_progress.dart';
import '../../singletons/shared_local_storage.dart';
import '../../singletons/tab_data.dart';

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
  final TextStyle tStyle = const TextStyle(
    fontWeight: FontWeight.w600,
    color: Colors.black,
    fontSize: 18.0,
    fontFamily: "Lato-Italic",
    decoration: TextDecoration.none,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudTheme.cardColor,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        elevation: 2.0,
        title: Translate(
          text: "Settings",
          style: tabData.eStyle.copyWith(fontSize: 16),
        ),
        actions: const [
        ],
      ),
      body: const WorkInProgress(),
    );
  }
}
