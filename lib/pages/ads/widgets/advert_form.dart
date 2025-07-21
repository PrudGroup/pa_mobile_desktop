import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:prudapp/models/advert/advert.dart';
import 'package:prudapp/notifiers/advert_notifier.dart';
import 'package:prudapp/providers/advert_providers.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

class AdvertForm extends ConsumerStatefulWidget {
  final Advert? advertToEdit; // If provided, means we are editing an existing advert
  const AdvertForm({super.key, this.advertToEdit});

  @override
  ConsumerState<AdvertForm> createState() => _AdvertFormState();
}

class _AdvertFormState extends ConsumerState<AdvertForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _mediaUrlController;
  late TextEditingController _linkUrlController;
  late TextEditingController _budgetController;
  late TextEditingController _internalVideoIdController;
  late TextEditingController _thumbnailUrlController;

  AdvertMediaType _selectedMediaType = AdvertMediaType.image;
  AdvertCosting? _selectedAdvertCosting; // Holds the selected AdvertCosting object
  bool _isInternalLink = false;
  File? _selectedMediaFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.advertToEdit?.title);
    _descriptionController = TextEditingController(text: widget.advertToEdit?.description);
    _mediaUrlController = TextEditingController(text: widget.advertToEdit?.mediaUrl);
    _linkUrlController = TextEditingController(text: widget.advertToEdit?.linkUrl);
    _budgetController = TextEditingController(text: widget.advertToEdit?.budget.toString());
    _internalVideoIdController = TextEditingController(text: widget.advertToEdit?.internalVideoId);
    _thumbnailUrlController = TextEditingController(text: widget.advertToEdit?.thumbnailUrl);

    if (widget.advertToEdit != null) {
      _selectedMediaType = widget.advertToEdit!.mediaType;
      _isInternalLink = widget.advertToEdit!.isInternalLink;
      _selectedAdvertCosting = widget.advertToEdit!.costing; // Initialize with existing costing
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mediaUrlController.dispose();
    _linkUrlController.dispose();
    _budgetController.dispose();
    _internalVideoIdController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickMediaFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
      );

      if (result != null) {
        final pickedFile = File(result.files.single.path!);
        final fileLength = await pickedFile.length(); // Get file size in bytes

        // Get file extension for type check
        final String fileExtension = pickedFile.path.split('.').last.toLowerCase();

        // Video duration check (placeholder - requires a plugin like video_player or media_info)
        if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(fileExtension)) {
          // Mock validation for now:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video duration validation (mock): Ensure it is not more than 3 minutes.')),
            );
          }
        } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
          const int maxImageSizeMegaBytes = 50; // 50 MB
          const int maxImageSizeInBytes = maxImageSizeMegaBytes * 1024 * 1024;
          if (fileLength > maxImageSizeInBytes) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image file must not be more than $maxImageSizeMegaBytes MB.')),
              );
            }
            return; // Don't proceed with selection
          }
        }

        setState(() {
          _selectedMediaFile = pickedFile;
          _mediaUrlController.text = _selectedMediaFile!.path.split('/').last; // Display filename
        });
      }
    } catch (e) {
      debugPrint("Error picking media file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick media file: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = myStorage.user;
    if (currentUser == null || currentUser.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in or ID missing.')),
        );
      }
      return;
    }

    if (_selectedAdvertCosting == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an advert costing option.')),
        );
      }
      return;
    }

    String? finalMediaUrl = _mediaUrlController.text;
    String? finalThumbnailUrl = _thumbnailUrlController.text.isNotEmpty ? _thumbnailUrlController.text : null;

    if (_selectedMediaFile != null) {
      try {
        final repo = ref.read(advertRepositoryProvider);
        Logger().i(repo);
        final token = iCloud.affAuthToken;
        if (token == null) {
          throw Exception('Authentication token not available.');
        }
        // Simulate file upload, in a real app this would be an actual upload to a server
        // and you'd get the URL back. For now, we'll just use a dummy URL.
        finalMediaUrl = "http://mockserver.com/uploads/${_selectedMediaFile!.path.split('/').last}";

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Media file selected for upload (mock): $finalMediaUrl')),
          );
        }
      } catch (e) {
        debugPrint("Error simulating media upload: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error simulating media upload: ${e.toString()}')),
          );
        }
        return;
      }
    }

    final advertToSave = Advert(
      id: widget.advertToEdit?.id,
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      advertiserId: currentUser.id!,
      mediaType: _selectedMediaType,
      mediaUrl: finalMediaUrl,
      thumbnailUrl: finalThumbnailUrl,
      linkUrl: _linkUrlController.text.isNotEmpty ? _linkUrlController.text : null,
      isInternalLink: _isInternalLink,
      internalVideoId: _isInternalLink ? _internalVideoIdController.text : null,
      budget: double.parse(_budgetController.text),
      costing: _selectedAdvertCosting!, // Use the selected AdvertCosting object
      startDate: widget.advertToEdit?.startDate ?? DateTime.now(),
      status: widget.advertToEdit?.status ?? AdvertStatus.pending,
      createdAt: widget.advertToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      currentSpend: widget.advertToEdit?.currentSpend ?? 0.0,
      impressions: widget.advertToEdit?.impressions ?? 0,
      clicks: widget.advertToEdit?.clicks ?? 0,
      watches: widget.advertToEdit?.watches ?? 0,
      totalWatchMinutes: widget.advertToEdit?.totalWatchMinutes ?? 0,
    );

    try {
      if (widget.advertToEdit == null) {
        await ref.read(advertListNotifierProvider.notifier).addAdvert(advertToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Advert created successfully!')),
          );
        }
      } else {
        await ref.read(advertListNotifierProvider.notifier).updateAdvert(advertToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Advert updated successfully!')),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error submitting advert form: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final advertCostingsAsync = ref.watch(advertCostingsProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.advertToEdit == null ? 'Create New Advert' : 'Edit Advert',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Advert Title'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AdvertMediaType>(
                value: _selectedMediaType,
                decoration: const InputDecoration(labelText: 'Media Type'),
                items: AdvertMediaType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (type) {
                  setState(() {
                    _selectedMediaType = type!;
                    if (_selectedMediaType == AdvertMediaType.text) {
                      _mediaUrlController.clear();
                      _thumbnailUrlController.clear();
                    }
                  });
                },
              ),
              if (_selectedMediaType != AdvertMediaType.text) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mediaUrlController,
                  readOnly: true, // Make it read-only as value comes from file picker
                  decoration: InputDecoration(
                    labelText: 'Media File (Max 3min for video, 50MB for image)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _pickMediaFile,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a media file or provide a URL.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _thumbnailUrlController,
                  decoration: const InputDecoration(labelText: 'Thumbnail URL (for Video Ads, Optional)'),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkUrlController,
                decoration: const InputDecoration(labelText: 'Link URL (Optional)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isInternalLink,
                    onChanged: (bool? value) {
                      setState(() {
                        _isInternalLink = value ?? false;
                      });
                    },
                  ),
                  const Text('Is Internal Video Link?'),
                ],
              ),
              if (_isInternalLink) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _internalVideoIdController,
                  decoration: const InputDecoration(labelText: 'Internal Video ID'),
                  validator: (value) => _isInternalLink && (value == null || value.isEmpty) ? 'Required for internal video links' : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Budget (\$)', hintText: 'e.g., 100.00'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a budget';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  if (double.parse(value) <= 0) return 'Budget must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              advertCostingsAsync.when(
                data: (costings) {
                  return DropdownButtonFormField<AdvertCosting>(
                    value: _selectedAdvertCosting,
                    decoration: const InputDecoration(labelText: 'Select Costing Option'),
                    items: costings.map((costing) {
                      return DropdownMenuItem<AdvertCosting>(
                        value: costing,
                        child: Text('${costing.costType.name.toUpperCase()}: ${costing.cost.toStringAsFixed(2)} ${costing.currency}'),
                      );
                    }).toList(),
                    onChanged: (AdvertCosting? newCosting) {
                      setState(() {
                        _selectedAdvertCosting = newCosting;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a costing option' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      Text(
                        'Failed to load costing options: ${error.toString()}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(advertCostingsProvider),
                        child: const Text('Retry Loading Costings'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(widget.advertToEdit == null ? 'Create Advert' : 'Update Advert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}