import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
class VideoCost extends StatefulWidget {
  final VidChannel channel;
  final String creatorId;
  final Function(dynamic) onCompleted;
  final Function onPrevious;

  const VideoCost({
    super.key, 
    required this.onCompleted, 
    required this.onPrevious, 
    required this.channel, 
    required this.creatorId
  });

  @override
  VideoCostState createState() => VideoCostState();
}

class VideoCostState extends State<VideoCost> {
  final GlobalKey _key1 = GlobalKey();
  TextEditingController txtCtrl = TextEditingController();
  double? cost = prudStudioNotifier.newVideo.costPerNonMemberView?? 0;
  bool result = false;
  FocusNode fNode = FocusNode();
  bool saving = false;
  bool promoteVideo = prudStudioNotifier.newVideo.promoted?? true;


  Future<void> save() async {
    if(cost == null || (cost != null && cost! <= 0)) return;
    if(mounted) setState(() => saving = true);
    await tryAsync("save", () async {
      prudStudioNotifier.newVideo.costPerNonMemberView = cost;
      prudStudioNotifier.newVideo.promoted = promoteVideo;
      if(promoteVideo) prudStudioNotifier.newVideo.sponsored = PromoteVideo(videoId: "");
      prudStudioNotifier.newVideo.channelId = widget.channel.id;
      await prudStudioNotifier.saveNewVideoData();
      ChannelVideo newVid = ChannelVideo(
        channelId: widget.channel.id!, promoted: promoteVideo, targetAudience: prudStudioNotifier.newVideo.targetAudience!,
        status: "active", statusDate: DateTime.now(), description: prudStudioNotifier.newVideo.description!,
        tags: prudStudioNotifier.newVideo.tags, videoThumbnail: prudStudioNotifier.newVideo.videoThumbnail!,
        title: prudStudioNotifier.newVideo.title!, uploadedBy: widget.creatorId, videoUrl: prudStudioNotifier.newVideo.videoUrl!,
        videoType: widget.channel.category, isLive: prudStudioNotifier.newVideo.isLive, liveStartsOn: prudStudioNotifier.newVideo.liveStartsOn,
        uploadedAt: DateTime.now(), updatedAt: DateTime.now(), scheduledFor: prudStudioNotifier.newVideo.scheduledFor,
        timezone: prudStudioNotifier.newVideo.timezone?? "WAT", costPerNonMemberView: prudStudioNotifier.newVideo.costPerNonMemberView!,
        iDeclared: prudStudioNotifier.newVideo.iDeclared!, videoDuration: prudStudioNotifier.newVideo.videoDuration!.toString(),
        movieDetailId: prudStudioNotifier.newVideo.movieDetailId, musicDetailId: prudStudioNotifier.newVideo.musicDetailId,
      );
      ChannelVideo? savedVid = await prudStudioNotifier.createNewVideo(newVid);
      if(savedVid != null){
        if(savedVid.id != null && prudStudioNotifier.newVideo.snippets != null && prudStudioNotifier.newVideo.snippets!.isNotEmpty){
          List<VideoSnippet> snippets = prudStudioNotifier.newVideo.snippets!.map<VideoSnippet>((snip) {
            snip.videoId = savedVid.id!;
            return snip;
          }).toList();
          savedVid.snippets = snippets;
          bool snippetsCreated = false;
          while(snippetsCreated == false){
            snippetsCreated = await prudStudioNotifier.createNewBulkSnippet(snippets);
          }
        }
        if(prudStudioNotifier.newVideo.promoted == true && prudStudioNotifier.newVideo.sponsored != null){
          PromoteVideo? sponsoredCreated;
          PromoteVideo sponsor = PromoteVideo(videoId: savedVid.id!);
          prudStudioNotifier.newVideo.sponsored = sponsor;
          while(sponsoredCreated == null){
            sponsoredCreated = await prudStudioNotifier.promoteVideo(sponsor);
          }
          savedVid.sponsored = sponsoredCreated;
        }
        if(prudStudioNotifier.newVideo.thriller != null){
          prudStudioNotifier.newVideo.thriller!.videoId = savedVid.id!;
          VideoThriller? vThriller = await prudStudioNotifier.createNewThriller(prudStudioNotifier.newVideo.thriller!);
          savedVid.thriller = vThriller;
        }
        if(mounted){
          setState(() {
            prudStudioNotifier.newVideo.hasSavedVideo = true;
            prudStudioNotifier.newVideo.savedVideo = savedVid;
            prudStudioNotifier.newVideo.hasSaveThriller = true;
            prudStudioNotifier.newVideo.hasSavedSnippets = true;
            prudStudioNotifier.newVideo.hasSavedSponsored = true;
            if(savedVid.thriller != null) prudStudioNotifier.newVideo.thriller = savedVid.thriller;
            if(savedVid.snippets != null) prudStudioNotifier.newVideo.snippets = savedVid.snippets;
            if(savedVid.sponsored != null) prudStudioNotifier.newVideo.sponsored = savedVid.sponsored;
            result = true;
            saving = false;
          });
        }
      }else{
        if(mounted){
          setState(() {
            result = false;
            saving = false;
          });
        }
      }
    }, error: (){
      if(mounted) setState(() => saving = false);
    });
    widget.onCompleted(result);
  }
  
