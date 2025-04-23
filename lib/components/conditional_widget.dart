import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/models/shared_classes.dart';

    
class ConditionalWidget extends StatelessWidget {
  final List<ConditionalWidgetItem>  decisions;
  final dynamic condition;
  
  const ConditionalWidget({ super.key, required this.decisions, this.condition });
  
  @override
  Widget build(BuildContext context) {
    int index = decisions.indexWhere((itm) {
      if(condition is Map){
        return mapEquals(itm.value, condition);
      }else{
        return itm.value == condition;
      }
    });
    return index > -1? decisions[index].widget : SizedBox();
  }
}