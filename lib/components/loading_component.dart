import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/components/prud_shimmer.dart';
import 'package:prudapp/models/theme.dart';

class LoadingComponent extends StatelessWidget {
  final bool isShimmer;
  final double? size;
  final double? height;
  final int shimmerType;
  final Color? spinnerColor;
  final bool defaultSpinnerType;

  const LoadingComponent({
    super.key,
    this.isShimmer = true,
    this.size = 50,
    this.shimmerType = 0,
    this.height,
    this.spinnerColor,
    this.defaultSpinnerType = true,
  }) : assert(isShimmer? height != null : size != null);

  @override
  Widget build(BuildContext context) {
    Widget spin = defaultSpinnerType? SpinKitFadingCircle(
      size: size!,
      color: spinnerColor?? prudColorTheme.iconB,
    ) : SpinKitThreeInOut(
      size: size!,
      color: spinnerColor?? prudColorTheme.iconB,
    );
    return isShimmer? SizedBox(
      height: height,
      child: PrudShimmer(type: shimmerType,),
    )
        :
    height != null? SizedBox(
      height: height,
      child: Center(
        child: spin,
      ),
    ) : spin ;
  }
}
