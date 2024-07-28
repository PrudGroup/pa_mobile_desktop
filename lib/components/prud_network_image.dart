import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';

class PrudNetworkImage extends StatelessWidget {
  final dynamic url;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const PrudNetworkImage({
    super.key, required this.url, this.errorWidget,
    this.fit = BoxFit.cover, this.width, this.height
  });

  @override
  Widget build(BuildContext context) {
    return FastCachedImage(
      url: url,
      fit: fit,
      width: width,
      height: height,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, progress){
        return LoadingComponent(
          isShimmer: false,
          defaultSpinnerType: false,
          spinnerColor: prudColorTheme.lineB,
          size: 20,
        );
      },
      errorBuilder: (context, exception, stacktrace){
        return errorWidget?? Image(
          image: AssetImage(prudImages.prudIcon),
          fit: BoxFit.contain,
        );
      },
    );
  }
}
