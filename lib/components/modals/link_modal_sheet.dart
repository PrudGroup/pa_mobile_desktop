import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../models/aff_link.dart';
import '../../models/theme.dart';
import '../../singletons/shared_local_storage.dart';
import '../prud_data_viewer.dart';
import '../prud_panel.dart';

class LinkModalSheet extends StatefulWidget {
  final double height;
  final AffLink affLink;
  final BorderRadiusGeometry radius;


  const LinkModalSheet({
    super.key,
    required this.affLink,
    required this.radius,
    required this.height,
  });

  @override
  LinkModalSheetState createState() => LinkModalSheetState();
}

class LinkModalSheetState extends State<LinkModalSheet> {

  void copyLink() async {
    await Clipboard.setData(ClipboardData(text: "${widget.affLink.fullShortUrl}"));
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Link Copied To Clipboard"),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry rad = widget.radius;
    double height = widget.height;
    return ClipRRect(
      borderRadius: rad,
      child: Container(
        height: height,
        constraints: BoxConstraints(maxHeight: height),
        decoration: BoxDecoration(
          borderRadius: rad,
          color: prudColorTheme.bgA
        ),
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              spacer.height,
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrudDataViewer(field: "Sparks Achieved", value: widget.affLink.totalSparks),
                  prudWidgetStyle.getShortButton(
                    onPressed: copyLink,
                    text: "Copy Link",
                  ),
                ],
              ),
              spacer.height,
              PrudPanel(
                title: "Affiliate Link",
                child: Column(
                  children: [
                    spacer.height,
                    SizedBox(
                      child: Text(
                        "${widget.affLink.fullShortUrl}",
                        style: prudWidgetStyle.hintStyle.copyWith(
                            color: prudColorTheme.iconA,
                            fontSize: 16
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ],
                ),
              ),
              spacer.height,
              PrudPanel(
                title: "Created On",
                child: Column(
                  children: [
                    spacer.height,
                    SizedBox(
                      child: Text(
                        "${widget.affLink.createdAt}",
                        style: prudWidgetStyle.hintStyle.copyWith(
                          color: prudColorTheme.textA,
                          fontSize: 16
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          myStorage.ago(dDate: widget.affLink.createdAt!, isShort: false),
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 10,
                            color: prudColorTheme.iconB
                          ),
                          textAlign: TextAlign.right,
                        )
                      ],
                    )

                  ],
                ),
              ),
              spacer.height,
              PrudPanel(
                title: "Last Updated On",
                child: Column(
                  children: [
                    spacer.height,
                    SizedBox(
                      child: Text(
                        "${widget.affLink.updatedAt}",
                        style: prudWidgetStyle.hintStyle.copyWith(
                            color: prudColorTheme.textA,
                            fontSize: 16
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          myStorage.ago(dDate: widget.affLink.updatedAt!, isShort: false),
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 10,
                              color: prudColorTheme.iconB
                          ),
                          textAlign: TextAlign.right,
                        )
                      ],
                    )

                  ],
                ),
              ),
              spacer.height,
              prudWidgetStyle.getLongButton(
                onPressed: () => Navigator.of(context).pop(),
                text: "Go Back"
              ),
              spacer.height,

            ],
          ),
        )
      ),
    );
  }
}
