import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prudapp/components/page_transitions/scale.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class StudioChannelListComponent extends StatelessWidget {
  final List<VidChannel> channels;
  final bool isOwner;

  const StudioChannelListComponent({
    super.key,
    required this.channels,
    this.isOwner = true,
  });

  Border getBorder(bool blocked){
    return Border.all(color: blocked? prudColorTheme.warning : prudColorTheme.bgC, width: 3);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey coKey = GlobalKey();
    final CarouselController cCtrl = CarouselController();
    Color cbg = prudColorTheme.bgA;
    BorderRadius bdRadius = BorderRadius.circular(50);
    return SizedBox(
      height: 120,
      child: ListView(
        // key: coKey,
        // controller: cCtrl,
        // flexWeights: [1, 3, 3, 1],
        scrollDirection: Axis.horizontal,
        children: channels.map((menu) {
          Border bd = getBorder(menu.blocked);
          return InkWell(
            onTap: () => Navigator.push(context, ScaleRoute(page: ChannelView(channel: menu, isOwner: isOwner))),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: cbg,
                      border: bd,
                      borderRadius: bdRadius
                    ),
                    child: ClipRRect(
                      borderRadius: bdRadius,
                      child: PrudNetworkImage(url: menu.logo, authorizeUrl: true,),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cbg,
                      border: bd,
                      borderRadius: bdRadius,
                      image: DecorationImage(
                        image: FastCachedImageProvider(
                          iCloud.authorizeDownloadUrl(menu.displayScreen),
                        )
                      )
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}