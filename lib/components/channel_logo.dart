import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/live_broadcast.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
class ChannelLogo extends StatelessWidget {
  final VidChannel channel;
  final bool isLive;
  final BuildContext context;
  final bool isOwner;
  
  const ChannelLogo({ 
    super.key, 
    required this.channel, 
    required this.isLive, required this.context, required this.isOwner 
  });
  
  void viewChannel(){
    iCloud.goto(context, ChannelView(
      channel: channel,
      isOwner: isOwner,
    ));
  }

  void viewLiveBroadcast(){
    iCloud.goto(context, LiveBroadcast(
      channel: channel,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return isLive? InkWell(
      onTap: viewLiveBroadcast,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 37.0,
                width: 37.0,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: prudColorTheme.bgF.withValues(alpha: 0.8),
                  border: Border.all(color: prudColorTheme.primary, width: 3.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  color: prudColorTheme.primary,
                ),
                child: Center(
                  child: Translate(
                    text: "Live",
                    align: TextAlign.center,
                    style: prudWidgetStyle.btnTextStyle.copyWith(
                      color: prudColorTheme.bgA,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                      letterSpacing: 0.5,
                    )
                  ),
                )
              )
            ],
          ),
          GFAvatar(
            backgroundImage: FastCachedImageProvider(
              iCloud.authorizeDownloadUrl(channel.logo),
            ),
            size: 27.0,
          ),
        ]
      )
    ) 
    : 
    InkWell(
      onTap: viewChannel,
      child: GFAvatar(
        backgroundImage: FastCachedImageProvider(
          iCloud.authorizeDownloadUrl(channel.logo),
        ),
        size: 27.0,
      ),
    );
  }
}