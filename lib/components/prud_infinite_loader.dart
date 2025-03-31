import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
    
class PrudInfiniteLoader extends StatelessWidget {
  final String text;
  const PrudInfiniteLoader({ super.key, required this.text });
  
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Container(
      width: screen.width,
      padding: const EdgeInsets.all(10),
      child: Center(
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
                  size: 40,
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
                  text: "getting more $text",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: prudColorTheme.success,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Translate(
                    text: "Wait For it!",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.secondary,
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