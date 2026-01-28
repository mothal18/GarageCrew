import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CarThumbnail extends StatefulWidget {
  const CarThumbnail({
    super.key,
    required this.url,
    this.size = 56,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
    this.backgroundColor,
  });

  final String? url;
  final double size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? backgroundColor;

  @override
  State<CarThumbnail> createState() => _CarThumbnailState();
}

// Pre-compiled regex patterns for better performance
final _scaleToWidthDownRegex = RegExp(r'/revision/latest/scale-to-width-down/\d+');
final _formatOriginalRegex = RegExp(r'([&?])format=original');

class _CarThumbnailState extends State<CarThumbnail> {
  late List<String> _candidates;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _candidates = _buildCandidates(widget.url);
  }

  @override
  void didUpdateWidget(covariant CarThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {
        _index = 0;
        _candidates = _buildCandidates(widget.url);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_candidates.isEmpty) {
      return _fallback(context);
    }

    final currentUrl = _candidates[_index];
    final width = widget.width ?? widget.size;
    final height = widget.height ?? widget.size;
    Widget errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      return _handleImageError(context, error, currentUrl);
    }

    final bgColor = widget.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;

    // Cache images at 2x display size for good quality on high-DPI screens
    // Only set cache size if dimensions are finite
    final int? cacheSize = width.isFinite ? (width * 2).toInt() : null;

    Widget imageWidget = kIsWeb
        ? Image.network(
            key: ValueKey('$currentUrl${widget.width}${widget.height}'),
            currentUrl,
            width: width,
            height: height,
            fit: widget.fit,
            // Force image to reload on every build to avoid Chrome caching issues
            gaplessPlayback: false,
            filterQuality: FilterQuality.medium,
            isAntiAlias: true,
            errorBuilder: errorBuilder,
          )
        : Image.network(
            key: ValueKey(currentUrl),
            currentUrl,
            width: width,
            height: height,
            fit: widget.fit,
            cacheWidth: cacheSize,
            cacheHeight: cacheSize,
            headers: const {
              'User-Agent': 'Mozilla/5.0',
              'Referer': 'https://hotwheels.fandom.com/',
            },
            errorBuilder: errorBuilder,
          );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          width: width,
          height: height,
          color: bgColor,
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _handleImageError(
    BuildContext context,
    Object error,
    String currentUrl,
  ) {
    debugPrint('Image load failed: $currentUrl -> $error');
    if (_index + 1 < _candidates.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _index += 1;
          });
        }
      });
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    final width = widget.width ?? widget.size;
    final height = widget.height ?? widget.size;
    if (width == height) {
      return CircleAvatar(
        radius: width / 2,
        child: const Icon(Icons.directions_car_filled_outlined),
      );
    }
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: const Icon(Icons.directions_car_filled_outlined),
    );
  }

  List<String> _buildCandidates(String? url) {
    if (url == null || url.isEmpty) {
      return const [];
    }

    final candidates = <String>[];
    final seen = <String>{};
    void addCandidate(String? value) {
      if (value == null || value.isEmpty) {
        return;
      }
      if (seen.add(value)) {
        candidates.add(value);
      }
    }

    if (kIsWeb) {
      addCandidate(_proxyForWeb(url));
    }
    addCandidate(url);
    final filePath = _buildFilePathUrl(url);
    if (kIsWeb && filePath != null) {
      addCandidate(_proxyForWeb(filePath));
    }
    addCandidate(filePath);
    final withoutFormat = _stripFormatOriginal(url);
    addCandidate(withoutFormat);
    if (!kIsWeb) {
      addCandidate(_withOriginalFormat(url));
    }

    final unscaled = _stripScaleToWidthDown(withoutFormat ?? url);
    if (kIsWeb && unscaled != null) {
      addCandidate(_proxyForWeb(unscaled));
    }
    addCandidate(unscaled);
    if (!kIsWeb && unscaled != null) {
      addCandidate(_withOriginalFormat(unscaled));
    }

    return candidates;
  }

  String? _proxyForWeb(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }
    if (!uri.host.contains('nocookie.net') &&
        !uri.host.contains('fandom.com')) {
      return null;
    }
    final target = StringBuffer(uri.host);
    target.write(uri.path);
    if (uri.hasQuery) {
      target.write('?');
      target.write(uri.query);
    }
    return Uri.https('images.weserv.nl', '/', {
      'url': target.toString(),
    }).toString();
  }

  String? _buildFilePathUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }
    if (uri.path.contains('Special:FilePath')) {
      return url;
    }
    final segments = uri.pathSegments;
    final revisionIndex = segments.indexOf('revision');
    if (revisionIndex <= 0) {
      return null;
    }
    final filename = segments[revisionIndex - 1];
    if (filename.isEmpty) {
      return null;
    }
    return Uri.https(
      'hotwheels.fandom.com',
      '/wiki/Special:FilePath/$filename',
    ).toString();
  }

  String _withOriginalFormat(String url) {
    if (url.contains('format=original')) {
      return url;
    }
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}format=original';
  }

  String? _stripScaleToWidthDown(String url) {
    if (!_scaleToWidthDownRegex.hasMatch(url)) {
      return null;
    }
    return url.replaceFirst(_scaleToWidthDownRegex, '/revision/latest');
  }

  String? _stripFormatOriginal(String url) {
    if (!url.contains('format=original')) {
      return null;
    }
    final cleaned = url.replaceAll(_formatOriginalRegex, '');
    if (cleaned.endsWith('?') || cleaned.endsWith('&')) {
      return cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }
}
