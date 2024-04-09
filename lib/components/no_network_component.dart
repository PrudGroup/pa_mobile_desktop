import 'package:flutter/material.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/images.dart';
import 'translate.dart';

class NoNetworkComponent extends StatelessWidget {
  const NoNetworkComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            prudImages.prudIcon,
            width: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20,),
          Translate(
            text: "Connection Issues",
            style: tabData.cStyle.copyWith(color: Colors.black45),
            align: TextAlign.center,
          ),
          const SizedBox(height: 7,),
          Translate(
            text: "Unable to reach server. Kindly Check Your Internet Network.",
            style: tabData.nRStyle.copyWith(color: Colors.black45),
            align: TextAlign.center,
          )
        ],
      ),
    );
  }
}
