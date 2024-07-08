import 'package:country_picker/country_picker.dart';
import 'package:country_state_city/models/city.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/cities_picker.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/states_picker.dart';
import 'package:prudapp/models/spark.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_state_city/models/state.dart' as ms;

import '../../../components/countries_picker.dart';
import '../../../components/figure_display.dart';
import '../../../components/loading_component.dart';
import '../../../components/pay_in.dart';
import '../../../components/prud_data_viewer.dart';
import '../../../components/translate.dart';
import '../../../models/spark_cost.dart';
import '../../../models/theme.dart';
import '../../../singletons/currency_math.dart';
import '../../../singletons/shared_local_storage.dart';
import '../../../singletons/tab_data.dart';
import '../../settings/legal.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

enum SparkCreationPhase {
  info,
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  payment,
  success,
  failed
}

class NewSpark extends StatefulWidget {
  final Function(int)? goToTab;

  const NewSpark({super.key, this.goToTab});

  @override
  NewSparkState createState() => NewSparkState();
}

class NewSparkState extends State<NewSpark> {
  SparkCreationPhase presentPhase = SparkCreationPhase.info;
  bool loading = false;
  List<String> categories = [
    "youtube",
    "prudapp",
    "telegram",
    "instagram",
    "twitch",
    "tiktok",
    "facebook",
    "twitter",
    "spotify",
    "discord",
    "soundcloud",
    "trovo",
    "linkedin",
    "reddit",
    "trustpilot",
    "vk",
    "dzen",
    "yelp",
    "kick",
    "likee",
    "threads",
    "rutube",
    "rumble",
    "truth",
    "playstore",
    "appstore",
    "website"
  ];
  List<String> locationTargets = [
    "global",
    "country",
    "countries",
    "towns",
    "town",
    "state",
    "states",
    "city",
    "Cities"
  ];
  List<String> sparkTypes = [
    "views",
    "traffic",
    "subscribe",
    "likes",
    "follow",
    "all"
  ];
  String? selectedCategory = "youtube";
  String? selectedType = "all";
  String? selectedTarget = "country";
  Spark newSpark = Spark(
      targetTowns: [], targetStates: [], targetCountries: [], targetCities: []);
  List<ms.State> allStates = [];
  List<City> stateCities = [];
  String? countryCode;
  bool showTown = false;
  bool gettingCost = false;
  bool hasError = false;
  List<SparkCost> costs = iCloud.sparkCosts;
  String? errorMsg;
  double? totalCost;
  double? vat;
  double? sumTotal;
  ScrollController scrollCtrl = ScrollController();

  Future<void> registerSpark() async {
    if (myStorage.user != null && myStorage.user!.id != null) {
      String sparkUrl = "$apiEndPoint/sparks/";
      Map<String, dynamic> sparkDetails = {
        "target_link": newSpark.targetLink,
        "spark_type": newSpark.sparkType,
        "spark_category": newSpark.sparkCategory,
        "target_sparks": newSpark.targetSparks,
        "location_target": newSpark.locationTarget,
        "target_countries": newSpark.targetCountries,
        "target_states": newSpark.targetStates,
        "target_cities": newSpark.targetCities,
        "target_towns": newSpark.targetTowns,
        "duration": newSpark.duration,
        "aff_id": myStorage.user!.id,
        "description": newSpark.description,
        "title": newSpark.title,
      };
      Response res = await prudDio.post(sparkUrl, data: sparkDetails);
      if (res.data != null && mounted) {
        dynamic savedSpark = res.data;
        setState(() => newSpark.id = savedSpark["spark_id"]);
        iCloud.addToMySpark(newSpark);
      }
    }
  }

  Future<bool> savePaymentToCloud(String payId) async {
    bool result = false;
    try {
      await registerSpark();
      debugPrint("sparkId: ${newSpark.id}");
      if (myStorage.user != null &&
          myStorage.user!.id != null &&
          newSpark.id != null) {
        String paymentUrl = "$apiEndPoint/payments/";
        Map<String, dynamic> paymentDetails = {
          "payment_ref": payId,
          "prud_platform": "spark",
          "prud_platform_id": newSpark.id,
          "amount_paid": totalCost ?? getTotal(),
          "payment_for": "sparks",
          "paid_by": myStorage.user!.id
        };
        Response res = await prudDio.post(paymentUrl, data: paymentDetails);
        debugPrint("Payment Updated: $res : updated_data: ${res.data}");
        if (res.data != null) {
          result = true;
        }
      }
    } catch (ex) {
      debugPrint("savePaymentToCloud: $ex");
    }
    return result;
  }

