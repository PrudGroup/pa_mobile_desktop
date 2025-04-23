import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class CommentsDetailComponent extends StatefulWidget {
  final bool membersOnly;
  final String id;
  final CommentType commentType;
  final double? parentObjHeight;
  
  const CommentsDetailComponent({
    super.key, this.membersOnly = false, 
    required this.id, required this.commentType, this.parentObjHeight
  });

  @override
  CommentsDetailComponentState createState() => CommentsDetailComponentState();
}

class CommentsDetailComponentState extends State<CommentsDetailComponent> {
  List<dynamic> comments = [];
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


  void close(){
    iCloud.goBack(context);
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
        decoration: BoxDecoration(
          borderRadius: prudRad,
          color: prudColorTheme.bgF
        ),
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
              child: Column(
                children: [
                  Expanded(
                    child: Li(
                      padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                      physics: BouncingScrollPhysics(),
                      child: ,
                    ),
                  ),

                ],
              ),
            )
          ],
        )
      ),
    );
  }
}