import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/pin_verifier.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/bus_dashboard.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/new_bus_brand_operator.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/new_bus_dashboard.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../../../components/translate_text.dart';
import '../../../../models/theme.dart';
import '../../../../singletons/i_cloud.dart';
import '../../../../singletons/shared_local_storage.dart';
import '../../switz_travels.dart';

class BusCompanyDashboard extends StatefulWidget {
  const BusCompanyDashboard({super.key});

  @override
  BusCompanyDashboardState createState() => BusCompanyDashboardState();
}

class BusCompanyDashboardState extends State<BusCompanyDashboard> {
  bool isOperator = false;
  bool checkingStatus = false;
  bool isActive = busNotifier.isActive;
  bool loading = false;
  bool getting = false;
  bool verified = false;

  Future<void> checkBrandStatus() async {
    await tryAsync("checkBrandStatus", () async {
      if(mounted) setState(() => checkingStatus = true);
      BusBrand? busBrand = await busNotifier.getBusBrandById(busNotifier.busBrandId!);
      if(busBrand != null && busBrand.status!.toLowerCase() == "active"){
        if(mounted) {
          busNotifier.isActive = true;
          setState(() {
            isActive = true;
            checkingStatus = false;
          });
          busNotifier.saveDefaultSettings();
        }
      }else{
        if(mounted) {
          setState(() {
            busNotifier.isActive = false;
            checkingStatus = false;
          });
        }
      }
    }, error: (){
      if(mounted) setState(() => checkingStatus = false);
    });
  }

  Future<void> updateOperator() async {
    await tryAsync("", () async {
      if(mounted) {
        setState(() {
          getting = true;
          verified = true;
        });
      }
      BusBrandOperator? optr = await busNotifier.getOperatorById(busNotifier.busOperatorId!);
      if(optr != null){
        busNotifier.busOperatorId = optr.id;
        busNotifier.busBrandRole = optr.role;
        busNotifier.isActive = optr.status.toLowerCase() == "active";
        busNotifier.busBrandId = optr.brandId;
        if(mounted){
          setState(() {
            isActive = busNotifier.isActive;
            isOperator = true;
          });
          busNotifier.saveDefaultSettings();
          if(isActive) {
            iCloud.goto(context, const BusDashboard());
          } else{
            iCloud.showSnackBar("Access Denied. Ask Admin",context, type: 3);
          }
        }
      }
      if(mounted) setState(() => getting = false);
    }, error: (){
      if(mounted) setState(() => getting = false);
    });
  }

  Future<void> joinTeam() async {
    if(busNotifier.busOperatorId == null && busNotifier.busBrandId == null && busNotifier.busBrandRole == null && myStorage.user != null && myStorage.user!.id != null){
      await tryAsync("joinTeam", () async {
        if(mounted) setState(() => loading = true);
        BusBrandOperator? optr = await busNotifier.getOperatorByAffId(myStorage.user!.id!);
        if(optr != null){
          busNotifier.busOperatorId = optr.id;
          busNotifier.busBrandRole = optr.role;
          busNotifier.isActive = optr.status.toLowerCase() == "active";
          busNotifier.busBrandId = optr.brandId;
          busNotifier.saveDefaultSettings();
          if(mounted){
            setState(() {
              isActive = busNotifier.isActive;
              isOperator = true;
            });
          }
        }
        if(mounted) setState(() => loading = false);
      }, error: (){
        if(mounted) setState(() => loading = false);
      });
    }
  }

