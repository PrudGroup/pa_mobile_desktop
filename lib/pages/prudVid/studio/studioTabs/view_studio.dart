import 'package:flutter/material.dart';
import 'package:prudapp/components/create_new_studio_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/manage_studio_component.dart';
import 'package:prudapp/models/theme.dart';
import '../../../../models/prud_vid.dart';
import '../../../../singletons/currency_math.dart';
import '../../../../singletons/i_cloud.dart';
import '../../../../singletons/prud_studio_notifier.dart';
import 'package:prudapp/components/network_issue_component.dart';

class ViewStudio extends StatefulWidget {
  final Function(int) goToTab;
  const ViewStudio({super.key, required this.goToTab});

  @override
  State<ViewStudio> createState() => _ViewStudioState();
}

class _ViewStudioState extends State<ViewStudio> {
  Studio? studio = prudStudioNotifier.studio;
  bool loading = false;
  bool prudServiceIsAvailable = true;

  Future<void> changeConnectionStatus() async{
    bool ok = await iCloud.prudServiceIsAvailable();
    if(mounted) setState(() => prudServiceIsAvailable = ok);
  }

  Future<void> _refresh() async {
    await currencyMath.loginAutomatically();
    await changeConnectionStatus();
  }

  Future<void> getStudio() async {
    if (studio == null) {
      setState(() => loading = true);
      await prudStudioNotifier.getStudio();
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    prudStudioNotifier.removeListener((){});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await changeConnectionStatus();
      await getStudio();
    });
    prudStudioNotifier.addListener((){
      if(mounted && prudStudioNotifier.studio != studio){
        setState(() => studio = prudStudioNotifier.studio);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading?
    LoadingComponent(
      isShimmer: false,
      defaultSpinnerType: false,
      size: 20,
      spinnerColor: prudColorTheme.lineB,
    )
        :
    (
      prudServiceIsAvailable? (
          studio != null? ManageStudioComponent()
              : CreateNewStudioComponent(onTabChange: (int tab) => widget.goToTab(tab),)
      ) : RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            spacer.height,
            const NetworkIssueComponent(),
            spacer.height,
          ],
        ),
      )
    );
  }
}