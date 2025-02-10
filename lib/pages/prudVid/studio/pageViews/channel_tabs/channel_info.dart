import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_data_viewer.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

class ChannelInfo extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;

  const ChannelInfo({super.key, required this.channel, required this.isOwner});

  @override
  ChannelInfoState createState() => ChannelInfoState();
}

class ChannelInfoState extends State<ChannelInfo> {
  bool gettingSubscribers = false;
  bool gettingMembers = false;
  int subscribers = 0;
  int members = 0;
  bool isSubscribed = false;
  bool isAMember = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getSubscribersCount();
      await getMembersCount();
    });
    super.initState();
  }

  Future<void> subscribe() async {

  }

  Future<void> unsubscribe() async {
    
  }

  Future<void> leave() async {
    
  }

  Future<void> join() async {
    
  }

  Future<void> getSubscribersCount() async {
    await tryAsync("getSubscribersCount", () async {
      if (mounted) setState(() => gettingSubscribers = true);
      int count =
          await prudStudioNotifier.getSubscribersCount(widget.channel.id!);
      if (mounted) {
        setState(() {
          subscribers = count;
          gettingSubscribers = false;
        });
      }
    }, error: () {
      if (mounted) setState(() => gettingSubscribers = false);
    });
  }

  Future<void> getMembersCount() async {
    await tryAsync("getMembersCount", () async {
      if (mounted) setState(() => gettingMembers = true);
      int count = await prudStudioNotifier.getMembersCount(widget.channel.id!);
      if (mounted) {
        setState(() {
          members = count;
          gettingMembers = false;
        });
      }
    }, error: () {
      if (mounted) setState(() => gettingMembers = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            spacer.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      gettingSubscribers? LoadingComponent(
                        isShimmer: false,
                        defaultSpinnerType: false,
                        size: 10,
                        spinnerColor: prudColorTheme.secondary,
                      ) : Text(
                        "${tabData.getFormattedNumber(widget.channel.subscriberLinks != null ? widget.channel.subscriberLinks!.length : subscribers)}",
                        style: prudWidgetStyle.btnTextStyle.copyWith(
                          fontSize: 14,
                          color: prudColorTheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Translate(
                        text: "Subscribers",
                        style: prudWidgetStyle.btnTextStyle.copyWith(
                          fontSize: 12,
                          color: prudColorTheme.iconC,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      )
                    ],
                  ),
                  widget.isOwner? SizedBox() : (
                    isSubscribed? prudWidgetStyle.getShortButton(
                      onPressed: unsubscribe, text: "Unsubscribe",
                      isSmall: true, isPill: true, makeLight: true
                    ) : prudWidgetStyle.getShortButton(
                      onPressed: subscribe, text: "Unsubscribe",
                      isSmall: true, isPill: false
                    )
                  )
                ],
              ),
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      gettingMembers? LoadingComponent(
                        isShimmer: false,
                        defaultSpinnerType: false,
                        size: 10,
                        spinnerColor: prudColorTheme.secondary,
                      ) : Text(
                        "${tabData.getFormattedNumber(widget.channel.memberLinks != null ? widget.channel.subscriberLinks!.length : members)}",
                        style: prudWidgetStyle.btnTextStyle.copyWith(
                          fontSize: 14,
                          color: prudColorTheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Translate(
                        text: "Members",
                        style: prudWidgetStyle.btnTextStyle.copyWith(
                          fontSize: 12,
                          color: prudColorTheme.iconC,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      )
                    ],
                  ),
                  widget.isOwner? SizedBox() : (
                    isSubscribed? prudWidgetStyle.getShortButton(
                      onPressed: leave, text: "Leave",
                      isSmall: true, isPill: true, makeLight: true
                    ) : prudWidgetStyle.getShortButton(
                      onPressed: join, text: "Join Now",
                      isSmall: true, isPill: false
                    )
                  )
                ],
              ),                        
            ),
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrudDataViewer(
                    field: "Target Age",
                    value: widget.channel.miniTargetAge,
                    makeTransparent: true,
                    removeWidth: true,
                    subValue: "Minimum",
                    size: PrudSize.smaller,
                  ),
                  PrudDataViewer(
                    field: "Target Age",
                    removeWidth: true,
                    value: widget.channel.maxTargetAge,
                    makeTransparent: true,
                    subValue: "Maximum",
                    size: PrudSize.smaller,
                  ),
                  PrudDataViewer(
                    field: "Membership",
                    value: "${tabData.getCurrencySymbol(widget.channel.channelCurrency)}${widget.channel.monthlyMembershipCost}",
                    makeTransparent: true,
                    valueIsMoney: true,
                    removeWidth: true,
                    size: PrudSize.smaller,
                    subValue: "${tabData.getCurrencyName(widget.channel.channelCurrency)}"
                  ),
                ]
              )
            ),
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            spacer.height,
          ],
        ),
      ),
    );
  }
}
