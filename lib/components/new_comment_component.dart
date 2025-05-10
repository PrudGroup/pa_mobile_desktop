import 'dart:isolate';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:intl/intl.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class NewCommentComponent extends StatefulWidget {
  final String? commentId;
  final String objId;
  final CommentType commentType;
  final bool startTyping;
  const NewCommentComponent({
    super.key, this.commentId, required this.objId, 
    required this.commentType, this.startTyping = false
  });

  @override
  NewCommentComponentState createState() => NewCommentComponentState();
}

class NewCommentComponentState extends State<NewCommentComponent> {
  bool showSmiles = false;
  bool showSendIcon = false;
  bool sending = false;
  bool loading = false;
  String comment = "";
  TextEditingController txtCtrl = TextEditingController();
  ReceivePort receivePort = ReceivePort();
  Isolate? receiveIsolate;
  ReceivePort whoPort = ReceivePort();
  Isolate? whoIsolate;
  PrudCredential cred = PrudCredential(
    key: prudApiKey, token: iCloud.affAuthToken!
  );
  bool commentIsFromOwner = false;
  String? commentor;
  final _scrollController = ScrollController();

  Future<void> whoIsCommenting() async {
    if(myStorage.user == null || myStorage.user?.id == null) return;
    if(mounted) setState(() => loading = true);
    whoIsolate = await Isolate.spawn(
      isCommentMadeByCreatorOrOwner, CommentActionArg(
        id: widget.objId,
        affId: myStorage.user!.id!,
        sendPort: whoPort.sendPort,
        commentType: CommentType.thrillerComment,
        cred: cred,
      ), 
      onError: whoPort.sendPort, onExit: whoPort.sendPort
    );
    whoPort.listen((resp){
      if(resp != null){
        WhoCommented who = WhoCommented.fromJson(resp);
        String res = iCloud.authorizeDownloadUrl(who.avatar);
        if(mounted) {
          setState(() {
            commentIsFromOwner = true;
            commentor = res;
            loading = false;
          });
        }
      }else{
        if(mounted) {
          setState(() {
            commentIsFromOwner = false;
            commentor = null;
            loading = false;
          });
        }
      }
    });
  }

  void toggleShowSmiley(){
    if(mounted) setState(() => showSmiles = !showSmiles);
  }

  dynamic createComment(){
    switch(widget.commentType){
      case CommentType.videoComment: return VideoComment(
        videoId: widget.objId,
        madeBy: myStorage.user!.id!,
        comment: comment,
        commentIsFromChannelOwner: commentIsFromOwner,
        isInnerComment: widget.commentId != null,
        innerCommentId: widget.commentId
      );
      case CommentType.thrillerComment: return VideoThrillerComment(
        thrillerId: widget.objId,
        madeBy: myStorage.user!.id!,
        comment: comment,
        commentIsFromChannelOwner: commentIsFromOwner,
        isInnerComment: widget.commentId != null,
        innerCommentId: widget.commentId
      );
      case CommentType.channelBroadcastComment: return ChannelBroadcastComment(
        broadcastId: widget.objId,
        madeBy: myStorage.user!.id!,
        comment: comment,
        commentIsFromChannelOwner: commentIsFromOwner,
        isInnerComment: widget.commentId != null,
        innerCommentId: widget.commentId
      );
      default: return StreamBroadcastComment(
        broadcastId: widget.objId,
        madeBy: myStorage.user!.id!,
        comment: comment,
        commentIsFromChannelOwner: commentIsFromOwner,
        isInnerComment: widget.commentId != null,
        innerCommentId: widget.commentId
      );
    }
  }

