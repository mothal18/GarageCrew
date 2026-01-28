import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'models/car_item.dart';
import 'services/hot_wheels_api.dart';
import 'utils/toy_number_validator.dart';
import 'widgets/car_thumbnail.dart';
import 'widgets/image_picker_sheet.dart';

/// Result returned from AddCarScreen containing the car and any pending file uploads
class AddCarResult {
  const AddCarResult({
    required this.car,
    this.pendingFiles = const [],
  });

  final CarItem car;
  final List<File> pendingFiles;
}

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key, this.initialCar});

  final CarItem? initialCar;

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

/// Represents a pending image - either a file to upload or a URL
class _PendingImage {
  const _PendingImage({this.file, this.url});

  final File? file;
  final String? url;

  bool get isFile => file != null;
  bool get isUrl => url != null;

  String? get displayUrl => url;
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _toyNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _variantController = TextEditingController();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  final _api = HotWheelsApi();
  Timer? _debounce;

  List<HotWheelsSearchResult> _results = [];
  bool _isSearching = false;
  String? _errorMessage;
  int _searchToken = 0;
  late final bool _isEditing;

  /// List of pending images (files or URLs)
  final List<_PendingImage> _pendingImages = [];

  static const int _maxImages = 5;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCar;
    _isEditing = initial != null;
    if (initial != null) {
      _nameController.text = initial.title;
      _toyNumberController.text = initial.toyNumber;
      _descriptionController.text = initial.description ?? '';
      _quantityController.text = initial.quantity.toString();
      _variantController.text = initial.variant ?? '';
      // Load existing images
      for (final url in initial.allImageUrls) {
        _pendingImages.add(_PendingImage(url: url));
      }
    } else {
      _quantityController.text = '1';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _toyNumberController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _variantController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      _searchToken++;
      setState(() {
        _results = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    final token = ++_searchToken;
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await _api.search(trimmed);
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _isSearching = false;
        _errorMessage =
            AppLocalizations.of(context)!.hotWheelsSearchFailed;
      });
    }
  }

  Future<void> _applyResult(HotWheelsSearchResult result) async {
    _nameController.text = result.title;
    if (_descriptionController.text.trim().isEmpty) {
      _descriptionController.text = result.snippet;
    }

    // Clear previous images and add new one
    setState(() {
      _pendingImages.clear(); // Clear all previous images
    });

    if (result.imageUrl != null && result.imageUrl!.isNotEmpty) {
      setState(() {
        _pendingImages.add(_PendingImage(url: result.imageUrl));
      });
    }

    // Clear search results and search field to hide the list
    setState(() {
      _results.clear();
      _searchController.clear();
    });

    // Try to fetch Toy # automatically
    final toyNumber = await _api.fetchToyNumber(result.pageId);

    if (toyNumber != null && toyNumber.isNotEmpty) {
      // Success - Toy # found!
      _toyNumberController.text = toyNumber;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.toyNumberLabel}: $toyNumber'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Not found - remind user to enter manually
      _toyNumberController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.toyNumberReminderAfterSearch),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    // Scroll to top to show the applied data
    if (mounted) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _addImage() async {
    if (_pendingImages.length >= _maxImages) return;

    final result = await ImagePickerSheet.show(context);
    if (result == null || !mounted) return;

    setState(() {
      if (result.file != null) {
        _pendingImages.add(_PendingImage(file: result.file));
      } else if (result.url != null && result.url!.isNotEmpty) {
        _pendingImages.add(_PendingImage(url: result.url));
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _pendingImages.removeAt(index);
    });
  }

  Widget _buildImagesSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Existing images
        for (int i = 0; i < _pendingImages.length; i++)
          _ImageTile(
            image: _pendingImages[i],
            onRemove: () => _removeImage(i),
          ),
        // Add button
        if (_pendingImages.length < _maxImages)
          InkWell(
            onTap: _addImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.addImageButton,
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Normalize Toy Number (trim and uppercase)
    final normalizedToyNumber = ToyNumberValidator.normalize(
      _toyNumberController.text,
    );

    // Collect URL images (files will be uploaded by the caller)
    final urlImages = _pendingImages
        .where((img) => img.isUrl)
        .map((img) => img.url!)
        .toList();

    // Collect file images to upload
    final fileImages = _pendingImages
        .where((img) => img.isFile)
        .map((img) => img.file!)
        .toList();

    // Use first URL image as imageUrl for backwards compatibility
    final primaryImageUrl = urlImages.isNotEmpty ? urlImages.first : null;

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final variant = _variantController.text.trim().isEmpty
        ? null
        : _variantController.text.trim();

    final car = CarItem(
      id: widget.initialCar?.id,
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imageUrl: primaryImageUrl,
      galleryUrls: urlImages,
      toyNumber: normalizedToyNumber,
      quantity: quantity,
      variant: variant,
    );

    // Return car and pending file uploads
    Navigator.of(context).pop(AddCarResult(car: car, pendingFiles: fileImages));
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
        title: Text(_isEditing ? l10n.editCarTitle : l10n.addCarTitle),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              l10n.carDataSection,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.carNameLabel,
                      prefixIcon: const Icon(
                        Icons.directions_car_filled_outlined,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.carNameEmpty;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _toyNumberController,
                    decoration: InputDecoration(
                      labelText: l10n.toyNumberLabel,
                      hintText: l10n.toyNumberHint,
                      helperText: l10n.toyNumberHelper,
                      prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 5,
                    validator: (value) => ToyNumberValidator.validateFormat(value, l10n),
                    onChanged: (value) {
                      // Auto-uppercase input
                      final normalized = ToyNumberValidator.normalize(value);
                      if (normalized != value) {
                        _toyNumberController.value = _toyNumberController.value.copyWith(
                          text: normalized,
                          selection: TextSelection.collapsed(offset: normalized.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            labelText: l10n.quantityLabel,
                            hintText: '1',
                            helperText: l10n.quantityHelper,
                            prefixIcon: const Icon(Icons.format_list_numbered),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) return l10n.quantityEmpty;
                            final num = int.tryParse(trimmed);
                            if (num == null || num < 1) return l10n.quantityInvalid;
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _variantController,
                          decoration: InputDecoration(
                            labelText: l10n.variantLabel,
                            hintText: l10n.variantHint,
                            helperText: l10n.variantHelper,
                            prefixIcon: const Icon(Icons.style),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.carDescriptionLabel,
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.short_text),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.carImagesSection,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildImagesSection(context),
            const SizedBox(height: 24),
            Text(
              l10n.hotWheelsSearchSection,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: l10n.hotWheelsSearchLabel,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            if (_isSearching) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
            ],
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (!_isSearching && _searchController.text.trim().length < 2)
              Text(l10n.hotWheelsSearchHint),
            if (_results.isNotEmpty)
              ..._results.map(
                (result) => _ResultCard(
                  result: result,
                  onSelected: () => _applyResult(result),
                ),
              ),
            if (!_isSearching &&
                _searchController.text.trim().length >= 2 &&
                _results.isEmpty &&
                _errorMessage == null)
              Text(l10n.noResults),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(
                _isEditing ? l10n.saveChanges : l10n.addToGarage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.onSelected,
  });

  final HotWheelsSearchResult result;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: _ResultImage(url: result.imageUrl),
        title: Text(result.title),
        subtitle: result.snippet.isNotEmpty ? Text(result.snippet) : null,
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onSelected,
          tooltip: AppLocalizations.of(context)!.useDataTooltip,
        ),
        onTap: onSelected,
      ),
    );
  }
}

class _ResultImage extends StatelessWidget {
  const _ResultImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return CarThumbnail(url: url, size: 56);
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.image,
    required this.onRemove,
  });

  final _PendingImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: image.isFile
              ? Image.file(
                  image.file!,
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                )
              : CarThumbnail(
                  url: image.url,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  borderRadius: 0,
                ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: colorScheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
