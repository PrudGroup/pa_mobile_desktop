import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/network_issue_component.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/settings_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class ChannelDetail extends StatefulWidget {
  final String cid;

  const ChannelDetail({super.key, required this.cid});

  @override
  ChannelDetailState createState() => ChannelDetailState();
}

class ChannelDetailState extends State<ChannelDetail> {
  Map<String, dynamic>? lastRouteData = localSettings.lastRouteData;

  Future<VidChannel>? getChannel() async {
    return await tryAsync("getChannel", () async {
      VidChannel? cha = await prudStudioNotifier.getChannelById(widget.cid);
      return cha;
    }, error: (){
      debugPrint("Error Occurred");
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if(mounted) setState(() => lastRouteData = localSettings.lastRouteData);
      },
      child: FutureBuilder(
        future: getChannel(), 
        builder: (BuildContext cText, AsyncSnapshot<VidChannel> snapshot){
          Widget loader = Scaffold(
            backgroundColor: prudColorTheme.primary,
            body: SafeArea(
              child: Center(
                child: LoadingComponent(
                  isShimmer: false,
                  spinnerColor: prudColorTheme.lineC,
                  defaultSpinnerType: false,
                  size: 15,
                ),
              ),
            ),
          );
          Widget error = Scaffold(
            backgroundColor: prudColorTheme.bgC,
            body: SafeArea(
              child: Column(
                children: [
                  largeSpacer.height,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: const NetworkIssueComponent(),
                  ),
                  spacer.height,
                ],
              )
            )
          );
          if(snapshot.hasError) return error;
          switch(snapshot.connectionState){
            case ConnectionState.none:
              return loader;
            case ConnectionState.waiting:
              return loader;
            default: {
              if(snapshot.hasData && snapshot.data != null){
                VidChannel channel = snapshot.data!;
                bool isOwner = lastRouteData?["isOwner"]?? false;
                return ChannelView(channel: channel, isOwner: isOwner);
              }else{
                return error;
              }
            }
          }
        }
      ),
    );
  }
}