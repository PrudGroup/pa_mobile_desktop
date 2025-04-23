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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  prudImages.prudIcon,
                  fit: BoxFit.contain,
                  width: 20,
                ),
                LoadingComponent(
                  size: 50,
                  isShimmer: false,
                  spinnerColor: prudColorTheme.primary,
                )
              ],
            ),
            spacer.width,
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Translate(
                  text: "Loading Clip",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: prudColorTheme.success,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Translate(
                    text: "Wait For it!",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.bgA,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Translate(
                    text: "Everyone get paid!",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
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