  Future<void> send() async {
    if(comment != "" && myStorage.user != null && myStorage.user!.id != null){
      dynamic newComment = createComment();
      receiveIsolate = await Isolate.spawn(
        addComments, CommentActionArg(
          id: "",
          sendPort: receivePort.sendPort,
          commentType: CommentType.thrillerComment,
          cred: cred, newComment: newComment
        ), 
        onError: receivePort.sendPort, onExit: receivePort.sendPort
      );
    }
    receivePort.listen((resp){
      if(resp != null && resp.isNotEmpty){
        // VideoThrillerComment res = VideoThrillerComment.fromJson(resp[0]);
        if(mounted) {
          txtCtrl.clear();
          setState(() => comment = "");
        }
      }
      if(mounted) setState(() => sending = false);
    });
  }

  @override
  void initState() {
    Future.wait([whoIsCommenting()]);
    super.initState();
    txtCtrl.addListener((){
      if(txtCtrl.text.isNotEmpty && mounted) {
        setState(() => showSendIcon = true);
      }else{
        setState(() => showSendIcon = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    txtCtrl.dispose();
    receivePort.close();
    whoPort.close();
    receiveIsolate?.kill(priority: Isolate.immediate);
    whoIsolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints: BoxConstraints(maxHeight: 300.0,),
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      color: prudColorTheme.bgF,
      child: Column(
        children: [
          Row(
            spacing: 15,
            children: [
              IconButton(
                onPressed: toggleShowSmiley, 
                icon: Icon(Icons.emoji_emotions_outlined),
                iconSize: 15,
                color: prudColorTheme.lineC,
              ),
              loading? LoadingComponent(
                isShimmer: false,
                spinnerColor: prudColorTheme.lineC,
                size: 25,
              ) : (
                commentor == null? 
                myStorage.user!.getAvatar(size: 25.0) 
                : 
                GFAvatar(
                  size: 25.0,
                  backgroundImage: FastCachedImageProvider(commentor!),
                )
              ),
              Expanded(
                child: FormBuilderTextField(
                  controller: txtCtrl,
                  name: 'comment',
                  autofocus: widget.startTyping,
                  style: tabData.npStyle,
                  enabled: loading == false,
                  keyboardType: TextInputType.text,
                  decoration: getDeco(
                    "Say Something",
                    filled: true,
                    hintSize: 14,
                    borderColor: prudColorTheme.lineC
                  ),
                  onChanged: (String? value){
                    if(mounted && value != null) setState(() => comment = value.trim());
                  },
                  valueTransformer: (text) => num.tryParse(text!),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.minWordsCount(1),
                    FormBuilderValidators.maxWordsCount(1000),
                  ]),
                ),
              ),
              IconButton(
                onPressed: send, 
                icon: Icon(FontAwesomeIcons.paperPlane),
                iconSize: 15,
                color: prudColorTheme.lineC,
              ),
            ],
          ),
          Offstage(
            offstage: !showSmiles,
            child: EmojiPicker(
              textEditingController: txtCtrl,
              scrollController: _scrollController,
              config: Config(
                height: 256,
                locale: Locale(Intl.getCurrentLocale()),
                checkPlatformCompatibility: true,
                viewOrderConfig: const ViewOrderConfig(
                  top: EmojiPickerItem.categoryBar,
                  middle: EmojiPickerItem.emojiView,
                  bottom: EmojiPickerItem.searchBar,
                ),
                emojiViewConfig: EmojiViewConfig(
                  backgroundColor: prudColorTheme.bgF,
                  loadingIndicator: LoadingComponent(
                    isShimmer: false, defaultSpinnerType: false, size: 15, spinnerColor: prudColorTheme.primary,
                  ),
                  verticalSpacing: 5,
                  horizontalSpacing: 5,
                  emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS? 1.2 : 1.0),
                ),
                skinToneConfig: SkinToneConfig(
                  dialogBackgroundColor: prudColorTheme.bgF,
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: prudColorTheme.bgF,
                  indicatorColor: prudColorTheme.primary,
                  iconColorSelected: prudColorTheme.primary,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  backgroundColor: prudColorTheme.primary,
                  buttonColor: prudColorTheme.primary,
                ),
                searchViewConfig: SearchViewConfig(
                  backgroundColor: prudColorTheme.bgF,
                  buttonIconColor: prudColorTheme.bgD,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}