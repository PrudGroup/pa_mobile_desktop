import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
    
class VideoLoading extends StatelessWidget {

  const VideoLoading({ super.key });
  
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Container(
      width: screen.width,
      padding: const EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  prudImages.prudIcon,
                  fit: BoxFit.contain,
                  width: 15,
                ),
                LoadingComponent(
                  size: 10,
                  isShimmer: false,
                  defaultSpinnerType: false,
                  spinnerColor: prudColorTheme.primary,
                )
              ],
            ),
            spacer.width,
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Translate(
                  text: "Loading Video",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: prudColorTheme.success,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: Translate(
                    text: "Wait For it!",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.secondary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Translate(
                    text: "Everyone get paid!",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.iconB,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}