// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prudapp/models/advert/advert.dart';
import 'package:prudapp/providers/advert_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvertDisplayWidget extends ConsumerStatefulWidget {
  final Advert advert;
  final bool compact; // Whether to display in a more compact form (e.g., in a list)

  const AdvertDisplayWidget({
    super.key,
    required this.advert,
    this.compact = false,
  });

  @override
  ConsumerState<AdvertDisplayWidget> createState() => _AdvertDisplayWidgetState();
}

class _AdvertDisplayWidgetState extends ConsumerState<AdvertDisplayWidget> {
  final GlobalKey _visibilityKey = GlobalKey();
  bool _isVisible = false;
  DateTime? _visibleStartTime;
  static const Duration _impressionThreshold = Duration(seconds: 1); // 1 second for an impression

  @override
  void initState() {
    super.initState();
    // Ensure the socket service is initialized for event emission
    ref.read(advertSocketServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Increment clicks on tap, regardless of link presence, as user intent is there
        ref.read(advertSocketServiceProvider).emitAdvertEvent(widget.advert.id!, 'click', count: 1);

        // Handle advert click
        if (widget.advert.linkUrl != null && widget.advert.linkUrl!.isNotEmpty) {
          final url = Uri.parse(widget.advert.linkUrl!);
          try {
            if (await canLaunchUrl(url) && mounted) {
              await launchUrl(url);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Advert clicked: ${widget.advert.title}')),
              );
            } else {
              debugPrint('Could not launch ${widget.advert.linkUrl}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open link for advert: ${widget.advert.title}')),
              );
            }
          } catch (e) {
            debugPrint('Error launching URL: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error opening link: ${e.toString()}')),
            );
          }
        }
      },
      child: Card(
        key: _visibilityKey, // Attach key for VisibilityDetector
        margin: EdgeInsets.symmetric(vertical: widget.compact ? 4.0 : 8.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.compact ? 8 : 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.compact && widget.advert.mediaUrl != null && widget.advert.mediaUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(widget.compact ? 8 : 12)),
                child: _buildMediaWidget(),
              ),
            Padding(
              padding: EdgeInsets.all(widget.compact ? 8.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.advert.title,
                    style: TextStyle(
                      fontSize: widget.compact ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  if (!widget.compact && widget.advert.description != null && widget.advert.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.advert.description!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                  if (widget.advert.mediaType == AdvertMediaType.text && widget.advert.description != null && widget.advert.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.advert.description!,
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (widget.advert.linkUrl != null && widget.advert.linkUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Learn More >',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: widget.compact ? 12 : 14),
                      ),
                    ),
                  ],
                  // Display costing type (optional, for debugging/clarity)
                  if (!widget.compact)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Costing Type: ${widget.advert.costing.costType.name.toUpperCase()}', // Changed from advert.advertType
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaWidget() {
    final placeholderImage = Image.network(
      widget.advert.thumbnailUrl ?? 'https://placehold.co/600x400/CCCCCC/000000?text=Ad+Media',
      width: double.infinity,
      height: widget.compact ? 120 : 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey.shade300,
        child: Icon(Icons.broken_image, size: widget.compact ? 30 : 50, color: Colors.grey.shade600),
      ),
    );

    switch (widget.advert.mediaType) {
      case AdvertMediaType.image:
        return Image.network(
          widget.advert.mediaUrl!,
          width: double.infinity,
          height: widget.compact ? 120 : 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.shade300,
            child: Icon(Icons.broken_image, size: widget.compact ? 30 : 50, color: Colors.grey.shade600),
          ),
        );
      case AdvertMediaType.video:
        return Stack(
          alignment: Alignment.center,
          children: [
            placeholderImage, // Display thumbnail
            Icon(Icons.play_circle_fill, size: widget.compact ? 40 : 60, color: Colors.white70),
          ],
        );
      case AdvertMediaType.text:
        return const SizedBox.shrink();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibilityAndReportImpression();
    });
  }

  @override
  void didUpdateWidget(covariant AdvertDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check visibility if the widget itself updates, might be a new advert at same position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibilityAndReportImpression();
    });
  }

  void _checkVisibilityAndReportImpression() {
    if (!mounted) return;

    final RenderBox? renderBox = _visibilityKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Rect rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final bool newVisibility = WidgetsBinding.instance.renderViews.first.paintBounds.overlaps(rect);

    if (newVisibility != _isVisible) {
      setState(() {
        _isVisible = newVisibility;
        if (_isVisible) {
          _visibleStartTime = DateTime.now();
          debugPrint('Advert ${widget.advert.id} became visible.');
        } else {
          if (_visibleStartTime != null) {
            final Duration visibleDuration = DateTime.now().difference(_visibleStartTime!);
            if (visibleDuration >= _impressionThreshold) {
              ref.read(advertSocketServiceProvider).emitAdvertEvent(widget.advert.id!, 'impression', count: 1);
              debugPrint('Advert ${widget.advert.id} impression counted after ${visibleDuration.inSeconds}s.');
            }
          }
          _visibleStartTime = null;
          debugPrint('Advert ${widget.advert.id} became invisible.');
        }
      });
    }
  }
}