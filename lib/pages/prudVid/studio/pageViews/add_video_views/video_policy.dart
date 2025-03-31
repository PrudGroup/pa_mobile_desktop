import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/settings/video_policies.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
class VideoPolicy extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoPolicy({super.key, required this.onCompleted, required this.onPrevious, });

  @override
  VideoPolicyState createState() => VideoPolicyState();
}

class VideoPolicyState extends State<VideoPolicy> {

  void openPolicy(){
    iCloud.goto(context, const VideoPolicies());
  }
  
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
          text: "Terms & Policies",
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
              text: "Uploading a video to PrudVid is a great way of creating passive income. "
              " We are very protective towards what video content can be uploaded to our platform. "
              " You must completely read and understand our policies regarding video contents. "
              "We just want to resound it clear that each policy is strictly to be adhered to."
              " The content must be original, of great value, and high quality. We greatly frown at AI generated contents."
              " The content must also adhere to government policies that exist in the country you primarily selected for your channel. "
              "Thumbnails must not be misleading. Thumbnails must be inline with the video content. No sexual, nudity or violence inciting contents allowed. "
              "If any video content policy is broken, that content will be blocked and your channel suppended for a month. ",
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
                  text: "Cancel",
                  makeLight: true,
                  isPill: false
                ),
                prudWidgetStyle.getShortButton(
                  onPressed: openPolicy, 
                  text: "Read Policies",
                  makeLight: true,
                  isPill: false
                ),
                prudWidgetStyle.getShortButton(
                  onPressed: () => widget.onCompleted(null), 
                  text: "Continue",
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