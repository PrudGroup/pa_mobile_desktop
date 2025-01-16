import 'package:flutter/material.dart';
import 'package:prudapp/pages/prudVid/studio/studioTabs/new_channel.dart';
import 'package:prudapp/pages/prudVid/studio/studioTabs/promote_studio_channel.dart';
import 'package:prudapp/pages/prudVid/studio/studioTabs/view_studio.dart';
import 'package:prudapp/pages/prudVid/studio/studioTabs/view_studio_channels.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';

import '../../../components/inner_menu.dart';
import '../../../components/translate_text.dart';
import '../../../models/images.dart';
import '../../../models/theme.dart';

class StudioChannel extends StatefulWidget {
  final Function(int)? goToTab;
  const StudioChannel({super.key, this.goToTab});

  @override
  StudioChannelState createState() => StudioChannelState();
}

class StudioChannelState extends State<StudioChannel> {
  int selectedTab = prudStudioNotifier.selectedTab;
  List<InnerMenuItem> tabMenus = [];
  final GlobalKey<InnerMenuState> _key = GlobalKey();

  @override
  void dispose() {
    super.dispose();
  }

  void moveTo(int index){
    if(_key.currentState != null){
      _key.currentState!.changeWidget(_key.currentState!.widget.menus[index].menu, index);
    }
  }

  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        tabMenus = [
          InnerMenuItem(imageIcon: prudImages.studio, title: "Studio", menu: ViewStudio(goToTab: (int index) => moveTo(index))),
          InnerMenuItem(imageIcon: prudImages.live, title: "New Channel", menu: NewChannel(goToTab: (int index) => moveTo(index))),
          InnerMenuItem(imageIcon: prudImages.localVideoLibrary, title: "Channels", menu: const ViewStudioChannels()),
          InnerMenuItem(imageIcon: prudImages.videoAd, title: "Promote Channel", menu:  const PromoteStudioChannel())
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Studio & Channels",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: InnerMenu(key: _key, menus: tabMenus, type: 0, hasIcon: true,),
    );
  }
}
