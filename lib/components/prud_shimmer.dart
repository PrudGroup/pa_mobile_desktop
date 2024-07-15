import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';

class PrudShimmer extends StatelessWidget {
  final int type;

  const PrudShimmer({super.key, this.type = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: type == 0? const ProfileShimmer(hasBottomLines: true) : (
        type == 1? const ProfilePageShimmer(hasBottomBox: true, isRectBox: true) : (
          type == 2? const VideoShimmer(hasBottomBox: true, isRectBox: true) : (
            type == 3? const ListTileShimmer(hasBottomBox: true, isRectBox: true) : (
              type == 4? const TextShimmer() : (
                type == 5? const YoutubeShimmer() : const PlayStoreShimmer()
              )
            )
          )
        )
      ),
    );
  }
}
