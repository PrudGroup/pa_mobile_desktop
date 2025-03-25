import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
class VideoDeclare extends StatefulWidget {
  final Function onPrevious;
  final Function(dynamic) onCompleted;
  const VideoDeclare({super.key, required this.onCompleted, required this.onPrevious, });

  @override
  VideoDeclareState createState() => VideoDeclareState();
}

class VideoDeclareState extends State<VideoDeclare> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => iCloud.goBack(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Declaration",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            spacer.height,
            Translate(
              text: "I have read and understood the terms and policies that binds video content creation and assure you "
              "that the video content am about to upload adheres to all the terms and policies mentioned on this platform." 
              "I agree to be held responsible if this is not true.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 15,
                color: prudColorTheme.textB,
                fontWeight: FontWeight.w500
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                prudWidgetStyle.getShortButton(
                  onPressed: widget.onPrevious, 
                  text: "I Disagree",
                  makeLight: true,
                  isPill: false
                ),
                prudWidgetStyle.getShortButton(
                  onPressed: () => widget.onCompleted(true), 
                  text: "I Agree",
                  makeLight: false,
                  isPill: false
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}