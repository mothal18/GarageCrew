class CarItem {
  const CarItem({
    this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.galleryUrls = const [],
    this.likesCount = 0,
    this.isLiked = false,
    this.toyNumber = '',
    this.quantity = 1,
    this.variant,
  });

  final String? id;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;
  final List<String> galleryUrls;
  final int likesCount;
  final bool isLiked;
  final String toyNumber;
  final int quantity;
  final String? variant;

  /// Returns the primary image URL - first gallery image or legacy imageUrl
  String? get primaryImageUrl =>
      galleryUrls.isNotEmpty ? galleryUrls.first : imageUrl;

  /// Returns all available image URLs (gallery + legacy imageUrl if not in gallery)
  List<String> get allImageUrls {
    if (galleryUrls.isNotEmpty) return galleryUrls;
    if (imageUrl != null && imageUrl!.isNotEmpty) return [imageUrl!];
    return [];
  }

  /// Returns true if this car has any images
  bool get hasImages => galleryUrls.isNotEmpty;

  /// Returns the prefix of the toy number (first 3 characters)
  String get toyNumberPrefix =>
      toyNumber.length >= 3 ? toyNumber.substring(0, 3) : '';

  factory CarItem.fromMap(Map<String, dynamic> map) {
    return CarItem(
      id: map['id']?.toString(),
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
      toyNumber: map['toy_number'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 1,
      variant: map['variant'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'toy_number': toyNumber,
      'quantity': quantity,
      'variant': variant,
    };
  }

  CarItem copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    List<String>? galleryUrls,
    int? likesCount,
    bool? isLiked,
    String? toyNumber,
    int? quantity,
    String? variant,
  }) {
    return CarItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      toyNumber: toyNumber ?? this.toyNumber,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
    );
  }
}
