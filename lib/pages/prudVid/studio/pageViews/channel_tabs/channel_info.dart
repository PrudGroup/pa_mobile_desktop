import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/modals/edit_channel_modal_sheet.dart';
import 'package:prudapp/components/prud_data_viewer.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
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
  List<ChannelMembership> channelsMembered = prudStudioNotifier.affJoined;
  List<ChannelSubscriber> channelsSubscribed = prudStudioNotifier.affSubscribed;
  bool checkingIfSubscribed = false;
  bool checkingIfMembered = false;
  bool subscribing = false;
  bool unsubscribing = false;
  bool joining = false;
  bool leaving = false;
  int totalStreamServices = 0;
  int totalStreamActiveServices = 0;
  double totalIncomeFromStream = 0;
  bool gettingStreamFigures = false;
  String? changedDescription;
  double? changedMembershipCost;
  double? changedStreamingCost;
  double? changedViewShare;
  double? changedMembershipShare;



  void openEditSheet(String editor, double height){
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: prudColorTheme.bgC,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: prudRad,
      ),
      builder: (BuildContext context) {
        return EditChannelModalSheet(
          editType: editor,
          radius: prudRad,
          height: height,
          channel: widget.channel,
        );
      },
    );
  }

  Future<void> setStreamServicesFigures() async {
    if(widget.channel.streamServices != null){
      int totalServices = widget.channel.streamServices!.length;
      int active = widget.channel.streamServices!.where((sm) => sm.active).length;
      double income = (changedStreamingCost?? widget.channel.monthlyStreamingCost) * active;
      if(mounted){
        setState((){
          totalStreamServices = totalServices;
          totalStreamActiveServices = active;
          totalIncomeFromStream = income;
        });
      }
    }else{
      await tryAsync("setStreamServicesFigures", () async {
        if(mounted) setState(() => gettingStreamFigures = true);
        ChannelStreamServiceFigure figure = await prudStudioNotifier.getChannelStreamFigures(widget.channel.id!);
        if(mounted){
          setState((){
            totalStreamServices = figure.total;
            totalStreamActiveServices = figure.active;
            totalIncomeFromStream = (changedStreamingCost?? widget.channel.monthlyStreamingCost) * figure.active;
            gettingStreamFigures = false;
          });
        }
      }, error: (){
        if(mounted) setState(() => gettingStreamFigures = false);
      });
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      // TODO: take this to isolate for speed
      await getSubscribersCount();
      await getMembersCount();
      await setStreamServicesFigures();
      checkIfSubscribed();
      checkIfMembered();
    });
    super.initState();
    prudStudioNotifier.addListener(() async {
      if (mounted) {
        setState(() {
          changedMembershipShare = prudStudioNotifier.changedMembershipShare;
          changedViewShare = prudStudioNotifier.changedViewShare;
          changedStreamingCost = prudStudioNotifier.changedStreamingCost;
          changedMembershipCost = prudStudioNotifier.changedMembershipCost;
          changedDescription = prudStudioNotifier.changedDescription;
          channelsMembered = prudStudioNotifier.affJoined;
          channelsSubscribed = prudStudioNotifier.affSubscribed;
        });
      }
      checkIfSubscribed();
      checkIfMembered();
    });
  }

  void checkIfSubscribed() {
    tryOnly("checkIfSubscribed", () async {
      if (mounted) setState(() => checkingIfSubscribed = true);
      if (channelsSubscribed.isNotEmpty) {
        bool subscribedB4 = channelsSubscribed.any(
          (cs) => cs.channelId == widget.channel.id,
        );
        if (mounted) {
          setState(() {
            checkingIfSubscribed = false;
            isSubscribed = subscribedB4;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            checkingIfSubscribed = false;
            isSubscribed = false;
          });
        }
      }
    }, error: () {
      if (mounted) setState(() => checkingIfSubscribed = false);
    });
  }

  void checkIfMembered() {
    tryOnly("checkIfMembered", () async {
      if (mounted) setState(() => checkingIfMembered = true);
      if (channelsMembered.isNotEmpty) {
        bool memberedB4 = channelsMembered.any(
          (cs) => cs.channelId == widget.channel.id,
        );
        if (mounted) {
          setState(() {
            checkingIfMembered = false;
            isAMember = memberedB4;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            checkingIfMembered = false;
            isAMember = false;
          });
        }
      }
    }, error: () {
      if (mounted) setState(() => checkingIfMembered = false);
    });
  }

  Future<void> subscribe() async {
    await tryAsync("subscribe", () async {
      if (mounted) setState(() => subscribing = true);
      ChannelSubscriber? sub = await prudStudioNotifier.subscribeToChannel(widget.channel.id!);
      if (mounted && sub != null) {
        prudStudioNotifier.addSubscribedToCache(sub);
        setState(() {
          subscribing = false;
          isSubscribed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Subscribed"),
        ));
      }
    }, error: () {
      if (mounted) {
        setState(() => subscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Subscribe"),
          backgroundColor: prudColorTheme.primary,
        ));
      }
    });
  }

  Future<void> unsubscribe() async {
    await tryAsync("unsubscribe", () async {
      if (mounted) setState(() => unsubscribing = true);
      bool sub = await prudStudioNotifier.unsubscribeFromAChannel(widget.channel.id!);
      if (mounted && sub == true) {
        await prudStudioNotifier.removeSubscribedFromCache(ChannelSubscriber(
          affId: myStorage.user!.id!, channelId: widget.channel.id!
        ));
        setState(() {
          unsubscribing = false;
          isSubscribed = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unsubscribed"),
          ));
        }
      }else{
        if (mounted) {
          setState(() => unsubscribing = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Unsubscribe"),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
    }, error: () {
      if (mounted) {
        setState(() => unsubscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Unsubscribe"),
          backgroundColor: prudColorTheme.primary,
        ));
      }
    });
  }

  Future<void> leave() async {
    await tryAsync("leave", () async {
      if (mounted) setState(() => leaving = true);
      bool sub = await prudStudioNotifier.leaveAChannel(widget.channel.id!);
      if (mounted && sub == true) {
        await prudStudioNotifier.removeJoinedFromCache(ChannelMembership(
          affId: myStorage.user!.id!, channelId: widget.channel.id!
        ));
        setState(() {
          leaving = false;
          isAMember = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Left"),
          ));
        }
      }else{
        if (mounted) {
          setState(() => leaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Leave"),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
    }, error: () {
      if (mounted) {
        setState(() => leaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Leave"),
          backgroundColor: prudColorTheme.primary,
        ));
      }
    });
  }

  Future<void> join() async {
    await tryAsync("join", () async {
      if (mounted) setState(() => joining = true);
      ChannelMembership? sub = await prudStudioNotifier.joinAChannel(widget.channel.id!);
      if (mounted && sub != null) {
        await prudStudioNotifier.addJoinedToCache(sub);
        setState(() {
          joining = false;
          isAMember = true;
        });
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Joined"),
          ));
        }
      }else{
        if (mounted) {
          setState(() => joining = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Join."),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
    }, error: () {
      if (mounted) {
        setState(() => joining = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Join."),
          backgroundColor: prudColorTheme.primary,
        ));
      }
    });
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
  void dispose() {
    prudStudioNotifier.removeListener(() {
      prudStudioNotifier.clearChannelChanges();
    });
    super.dispose();
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
                      gettingSubscribers
                          ? LoadingComponent(
                              isShimmer: false,
                              defaultSpinnerType: false,
                              size: 10,
                              spinnerColor: prudColorTheme.secondary,
                            )
                          : Text(
                              tabData.getFormattedNumber(widget.channel.subscriberLinks != null ? widget.channel.subscriberLinks!.length : subscribers),
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
                  widget.isOwner
                      ? SizedBox()
                      : (checkingIfSubscribed
                          ? LoadingComponent(
                              isShimmer: false,
                              defaultSpinnerType: false,
                              size: 10,
                              spinnerColor: prudColorTheme.lineC,
                            )
                          : (isSubscribed
                              ? (
                                unsubscribing? LoadingComponent(
                                  isShimmer: false,
                                  size: 15,
                                  spinnerColor: prudColorTheme.primary,
                                ) :
                                prudWidgetStyle.getShortButton(
                                  onPressed: unsubscribe,
                                  text: "Unsubscribe",
                                  isSmall: true,
                                  isPill: true,
                                  makeLight: true
                              ))
                              : 
                              (
                                subscribing? LoadingComponent(
                                  isShimmer: false,
                                  size: 15,
                                  spinnerColor: prudColorTheme.primary,
                                ) 
                                :
                                prudWidgetStyle.getShortButton(
                                  onPressed: subscribe,
                                  text: "Subscribe",
                                  isSmall: true,
                                  isPill: false
                                )
                              )
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
                      gettingMembers
                          ? LoadingComponent(
                              isShimmer: false,
                              defaultSpinnerType: false,
                              size: 10,
                              spinnerColor: prudColorTheme.secondary,
                            )
                          : Text(
                              tabData.getFormattedNumber(widget.channel.memberLinks != null ? widget.channel.subscriberLinks!.length : members),
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
                  widget.isOwner
                      ? SizedBox()
                      : (checkingIfMembered
                          ? LoadingComponent(
                              isShimmer: false,
                              defaultSpinnerType: false,
                              size: 10,
                              spinnerColor: prudColorTheme.lineC,
                            )
                          : 
                          (
                            isAMember? 
                            (
                              (
                                leaving? LoadingComponent(
                                  isShimmer: false,
                                  size: 15,
                                  spinnerColor: prudColorTheme.primary,
                                ) 
                                :
                                prudWidgetStyle.getShortButton(
                                  onPressed: leave,
                                  text: "Leave",
                                  isSmall: true,
                                  isPill: true,
                                  makeLight: true
                                )
                              )
                            )
                            : 
                            (
                              joining? 
                              LoadingComponent(
                                isShimmer: false,
                                size: 15,
                                spinnerColor: prudColorTheme.primary,
                              ) 
                                :
                              prudWidgetStyle.getShortButton(
                                onPressed: join,
                                text: "Join",
                                isSmall: true,
                                isPill: false
                              )
                            )
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
                    subValue: "Minimum",
                    size: PrudSize.smaller,
                  ),
                  PrudDataViewer(
                    field: "Target Age",
                    value: widget.channel.maxTargetAge,
                    makeTransparent: true,
                    subValue: "Maximum",
                    size: PrudSize.smaller,
                  ),
                  PrudDataViewer(
                      field: "Membership",
                      value:
                          "${tabData.getCurrencySymbol(widget.channel.channelCurrency)}${changedMembershipCost?? widget.channel.monthlyMembershipCost}",
                      makeTransparent: true,
                      valueIsMoney: true,
                      size: PrudSize.smaller,
                      subValue:
                          "${tabData.getCurrencyName(widget.channel.channelCurrency)}"),
                ],
              ),
            ),
            if(widget.isOwner) spacer.height,
            if(widget.isOwner) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: prudWidgetStyle.getLongButton(
                onPressed: () => openEditSheet("membership_cost", screen.height),
                text: "Change Membership Fee",
                shape: 1,
              ),
            ),
            if(widget.isOwner) spacer.height,
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Translate(
                    text: changedDescription?? widget.channel.description,
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: prudColorTheme.textB
                    ),
                    align: TextAlign.center,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      iconSize: 25,
                      color: prudColorTheme.primary,
                      onPressed: () => openEditSheet("description", screen.height),
                      icon: Icon(Icons.edit),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: PrudPanel(
                title: "Creators",
                bgColor: prudColorTheme.bgC,
                titleSize: 14,
                child: FittedBox(
                  child: Row(
                    children:[
                      PrudDataViewer(
                        field: "Status",
                        value: widget.channel.presentlySeekingCreators? "Presently": "Not",
                        makeTransparent: true,
                        size: PrudSize.smaller,
                        subValue: "Seeking",
                      ),
                      PrudDataViewer(
                        field: "Creators",
                        value: widget.channel.creators?.length?? 0,
                        makeTransparent: true,
                        size: PrudSize.smaller,
                        subValue: "Expert"
                      ),
                      PrudDataViewer(
                        field: "Videos",
                        value: widget.channel.videos?.length?? 0,
                        makeTransparent: true,
                        size: PrudSize.smaller,
                        subValue: "Uploaded"
                      ),
                    ]
                  ),
                ),
              ),
            ),
            if(widget.isOwner) spacer.height,
            if(widget.isOwner) Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            if(widget.isOwner) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: prudWidgetStyle.getLongButton(
                onPressed: () => openEditSheet("creator_membership_share", screen.height),
                text: "Change Creator's Share",
                shape: 1,
              ),
            ),
            if(widget.isOwner) Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            spacer.height,
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrudDataViewer(
                    field: "Streaming Fee",
                    value: "${tabData.getCurrencySymbol(widget.channel.channelCurrency)}${changedStreamingCost?? widget.channel.monthlyStreamingCost}",
                    makeTransparent: true,
                    valueIsMoney: true,
                    subValue: "${tabData.getCurrencyName(widget.channel.channelCurrency)}",
                    size: PrudSize.smaller,
                  ),
                  PrudDataViewer(
                    field: "Membership Share",
                    value: "${changedMembershipShare?? widget.channel.membershipPercentageSharePerMonth}%",
                    makeTransparent: true,
                    subValue: "Creators",
                    size: PrudSize.smaller,
                  ),
                  PrudDataViewer(
                    field: "View Share",
                    value: "${changedViewShare?? widget.channel.contentPercentageSharePerView}%",
                    makeTransparent: true,
                    size: PrudSize.smaller,
                    subValue: "Creators"
                  ),
                ],
              ),
            ),
            if(widget.isOwner) Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            if(widget.isOwner) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: prudWidgetStyle.getLongButton(
                onPressed: () => openEditSheet("streaming_cost", screen.height),
                text: "Change Streaming Fee",
                shape: 1,
              ),
            ),
            if(widget.isOwner) Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: PrudPanel(
                title: "Streaming",
                bgColor: prudColorTheme.bgC,
                titleSize: 14,
                child: FittedBox(
                  child: Row(
                    children:[
                      gettingStreamFigures? LoadingComponent(
                        isShimmer:false,
                        defaultSpinnerType: false,
                        size: 10,
                        spinnerColor: prudColorTheme.lineC,
                      ) : PrudDataViewer(
                        field: "Services",
                        value: totalStreamServices,
                        makeTransparent: true,
                        size: PrudSize.smaller,
                        subValue: "Total",
                      ),
                      gettingStreamFigures? LoadingComponent(
                        isShimmer:false,
                        defaultSpinnerType: false,
                        size: 10,
                        spinnerColor: prudColorTheme.lineC,
                      ) : PrudDataViewer(
                        field: "Services",
                        value: totalStreamActiveServices,
                        makeTransparent: true,
                        size: PrudSize.smaller,
                        subValue: "Active"
                      ),
                      if(widget.isOwner) (
                        gettingStreamFigures? LoadingComponent(
                        isShimmer:false,
                        defaultSpinnerType: false,
                        size: 10,
                        spinnerColor: prudColorTheme.lineC,
                      ) : PrudDataViewer(
                        field: "Month's Income",
                        value: "${tabData.getCurrencySymbol(widget.channel.channelCurrency)}${tabData.getFormattedNumber(totalIncomeFromStream)}",
                        makeTransparent: true,
                        valueIsMoney: true,
                        size: PrudSize.smaller,
                        subValue: "${tabData.getCurrencyName(widget.channel.channelCurrency)}"
                      )),
                    ]
                  ),
                ),
              ),
            ),
            spacer.height,
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.channel.verified? Icons.check : Icons.access_alarm_sharp,
                        color: widget.channel.verified? prudColorTheme.success : prudColorTheme.warning,
                        size: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Translate(
                          text: "VERIFIED",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: prudColorTheme.iconC
                          ),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.channel.promoted? Icons.check : Icons.access_alarm_sharp,
                        color: widget.channel.promoted? prudColorTheme.success : prudColorTheme.warning,
                        size: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Translate(
                          text: "SPONSORED",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: prudColorTheme.iconC
                          ),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.channel.blocked? Icons.check : Icons.access_alarm_sharp,
                        color: widget.channel.blocked? prudColorTheme.primary : prudColorTheme.success,
                        size: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Translate(
                          text: "BLOCKED",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: prudColorTheme.iconC
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            xLargeSpacer.height,
          ],
        ),
      ),
    );
  }
}
