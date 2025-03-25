import 'package:flutter/material.dart';

import '../../../components/inner_menu.dart';
import '../../../components/translate_text.dart';
import '../../../models/images.dart';
import '../../../models/theme.dart';
import 'creatorTabs/add_as_creator.dart';
import 'creatorTabs/add_creator_to_channel.dart';
import 'creatorTabs/remove_creator_from_channel.dart';
import 'creatorTabs/view_studio_creators.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class StudioCreators extends StatefulWidget {
  final Function(int)? goToTab;
  const StudioCreators({super.key, this.goToTab});

  @override
  StudioCreatorsState createState() => StudioCreatorsState();
}

class StudioCreatorsState extends State<StudioCreators> {

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
          InnerMenuItem(imageIcon: prudImages.addOperator, title: "Add As Creator", menu: const AddAsCreator()),
          InnerMenuItem(imageIcon: prudImages.prudVider, title: "Add To Channel", menu: const AddCreatorToChannel()),
          InnerMenuItem(icon: Icons.person_remove, title: "Remove From Channel", menu: const RemoveCreatorFromChannel()),
          InnerMenuItem(icon: Icons.group_rounded, title: "View Creators", menu:  const ViewStudioCreators())
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
          onPressed: () => iCloud.goBack(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Studio Creators",
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
