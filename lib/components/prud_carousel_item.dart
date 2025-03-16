import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/components/page_transitions/scale.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';

enum PrudCarouselItemShape {
  circle,
  rectangle,
  square,
}

class PrudCarouselItem extends StatelessWidget {
  final PrudCarouselItemShape shape;
  final String title;
  final String? subtitle;
  final String? moreTitle;
  final String logoUrl;
  final String? displayUrl;
  final Widget navigateToWidget;
  final bool blocked;
  final bool withBlur;

  const PrudCarouselItem({
    super.key,
    required this.logoUrl,
    required this.title,
    required this.shape,
    this.displayUrl,
    this.moreTitle,
    this.subtitle,
    this.blocked = false,
    this.withBlur = false,
    required this.navigateToWidget,
  });

  Border getBorder() {
    return Border.all(
        color: blocked ? prudColorTheme.warning : prudColorTheme.bgC, width: 3);
  }

  @override
  Widget build(BuildContext context) {
    late Widget widget;
    Color cbg = prudColorTheme.bgA;
    BorderRadius bdRadius = BorderRadius.circular(50);
    Border bd = getBorder();
    switch (shape) {
      case PrudCarouselItemShape.circle:
        {
          widget = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: cbg, border: bd, borderRadius: bdRadius),
                      child: ClipRRect(
                        borderRadius: bdRadius,
                        child: PrudNetworkImage(
                          url: logoUrl,
                          authorizeUrl: true,
                        ),
                      ),
                    ),
                  ),
                  if (displayUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: cbg,
                            border: bd,
                            borderRadius: bdRadius,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FastCachedImageProvider(
                                  iCloud.authorizeDownloadUrl(displayUrl!),
                                ))),
                      ),
                    ),
                ],
              ),
              Flexible(
                child: FittedBox(
                  child: SizedBox(
                    width: 120,
                    child: Text(
                      tabData.shortenStringWithPeriod(title, length: 40),
                      textAlign: TextAlign.center,
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: prudColorTheme.secondary),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      case PrudCarouselItemShape.rectangle:
        {
          widget = Stack(
            children: [
              if (displayUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Stack(
                    children: [
                      Container(
                        width: 180,
                        height: 130,
                        decoration: BoxDecoration(
                          color: cbg,
                          border: bd,
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: FastCachedImageProvider(
                              iCloud.authorizeDownloadUrl(displayUrl!),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 70),
                        child: Container(
                          width: 180,
                          height: 60,
                          decoration: BoxDecoration(
                            border: withBlur? null : bd,
                            color: withBlur? null : prudColorTheme.bgA.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            gradient: withBlur? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomLeft,
                              stops: [0.0, 0.2],
                              colors: [
                                prudColorTheme.bgA.withValues(alpha: 0.01),
                                prudColorTheme.bgA.withValues(alpha: 0.9),
                              ],
                            ) : null,
                          ),
                          child: Flex(
                            direction: Axis.vertical,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, right: 10),
                                  child: Wrap(
                                    runSpacing: -3.0,
                                    spacing: -3.0,
                                    direction: Axis.vertical,
                                    children: [
                                      if (moreTitle != null)
                                        Text(
                                          tabData.shortenStringWithPeriod(
                                              moreTitle!,
                                              length: 15),
                                          style:
                                              prudWidgetStyle.hintStyle.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 9,
                                            color: prudColorTheme.warning,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      FittedBox(
                                          child: SizedBox(
                                        child: ClipRRect(
                                          child: Text(
                                            overflow: TextOverflow.fade,
                                            softWrap: true,
                                            tabData.shortenStringWithPeriod(title,
                                                length: 30),
                                            style: prudWidgetStyle.hintStyle
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              height: 0.9,
                                              color: prudColorTheme.secondary,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      )),
                                      if (subtitle != null)
                                        FittedBox(
                                          child: Text(
                                            softWrap: false,
                                            tabData.shortenStringWithPeriod(
                                                subtitle!,
                                                length: 20),
                                            style: prudWidgetStyle.btnTextStyle
                                                .copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                              color: prudColorTheme.iconB,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                      
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 30),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: cbg,
                      border: bd,
                      borderRadius: bdRadius,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FastCachedImageProvider(
                            iCloud.authorizeDownloadUrl(logoUrl),
                          ))),
                ),
              ),
            ],
          );
        }
      default:
        {
          widget = Container();
        }
    }
    return InkWell(
      onTap: () {
        debugPrint("Request to open page");
        Navigator.push(context, ScaleRoute(page: navigateToWidget));
      },
      child: widget,
    );
  }
}
