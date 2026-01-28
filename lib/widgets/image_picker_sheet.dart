import 'dart:io';

import 'package:flutter/material.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import '../services/image_picker_service.dart';
import '../theme/app_colors.dart';

enum ImageSource { camera, gallery, url }

class ImagePickerResult {
  const ImagePickerResult({
    this.file,
    this.url,
    required this.source,
  });

  final File? file;
  final String? url;
  final ImageSource source;
}

class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({
    super.key,
    this.showUrlOption = true,
  });

  final bool showUrlOption;

  static Future<ImagePickerResult?> show(
    BuildContext context, {
    bool showUrlOption = true,
  }) async {
    return showModalBottomSheet<ImagePickerResult>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ImagePickerSheet(showUrlOption: showUrlOption),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.pickImageTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            // Row layout with equal spacing - prevents overlapping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _OptionCard(
                  icon: Icons.camera_alt_outlined,
                  label: l10n.pickFromCamera,
                  onTap: () => _pickFromCamera(context),
                ),
                _OptionCard(
                  icon: Icons.photo_library_outlined,
                  label: l10n.pickFromGallery,
                  onTap: () => _pickFromGallery(context),
                ),
                if (showUrlOption)
                  _OptionCard(
                    icon: Icons.link,
                    label: l10n.pickFromUrl,
                    onTap: () => _enterUrl(context),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final service = ImagePickerService();
    final file = await service.pickFromCamera();

    if (file != null && context.mounted) {
      Navigator.of(context).pop(ImagePickerResult(
        file: file,
        source: ImageSource.camera,
      ));
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final service = ImagePickerService();
    final file = await service.pickFromGallery();

    if (file != null && context.mounted) {
      Navigator.of(context).pop(ImagePickerResult(
        file: file,
        source: ImageSource.gallery,
      ));
    }
  }

  Future<void> _enterUrl(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pickFromUrl),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            prefixIcon: const Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (url != null && url.trim().isNotEmpty && context.mounted) {
      Navigator.of(context).pop(ImagePickerResult(
        url: url.trim(),
        source: ImageSource.url,
      ));
    }
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                icon,
                size: 28,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
