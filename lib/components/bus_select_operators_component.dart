import 'package:flutter/material.dart';
import 'package:prudapp/components/operator_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';
import '../singletons/bus_notifier.dart';

class BusSelectOperatorsComponent extends StatelessWidget {
  const BusSelectOperatorsComponent({super.key});

  void choose(BusBrandOperator optr, BuildContext context){
    busNotifier.updateSelectedOperator(optr);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    Widget noOperators = tabData.getNotFoundWidget(
      title: "No Staff/Operator",
      desc: "No operator found. You can start by creating one."
    );
    return Container(
      height: height * 0.35,
      decoration: BoxDecoration(
        borderRadius: prudRad,
        color: prudColorTheme.bgC,
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: busNotifier.operators.isEmpty?
        Center(child: noOperators,)
            :
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: busNotifier.operators.length,
          itemBuilder: (context, index){
            List<BusBrandOperator> dOps = busNotifier.operators.reversed.toList();
            BusBrandOperator op = dOps[index];
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
