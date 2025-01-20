import 'package:flutter/material.dart';
import 'package:prudapp/components/page_transitions/scale.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';

class StudioChannelListComponent extends StatelessWidget {
  final List<VidChannel> channels;
  final bool isOwner;

  const StudioChannelListComponent({
    super.key,
    required this.channels,
    this.isOwner = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = prudColorTheme.bgC;
    Color cbg = prudColorTheme.bgA;
    BorderRadius bdRadius = BorderRadius.only(
      bottomLeft: Radius.circular(40),
      bottomRight: Radius.circular(40),
    );
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      margin: const EdgeInsets.all(10),
      child: Wrap(
        spacing: 10,
        runSpacing: 20,
        alignment: WrapAlignment.spaceBetween,
        children: channels.map((menu) => InkWell(
          onTap: () => Navigator.push(context, ScaleRoute(page: ChannelView(channel: menu, isOwner: isOwner))),
          splashColor: bgColor.withValues(alpha: 0.7),
          hoverColor: bgColor.withValues(alpha: 0.7),
          child: Stack(
            children: [
              Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                  color: cbg,
                  border: Border(bottom: BorderSide(color: bgColor, width: 3)),
                  borderRadius: bdRadius
                ),
                child: ClipRRect(
                  borderRadius: bdRadius,
                  child: PrudNetworkImage(url: menu.logo, authorizeUrl: true,),
                ),
              ),
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: cbg,

                ),
              )
            ],
          ),
        )).toList(),
      ),
    );
  }
}