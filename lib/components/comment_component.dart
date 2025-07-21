import 'dart:isolate';

import 'package:comment_tree/data/comment.dart' as t;
import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:prudapp/components/inner_comments_detail_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/modals/edit_comment_modal_sheet.dart';
import 'package:prudapp/components/point_divider.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/models/user.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class CommentComponent extends StatefulWidget {
  final Comment comment;
  final CommentType commentType;
  final String objId;
  final double? parentObjHeight;
  final bool showReplies;

  const CommentComponent({
    super.key, required this.comment, 
    required this.commentType, 
    required this.objId,
    this.parentObjHeight,
    this.showReplies = true
  });

  @override
  CommentComponentState createState() => CommentComponentState();
}

class CommentComponentState extends State<CommentComponent> {
  
  String? username;
  User? otherCommentor;
  bool isTheCreator = false;
  String? avatar;
  bool loading = false;
  bool gettingReplies = false;
  ReceivePort whoPort = ReceivePort();
  Isolate? whoIsolate;
  ReceivePort otherPort = ReceivePort();
  Isolate? otherIsolate;
  ReceivePort totalPort = ReceivePort();
  Isolate? totalIsolate;
  PrudCredential cred = PrudCredential(
    key: prudApiKey, token: iCloud.affAuthToken!
  );
  int totalReplies = 0;
  bool liked = false;
  bool disliked = false;
  bool actionAlreadyTaken = false;
  bool checking = false;
  dynamic comment;

  Future<void> likeOrDislike(bool like) async {
    ActionType actionType = ActionType.videoComment;
    switch(widget.commentType){
      case CommentType.videoComment: actionType = ActionType.videoComment;
      case CommentType.thrillerComment: actionType = ActionType.thrillerComment;
      case CommentType.channelBroadcastComment: actionType = ActionType.channelBroadcastComment;
      default: actionType = ActionType.streamBroadcastComment;
    }
    LikeDislikeAction action = LikeDislikeAction(
      itemId: comment.id, liked: like == true? 1 : 0
    );
    prudVidNotifier.addToLikeOrDislikeActions(
      actionType, action, context
    );
  }


  Future<void> checkLikeStatus() async {
    if(mounted) setState(() => checking = true);
    ActionType actionType = ActionType.videoComment;
    switch(widget.commentType){
      case CommentType.videoComment: actionType = ActionType.videoComment;
      case CommentType.thrillerComment: actionType = ActionType.thrillerComment;
      case CommentType.channelBroadcastComment: actionType = ActionType.channelBroadcastComment;
      case CommentType.streamBroadcastComment: actionType = ActionType.streamBroadcastComment;
    }
    LikeDislikeAction? action = prudVidNotifier.checkIfLikeOrDislikeActionExist(widget.objId, actionType);
    if(mounted){
      if(action != null){
        if(action.liked == 1){
          setState(() {
            liked = true;
            disliked = false;
            actionAlreadyTaken = true;
            checking = false;
          });
        }else{
          setState(() {
            liked = false;
            disliked = true;
            actionAlreadyTaken = true;
            checking = false;
          });
        }
      }else{
        setState(() {
          liked = false;
          disliked = false;
          actionAlreadyTaken = false;
          checking = false;
        });
      }
    }
  }

