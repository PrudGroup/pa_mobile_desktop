import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class EditCommentModalSheet extends StatefulWidget {
  final String comment;
  final String commentId;
  final CommentType commentType;
  final double? parentObjHeight;
  
  const EditCommentModalSheet({super.key, required this.comment, required this.commentId, required this.commentType, this.parentObjHeight});

  @override
  EditCommentModalSheetState createState() => EditCommentModalSheetState();
}

class EditCommentModalSheetState extends State<EditCommentModalSheet> {
  String comment = "";
  final GlobalKey _key1 = GlobalKey();
  TextEditingController txtCtrl = TextEditingController();
  FocusNode fNode = FocusNode();
  bool loading = false;
  Isolate? saveIsolate;
  ReceivePort savePort = ReceivePort();
  PrudCredential cred = PrudCredential(
    key: prudApiKey, token: iCloud.affAuthToken!
  );

  @override
  void initState() {
    if(mounted) setState(() => comment = widget.comment);
    txtCtrl.text = comment;
    super.initState();
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    fNode.dispose();
    savePort.close();
    saveIsolate?.kill(priority: Isolate.immediate);
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  Future<void> save() async {
    if(comment != widget.comment){
      if(mounted) setState(() => loading = true);
      saveIsolate = await Isolate.spawn(
        updateComments, CommentActionArg(
          id: widget.commentId,
          commentType: widget.commentType,
          cred: cred,
          sendPort: savePort.sendPort,
          newUpdate: CommentPutSchema(message: comment),
        ),
        onError: savePort.sendPort,
        onExit: savePort.sendPort
      );
      savePort.listen((resp){
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: resp == true? "updated Successfully":"Unable To Save"),
            backgroundColor: resp? null : prudColorTheme.primary,
          ));
          if(resp == true){
            prudVidNotifier.updateEdittedComment(EdittedComment(commentId: widget.commentId, comment: comment));
            iCloud.goBack(context);
          }
          setState(() => loading = false);
        }
      });
    }else{
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "No changes to save"),
          backgroundColor: prudColorTheme.primary,
          showCloseIcon: true,
        ));
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Container(
      color: prudColorTheme.bgF,
      constraints: BoxConstraints(
        minHeight: 400.0,
        maxHeight: widget.parentObjHeight != null? screen.height - widget.parentObjHeight! : 600.0
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            FormBuilder(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: FormBuilderTextField(
                controller: txtCtrl,
                key: _key1,
                name: 'Comment',
                minLines: 3,
                maxLines: 5,
                focusNode: fNode,
                enableInteractiveSelection: true,
                onTap: (){
                  fNode.requestFocus();
                },
                autofocus: true,
                style: tabData.npStyle,
                keyboardType: TextInputType.text,
                decoration: getDeco(
                  "Edit Comment",
                  onlyBottomBorder: true,
                  borderColor: prudColorTheme.lineC
                ),
                onChanged: (String? valueDesc){
                  if(mounted && valueDesc != null) setState(() => comment = valueDesc.trim());
                },
                valueTransformer: (text) => num.tryParse(text!),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
            ),
            spacer.height,
            loading? Center(child: LoadingComponent(
              isShimmer: false,
              size: 30.0,
              spinnerColor: prudColorTheme.primary,
            )) : prudWidgetStyle.getLongButton(
              onPressed: save, text: "Save Editted Comment"
            ),
            mediumSpacer.height,
          ],
        ),
      ),
    );
  }
}