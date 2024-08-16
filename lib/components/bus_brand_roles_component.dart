import 'package:flutter/material.dart';
import 'package:prudapp/models/images.dart';

import '../models/theme.dart';
import '../singletons/bus_notifier.dart';

class BusBrandRolesComponent extends StatelessWidget {
  const BusBrandRolesComponent({super.key});

  void choose(String role, BuildContext context){
    busNotifier.updateSelectedRole(role);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.35,
      decoration: BoxDecoration(
        borderRadius: prudRad,
        color: prudColorTheme.bgC,
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: busNotifier.roles.length,
            itemBuilder: (context, index){
              List<String> dRoles = busNotifier.roles.reversed.toList();
              String dRole = dRoles[index];
              return InkWell(
                onTap: () => choose(dRole, context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: prudColorTheme.bgA,
                    border: Border(
                      bottom: BorderSide(
                          color: prudColorTheme.bgC, width: 5
                      )
                    )
                  ),
                  child: Row(
                    children: [
                      Image.asset(prudImages.user, width: 25,),
                      Text(
                        dRole,
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: prudColorTheme.textA
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}