  bool validateLocations() {
    switch (newSpark.locationTarget) {
      case "country":
        return newSpark.targetCountries.isNotEmpty;
      case "countries":
        return newSpark.targetCountries.isNotEmpty &&
            newSpark.targetCountries.length > 1;
      case "state":
        return newSpark.targetCountries.isNotEmpty &&
            newSpark.targetStates.isNotEmpty;
      case "states":
        return newSpark.targetCountries.isNotEmpty &&
            newSpark.targetStates.isNotEmpty &&
            newSpark.targetStates.length > 1;
      case "city":
        return newSpark.targetCountries.isNotEmpty &&
            newSpark.targetStates.isNotEmpty &&
            newSpark.targetCities.isNotEmpty;
      case "cities":
        return newSpark.targetCountries.isNotEmpty &&
            newSpark.targetStates.isNotEmpty &&
            newSpark.targetCities.isNotEmpty &&
            newSpark.targetCities.length > 1;
      case "town":
        return newSpark.targetCountries.isNotEmpty &&
            newSpark.targetStates.isNotEmpty &&
            newSpark.targetCities.isNotEmpty &&
            newSpark.targetTowns.isNotEmpty;
      default:
        return newSpark.targetCountries.isNotEmpty &&
            newSpark.targetStates.isNotEmpty &&
            newSpark.targetCities.isNotEmpty &&
            newSpark.targetTowns.isNotEmpty &&
            newSpark.targetTowns.length > 1;
    }
  }

  bool validateEntries() {
    if (mounted) {
      setState(() {
        newSpark.sparkType = selectedType;
        newSpark.sparkCategory = selectedCategory;
        newSpark.locationTarget = selectedTarget;
      });
    }
    return newSpark.locationTarget != null &&
        newSpark.sparkCategory != null &&
        newSpark.sparkType != null &&
        newSpark.targetSparks != null &&
        newSpark.targetLink != null &&
        newSpark.title != null &&
        newSpark.description != null &&
        newSpark.duration != null;
  }

  void gotoTab(index) {
    if (widget.goToTab != null) widget.goToTab!(index);
  }

  String turnListToString(List<dynamic> arr) => arr.join(", ");

  void _goBack() {
    if (mounted) {
      setState(() {
        switch (presentPhase) {
          case SparkCreationPhase.first:
            presentPhase = SparkCreationPhase.info;
          case SparkCreationPhase.second:
            presentPhase = SparkCreationPhase.first;
          case SparkCreationPhase.third:
            presentPhase = SparkCreationPhase.second;
          case SparkCreationPhase.fourth:
            presentPhase = SparkCreationPhase.third;
          case SparkCreationPhase.fifth:
            presentPhase = SparkCreationPhase.fourth;
          case SparkCreationPhase.sixth:
            presentPhase = SparkCreationPhase.fifth;
          case SparkCreationPhase.payment:
            presentPhase = SparkCreationPhase.sixth;
          default:
            presentPhase = SparkCreationPhase.payment;
        }
      });
    }
  }

  void _next() {
    if (mounted) {
      setState(() {
        switch (presentPhase) {
          case SparkCreationPhase.info:
            presentPhase = SparkCreationPhase.first;
          case SparkCreationPhase.first:
            presentPhase = SparkCreationPhase.second;
          case SparkCreationPhase.second:
            presentPhase = SparkCreationPhase.third;
          case SparkCreationPhase.third:
            {
              if (validateEntries()) {
                if (selectedTarget == 'global') {
                  presentPhase = SparkCreationPhase.fifth;
                } else {
                  presentPhase = SparkCreationPhase.fourth;
                }
              }
            }
          case SparkCreationPhase.fourth:
            if (validateLocations()) presentPhase = SparkCreationPhase.fifth;
          case SparkCreationPhase.fifth:
            {
              getTotal();
              presentPhase = SparkCreationPhase.sixth;
            }
          case SparkCreationPhase.sixth:
            presentPhase = SparkCreationPhase.payment;
          case SparkCreationPhase.payment:
            presentPhase = SparkCreationPhase.success;
          default:
            presentPhase = SparkCreationPhase.failed;
        }
      });
      iCloud.scrollTop(scrollCtrl);
    }
  }

  String _convertLocationTargetsToString() {
    List newArray = [];
    newArray.addAll(newSpark.targetCountries);
    newArray.addAll(newSpark.targetStates);
    newArray.addAll(newSpark.targetCities);
    newArray.addAll(newSpark.targetTowns);
    return newSpark.locationTarget == "global"
        ? newSpark.locationTarget!
        : newArray.join(", ");
  }

