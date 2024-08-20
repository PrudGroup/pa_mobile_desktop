import 'package:flutter/material.dart';
import 'package:prudapp/components/operator_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';
import '../singletons/bus_notifier.dart';

class BusSelectOperatorsComponent extends StatelessWidget {
  final String? onlyRole;
  final List<String>? excludeIds;
  const BusSelectOperatorsComponent({super.key, this.onlyRole, this.excludeIds});

  void choose(OperatorDetails optr, BuildContext context){
    busNotifier.updateSelectedOperator(optr);
    Navigator.pop(context);
  }

  List<OperatorDetails> getList(){
    List<OperatorDetails> found = onlyRole != null? busNotifier.operatorDetails.where((ele) => ele.op.role.toLowerCase() == onlyRole!.toLowerCase()).toList() : busNotifier.operatorDetails;
    List<OperatorDetails> reversed = found.reversed.toList();
    if(excludeIds != null && excludeIds!.isNotEmpty){
      return reversed.where((ele) =>
        excludeIds!.contains(ele.op.id)? false : true).toList();
    }else{
      return reversed;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    Widget noOperators = tabData.getNotFoundWidget(
      title: "No Staff/Operator",
      desc: "No ${onlyRole ?? ''} operator found. You can start by creating one."
    );

    List<OperatorDetails> dOps = getList();
    return Container(
      height: height * 0.35,
      decoration: BoxDecoration(
        borderRadius: prudRad,
        color: prudColorTheme.bgC,
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: dOps.isEmpty?
        Center(child: noOperators,)
            :
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: dOps.length,
          itemBuilder: (context, index){
            OperatorDetails op = dOps[index];
            return InkWell(
              onTap: () => choose(op, context),
              child: OperatorComponent(operator: op),
            );
          }
        ),
      ),
    );
  }
}
