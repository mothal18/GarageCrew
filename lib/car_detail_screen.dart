import 'package:flutter/material.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'add_car_screen.dart';
import 'models/car_item.dart';
import 'repositories/car_image_repository.dart';
import 'services/error_logger.dart';
import 'utils/date_formatter.dart';
import 'widgets/car_image_gallery.dart';
import 'widgets/return_to_garage_button.dart';

class CarDetailScreen extends StatefulWidget {
  const CarDetailScreen({super.key, required this.car});

  final CarItem car;

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final _imageRepository = CarImageRepository();
  List<String> _galleryUrls = [];
  bool _isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  Future<void> _loadGalleryImages() async {
    final carId = widget.car.id;
    if (carId == null) {
      setState(() {
        _isLoadingImages = false;
        _galleryUrls = widget.car.allImageUrls;
      });
      return;
    }

    try {
      final urls = await _imageRepository.getImageUrlsForCar(carId);
      if (!mounted) return;

      setState(() {
        _galleryUrls = urls.isNotEmpty ? urls : widget.car.allImageUrls;
        _isLoadingImages = false;
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'loadGalleryImages');
      if (!mounted) return;
      setState(() {
        _galleryUrls = widget.car.allImageUrls;
        _isLoadingImages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6A00), // Hot Wheels Orange
                Color(0xFFFF8533), // Lighter Orange
              ],
            ),
          ),
        ),
        title: Text(l10n.carDetailsTitle),
        actions: [
          const ReturnToGarageButton(),
          IconButton(
            tooltip: l10n.editCarTooltip,
            onPressed: () => _editCar(context),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            if (_isLoadingImages)
              const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              CarImageGallery(
                imageUrls: _galleryUrls,
                height: 220,
                heroTagPrefix: 'car_detail_${widget.car.id}',
                onTap: _galleryUrls.isNotEmpty
                    ? () => FullScreenImageGallery.show(
                          context,
                          imageUrls: _galleryUrls,
                          heroTagPrefix: 'car_detail_${widget.car.id}',
                        )
                    : null,
              ),
            const SizedBox(height: 16),
            Text(
              widget.car.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            // Toy Number display
            if (widget.car.toyNumber.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.toyNumberLabel}: ${widget.car.toyNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // Quantity and Variant display
            Row(
              children: [
                // Quantity
                Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${l10n.quantityLabel}: ${widget.car.quantity}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // Variant (if present)
                if (widget.car.variant != null && widget.car.variant!.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.style,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${l10n.variantLabel}: ${widget.car.variant}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.car.description?.trim().isNotEmpty == true
                  ? widget.car.description!
                  : l10n.noDescription,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (widget.car.createdAt != null) ...[
              Text(
                l10n.addedAtLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(DateFormatter.formatDateTime(widget.car.createdAt!)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _editCar(BuildContext context) async {
    // Create a car with current gallery URLs for editing
    final carWithGallery = widget.car.copyWith(galleryUrls: _galleryUrls);

    final result = await Navigator.of(context).push<AddCarResult>(
      MaterialPageRoute(builder: (_) => AddCarScreen(initialCar: carWithGallery)),
    );
    if (result == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    // Pop with the result car - the caller will handle file uploads
    Navigator.of(context).pop(result.car.copyWith(
      id: widget.car.id,
      createdAt: widget.car.createdAt,
    ));
  }
}
