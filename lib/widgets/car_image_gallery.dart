import 'package:flutter/material.dart';

import 'car_thumbnail.dart';

class CarImageGallery extends StatefulWidget {
  const CarImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 250,
    this.onTap,
    this.heroTagPrefix,
  });

  final List<String> imageUrls;
  final double height;
  final VoidCallback? onTap;
  final String? heroTagPrefix;

  @override
  State<CarImageGallery> createState() => _CarImageGalleryState();
}

class _CarImageGalleryState extends State<CarImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: CarThumbnail(
          url: null,
          width: double.infinity,
          height: widget.height,
          fit: BoxFit.contain,
          borderRadius: 0,
        ),
      );
    }

    if (widget.imageUrls.length == 1) {
      return GestureDetector(
        onTap: widget.onTap,
        child: _buildImage(widget.imageUrls.first, 0),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: widget.onTap,
                child: _buildImage(widget.imageUrls[index], index),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _DotsIndicator(
          count: widget.imageUrls.length,
          currentIndex: _currentPage,
        ),
      ],
    );
  }

  Widget _buildImage(String url, int index) {
    final imageWidget = CarThumbnail(
      url: url,
      width: double.infinity,
      height: widget.height,
      fit: BoxFit.contain,
      borderRadius: 0,
    );

    if (widget.heroTagPrefix != null) {
      return Hero(
        tag: '${widget.heroTagPrefix}_$index',
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  const FullScreenImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTagPrefix,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTagPrefix;

  static void show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
    String? heroTagPrefix,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenImageGallery(
            imageUrls: imageUrls,
            initialIndex: initialIndex,
            heroTagPrefix: heroTagPrefix,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageWidget = InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CarThumbnail(
                url: widget.imageUrls[index],
                width: double.infinity,
                fit: BoxFit.contain,
                borderRadius: 0,
              ),
            ),
          );

          if (widget.heroTagPrefix != null && index == widget.initialIndex) {
            return Hero(
              tag: '${widget.heroTagPrefix}_$index',
              child: imageWidget,
            );
          }

          return imageWidget;
        },
      ),
    );
  }
}
