import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';

List<ConditionalWidgetItem> getDownloadConditions(Orientation screen, {Uint8List? placeholder}){
  int status = screen == Orientation.portrait? 0 : 1;
  double width = status == 0? 130.0 : 200.0;
  double height = status == 0? 90 : 130;
  return [
    ConditionalWidgetItem(
      value: {
        "downloading": true,
        "imgDownloaded": false,
        "vidDownloaded": false,
      }, 
      widget: FadeShimmer(
        height: height,
        width: width,
        radius: 20,
        highlightColor: prudColorTheme.bgF,
        baseColor: prudColorTheme.bgD,
      ),
    ),
    ConditionalWidgetItem(
      value: {
        "downloading": true,
        "imgDownloaded": true,
        "vidDownloaded": false,
      }, 
      widget: placeholder != null? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: prudColorTheme.bgD,
          image: DecorationImage(
            image: MemoryImage(placeholder),
            fit: BoxFit.cover,
          )
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: prudColorTheme.bgA.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ) : SizedBox(),
    ),
    ConditionalWidgetItem(
      value: {
        "downloading": false,
        "imgDownloaded": true,
        "vidDownloaded": true,
      }, 
      widget: placeholder != null? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: prudColorTheme.bgD,
          image: DecorationImage(
            image: MemoryImage(placeholder),
            fit: BoxFit.cover,
          )
        ),
      ) : SizedBox(),
    ),
  ];
}