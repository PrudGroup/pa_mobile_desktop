import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_image_picker.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class AddMovieCastView extends StatefulWidget {
  final Function(VideoMovieCast) onCastAdded;
  const AddMovieCastView({super.key, required this.onCastAdded});

  @override
  AddMovieCastViewState createState() => AddMovieCastViewState();
}

class AddMovieCastViewState extends State<AddMovieCastView> {
  String? fullName;
  String? roleName;
  String detailId = "";
  String? castPhotoUrl;
  String? rolePlot;
  bool reset = false;

  void addCast() {
    VideoMovieCast cast = VideoMovieCast(
      detailId: detailId,
      roleName: roleName!,
      rolePlot: rolePlot,
      fullname: fullName!,
      castPhotoUrl: castPhotoUrl,
    );
    if(mounted){
      setState((){
        detailId = "";
        roleName = null;
        rolePlot = null;
        fullName = null;
        castPhotoUrl = null;
        reset = true;
      });
    }
    widget.onCastAdded(cast);
  }

  @override
  Widget build(BuildContext context) {
    return PrudPanel(
      title: "MovieCast AddOn",
      hasPadding: true,
      bgColor: prudColorTheme.bgC,
      titleColor: prudColorTheme.secondary,
      titleSize: 14,
      child: FormBuilder(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            spacer.height,
            PrudImagePicker(
              destination: "movie_casts/images",
              saveToCloud: true,
              reset: reset,
              onSaveToCloud: (String? url){
                tryOnly("Picker onSaveToCloud", (){
                  if(mounted && url != null) setState(() => castPhotoUrl = url);
                });
              },
              onError: (err){
                debugPrint("Picker Error: $err");
              },
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Actor/Actress Fullname",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: fullName?? "",
                    name: 'fullname',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Fullname",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          fullName = value?.trim();
                        });
                      }
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(50),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Role Name",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: roleName?? "",
                    name: 'rolename',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Role Name",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          roleName = value?.trim();
                        });
                      }
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(50),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              ),
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Role Plot",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: rolePlot?? "",
                    name: 'plot',
                    style: tabData.npStyle,
                    minLines: 3,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: getDeco(
                      "Role Plot",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          rolePlot = value?.trim();
                        });
                      }
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(150),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              ),
            ),
            spacer.height,
            if(rolePlot != null && roleName != null && fullName != null && castPhotoUrl != null) prudWidgetStyle.getLongButton(
              onPressed: addCast, text: "Save Cast", shape: 1,
            ),
            spacer.height,
          ],
        ),
      )
    );
  }
}