  void edit() {
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgF,
      elevation: 0,
      isDismissible: false,
      barrierColor: prudColorTheme.bgF,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return EditCommentModalSheet(
          comment: comment.comment,
          commentId: comment.id,
          commentType: widget.commentType,
          parentObjHeight: widget.parentObjHeight,
        );
      }
    );
  }

  void openInnerComment(bool isReply){
    if(isReply == false && totalReplies <= 0) return;
    if(username == null || comment == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgF,
      elevation: 0,
      isDismissible: false,
      barrierColor: prudColorTheme.bgF,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return InnerCommentsDetailComponent(
          innerId: comment.id,
          objId: widget.objId,
          startTyping: isReply,
          commentType: widget.commentType,
          parentObjHeight: widget.parentObjHeight,
          comment: Comment(comment: comment, whoCommented: widget.comment.whoCommented),
        );
      },
    );
  }


  Future<void> getTotalReplies() async {
    totalIsolate = await Isolate.spawn(
      getTotalInnerComments, CommentActionArg(
        id: comment.id,
        sendPort: totalPort.sendPort,
        commentType: widget.commentType,
        cred: cred,
      ), 
      onError: totalPort.sendPort, onExit: totalPort.sendPort
    );
    totalPort.listen((resp) async {
      if(resp != null && resp["total"] != null){
        CountSchema res = CountSchema.fromJson(resp);
        if(mounted) {
          setState(() {
            totalReplies = res.total;
            gettingReplies = false;
          });
        }
      }else{
        if(mounted) {
          setState(() {
            totalReplies = 0;
            gettingReplies = false;
          });
        }
      }
    });
  }

  Future<void> getOtherCommentor() async{
    if(comment.affiliate != null){
      User who = comment.affiliate;
      if(mounted) {
        setState(() {
          username = tabData.toTitleCaseWithoutSpace(who.fullName!);
          otherCommentor = who;
          loading = false;
        });
      }
    }else{
      otherIsolate = await Isolate.spawn(
        getInfluencerById, CommonArg(
          id: comment.madeBy,
          sendPort: otherPort.sendPort,
          cred: cred,
        ), 
        onError: otherPort.sendPort, onExit: otherPort.sendPort
      );
      whoPort.listen((resp) async {
        if(resp != null && resp["id"] != null){
          User who = User.fromJson(resp);
          if(mounted) {
            setState(() {
              username = tabData.toTitleCaseWithoutSpace(who.fullName!);
              otherCommentor = who;
              loading = false;
            });
          }
        }else{
          if(mounted) {
            setState(() {
              username = "Ananymous";
              avatar = null;
              loading = false;
            });
          }
        }
      });
    }
  }

  Future<void> whoCommented() async {
    if(mounted) setState(() => loading = true);
    if(widget.comment.whoCommented != null){
      dynamic whoCommented = widget.comment.whoCommented;
      if(whoCommented != false){
        WhoCommented who = whoCommented;
        String res = iCloud.authorizeDownloadUrl(who.avatar);
        if(mounted) {
          setState(() {
            avatar = res;
            username = who.username;
            isTheCreator = who.isCreator;
            loading = false;
          });
        }
      }else{
        await getOtherCommentor();
      }
    }else{
      whoIsolate = await Isolate.spawn(
        isCommentMadeByCreatorOrOwner, CommentActionArg(
          id: widget.objId,
          affId: comment.madeBy,
          sendPort: whoPort.sendPort,
          commentType: widget.commentType,
          cred: cred,
        ), 
        onError: whoPort.sendPort, onExit: whoPort.sendPort
      );
      whoPort.listen((resp) async {
        if(resp != null){
          WhoCommented who = WhoCommented.fromJson(resp);
          String res = iCloud.authorizeDownloadUrl(who.avatar);
          if(mounted) {
            setState(() {
              avatar = res;
              username = who.username;
              isTheCreator = who.isCreator;
              loading = false;
            });
          }
        }else{
          await getOtherCommentor();
        }
      });
    }
  }

  @override
  void initState() {
    if(mounted){
      setState(() {
        comment = widget.comment.comment;
      });
    }
    Future.wait([whoCommented(), getTotalReplies(), checkLikeStatus()]);
    super.initState();
    prudVidNotifier.addListener(() async {
      if(prudVidNotifier.edittedComment != null && prudVidNotifier.edittedComment!.commentId == comment.id){
        if(mounted) {
          setState(() {
            comment.comment = prudVidNotifier.edittedComment!.comment;
            comment.updatedOn = DateTime.now();
          });
        }
      }
      await checkLikeStatus();
    });
  }

  @override
  void dispose() {
    whoPort.close();
    otherPort.close();
    totalPort.close();
    whoIsolate?.kill(priority: Isolate.immediate);
    otherIsolate?.kill(priority: Isolate.immediate);
    totalIsolate?.kill(priority: Isolate.immediate);
    prudVidNotifier.removeListener((){});
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openInnerComment(false),
      child: CommentTreeWidget<t.Comment, t.Comment>(
        t.Comment(avatar: avatar, userName: "@$username", content: comment.comment), widget.showReplies? [
          t.Comment(
            avatar: 'null',
            userName: 'null',
            content: '$totalReplies Replies'
          ),
        ] : [],
        treeThemeData: TreeThemeData(lineColor: prudColorTheme.lineC, lineWidth: 3),
        avatarRoot: (context, data) => PreferredSize(
          preferredSize: Size.fromRadius(18),
          child: data.avatar != null? GFAvatar(
            radius: 18, backgroundColor: prudColorTheme.lineC,
            backgroundImage: FastCachedImageProvider(data.avatar!),
          ) : (
            otherCommentor != null? otherCommentor!.getAvatar(radius: 18) : GFAvatar(radius: 18, backgroundColor: prudColorTheme.lineC, child: Text("${username?.characters.first}"),)
          ),
        ),
        avatarChild: (context, data) => PreferredSize(
          preferredSize: widget.showReplies? Size.fromRadius(10) : Size.fromRadius(0.1),
          child: widget.showReplies? CircleAvatar(
            radius: 10,
            backgroundColor: prudColorTheme.lineC,
            child: Center(
              child: Icon(FontAwesomeIcons.replyAll, color: prudColorTheme.bgF, size: 6,),
            ),
          ) : SizedBox(),
        ),
        contentRoot: (context, data){
          return Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: prudColorTheme.lineC,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10.0,
                      children: [
                        Text(
                          data.userName!,
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 10.0,
                            color: prudColorTheme.buttonA,
                            fontWeight: FontWeight.w500
                          ),
                          textAlign: TextAlign.left,
                        ),
                        PointDivider(),
                        Translate(
                          text: "${comment.isEditted? "Editted" : ""} ${myStorage.ago(dDate: comment.updatedOn,)}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 10.0,
                            color: prudColorTheme.buttonA,
                            fontWeight: FontWeight.w500
                          ),
                          align: TextAlign.right,
                        ),
                      ],
                    ),
                    SizedBox(
                      child: Translate(
                        text: '${data.content}',
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                          color: prudColorTheme.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  checking? LoadingComponent(
                    isShimmer: false,
                    defaultSpinnerType: false,
                    spinnerColor: prudColorTheme.bgA,
                    size: 15
                  ) 
                  : 
                  InkWell(
                    onTap: () => likeOrDislike(true),
                    child: Row(
                      spacing: 4,
                      children: [
                        Text(
                          tabData.getFormattedNumber(comment.likes),
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 12,
                            color: prudColorTheme.lineC,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        Icon(
                          liked? FontAwesomeIcons.solidThumbsUp : FontAwesomeIcons.thumbsUp,
                          color: prudColorTheme.bgA,
                          size: 15,
                        ),
                      ],
                    )
                  ),
                  checking? LoadingComponent(
                    isShimmer: false,
                    defaultSpinnerType: false,
                    spinnerColor: prudColorTheme.bgA,
                    size: 15
                  ) 
                  : 
                  InkWell(
                    onTap: () => likeOrDislike(false),
                    child: Row(
                      spacing: 4,
                      children: [
                        Text(
                          tabData.getFormattedNumber(comment.dislikes),
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 12,
                            color: prudColorTheme.lineC,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        Icon(
                          disliked? FontAwesomeIcons.solidThumbsDown : FontAwesomeIcons.thumbsDown,
                          color: prudColorTheme.bgA,
                          size: 15,
                        ),
                      ],
                    )
                  ),
                  InkWell(
                    onTap: () => openInnerComment(true),
                    child: Row(
                      spacing: 4,
                      children: [
                        Text(
                          tabData.getFormattedNumber(totalReplies),
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 12,
                            color: prudColorTheme.lineC,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        Icon(
                          totalReplies > 0? FontAwesomeIcons.solidComments : FontAwesomeIcons.comments,
                          color: prudColorTheme.bgA,
                          size: 15,
                        ),
                      ],
                    )
                  ),
                  if(isTheCreator) InkWell(
                    onTap: edit,
                    child: Icon(
                      FontAwesomeIcons.pen,
                      color: prudColorTheme.bgA,
                      size: 15,
                    ),
                  ),
                ],
              )
            ],
          );
        },
        contentChild: (context, data) {
          return widget.showReplies? Translate(
            text: data.content!,
            style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 14,
              color: prudColorTheme.bgA,
              fontWeight: FontWeight.w600
            ),
          ) : SizedBox();
        }
      ),
    );
  }
}