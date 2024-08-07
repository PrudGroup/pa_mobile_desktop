import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_to_pdf/export_frame.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/loading_component.dart';
import '../../components/prud_panel.dart';
import '../../components/translate_text.dart';
import '../../models/theme.dart';
import '../../singletons/i_cloud.dart';
import '../../singletons/tab_data.dart';
import 'package:pdf/widgets.dart' as pw;

class UtilityTransactionDetailDisplay extends StatefulWidget {
  final Utility trans;
  final UtilityTransactionDetails tranDetails;

  const UtilityTransactionDetailDisplay({
    super.key,
    required this.trans,
    required this.tranDetails,
  });

  @override
  UtilityTransactionDetailDisplayState createState() => UtilityTransactionDetailDisplayState();
}

class UtilityTransactionDetailDisplayState extends State<UtilityTransactionDetailDisplay> {
  ScrollController scrollCtrl = ScrollController();
  Color lTxtColor = prudColorTheme.iconC;
  Color rTxtColor = prudColorTheme.textA;
  Color symbolColor = prudColorTheme.primary;
  double lTxtSize = 13;
  double rTxtSize = 15;
  FontWeight lTxtWeight = FontWeight.w500;
  FontWeight rTxtWeight = FontWeight.w600;
  double smallSize = 10;
  Color smallSizeColor = prudColorTheme.success;
  bool loading = false;
  List<GiftRedeemCode>? giftCard;
  RedeemInstruction? redeemInstruction;
  String frameId = "";
  bool saving = false;
  bool sharing = false;
  bool printing = false;
  String filePath = "";
  String fileName = "";

  Future<String> writeToTemp(pw.Document pdf) async {
    final output = await getTemporaryDirectory();
    String path = "${output.path}/$fileName";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return path;
  }


  Future<void> share() async {
    await tryAsync("share", () async {
      if(mounted) setState(() => sharing = true);
      pw.Document pdf = await iCloud.exportToPdf(frameId);
      String path = await writeToTemp(pdf);
      ShareResult result = await Share.shareXFiles([XFile(path)], text: 'TopUp Receipt');
      if (result.status == ShareResultStatus.success) {
        if(mounted) {
          iCloud.showSnackBar("Receipt shared", context, title: "TopUp");
          setState(() => saving = false);
        }
      }else{
        await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
      }
    }, error: (){
      if(mounted) setState(() => sharing = false);
    });
  }

  Future<void>  save() async {
    await tryAsync("save", () async {
      if(mounted) setState(() => saving = true);
      pw.Document pdf = await iCloud.exportToPdf(frameId);
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      if(mounted){
        iCloud.showSnackBar("File saved successfully.", context, title: "Saved");
        setState(() => saving = false);
      }
    }, error: (){
      if(mounted) setState(() => saving = false);
    });
  }

