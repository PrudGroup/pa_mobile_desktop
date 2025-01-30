import 'package:flutter/material.dart';

import '../../../../../components/prud_showroom.dart';
import '../../../../../components/studio_channel_list_component.dart';
import '../../../../../models/prud_vid.dart';
import '../../../../../singletons/i_cloud.dart';
import '../../../../../singletons/prud_studio_notifier.dart';
import '../../../../../singletons/tab_data.dart';

class AffiliatedChannels extends StatefulWidget {

  const AffiliatedChannels({super.key});

  @override
  State<AffiliatedChannels> createState() => _AffiliatedChannelsState();
}

class _AffiliatedChannelsState extends State<AffiliatedChannels> {

  List<VidChannel> affChannels = prudStudioNotifier.affiliatedChannels;
  Widget notFound = tabData.getNotFoundWidget(
      title: "Channels Not Found",
      desc: "Unable to reach PrudServices or you are not affiliated to any channel. You can start by sending a request to one."
  );

  Future<void> refresh() async {
    await prudStudioNotifier.getAffiliatedChannels();
  }

  @override
  void initState() {
    super.initState();
    prudStudioNotifier.addListener((){
      if(mounted) setState(() => affChannels = prudStudioNotifier.affiliatedChannels);
    });
  }

  @override
  void dispose() {
    prudStudioNotifier.removeListener((){});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: refresh,
      child: SizedBox(
        height: screen.height,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: PrudShowroom(items: iCloud.getShowroom(context, showroomItems: 1)),
              ),
              affChannels.isNotEmpty? StudioChannelListComponent(channels: affChannels, isOwner: false) : notFound,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: PrudShowroom(items: iCloud.getShowroom(context, showroomItems: 3)),
              ),
            ],
          ),
        )
      )
    );
  }
}