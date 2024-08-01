import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';

import '../models/theme.dart';

class NetworkIssueComponent extends StatelessWidget {
  const NetworkIssueComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return PrudContainer(
      title: "Network Issues",
      hasTitle: true,
      hasPadding: false,
      titleBorderColor: prudColorTheme.bgC,
      child: Container(
        color: prudColorTheme.primary,
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
        child: Row(
          children: [
            Image.asset(
              prudImages.prudIcon,
              width: 40,
            ),
            spacer.width,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Translate(
                  text: "PrudServices Unreachable",
                  style: prudWidgetStyle.hintStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: prudColorTheme.bgA,
                  ),
                ),
                SizedBox(
                  width: 270,
                  child: Translate(
                    text: "Prudapp was unable to connect with Prudapp services. check your internet and try again.",
                    style: prudWidgetStyle.hintStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: prudColorTheme.lineD,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
