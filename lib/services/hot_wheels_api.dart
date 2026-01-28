import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class HotWheelsSearchResult {
  HotWheelsSearchResult({
    required this.pageId,
    required this.title,
    required this.snippet,
    this.imageUrl,
    this.toyNumber,
  });

  final int pageId;
  final String title;
  final String snippet;
  final String? imageUrl;
  final String? toyNumber;
}

class HotWheelsApi {
  static const _baseUrl = 'https://hotwheels.fandom.com/api.php';
  static const _timeout = Duration(seconds: 10);

  Future<List<HotWheelsSearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final searchUri = Uri.parse(_baseUrl).replace(queryParameters: {
      'action': 'query',
      'list': 'search',
      'srsearch': trimmed,
      'srlimit': '12',
      'format': 'json',
      'origin': '*',
    });

    final searchResponse = await http.get(searchUri).timeout(_timeout);
    if (searchResponse.statusCode != 200) {
      throw Exception('Search failed: ${searchResponse.statusCode}');
    }

    final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final searchList =
        (searchJson['query']?['search'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

    final results = <HotWheelsSearchResult>[];
    for (final item in searchList) {
      results.add(
        HotWheelsSearchResult(
          pageId: item['pageid'] as int,
          title: item['title'] as String,
          snippet: _stripHtml(item['snippet'] as String? ?? ''),
          toyNumber: null, // Will be fetched on demand
        ),
      );
    }

    if (results.isEmpty) {
      return results;
    }

    final pageIds = results.map((e) => e.pageId).join('|');
    final imagesUri = Uri.parse(_baseUrl).replace(queryParameters: {
      'action': 'query',
      'pageids': pageIds,
      'prop': 'pageimages',
      'piprop': 'thumbnail|original',
      'pithumbsize': '200',
      'format': 'json',
      'origin': '*',
    });

    final imagesResponse = await http.get(imagesUri).timeout(_timeout);
    if (imagesResponse.statusCode != 200) {
      return results;
    }

    final imagesJson = jsonDecode(imagesResponse.body) as Map<String, dynamic>;
    final pages = imagesJson['query']?['pages'] as Map<String, dynamic>? ?? {};

    final imageMap = <int, String>{};
    for (final entry in pages.entries) {
      final page = entry.value as Map<String, dynamic>;
      final pageId = page['pageid'] as int?;
      final thumbnail = page['thumbnail'] as Map<String, dynamic>?;
      final original = page['original'] as Map<String, dynamic>?;
      final source =
          (thumbnail?['source'] as String?) ?? (original?['source'] as String?);
      if (pageId != null && source != null && source.isNotEmpty) {
        imageMap[pageId] = source;
      }
    }

    return results
        .map(
          (result) => HotWheelsSearchResult(
            pageId: result.pageId,
            title: result.title,
            snippet: result.snippet,
            imageUrl: imageMap[result.pageId],
            toyNumber: null, // Will be fetched on demand
          ),
        )
        .toList();
  }

  /// Fetches detailed page content and tries to extract Toy Number (Segment Code)
  ///
  /// Searches for Hot Wheels segment codes in format XXX## (3 letters + 2 digits)
  /// like JJM02, FYB52, etc. from version tables in WikiText.
  Future<String?> fetchToyNumber(int pageId) async {
    try {
      final parseUri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'parse',
        'pageid': pageId.toString(),
        'prop': 'wikitext',
        'format': 'json',
        'origin': '*',
      });

      final response = await http.get(parseUri).timeout(_timeout);
      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final wikitext = json['parse']?['wikitext']?['*'] as String?;

      if (wikitext == null) return null;

      // Extract Segment Code (Toy Number) from WikiText
      // Hot Wheels uses segment codes in format XXX## (3 uppercase letters + 2 digits)
      // Common patterns in version tables and templates:
      // |toy=JJM02
      // |item=FYB52
      // |number=GHC31
      // {{version|toy=JJM02|...}}

      // Strategy: Find ALL segment codes and return the most recent/first one
      final segmentCodePattern = RegExp(
        r'\b([A-Z]{3}\d{2})\b',
        caseSensitive: true,
      );

      final matches = segmentCodePattern.allMatches(wikitext);

      // Collect all valid segment codes
      final validCodes = <String>{};
      for (final match in matches) {
        final code = match.group(1);
        if (code != null && code.length == 5) {
          // Additional validation: first char should be a letter from recent years
          // Hot Wheels segment codes typically start with letters like F, G, H, J, K, L, M, N, P, etc.
          final firstChar = code.codeUnitAt(0);
          if (firstChar >= 65 && firstChar <= 90) { // A-Z
            validCodes.add(code);
          }
        }
      }

      // Return the first valid code found (usually the most relevant one)
      // Sort to get most recent codes first (later letters in alphabet = newer years)
      if (validCodes.isNotEmpty) {
        final sortedCodes = validCodes.toList()..sort((a, b) => b.compareTo(a));
        return sortedCodes.first;
      }

      return null;
    } catch (error) {
      // Silently fail - Toy Number is optional
      return null;
    }
  }

  String _stripHtml(String input) {
    final withoutTags = input.replaceAll(RegExp(r'<[^>]*>'), '');
    return withoutTags
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}
