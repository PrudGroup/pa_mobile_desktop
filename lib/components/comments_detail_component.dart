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
    
class CommentsDetailComponent extends StatefulWidget {
  final bool membersOnly;
  final String id;
  final CommentType commentType;
  final double? parentObjHeight;
  final String? channelOrStreamId;
  
  const CommentsDetailComponent({
    super.key, this.membersOnly = false, 
    required this.id, required this.commentType, this.parentObjHeight, this.channelOrStreamId
  }): assert(membersOnly? channelOrStreamId != null : channelOrStreamId == null);

  @override
  CommentsDetailComponentState createState() => CommentsDetailComponentState();
}

class CommentsDetailComponentState extends State<CommentsDetailComponent> {
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


  Future<void> getMainComments() async {
    if(mounted) setState(() => loading = true);
    receiveIsolate = await Isolate.spawn(
      widget.membersOnly? getComments : getMembersComments, CommentActionArg(
        id: widget.id,
        channelOrStreamId: widget.channelOrStreamId,
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

  Future<void> getMoreMainComments() async {
    if(mounted) setState(() => gettingMore = true);
    moreIsolate = await Isolate.spawn(
      widget.membersOnly? getComments : getMembersComments, CommentActionArg(
        id: widget.id,
        channelOrStreamId: widget.channelOrStreamId,
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

  void close(){
    iCloud.goBack(context);
  }

  @override
  void initState() {
    Future.wait([getMainComments()]);
    super.initState();
    sCtrl.addListener(() async {
      if(mounted){
        setState(() => lastScrollPoint = sCtrl.offset);
      }
      if(sCtrl.position.pixels == sCtrl.position.maxScrollExtent && comments.isNotEmpty) await getMoreMainComments();
    });
  }

  @override
  void dispose() {
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
                  Translate(
                    text: "Comments",
                    style: prudWidgetStyle.typedTextStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: prudColorTheme.bgD,
                    ),
                  ),
                  IconButton(
                    onPressed: close, 
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
              (
                comments.isNotEmpty? 
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        controller: sCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return CommentComponent(
                            comment: comments[index],
                            commentType: widget.commentType,
                            objId: widget.id,
                            parentObjHeight: widget.parentObjHeight,
                          );
                        },
                      ),
                    ),
                    if(gettingMore) PrudInfiniteLoader(text: "Comments"),
                  ],
                ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [if(loaded) noVideos],
                )
              ),
            ),
            NewCommentComponent(
              commentType: widget.commentType,
              objId: widget.id,
            ),
          ],
        )
      ),
    );
  }
}