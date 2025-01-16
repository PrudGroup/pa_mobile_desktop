import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_data_viewer.dart';
import 'package:prudapp/components/prud_showroom.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../models/prud_vid.dart';
import '../singletons/i_cloud.dart';

class ManageStudioComponent extends StatefulWidget {

  const ManageStudioComponent({super.key});

  @override
  State<ManageStudioComponent> createState() => _ManageStudioComponentState();
}

class _ManageStudioComponentState extends State<ManageStudioComponent> {

  Studio? studio = prudStudioNotifier.studio;

  @override
  void initState() {
    super.initState();
  }

  int getTotalChannels() {
    if(studio!.channels == null) {
      return 0;
    } else {
      return studio!.channels!.length;
    }
  }

  int getTotalStreams() {
    if(studio!.streams == null) {
      return 0;
    } else {
      return studio!.streams!.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        // padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            spacer.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: FittedBox(
                child: PrudDataViewer(field: "Studio Name", value: studio!.studioName, makeTransparent: true,),
              ),
            ),
            spacer.height,
            SizedBox(
              height: 140,
              child: ListView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                children: [
                  PrudDataViewer(
                    field: "Created When",
                    value: myStorage.ago(dDate: studio!.createdOn!),
                  ),
                  spacer.width,
                  PrudDataViewer(
                    field: "Channels",
                    value: "${getTotalChannels()}",
                  ),
                  spacer.width,
                  PrudDataViewer(
                    field: "Streams",
                    value: "${getTotalStreams()}",
                  ),
                ],
              ),
            ),
            spacer.height,
            spacer.height,
            Divider(
              indent: 20,
              endIndent: 20,
              height: 2,
              thickness: 3,
              color: prudColorTheme.bgD,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: FittedBox(
                child: PrudDataViewer(field: "Studio ID", value: studio!.id, makeTransparent: true,),
              ),
            ),
            Divider(
              indent: 20,
              endIndent: 20,
              height: 2,
              thickness: 3,
              color: prudColorTheme.bgD,
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: PrudShowroom(items: iCloud.getShowroom(context, showroomItems: 5)),
            ),
            largeSpacer.height,
          ],
        ),
      ),
    );
  }
}