import 'package:flutter/material.dart';
import 'package:prudapp/components/create_new_studio_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/manage_studio_component.dart';
import 'package:prudapp/models/theme.dart';
import '../../../../models/prud_vid.dart';
import '../../../../singletons/prud_studio_notifier.dart';

class ViewStudio extends StatefulWidget {

    const ViewStudio({super.key});

    @override
    State<ViewStudio> createState() => _ViewStudioState();
}

class _ViewStudioState extends State<ViewStudio> {
  Studio? studio = prudStudioNotifier.studio;
  bool loading = false;

  Future<void> getStudio() async {
    if (studio == null) {
      setState(() => loading = true);
      await prudStudioNotifier.getStudio();
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getStudio();
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
        studio != null? ManageStudioComponent() : CreateNewStudioComponent()
    );
  }
}