  @override
  void initState() {
    if(mounted){
      setState(() {
        isOperator = busNotifier.busBrandId != null && busNotifier.busOperatorId != null;
      });
    }
    Future.delayed(Duration.zero, () async {
      if(isOperator) await checkBrandStatus();
      await joinTeam();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> createOperator() async {
    await tryAsync("createOperator", () async {
      if(mounted) setState(() => loading = true);
      BusBrandOperator newOpr = BusBrandOperator(
        affId: myStorage.user!.id!,
        status: "ACTIVE",
        brandId: busNotifier.busBrandId!,
        role: "SUPER"
      );
      BusBrandOperator? opr = await busNotifier.createNewOperator(newOpr);
      if(mounted) {
        if(opr != null){
          busNotifier.busOperatorId = opr.id;
          busNotifier.busBrandRole = opr.role;
          await busNotifier.saveDefaultSettings();
          if(mounted) {
            iCloud.goto(context, const SwitzTravels(tab: 2,));
            Navigator.pop(context);
          }
        }
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: isOperator?
      (
        isActive?
        SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              spacer.height,
              PrudContainer(
                hasPadding: true,
                child: Column(
                  children: [
                    spacer.height,
                    Translate(
                      text: "The staff/operator you have on SwitzTravel, the lesser your work. Easily add more staff/operator here.",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.textB
                      ),
                      align: TextAlign.center,
                    ),
                    spacer.height,
                    prudWidgetStyle.getLongButton(
                      onPressed: () => iCloud.goto(context, const NewBusBrandOperator()),
                      text: "Add More Staff/Operator"
                    ),
                    spacer.height,
                  ],
                )
              ),
              spacer.height,
              PrudContainer(
                hasTitle: true,
                title: "Go To Dashboard",
                titleAlignment: MainAxisAlignment.center,
                titleBorderColor: prudColorTheme.bgC,
                hasPadding: true,
                child: Column(
                  children: [
                    mediumSpacer.height,
                    getting? LoadingComponent(
                      isShimmer: false,
                      defaultSpinnerType: false,
                      spinnerColor: prudColorTheme.primary,
                      size: 20,
                    )
                        :
                    (
                      verified?
                      const SizedBox()
                          :
                      PinVerifier(
                        onVerified: (bool isVerified) async {
                          debugPrint("Things got here AA");
                          if(isVerified) await updateOperator();
                          debugPrint("Things got here AAB");
                        }
                      )
                    ),
                    mediumSpacer.height,
                  ],
                )
              ),
              spacer.height,
            ],
          ),
        )
            :
        (
          checkingStatus?
          LoadingComponent(
            isShimmer: true,
            shimmerType: 3,
            height: screen.height,
          )
              :
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                spacer.height,
                Translate(
                  text: "Thanks for your patience. It takes at most 72 hours for our efficient team to validate your "
                      "transport company in the country you indicated. Kindly reach out to our support team if these "
                      "hours are exceeded. We glad to have you onboard SwitzTravels via Prudapp.",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.textB
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
                Translate(
                  text: "If you are seeing this message, you are yet to be validated. Wait for 72 hours before you reach-out "
                      "to our support team for help.",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.textB
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
              ],
            ),
          )
        )
      )
          :
      (
        busNotifier.busBrandId != null && busNotifier.busOperatorId == null?
        Column(
          children: [
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Operator",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  Translate(
                    text: "We were unable to create access for you automatically. Kindly try it again",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.textB
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  loading? LoadingComponent(
                    isShimmer: false,
                    size: 35,
                    spinnerColor: prudColorTheme.primary,
                  )
                      :
                  prudWidgetStyle.getLongButton(
                    onPressed: createOperator,
                    text: "Create Access"
                  ),
                  spacer.height,
                ],
              )
            ),
          ],
        )
            :
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              spacer.height,
              Translate(
                text: "Do you have a bus transport company which you intend bring unto our platform? We will be"
                    " glad to have you onboard. There are many reasons why you should put your transport"
                    " company on SwitzTravels under Prudapp. One of these reasons is that you get to have "
                    "a world class mobile app with which you can manage your transport inventory effectively with less cost of operations.",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: prudColorTheme.textB
                ),
                align: TextAlign.center,
              ),
              spacer.height,
              prudWidgetStyle.getLongButton(
                onPressed: () => iCloud.goto(context, const NewBusDashboard()),
                text: "Create Bus Transport System",
                shape: 1
              ),
              mediumSpacer.height,
              Translate(
                text: "If you are a staff/admin of a particular transport company, ask your admin to add you as an operator and then click below to join.",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: prudColorTheme.textB
                ),
                align: TextAlign.center,
              ),
              spacer.height,
              loading? LoadingComponent(
                isShimmer: false,
                spinnerColor: prudColorTheme.primary,
                size: 30,
              ) : prudWidgetStyle.getLongButton(
                onPressed: joinTeam,
                text: "Join A Transport Company",
                shape: 1
              ),
            ],
          ),
        )
      )
    );
  }
}
