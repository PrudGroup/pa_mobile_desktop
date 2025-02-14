import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/models/theme.dart';
    
class AddVideo extends StatefulWidget {
  final String channelId;
  final String? creatorId;
  const AddVideo({super.key, required this.channelId, this.creatorId});

  @override
  AddVideoState createState() => AddVideoState();
}

class AddVideoState extends State<AddVideo> {
  
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
          text: "New Video",
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