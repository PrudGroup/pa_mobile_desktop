import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/shape/gf_avatar_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';
import 'loading_component.dart';

class PrudImagePicker extends StatefulWidget {
  final String destination;
  final bool saveToCloud;
  final Function(XFile)? onPickedFile;
  final Function(Uint8List)? onPickedMemory;
  final Function(String?)? onSaveToCloud;
  final Function(dynamic)? onError;
  final bool reset;
  final String? existingUrl;
  
  const PrudImagePicker({
    super.key, 
    this.saveToCloud = false,
    this.reset = false,
    this.onPickedFile, 
    this.onSaveToCloud,
    this.onError,
    this.onPickedMemory,
    this.existingUrl,
    required this.destination,
  });

  @override
  PrudImagePickerState createState() => PrudImagePickerState();
}

class PrudImagePickerState extends State<PrudImagePicker> {
  bool picking = false;
  final ImagePicker picker = ImagePicker();
  Uint8List? photo;
  String? existingUrl;

  @override
  void initState() {
    if(mounted){
      setState(() {
        if(widget.reset) photo = null;
        existingUrl = widget.existingUrl;
      });
    }
    super.initState();
  }

  Future<void> save(XFile file) async {
    await tryAsync("Picker save", () async {
      String? url = await iCloud.saveFileToCloud(file, widget.destination);
      if(widget.onSaveToCloud != null) widget.onSaveToCloud!(url);
      if(mounted) setState(() => existingUrl = url);
    }, error: (){
      if(mounted) setState(() => picking = false);
    });
  }
  
  Future<void> pickImage() async {
    try{
      if(mounted) {
        setState(() {
          picking = true;
          existingUrl = null;
        });
      }
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if(image != null) {
        Uint8List pickedPhoto = await image.readAsBytes();
        if(widget.onPickedFile != null) widget.onPickedFile!(image);
        if(widget.onPickedMemory != null) widget.onPickedMemory!(pickedPhoto);
        if(widget.saveToCloud) await save(image);
        if(mounted) {
          setState(() {
            photo = pickedPhoto;
            picking = false;
          });
        }
      }else{
        if(mounted) {
          setState(() {
            picking = false;
            existingUrl = widget.existingUrl;
          });
        }
      }
    }catch(ex){
      if(mounted) {
        setState(() {
          picking = false;
          existingUrl = widget.existingUrl;
        });
      }
      debugPrint("Picker Error: $ex");
      if(widget.onError != null) widget.onError!(ex);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PrudContainer(
      hasTitle: true,
      title: "Select Image",
      child: Column(
        children: [
          mediumSpacer.height,
          Center(
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(existingUrl != null && photo == null) GFAvatar(
                  size: GFSize.LARGE,
                  shape: GFAvatarShape.circle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(GFSize.LARGE),
                    child: PrudNetworkImage(
                      url: existingUrl,
                      authorizeUrl: true,
                      height: GFSize.LARGE,
                      width: GFSize.LARGE,
                    ),
                  )
                ),
                if(photo != null) GFAvatar(
                  backgroundImage: MemoryImage(photo!),
                  size: GFSize.LARGE,
                ),
                picking? LoadingComponent(
                  size: 40,
                  isShimmer: false,
                  spinnerColor: prudColorTheme.primary,
                ) : prudWidgetStyle.getShortButton(
                    text: "Pick From Gallery",
                    onPressed: pickImage
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}