  void gotoYoutube() async {
    final Uri url = Uri.parse('https://youtu.be/bIh7cb5ebIs');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void startSparkCreation() {
    try {
      if (mounted) setState(() => presentPhase = SparkCreationPhase.first);
    } catch (ex) {
      debugPrint("startSparkCreation Error: $ex");
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        newSpark.targetTowns = [];
        newSpark.targetStates = [];
        newSpark.targetCountries = [];
        newSpark.targetCities = [];
      });
    }
    getCosts();
  }

  void getCosts() {
    Future.delayed(Duration.zero, () async {
      try {
        if (costs.isEmpty) {
          if (mounted) {
            setState(() {
              gettingCost = true;
              hasError = false;
            });
          }
          String costUrl = "$apiEndPoint/sparks/costs/";
          List<dynamic> costResult = await iCloud.getSparkCost(costUrl);
          if (costResult[1]) {
            List<SparkCost> scts = [];
            costResult[0].forEach((dynamic cost) {
              scts.add(SparkCost.fromJson(cost));
            });
            if (mounted) {
              setState(() => costs = scts);
              iCloud.updateSparkCost(costs);
            }
          } else {
            if (mounted) setState(() => hasError = true);
          }
        }
        if (mounted) setState(() => gettingCost = false);
      } catch (ex) {
        debugPrint("Error Error: $ex");
        if (mounted) {
          setState(() {
            hasError = true;
            gettingCost = false;
          });
        }
      }
    });
  }

  String getCost(String platform) {
    String res = "";
    if (costs.isNotEmpty) {
      List<SparkCost> dCosts = costs
          .where((SparkCost sct) =>
              sct.platform?.toLowerCase() == platform.toLowerCase())
          .toList();
      if (dCosts.isNotEmpty) res = "${dCosts[0].costPerSpark}";
    }
    return res;
  }

  double getTotal() {
    double res = 0;
    if (newSpark.sparkCategory != null) {
      List<SparkCost> dCosts = costs
          .where((SparkCost sct) =>
              sct.platform?.toLowerCase() ==
              newSpark.sparkCategory!.toLowerCase())
          .toList();
      if (dCosts.isNotEmpty && newSpark.duration != null) {
        double? cost = dCosts[0].costPerSpark;
        if (cost != null && newSpark.targetSparks != null) {
          res = cost * newSpark.targetSparks! * newSpark.duration!;
          if (mounted) {
            setState(() {
              totalCost = currencyMath.roundDouble(res, 2);
              vat = currencyMath.roundDouble((res * waveVat), 2);
              sumTotal = currencyMath.roundDouble((res + vat!), 2);
            });
          }
        }
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: prudColorTheme.bgA,
          ),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        backgroundColor: prudColorTheme.primary,
        title: Translate(
          text: "Create Spark",
          style: prudWidgetStyle.tabTextStyle
              .copyWith(fontSize: 16, color: prudColorTheme.bgA),
        ),
        actions: [
          if (presentPhase == SparkCreationPhase.info && hasError)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: getCosts,
              color: prudColorTheme.buttonD,
            ),
          if (presentPhase != SparkCreationPhase.info)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: _goBack,
              color: prudColorTheme.buttonD,
            ),
          if (presentPhase != SparkCreationPhase.info) spacer.width,
          if (presentPhase != SparkCreationPhase.info &&
              presentPhase != SparkCreationPhase.sixth &&
              presentPhase != SparkCreationPhase.payment)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _next,
              color: prudColorTheme.buttonD,
            ),
        ],
      ),
      body: SizedBox(
        height: screen.height,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          controller: scrollCtrl,
          child: presentPhase == SparkCreationPhase.info
              ? Column(
                  children: [
                    spacer.height,
                    Translate(
                      text:
                          "Kindly read through our terms and policies with regard to 'Sparks'. "
                          "Creating a spark indicates you agree to the terms and policies.",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: prudColorTheme.textA),
                      align: TextAlign.center,
                    ),
                    spacer.height,
                    Translate(
                      text: "To understand spark better and use it effectively "
                          " on different platforms, visit our youtube channel.",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: prudColorTheme.textB),
                      align: TextAlign.center,
                    ),
                    mediumSpacer.height,
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        getTextButton(
                            title: "Terms",
                            color: prudColorTheme.iconB,
                            onPressed: () =>
                                iCloud.goto(context, const LegalPage())),
                        getTextButton(
                          title: "Youtube",
                          color: prudColorTheme.buttonA,
                          onPressed: gotoYoutube,
                        ),
                        gettingCost
                            ? SpinKitFadingCircle(
                                color: prudColorTheme.bgB, size: 40)
                            : (hasError
                                ? Translate(
                                    text: "No Internet Connection",
                                    style: prudWidgetStyle.tabTextStyle
                                        .copyWith(
                                            color: prudColorTheme.error,
                                            fontSize: 14),
                                  )
                                : getTextButton(
                                    title: "Create Spark",
                                    color: prudColorTheme.primary,
                                    onPressed: startSparkCreation,
                                  )),
                      ],
                    ),
                    mediumSpacer.height,
                  ],
                )
              : (presentPhase == SparkCreationPhase.first
                  ? Column(
                      children: [
                        spacer.height,
                        spacer.height,
                        FormBuilderChoiceChip(
                          name: "spark_category",
                          initialValue: selectedCategory,
                          spacing: 10.0,
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.center,
                          selectedColor: prudColorTheme.primary,
                          decoration: getDeco("Select Spark Category"),
                          backgroundColor: prudColorTheme.bgA,
                          shape: prudWidgetStyle.choiceChipShape,
                          options: categories
                              .map((String e) => FormBuilderChipOption(
                                    value: e,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Translate(
                                            style: prudWidgetStyle.btnTextStyle
                                                .copyWith(
                                                    color: e == selectedCategory
                                                        ? prudColorTheme.bgA
                                                        : prudColorTheme
                                                            .primary),
                                            text: e),
                                        Text(
                                          "€${getCost(e)}",
                                          style: prudWidgetStyle.btnTextStyle
                                              .copyWith(
                                                  color: e == selectedCategory
                                                      ? prudColorTheme.bgA
                                                      : prudColorTheme.primary,
                                                  fontSize: 13),
                                        )
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            try {
                              if (mounted && value != null) {
                                setState(() => selectedCategory = value);
                              }
                            } catch (ex) {
                              debugPrint("Error: $ex");
                            }
                          },
                        ),
                        spacer.height,
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            prudWidgetStyle.getShortButton(
                                onPressed: _goBack,
                                text: "Previous",
                                makeLight: true),
                            prudWidgetStyle.getShortButton(
                              onPressed: _next,
                              text: "Next",
                            )
                          ],
                        ),
                        mediumSpacer.height,
                      ],
                    )
                  : (presentPhase == SparkCreationPhase.second
                      ? FormBuilder(
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              spacer.height,
                              spacer.height,
                              FormBuilderChoiceChip(
                                name: "spark_type",
                                initialValue: selectedType,
                                spacing: 10.0,
                                runSpacing: 7.0,
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.center,
                                selectedColor: prudColorTheme.primary,
                                decoration: getDeco("Select Spark Type"),
                                backgroundColor: prudColorTheme.bgA,
                                shape: prudWidgetStyle.choiceChipShape,
                                options: sparkTypes
                                    .map((String t) => FormBuilderChipOption(
                                          value: t,
                                          child: Translate(
                                              style: prudWidgetStyle
                                                  .btnTextStyle
                                                  .copyWith(
                                                      color: t == selectedType
                                                          ? prudColorTheme.bgA
                                                          : prudColorTheme
                                                              .primary),
                                              text: t),
                                        ))
                                    .toList(),
                                onChanged: (String? value) {
                                  try {
                                    if (mounted && value != null) {
                                      setState(() => selectedType = value);
                                    }
                                  } catch (ex) {
                                    debugPrint("Error: $ex");
                                  }
                                },
                              ),
                              spacer.height,
                              FormBuilderChoiceChip(
                                name: "spark_target",
                                initialValue: selectedTarget,
                                spacing: 10.0,
                                runSpacing: 7.0,
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.center,
                                selectedColor: prudColorTheme.primary,
                                decoration: getDeco("Select Spark Target"),
                                backgroundColor: prudColorTheme.bgA,
                                shape: prudWidgetStyle.choiceChipShape,
                                options: locationTargets
                                    .map((String e) => FormBuilderChipOption(
                                          value: e,
                                          child: Translate(
                                              style: prudWidgetStyle
                                                  .btnTextStyle
                                                  .copyWith(
                                                      color: e == selectedTarget
                                                          ? prudColorTheme.bgA
                                                          : prudColorTheme
                                                              .primary),
                                              text: e),
                                        ))
                                    .toList(),
                                onChanged: (String? value) {
                                  try {
                                    if (mounted && value != null) {
                                      setState(() => selectedTarget = value);
                                    }
                                  } catch (ex) {
                                    debugPrint("Error: $ex");
                                  }
                                },
                              ),
                              spacer.height,
                              Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  prudWidgetStyle.getShortButton(
                                      onPressed: _goBack,
                                      text: "Previous",
                                      makeLight: true),
                                  prudWidgetStyle.getShortButton(
                                    onPressed: _next,
                                    text: "Next",
                                  )
                                ],
                              ),
                              mediumSpacer.height,
                            ],
                          ),
                        )
                      : (presentPhase == SparkCreationPhase.third
                          ? FormBuilder(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                children: [
                                  spacer.height,
                                  spacer.height,
                                  PrudPanel(
                                    title: "SparK Details",
                                    bgColor: prudColorTheme.bgC,
                                    child: Column(
                                      children: [
                                        spacer.height,
                                        spacer.height,
                                        FormBuilderTextField(
                                          initialValue:
                                              newSpark.targetLink ?? "",
                                          name: 'link',
                                          autofocus: true,
                                          style: tabData.npStyle,
                                          keyboardType: TextInputType.url,
                                          decoration: getDeco("Target Link"),
                                          onChanged: (dynamic value) {
                                            if (mounted && value != null) {
                                              setState(() {
                                                newSpark.targetLink =
                                                    value!.trim();
                                              });
                                            }
                                          },
                                          valueTransformer: (text) =>
                                              num.tryParse(text!),
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.minLength(3),
                                          ]),
                                        ),
                                        spacer.height,
                                        spacer.height,
                                        Translate(
                                          text:
                                              "How many likes, views, subscriptions, or followership do you target.",
                                          style: prudWidgetStyle.tabTextStyle
                                              .copyWith(
                                                  color:
                                                      prudColorTheme.secondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                          align: TextAlign.center,
                                        ),
                                        FormBuilderTextField(
                                          initialValue:
                                              "${newSpark.targetSparks ?? 0}",
                                          name: 'sparks',
                                          style: tabData.npStyle,
                                          keyboardType: TextInputType.number,
                                          decoration: getDeco("Target Sparks"),
                                          onChanged: (dynamic value) {
                                            try {
                                              if (mounted && value != null) {
                                                setState(() {
                                                  newSpark.targetSparks =
                                                      int.tryParse(
                                                          value!.trim());
                                                });
                                              }
                                            } catch (ex) {
                                              debugPrint("error: $ex");
                                            }
                                          },
                                          valueTransformer: (text) =>
                                              num.tryParse(text!),
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.min(1000),
                                            FormBuilderValidators.max(
                                                1000000000),
                                          ]),
                                        ),
                                        spacer.height,
                                        FormBuilderTextField(
                                          initialValue: newSpark.title ?? "",
                                          name: 'title',
                                          style: tabData.npStyle,
                                          keyboardType: TextInputType.text,
                                          decoration: getDeco("Title"),
                                          onChanged: (dynamic value) {
                                            try {
                                              if (mounted && value != null) {
                                                setState(() {
                                                  newSpark.title =
                                                      value!.trim();
                                                });
                                              }
                                            } catch (ex) {
                                              debugPrint("$ex");
                                            }
                                          },
                                          valueTransformer: (text) =>
                                              num.tryParse(text!),
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.minLength(3),
                                          ]),
                                        ),
                                        spacer.height,
                                        FormBuilderTextField(
                                          initialValue:
                                              newSpark.description ?? "",
                                          name: 'description',
                                          style: tabData.npStyle,
                                          keyboardType: TextInputType.text,
                                          decoration: getDeco("Description"),
                                          onChanged: (dynamic value) {
                                            try {
                                              if (mounted && value != null) {
                                                setState(() {
                                                  newSpark.description =
                                                      value!.trim();
                                                });
                                              }
                                            } catch (ex) {
                                              debugPrint("$ex");
                                            }
                                          },
                                          valueTransformer: (text) =>
                                              num.tryParse(text!),
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.minLength(3),
                                          ]),
                                        ),
                                        spacer.height,
                                        spacer.height,
                                        Translate(
                                          text:
                                              "How long do you want to retain intended subscribers, viewers, and followers? This will "
                                              "will be costed into your payment.",
                                          style: prudWidgetStyle.tabTextStyle
                                              .copyWith(
                                                  color:
                                                      prudColorTheme.secondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                          align: TextAlign.center,
                                        ),
                                        FormBuilderTextField(
                                          initialValue:
                                              "${newSpark.duration ?? 0}",
                                          name: 'duration',
                                          style: tabData.npStyle,
                                          keyboardType: TextInputType.number,
                                          decoration:
                                              getDeco("Duration (Months)"),
                                          onChanged: (dynamic value) {
                                            try {
                                              if (mounted && value != null) {
                                                setState(() {
                                                  newSpark.duration =
                                                      int.tryParse(
                                                          value!.trim());
                                                });
                                              }
                                            } catch (ex) {
                                              debugPrint("$ex");
                                            }
                                          },
                                          valueTransformer: (text) =>
                                              num.tryParse(text!),
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.min(1),
                                            FormBuilderValidators.max(48),
                                          ]),
                                        ),
                                        spacer.height,
                                      ],
                                    ),
                                  ),
                                  spacer.height,
                                  Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      prudWidgetStyle.getShortButton(
                                          onPressed: _goBack,
                                          text: "Previous",
                                          makeLight: true),
                                      prudWidgetStyle.getShortButton(
                                        onPressed: _next,
                                        text: "Next",
                                      )
                                    ],
                                  ),
                                  mediumSpacer.height,
                                  largeSpacer.height,
                                ],
                              ),
                            )
                          : (presentPhase == SparkCreationPhase.fourth
                              ? Column(
                                  children: [
                                    spacer.height,
                                    spacer.height,
                                    PrudPanel(
                                      title: "Target Countries",
                                      bgColor: prudColorTheme.bgC,
                                      child: Column(
                                        children: [
                                          spacer.height,
                                          spacer.height,
                                          Translate(
                                            text:
                                                "Add all the intended countries you want your viewers to be based in. "
                                                "You can between one to five countries of your choice.",
                                            style: prudWidgetStyle.tabTextStyle
                                                .copyWith(
                                                    color: prudColorTheme
                                                        .secondary,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                            align: TextAlign.center,
                                          ),
                                          CountriesPicker(
                                            isMultiple:
                                                selectedTarget == "countries"
                                                    ? true
                                                    : false,
                                            selected: newSpark.targetCountries,
                                            onChange: (List<String> selected) {
                                              try {
                                                if (mounted) setState(() => newSpark.targetCountries = selected);
                                                if (selectedTarget != "global" && selectedTarget != "country" && selectedTarget != "countries") {
                                                  if (newSpark.targetCountries.isNotEmpty) {
                                                    Future.delayed(Duration.zero, () async {
                                                      Country? ctry = CountryService().findByName(newSpark.targetCountries[0]);
                                                      if (ctry != null) {
                                                        List<ms.State> dStates = await csc.getStatesOfCountry(ctry.countryCode);
                                                        if (mounted) {
                                                          setState(() {
                                                            allStates = dStates;
                                                            countryCode = ctry.countryCode;
                                                          });
                                                        }
                                                      }
                                                    });
                                                  }
                                                }
                                              } catch (ex) {
                                                debugPrint("Error: $ex");
                                              }
                                            },
                                          ),
                                          spacer.height,
                                          spacer.height,
                                          if (allStates.isNotEmpty)
                                            StatesPicker(
                                                isMultiple: selectedTarget == "states"? true : false,
                                                selected: newSpark.targetStates,
                                                allStates: allStates,
                                                onChange: (List<String>
                                                        selected,
                                                    String? firstStateCode) {
                                                  try {
                                                    if (mounted) setState(() => newSpark .targetStates = selected);
                                                    if (countryCode != null && selectedTarget!.indexOf("cit") == 0 || selectedTarget!.indexOf("town") == 0) {
                                                      if (newSpark.targetStates.isNotEmpty && firstStateCode != null) {
                                                        Future.delayed(Duration.zero, () async {
                                                          List<City> dCities = await csc.getStateCities(countryCode!, firstStateCode);
                                                          if (mounted) setState(() => stateCities = dCities);
                                                        });
                                                      }
                                                    }
                                                  } catch (ex) {
                                                    debugPrint("Error: $ex");
                                                  }
                                                }),
                                          spacer.height,
                                          spacer.height,
                                          if (stateCities.isNotEmpty) CitiesPicker(
                                              cities: stateCities,
                                              selected: newSpark.targetCities,
                                              isMultiple: selectedTarget == "cities"? true : false,
                                              onChange: (List<String> selected) {
                                                try {
                                                  if (mounted) setState(() => newSpark.targetCities = selected);
                                                  if (selectedTarget!.indexOf("town") == 0) {
                                                    if (newSpark.targetCities.isNotEmpty) {
                                                      if (mounted) setState(() => showTown = true);
                                                    }
                                                  }
                                                } catch (ex) {
                                                  debugPrint("Error: $ex");
                                                }
                                              },
                                            ),
                                          spacer.height,
                                          spacer.height,
                                          if (showTown && selectedTarget!.indexOf("town") == 0) PrudPanel(
                                                title: "Type Town(s)",
                                                bgColor: prudColorTheme.bgC,
                                                child: Column(
                                                  children: [
                                                    spacer.height,
                                                    spacer.height,
                                                    Translate(
                                                      text:
                                                        "Type out your target town(s). If it's more than one town, separate them with a comma.",
                                                      style: prudWidgetStyle.tabTextStyle.copyWith(
                                                        color: prudColorTheme.secondary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500
                                                      ),
                                                      align: TextAlign.center,
                                                    ),
                                                    FormBuilderTextField(
                                                      initialValue: newSpark.targetTowns.isNotEmpty? turnListToString(newSpark.targetTowns)
                                                          : "Type Town(s)",
                                                      name: 'towns',
                                                      style: tabData.npStyle,
                                                      keyboardType: TextInputType.text,
                                                      decoration: getDeco("Target Town(s)"),
                                                      onChanged: (String? value) {
                                                        try {
                                                          if (mounted && value != null) {
                                                            setState(() {
                                                              newSpark.targetTowns = value.split(", ");
                                                            });
                                                          }
                                                        } catch (ex) {
                                                          debugPrint("error: $ex");
                                                        }
                                                      },
                                                      valueTransformer:
                                                          (text) =>
                                                              num.tryParse(
                                                                  text!),
                                                      validator:
                                                          FormBuilderValidators
                                                              .compose([
                                                        FormBuilderValidators
                                                            .required(),
                                                        FormBuilderValidators
                                                            .minWordsCount(1),
                                                        FormBuilderValidators
                                                            .maxWordsCount(5),
                                                      ]),
                                                    ),
                                                    spacer.height,
                                                    spacer.height,
                                                  ],
                                                )),
                                          spacer.height,
                                        ],
                                      ),
                                    ),
                                    spacer.height,
                                    Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        prudWidgetStyle.getShortButton(
                                            onPressed: _goBack,
                                            text: "Previous",
                                            makeLight: true),
                                        prudWidgetStyle.getShortButton(
                                          onPressed: _next,
                                          text: "Next",
                                        )
                                      ],
                                    ),
                                    largeSpacer.height,
                                  ],
                                )
                              : (presentPhase == SparkCreationPhase.fifth
                                  ? Column(
                                      children: [
                                        spacer.height,
                                        if (selectedCategory != null &&
                                            newSpark.targetSparks != null)
                                          FigureDisplay(
                                            title: selectedCategory!,
                                            per: "Spark",
                                            perFigure: double.parse(
                                                getCost(selectedCategory!)),
                                            quantity: newSpark.targetSparks!,
                                            desc:
                                                _convertLocationTargetsToString(),
                                            descTitle: "Location Targets",
                                            duration: newSpark.duration!,
                                            durationDesc: "Month(s)",
                                          ),
                                        spacer.height,
                                        spacer.height,
                                        Translate(
                                          text:
                                              "We will provide you with audience and influencers who are interested in your content and"
                                              " will stay with you for ${newSpark.duration} months. You will need to upload content to your"
                                              " channel at least once a week. ",
                                          style: prudWidgetStyle.tabTextStyle
                                              .copyWith(
                                                  color:
                                                      prudColorTheme.secondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                          align: TextAlign.center,
                                        ),
                                        spacer.height,
                                        Flex(
                                          direction: Axis.horizontal,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            prudWidgetStyle.getShortButton(
                                                onPressed: _goBack,
                                                text: "Previous",
                                                makeLight: true),
                                            prudWidgetStyle.getShortButton(
                                              onPressed: _next,
                                              text: "Make Payment",
                                            )
                                          ],
                                        ),
                                        xLargeSpacer.height,
                                      ],
                                    )
                                  : (presentPhase == SparkCreationPhase.sixth
                                      ? Column(
                                          children: [
                                            spacer.height,
                                            spacer.height,
                                            Translate(
                                              text:
                                                  "We are working round the clock to make payment as easy as possible. "
                                                  "Our financial partners presently support FlutterWave. You have a number of "
                                                  "payment channels like Credit Card, USSD, etc. Please note that you might be charged "
                                                  "by Flutterwave for this transaction. ",
                                              style: prudWidgetStyle
                                                  .tabTextStyle
                                                  .copyWith(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          prudColorTheme.textB),
                                              align: TextAlign.center,
                                            ),
                                            spacer.height,
                                            spacer.height,
                                            SizedBox(
                                                height: 200,
                                                child: ListView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    // padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    children: [
                                                      PrudDataViewer(
                                                        field: "Spark Cost",
                                                        value: "€$totalCost",
                                                      ),
                                                      spacer.width,
                                                      PrudDataViewer(
                                                        field: "You Will Pay",
                                                        value: "€$sumTotal",
                                                        inverseColor: true,
                                                      ),
                                                      spacer.width,
                                                      PrudDataViewer(
                                                        field: "Vat & Charges",
                                                        value: "€$vat",
                                                      ),
                                                    ])),
                                            spacer.height,
                                            spacer.height,
                                            Flex(
                                              direction: Axis.horizontal,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                prudWidgetStyle.getShortButton(
                                                    onPressed: _goBack,
                                                    text: "Previous",
                                                    makeLight: true),
                                                prudWidgetStyle.getShortButton(
                                                  onPressed: _next,
                                                  text: "Pay Via Flutterwave",
                                                )
                                              ],
                                            ),
                                            largeSpacer.height,
                                          ],
                                        )
                                      : (
                                          presentPhase == SparkCreationPhase.payment && sumTotal != null?
                                          Column(
                                            children: [
                                              spacer.height,
                                              if (loading)
                                                LoadingComponent(
                                                  shimmerType: 1,
                                                  height: screen.height - 100,
                                                ),
                                              PayIn(
                                                  amount: sumTotal!,
                                                  onPaymentMade:(bool verified, String transID) {
                                                    if (mounted) setState(() => loading = true);
                                                    if (verified) {
                                                      Future.delayed(Duration.zero, () async {
                                                        await currencyMath.loginAutomatically();
                                                        if (iCloud.affAuthToken != null) {
                                                          bool saved = await savePaymentToCloud(transID);
                                                          debugPrint("saved: $saved");
                                                          if (saved && mounted) {
                                                            setState(() {
                                                              presentPhase = SparkCreationPhase.success;
                                                              loading = false;
                                                            });
                                                          } else {
                                                            if (mounted) {
                                                              setState(() {
                                                                loading = false;
                                                                presentPhase = SparkCreationPhase.failed;
                                                              });
                                                            }
                                                          }
                                                        } else {
                                                          if (mounted) {
                                                            setState(() {
                                                              errorMsg = "Unable to login to server. Check your network.";
                                                              presentPhase = SparkCreationPhase.failed;
                                                              loading = false;
                                                            });
                                                          }
                                                        }
                                                      });
                                                    } else {
                                                      if (mounted) {
                                                        setState(() {
                                                          hasError = true;
                                                          errorMsg = "Unable to verify payment.";
                                                          presentPhase = SparkCreationPhase.failed;
                                                          loading = false;
                                                        });
                                                      }
                                                    }
                                                  },
                                                  onCancel: () {
                                                    if (mounted) {
                                                      setState(() {
                                                        errorMsg = "Payment Canceled";
                                                        presentPhase = SparkCreationPhase.failed;
                                                      });
                                                    }
                                                  }),
                                              largeSpacer.height,
                                            ],
                                          )
                                          : (
                                              presentPhase == SparkCreationPhase.success?
                                              Column(
                                                  children: [
                                                    spacer.height,
                                                    spacer.height,
                                                    Translate(
                                                        text:
                                                            "Great! You have successfully created a spark for your brand. Visit "
                                                            "our youtube channel and learn what to do next.",
                                                        style: prudWidgetStyle
                                                            .tabTextStyle
                                                            .copyWith(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    prudColorTheme
                                                                        .textB),
                                                        align:
                                                            TextAlign.center),
                                                    spacer.height,
                                                    spacer.height,
                                                    prudWidgetStyle
                                                        .getLongButton(
                                                            onPressed: () =>
                                                                gotoTab(0),
                                                            text: "See Details")
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    spacer.height,
                                                    spacer.height,
                                                    Translate(
                                                        text: errorMsg ??
                                                            "An Error Occurred, "
                                                                "and could not continue the process. Kindly try again later.",
                                                        style: prudWidgetStyle
                                                            .tabTextStyle
                                                            .copyWith(
                                                                fontSize: 16,
                                                                color:
                                                                    prudColorTheme
                                                                        .error),
                                                        align:
                                                            TextAlign.center),
                                                    spacer.height,
                                                    spacer.height,
                                                    prudWidgetStyle
                                                        .getLongButton(
                                                            onPressed: _goBack,
                                                            text: "Go Back")
                                                  ],
                                                ))))))))),
        ),
      ),
    );
  }
}
