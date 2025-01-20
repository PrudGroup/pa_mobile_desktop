import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_showroom.dart';
import 'package:prudapp/components/studio_channel_list_component.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../../../../models/prud_vid.dart';
import '../../../../../singletons/i_cloud.dart';

class MyChannels extends StatefulWidget {

  const MyChannels({super.key});

  @override
  State<MyChannels> createState() => _MyChannelsState();
}

class _MyChannelsState extends State<MyChannels> {

  List<VidChannel> myChannels = prudStudioNotifier.myChannels;
  Widget notFound = tabData.getNotFoundWidget(
    title: "Channels Not Found",
    desc: "Unable to reach PrudServices or you don't have a channel in your studio yet. It's easy to start one."
  );

  Future<void> refresh() async {
    await prudStudioNotifier.getMyChannels();
  }

  @override
  void initState() {
    super.initState();
    prudStudioNotifier.addListener((){
      if(mounted) setState(() => myChannels = prudStudioNotifier.myChannels);
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
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PrudShowroom(items: iCloud.getShowroom(context, showroomItems: 1)),
              myChannels.isNotEmpty? StudioChannelListComponent(channels: myChannels) : notFound,
              PrudShowroom(items: iCloud.getShowroom(context, showroomItems: 2)),
            ],
          ),
        )
      )
    );
  }
}