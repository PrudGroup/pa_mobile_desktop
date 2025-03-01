import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class VideoSnippetCard extends StatelessWidget {
  final VideoSnippet videoSnippet;

  const VideoSnippetCard({ super.key, required this.videoSnippet });
  
  @override
  Widget build(BuildContext context) {
    BorderRadius rad = BorderRadius.circular(10);
    return Container(
      margin: const EdgeInsets.only(right: 10),
      height: 75,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: rad,
        border: Border.all(color: prudColorTheme.textD,),
        color: prudColorTheme.primary,
      ),
      child: ClipRRect(
        borderRadius: rad,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Translate(
                text: tabData.shortenStringWithPeriod(videoSnippet.title, length: 20),
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: prudColorTheme.bgD,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Text(
                  "${videoSnippet.startAt} - ${videoSnippet.endAt}",
                  style: prudWidgetStyle.hintStyle.copyWith(
                    fontSize: 10,
                    color: prudColorTheme.bgA,
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}