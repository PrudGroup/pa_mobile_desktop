import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';
import 'loading_component.dart';

class PrudImagePicker extends StatefulWidget {
  final String destination;
  final String? name;
  final bool saveToCloud;
  final Function(XFile)? onPickedFile;
  final Function(Uint8List)? onPickedMemory;
  final Function(String?)? onSaveToCloud;
  final Function(dynamic)? onError;
  final bool reset;
  
  const PrudImagePicker({
    super.key, 
    this.saveToCloud = false,
    this.reset = false,
    this.onPickedFile, 
    this.onSaveToCloud,
    this.onError,
    this.onPickedMemory,
    required this.destination,
    this.name,
  });

  @override
  PrudImagePickerState createState() => PrudImagePickerState();
}

class PrudImagePickerState extends State<PrudImagePicker> {
  bool picking = false;
  final ImagePicker picker = ImagePicker();
  Uint8List? photo;

  @override
  void initState() {
    if(mounted){
      setState(() {
        if(widget.reset) photo = null;
      });
    }
    super.initState();
  }

  Future<void> save(XFile file) async {
    await tryAsync("Picker save", () async {
      String? url = await iCloud.saveFileToCloud(file, widget.destination, widget.name?? file.name);
      if(widget.onSaveToCloud != null) widget.onSaveToCloud!(url);
    });
  }
  
  Future<void> pickImage() async {
    try{
      if(mounted) setState(() => picking = true);
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
      }
    }catch(ex){
      if(mounted) setState(() => picking = false);
      debugPrint("Picker Error: $ex");
      if(widget.onError != null) widget.onError!(ex);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PrudContainer(
      hasTitle: true,
      title: "Select Image",
      child: Center(
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
      )
    );
  }
}
