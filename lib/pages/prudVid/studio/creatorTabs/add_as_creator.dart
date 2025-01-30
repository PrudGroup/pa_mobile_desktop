
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_showroom.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:share_plus/share_plus.dart';

class AddAsCreator extends StatefulWidget{

  const AddAsCreator({super.key, });

  @override
  AddAsCreatorState createState() => AddAsCreatorState();
}


class AddAsCreatorState extends State<AddAsCreator>{
  bool loading = false;
  ContentCreator? creator = prudStudioNotifier.amACreator;

  @override
  void initState() {
    super.initState();
    prudStudioNotifier.addListener((){
      if(mounted) setState(() => creator = prudStudioNotifier.amACreator);
    });
  } 

  void copyToClipboard() async {
    if(creator != null && creator!.id != null){
      await Clipboard.setData(ClipboardData(text: "${creator!.id}"));
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("ID Copied To Clipboard"),
        ));
      }
    }
  }

  void share() async {
    final result = await Share.share('I am a content creator on Prudapp with creator id ${creator!.id}', subject: "CreatorID");
    if (result.status == ShareResultStatus.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("CreatorID Shared"),
      ));
    }
  }

  @override
  void dispose() {
    prudStudioNotifier.removeListener((){});
    super.dispose();
  }

  Future<void> _create() async {
    await tryAsync("_create", () async {
      if(myStorage.user != null && myStorage.user!.id != null){
        ContentCreator newCreator = ContentCreator(affId: myStorage.user!.id!);
        ContentCreator? added = await prudStudioNotifier.createNewCreator(newCreator);
        debugPrint("Creator: $added");
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            spacer.height,
            PrudShowroom(items: iCloud.getShowroom(context, showroomItems: 1)),
            creator != null? 
            Column(
              spacing: 5,
              children: [
                ImageIcon(AssetImage(prudImages.income), size: 60, color: prudColorTheme.secondary,),
                Translate(
                  text: "Waooh! Content Creator!",
                  style: tabData.bStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: prudColorTheme.secondary,
                  ),
                  align: TextAlign.center,
                ),
                Translate(
                  text: "Create as many original contents as you can, then relax, and enjoy the passive income that comes with it.",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: prudColorTheme.textB,
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
                Row(
                  children: [
                    FittedBox(
                      child: Text(
                        "${creator?.id}",
                        style: prudWidgetStyle.btnTextStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: prudColorTheme.textA,
                        ),
                      ),
                    ),
                    spacer.width,
                    IconButton(
                      tooltip: "Copy To Clipboard",
                      onPressed: copyToClipboard, 
                      icon: Icon(Icons.copy_sharp,),
                      color: prudColorTheme.primary,
                      iconSize: 30,
                    ),
                    spacer.width,
                    IconButton(
                      tooltip: "Share Via Social",
                      onPressed: share, 
                      icon: Icon(Icons.share,),
                      color: prudColorTheme.primary,
                      iconSize: 30,
                    )
                  ],
                )
              ],
            ) 
            : 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                Translate(
                  text: "Signing up as a content creator on prudapp is the most valueable decision anyone would make. As a content "
                  "creator, you get to request to join any channel you desire especially already successful channels. If accepted, "
                  "you will be paid for all the content you create for the channel. Are you ready?",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: prudColorTheme.textB,
                  ),
                  align: TextAlign.center,
                ),
                loading? LoadingComponent(
                  isShimmer: false,
                  defaultSpinnerType: false,
                  size: 30,
                  spinnerColor: prudColorTheme.primary,
                ) : prudWidgetStyle.getLongButton(
                  onPressed: _create, 
                  text: "Become A Content Creator",
                  shape: 1
                ),
              ],
            ),
            PrudShowroom(items: iCloud.getShowroom(context, showroomItems: 2)),
          ],
        ),
      ),
    );
  }

}