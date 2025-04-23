import 'package:flutter/material.dart';
import 'package:prudapp/models/shared_classes.dart';
    
class InnerCommentsDetailComponent extends StatefulWidget {
  final String innerId;
  final CommentType commentType;
  
  const InnerCommentsDetailComponent({super.key, required this.innerId, required this.commentType});

  @override
  InnerCommentsDetailComponentState createState() => InnerCommentsDetailComponentState();
}

class InnerCommentsDetailComponentState extends State<InnerCommentsDetailComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(),
    );
  }
}