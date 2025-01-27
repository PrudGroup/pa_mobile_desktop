import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';

class SelectableChannelComponent extends StatelessWidget{
  final Color borderColor;
  final VidChannel channel;

  const SelectableChannelComponent({
    super.key, required this.borderColor, required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        border: Border.all(width: 4, color: borderColor),
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: FastCachedImageProvider(
            iCloud.authorizeDownloadUrl(channel.logo),
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            prudColorTheme.primary.withValues(alpha: 0.4), 
            BlendMode.srcOver
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: FittedBox(
              child: SizedBox(
                width: 40,
                child: Text(
                  tabData.shortenStringWithPeriod(channel.channelName),
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: borderColor.withValues(alpha: 0.7)
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}