  @override
  void initState(){
    if(mounted){
      txtCtrl.text = "$cost";
    }
    super.initState();
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    fNode.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    String cate = promoteVideo? "Yes" : "No";
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
          text: "Video Viewing Cost",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            spacer.height,
            Translate(
              text: "How much do you intend to charge non-member viewers who watch this video. Be reasonable! "
              "consider the fact that the lower your rate, the more views which eventually will get you more income than over-prices contents. "
              "Be sure that the rate is not lower than 0.05 Euro and not higher than 5 Euro when converted to your channel currency.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 15,
                color: prudColorTheme.textB,
                fontWeight: FontWeight.w500
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Viewing Cost",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    controller: txtCtrl,
                    name: 'cost',
                    key: _key1,
                    autofocus: true,
                    style: tabData.npStyle,
                    keyboardType: TextInputType.number,
                    decoration: getDeco(
                      "Video View Cost",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      tryOnly("onChange", (){
                        if(mounted && value != null) {
                          setState(() { 
                            cost = double.parse(value.trim());
                          });
                        }
                      }, error: (){
                        debugPrint("Wrong Values");
                      });
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            spacer.height,
            Translate(
              text: "Would you like to promote this video in other to reach many viewers quickly without having to pay from your own pocket? "
              "We make promoting videos on PrudApp easy so you can only pay from the proceeds of the promotion."
              " What this means is that you only pay us 30% of what you make on your video/channel monthly while your video/channel"
              " is promoted. You can always hub out of this whenever you want from PrudStudio.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 15,
                color: prudColorTheme.textB,
                fontWeight: FontWeight.w500
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Promote Video",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilder(
                    child: FormBuilderChoiceChips(
                      decoration: getDeco("Should Promote?"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        tryOnly("proSelector", (){
                          if(mounted && selected != null){
                            setState(() { 
                              promoteVideo = selected == "Yes";
                            });
                          }
                        });
                      },
                      name: "promote",
                      initialValue: cate,
                      options: ["Yes", "No"].map((String ele) {
                        return FormBuilderChipOption(
                          value: ele,
                          child: Translate(
                            text: ele,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                color: ele == cate?
                                prudColorTheme.bgA : prudColorTheme.primary
                            ),
                            align: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                prudWidgetStyle.getShortButton(
                  onPressed: widget.onPrevious, 
                  text: "Previous",
                  makeLight: true,
                  isPill: false
                ),
                saving? LoadingComponent(
                  isShimmer: false,
                  defaultSpinnerType: false,
                  size: 15,
                  spinnerColor: prudColorTheme.primary,
                ) : prudWidgetStyle.getShortButton(
                  onPressed: save, 
                  text: "Next",
                  makeLight: false,
                  isPill: false
                ),
              ],
            ),
            xLargeSpacer.height,
          ],
        ),
      ),
    );
  }
}