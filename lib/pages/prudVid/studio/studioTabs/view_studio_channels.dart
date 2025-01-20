import 'package:flutter/material.dart';
import 'package:prudapp/pages/prudVid/studio/studioTabs/channelTabs/affiliated_channels.dart';
import 'package:prudapp/pages/prudVid/studio/studioTabs/channelTabs/my_channels.dart';

import '../../../../components/inner_menu.dart';

class ViewStudioChannels extends StatefulWidget {
  const ViewStudioChannels({super.key});

  @override
  State<ViewStudioChannels> createState() => _ViewStudioChannelsState();
}

class _ViewStudioChannelsState extends State<ViewStudioChannels> {
  List<InnerMenuItem> tabMenus = [];
  final GlobalKey<InnerMenuState> _key = GlobalKey();

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
            InnerMenuItem(icon: Icons.manage_accounts, title: "My Channels", menu: MyChannels(),),
            InnerMenuItem(icon: Icons.baby_changing_station, title: "Affiliated Channels", menu: AffiliatedChannels()),
          ];
        });
      }
    }

    @override
     Widget build(BuildContext context) {
         return InnerMenu(key: _key, menus: tabMenus, type: 1, hasIcon: true,);
     }
}