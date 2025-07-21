import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/images.dart';
import '../singletons/shared_local_storage.dart';
import 'translate_text.dart';

class WorkInProgress extends StatelessWidget {
  const WorkInProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.maxFinite,
      child: Column(
        spacing: 20.0,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              prudImages.prudIcon,
              height: 60,
              width: 60,
              fit: BoxFit.contain,
            ),
          ),
          Wrap(
            spacing: 5,
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Translate(
                text: "Work In Progress",
                style: tabData.tBStyle.copyWith(
                  color: prudTheme.tabBarTheme.indicatorColor!.withValues(alpha: 0.6),
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                ),
              ),
              SpinKitThreeBounce(
                color: prudTheme.primaryColor,
                size: 20,
              ),
            ],
          )
        ],
      ),
    );
  }
}