  Future<void> printDocument() async {
    await tryAsync("printDocument", () async {
      if(mounted) setState(() => printing = true);
      pw.Document pdf = await iCloud.exportToPdf(frameId);
      bool printed = await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save()
      );
      if(mounted) {
        debugPrint("PrintedFile: $printed");
        setState(() => saving = false);
      }
    }, error: (){
      if(mounted) setState(() => printing = false);
    });
  }

  Future<void> setDocumentPath() async {
    final output = await getApplicationDocumentsDirectory();
    if(mounted) {
      int date = (DateTime.parse(widget.trans.submittedAt!)).millisecondsSinceEpoch;
      setState(() {
        fileName = "topUp_${widget.tranDetails.transactionType}_${widget.tranDetails.transId}_$date.pdf";
        frameId = tabData.getRandomString(6);
        filePath = "${output.path}/$fileName";
      });
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await setDocumentPath();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        controller: scrollCtrl,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mediumSpacer.height,
            ExportFrame(
                frameId: frameId,
                exportDelegate: exportDelegate,
                child: Column(
                  children: [
                    PrudPanel(
                      title: "Transaction Details",
                      bgColor: prudColorTheme.bgC,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            spacer.height,
                            Container(
                              width: double.maxFinite,
                              height: 20,
                              color: tabData.getTransactionStatusColor(widget.trans.status!),
                            ),
                            spacer.height,
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Status:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    "${widget.trans.status}",
                                    style: prudWidgetStyle.typedTextStyle.copyWith(
                                        fontSize: rTxtSize,
                                        color: tabData.getTransactionStatusColor(widget.trans.status!),
                                        fontWeight: rTxtWeight
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if(widget.trans.referenceId != null) Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Reference:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontSize: lTxtSize,
                                      color: lTxtColor,
                                      fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                Text(
                                  "${widget.trans.referenceId}",
                                  style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: rTxtSize,
                                      color: rTxtColor,
                                      fontWeight: rTxtWeight
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Transaction Ref:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontSize: lTxtSize,
                                      color: lTxtColor,
                                      fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    "${widget.tranDetails.transId}",
                                    style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: rTxtSize,
                                      color: rTxtColor,
                                      fontWeight: rTxtWeight
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Currency:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Row(
                                    children: [
                                      Translate(
                                        text: "${widget.tranDetails.selectedCurrencyCode}",
                                        style: prudWidgetStyle.typedTextStyle.copyWith(
                                            fontSize: rTxtSize,
                                            color: rTxtColor,
                                            fontWeight: rTxtWeight
                                        ),
                                      ),
                                      spacer.width,
                                      Text(
                                        "${tabData.getCurrencyName(widget.tranDetails.selectedCurrencyCode!)}",
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            fontSize: smallSize,
                                            color: smallSizeColor
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Amount:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Row(
                                    children: [
                                      Text(
                                        "${tabData.getCurrencySymbol(widget.tranDetails.selectedCurrencyCode!)}",
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            fontSize: smallSize,
                                            color: smallSizeColor
                                        ),
                                      ),
                                      Text(
                                        "${widget.tranDetails.transactionPaidInSelected}",
                                        style: prudWidgetStyle.typedTextStyle.copyWith(
                                            fontSize: rTxtSize,
                                            color: rTxtColor,
                                            fontWeight: rTxtWeight
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Transaction Date:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontSize: lTxtSize,
                                      color: lTxtColor,
                                      fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Translate(
                                    text: "${widget.trans.submittedAt}",
                                    style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: rTxtSize,
                                      color: rTxtColor,
                                      fontWeight: rTxtWeight
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    spacer.height,
                    PrudPanel(
                      title: "Bill Details",
                      bgColor: prudColorTheme.bgC,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            spacer.height,
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Network Provider:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                Text(
                                  "${widget.trans.billDetails?.billerName}",
                                  style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: rTxtSize,
                                      color: tabData.getTransactionStatusColor(widget.trans.status!),
                                      fontWeight: rTxtWeight
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Subscriber:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                Text(
                                  "${widget.trans.billDetails?.subscriberNumber}",
                                  style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: rTxtSize,
                                      color: tabData.getTransactionStatusColor(widget.trans.status!),
                                      fontWeight: rTxtWeight
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Bill Type:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                Text(
                                  "${widget.trans.billDetails?.type}",
                                  style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: rTxtSize,
                                      color: tabData.getTransactionStatusColor(widget.trans.status!),
                                      fontWeight: rTxtWeight
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Service Type:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                Text(
                                  "${widget.trans.billDetails?.serviceType}",
                                  style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: rTxtSize,
                                      color: tabData.getTransactionStatusColor(widget.trans.status!),
                                      fontWeight: rTxtWeight
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Country:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontSize: lTxtSize,
                                      color: lTxtColor,
                                      fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                if(widget.trans.billDetails != null && widget.trans.billDetails!.billerCountryCode != null) Text(
                                  "${tabData.getCountryName(widget.trans.billDetails!.billerCountryCode!)}",
                                  style: prudWidgetStyle.typedTextStyle.copyWith(
                                    fontSize: rTxtSize,
                                    color: rTxtColor,
                                    fontWeight: rTxtWeight
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Currency:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Row(
                                    children: [
                                      Translate(
                                        text: "${widget.trans.deliveryAmountCurrencyCode}",
                                        style: prudWidgetStyle.typedTextStyle.copyWith(
                                            fontSize: rTxtSize,
                                            color: rTxtColor,
                                            fontWeight: rTxtWeight
                                        ),
                                      ),
                                      spacer.width,
                                      Text(
                                        "${tabData.getCurrencyName(widget.trans.deliveryAmountCurrencyCode!)}",
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            fontSize: smallSize,
                                            color: smallSizeColor
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Unit Amount:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Row(
                                    children: [
                                      Text(
                                        "${tabData.getCurrencySymbol(widget.trans.deliveryAmountCurrencyCode!)}",
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            fontSize: smallSize,
                                            color: smallSizeColor
                                        ),
                                      ),
                                      Text(
                                        "${widget.trans.deliveryAmount}",
                                        style: prudWidgetStyle.typedTextStyle.copyWith(
                                            fontSize: rTxtSize,
                                            color: rTxtColor,
                                            fontWeight: rTxtWeight
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Completed At:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                        fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    "${widget.trans.billDetails?.completedAt}",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        fontSize: smallSize,
                                        color: smallSizeColor
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    spacer.height,
                    PrudPanel(
                      title: "Pin Details",
                      bgColor: prudColorTheme.bgC,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            spacer.height,
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Translate(
                                    text: "Token:",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: lTxtSize,
                                        color: lTxtColor,
                                      fontWeight: lTxtWeight
                                    ),
                                  ),
                                ),
                                Text(
                                  "${widget.trans.billDetails?.pinDetails?.token}",
                                  style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: rTxtSize,
                                      color: tabData.getTransactionStatusColor(widget.trans.status!),
                                      fontWeight: rTxtWeight
                                  ),
                                ),
                              ],
                            ),
                            spacer.height,
                            if(widget.trans.billDetails != null && widget.trans.billDetails!.pinDetails != null && widget.trans.billDetails!.pinDetails!.info1 != null) PrudPanel(
                              title: "Instruction",
                              hasPadding: true,
                              titleColor: prudColorTheme.primary,
                              bgColor: prudColorTheme.bgC,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Translate(
                                  text: "${widget.trans.billDetails?.pinDetails?.info1}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                    color: prudColorTheme.textB,
                                    fontSize: 14,
                                  ),
                                  align: TextAlign.center,
                                ),
                              ),
                            ),
                            spacer.height,
                            if(widget.trans.billDetails != null && widget.trans.billDetails!.pinDetails != null && widget.trans.billDetails!.pinDetails!.info2 != null) PrudPanel(
                              title: "Instruction",
                              hasPadding: true,
                              titleColor: prudColorTheme.primary,
                              bgColor: prudColorTheme.bgC,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Translate(
                                  text: "${widget.trans.billDetails?.pinDetails?.info2}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                    color: prudColorTheme.textB,
                                    fontSize: 14,
                                  ),
                                  align: TextAlign.center,
                                ),
                              ),
                            ),
                            spacer.height,
                            if(widget.trans.billDetails != null && widget.trans.billDetails!.pinDetails != null && widget.trans.billDetails!.pinDetails!.info3 != null) PrudPanel(
                              title: "Instruction",
                              hasPadding: true,
                              titleColor: prudColorTheme.primary,
                              bgColor: prudColorTheme.bgC,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Translate(
                                  text: "${widget.trans.billDetails?.pinDetails?.info3}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                    color: prudColorTheme.textB,
                                    fontSize: 14,
                                  ),
                                  align: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    spacer.height,
                  ],
                )
            ),
            spacer.height,
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sharing? LoadingComponent(
                  isShimmer: false,
                  size: 30,
                  spinnerColor: prudColorTheme.primary,
                ) : prudWidgetStyle.getShortButton(
                  onPressed: share,
                  text: "Share",
                  isPill: false,
                ),
                saving? LoadingComponent(
                  isShimmer: false,
                  size: 30,
                  spinnerColor: prudColorTheme.primary,
                ) : prudWidgetStyle.getShortButton(
                  onPressed: save,
                  text: "Save To Device",
                  isPill: false,
                ),
                printing? LoadingComponent(
                  isShimmer: false,
                  size: 30,
                  spinnerColor: prudColorTheme.primary,
                ) : prudWidgetStyle.getShortButton(
                  onPressed: printDocument,
                  text: "Print",
                  isPill: false,
                )
              ],
            ),
            mediumSpacer.height,
          ],
        ),
      ),
    );
  }
}
