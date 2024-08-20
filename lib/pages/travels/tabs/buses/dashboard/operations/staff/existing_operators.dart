import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../../components/loading_component.dart';
import '../../../../../../../components/operator_component.dart';
import '../../../../../../../models/bus_models.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/tab_data.dart';

class ExistingOperators extends StatefulWidget {
  const ExistingOperators({super.key});

  @override
  ExistingOperatorsState createState() => ExistingOperatorsState();
}

class ExistingOperatorsState extends State<ExistingOperators> {

  List<OperatorDetails> operators = busNotifier.operatorDetails;
  bool loading = false;
  Widget noOperator = tabData.getNotFoundWidget(
    title: "No Operator Found",
    desc: "You are yet to add operators/staff to your transport"
  );

  Future<void> getOperatorsFromCloud() async {
    await tryAsync("getOperatorsFromCloud", () async {
      if(mounted) setState(() => loading = true);
      await busNotifier.getOperators();
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  Future<void> getOperators() async {
    if(operators.isEmpty) await getOperatorsFromCloud();
  }

  Future<void> refresh() async {
    await getOperatorsFromCloud();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getOperators();
    });
    super.initState();
    busNotifier.addListener((){
      if(mounted && busNotifier.operatorDetails.isNotEmpty){
        setState(() => operators = busNotifier.operatorDetails);
      }
    });
  }

  @override
  void dispose() {
    busNotifier.removeListener((){});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: loading? LoadingComponent(
        shimmerType: 3,
        height: screen.height,
      )
          :
      Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spacer.height,
              if(busNotifier.operatorDetails.isNotEmpty) Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: operators.length,
                    itemBuilder: (context, index){
                      return OperatorComponent(operator: operators[index], showControls: true,);
                    }
                ),
              ),
              if(busNotifier.operatorDetails.isEmpty) Expanded(
                  child: Center(child: noOperator,)
              ),
              largeSpacer.height
            ],
          ),
          Positioned(
              right: 40,
              bottom: 80,
              child: FloatingActionButton(
                foregroundColor: prudColorTheme.bgC,
                backgroundColor: prudColorTheme.primary,
                tooltip: "Refreshes data from PrudServices",
                onPressed: refresh,
                child: const Icon(FontAwesomeIcons.arrowsRotate, size: 30,),
              )
          )
        ],
      ),
    );
  }
}
