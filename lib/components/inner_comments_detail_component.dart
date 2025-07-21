import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:prudapp/components/comment_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/new_comment_component.dart';
import 'package:prudapp/components/prud_infinite_loader.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class InnerCommentsDetailComponent extends StatefulWidget {
  final String innerId;
  final String objId;
  final CommentType commentType;
  final bool startTyping;
  final double? parentObjHeight;
  final Comment comment;
  
  const InnerCommentsDetailComponent({
    super.key, required this.innerId, 
    required this.commentType, required this.objId,
    this.startTyping = false, this.parentObjHeight,
    required this.comment
  });

  @override
  InnerCommentsDetailComponentState createState() => InnerCommentsDetailComponentState();
}

class InnerCommentsDetailComponentState extends State<InnerCommentsDetailComponent> {
  List<Comment> comments = [];
  bool loading = false;
  bool loaded = false;
  bool gettingMore = false;  
  Widget noVideos = tabData.getNotFoundWidget(
    title: "No Comment!",
    desc: "No comments made yet. Be the first to comment about this.",
    isRow: true,
  );
  int offset = 0;
  double lastScrollPoint = 0;
  ScrollController sCtrl = ScrollController();
  ReceivePort receivePort = ReceivePort();
  Isolate? receiveIsolate;
  ReceivePort morePort = ReceivePort();
  Isolate? moreIsolate;
  PrudCredential cred = PrudCredential(
    key: prudApiKey, token: iCloud.affAuthToken!
  );
  
  Future<void> getInnerComment() async {
    if(mounted) setState(() => loading = true);
    receiveIsolate = await Isolate.spawn(
      getInnerComments, CommentActionArg(
        id: widget.innerId,
        sendPort: receivePort.sendPort,
        commentType: widget.commentType,
        cred: cred, limit: 50, offset: 0
      ), 
      onError: receivePort.sendPort, onExit: receivePort.sendPort
    );
    receivePort.listen((resp){
      if(resp != null && resp.isNotEmpty){
        List<Comment> result = [];
        for(var re in resp){
          result.add(Comment.fromJson(re, widget.commentType));
        }
        if(mounted) {
          setState(() {
            comments = result;
            offset = comments.length;
            loading = false;
            loaded = true;
          });
        }
      }else{
        if(mounted) {
          setState(() {
            loading = false;
            loaded = true;
          });
        }
      }
    });
  }

  Future<void> getMoreInnerComments() async {
    if(mounted) setState(() => gettingMore = true);
    moreIsolate = await Isolate.spawn(
      getInnerComments, CommentActionArg(
        id: widget.innerId,
        sendPort: morePort.sendPort,
        commentType: widget.commentType,
        cred: cred, limit: 50, offset: offset
      ), 
      onError: morePort.sendPort, onExit: morePort.sendPort
    );
    morePort.listen((resp){
      if(resp != null && resp.isNotEmpty){
        List<Comment> result = [];
        for(var re in resp){
          result.add(Comment.fromJson(re, widget.commentType));
        }
        if(mounted) {
          setState(() {
            comments.addAll(result);
            offset = comments.length;
            gettingMore = false;
          });
        }
      }else{
        if(mounted) setState(() => gettingMore = false);
      }
    });
  }

  @override
  void initState(){
    Future.wait([getInnerComment(), ]);
    super.initState();
    sCtrl.addListener(() async {
      if(mounted){
        setState(() => lastScrollPoint = sCtrl.offset);
      }
      if(sCtrl.position.pixels == sCtrl.position.maxScrollExtent && comments.isNotEmpty) await getMoreInnerComments();
    });
  }

  void close(){
    iCloud.goBack(context);
  }

  @override
  void dispose(){
    receivePort.close();
    morePort.close();
    receiveIsolate?.kill(priority: Isolate.immediate);
    moreIsolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return ClipRRect(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screen.height * 1,
          minHeight: widget.parentObjHeight != null? (screen.height - widget.parentObjHeight!) : (screen.height * 0.5),
        ),
        color: prudColorTheme.bgF,
        padding: const EdgeInsets.only(left: 5, right: 5, top: 20),
        child: Column(
          children: [
            Container(
              color: prudColorTheme.textB,
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 20,
                    children: [
                      IconButton(
                        onPressed: close, 
                        icon: Icon(Icons.arrow_back_ios),
                        iconSize: 25,
                        color: prudColorTheme.bgD,
                      ),
                      Translate(
                        text: "Comments",
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: prudColorTheme.bgD,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => iCloud.goBack(context), 
                    icon: Icon(Icons.close),
                    iconSize: 25,
                    color: prudColorTheme.bgD,
                  ),
                ],
              ),
            ),
            Expanded(
              child: loading? Center(
                child: LoadingComponent(
                  isShimmer: false,
                  size: 40,
                  spinnerColor: prudColorTheme.iconC
                ),
              ) 
              : 
              Column(
                children: [
                  CommentComponent(
                    comment: widget.comment,
                    commentType: widget.commentType,
                    objId: widget.objId,
                    parentObjHeight: widget.parentObjHeight,
                    showReplies: false,
                  ),
                  spacer.height,
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: sCtrl,
                      padding: const EdgeInsets.only(left: 50, right: 2),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return CommentComponent(
                          comment: comments[index],
                          commentType: widget.commentType,
                          objId: widget.objId,
                          parentObjHeight: widget.parentObjHeight,
                        );
                      },
                    ),
                  ),
                  if(gettingMore) PrudInfiniteLoader(text: "Comments"),
                ],
              ),
            ),
            NewCommentComponent(
              commentType: widget.commentType,
              objId: widget.objId,
              commentId: widget.innerId,
              startTyping: widget.startTyping
            ),
          ],
        )
      ),
    );
  }
}