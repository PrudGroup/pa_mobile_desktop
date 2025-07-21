// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prudapp/models/advert/advert.dart';
import 'package:prudapp/notifiers/advert_notifier.dart';
import 'package:prudapp/pages/ads/widgets/advert_form.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

class AdvertManagementScreen extends ConsumerWidget {
  const AdvertManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advertsAsync = ref.watch(advertListNotifierProvider);
    final currentUserId = myStorage.user?.id ?? '';

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const Dialog(
              child: AdvertForm(),
            ),
          );
        },
        label: const Text('New Advert'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: advertsAsync.when(
        data: (adverts) {
          if (adverts.isEmpty) {
            return const Center(
              child: Text(
                'No adverts created yet. Tap the + button to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: adverts.length,
            itemBuilder: (context, index) {
              final advert = adverts[index];
              final isOwnedByCurrentUser = advert.advertiserId == currentUserId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advert.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 8),
                      if (advert.description != null && advert.description!.isNotEmpty)
                        Text(
                          advert.description!,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        ),
                      const SizedBox(height: 8),
                      _buildMediaPreview(advert.mediaType, advert.mediaUrl, advert.thumbnailUrl),
                      const SizedBox(height: 8),
                      Text('Costing Type: ${advert.costing.costType.name.toUpperCase()}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('Status: ${advert.status.name.toUpperCase()}', style: TextStyle(fontSize: 13, color: _getStatusColor(advert.status))),
                      Text('Budget: \$${advert.budget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('Spend: \$${advert.currentSpend.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('Impressions: ${advert.impressions}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('Clicks: ${advert.clicks}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('Watches: ${advert.watches}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('Total Watch Minutes: ${advert.totalWatchMinutes} min', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('Cost: \$${advert.costing.cost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('Currency: ${advert.costing.currency}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      if (advert.linkUrl != null && advert.linkUrl!.isNotEmpty)
                        Text('Link: ${advert.linkUrl}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      if (advert.isInternalLink)
                        Text('Internal Video ID: ${advert.internalVideoId ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 10),
                      if (isOwnedByCurrentUser)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DropdownButton<AdvertStatus>(
                              value: advert.status,
                              onChanged: (AdvertStatus? newStatus) {
                                if (newStatus != null) {
                                  // Call update status and handle potential errors
                                  ref.read(advertListNotifierProvider.notifier).updateAdvertStatus(advert.id!, newStatus).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Advert status updated to ${newStatus.name.toUpperCase()}')),
                                    );
                                  }).catchError((e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to update status: $e')),
                                    );
                                  });
                                }
                              },
                              items: AdvertStatus.values
                                  .map<DropdownMenuItem<AdvertStatus>>((AdvertStatus status) {
                                return DropdownMenuItem<AdvertStatus>(
                                  value: status,
                                  child: Text(status.name.toUpperCase()),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: AdvertForm(advertToEdit: advert),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(context, ref, advert);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 10),
                Text(
                  'Error loading adverts: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(advertListNotifierProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AdvertStatus status) {
    switch (status) {
      case AdvertStatus.active:
        return Colors.green;
      case AdvertStatus.paused:
        return Colors.orange;
      case AdvertStatus.pending:
        return Colors.blueGrey;
      case AdvertStatus.rejected:
        return Colors.red;
      case AdvertStatus.completed:
        return Colors.purple;
      case AdvertStatus.deleted:
        return Colors.grey;
    }
  }

  Widget _buildMediaPreview(AdvertMediaType mediaType, String? mediaUrl, String? thumbnailUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    // Placeholder image for video thumbnails or general images
    final placeholderImage = Image.network(
      thumbnailUrl ?? 'https://placehold.co/600x400/CCCCCC/000000?text=No+Thumbnail',
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey.shade300,
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey.shade600),
      ),
    );

    switch (mediaType) {
      case AdvertMediaType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            mediaUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade300,
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey.shade600),
            ),
          ),
        );
      case AdvertMediaType.video:
        // For video, display thumbnail or a video icon. Actual video playback
        // will occur when the advert is displayed to users in a player context.
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              placeholderImage,
              const Icon(Icons.play_circle_fill, size: 60, color: Colors.white70),
            ],
          ),
        );
      case AdvertMediaType.text:
        return const SizedBox.shrink(); // No media to display for text type
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Advert advert) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.red)),
          content: Text('Are you sure you want to delete the advert "${advert.title}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Call delete and handle potential errors
                ref.read(advertListNotifierProvider.notifier).deleteAdvert(advert.id!).then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Advert "${advert.title}" deleted.')),
                  );
                }).catchError((e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete advert: $e')),
                  );
                });
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}