import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_carousel_item.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';
import 'package:prudapp/singletons/tab_data.dart';

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
    final GlobalKey coKey = GlobalKey();
    final CarouselController cCtrl = CarouselController(
      initialItem: 0
    );
    
    return SizedBox(
      height: 180,
      child: CarouselView.weighted(
        backgroundColor: prudColorTheme.bgE,
        padding: const EdgeInsets.only(left: 5),
        // shrinkExtent: 50.0,
        key: coKey,
        itemSnapping: true,
        controller: cCtrl,
        flexWeights: [3, 2, 1],
        scrollDirection: Axis.horizontal,
        children: channels.map<Widget>((menu) => PrudCarouselItem(
          navigateToWidget: ChannelView(channel: menu, isOwner: isOwner),
          title: menu.channelName,
          moreTitle: menu.category.toUpperCase(),
          blocked: menu.blocked,
          logoUrl: menu.logo,
          shape: isOwner? PrudCarouselItemShape.rectangle : PrudCarouselItemShape.circle,
          displayUrl: menu.displayScreen,
          subtitle: "${tabData.getCurrencySymbol(menu.channelCurrency)} | ${tabData.getCurrencyName(menu.channelCurrency)}",
        )).toList(),
      ),
    );
  }
}