import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_task_app/models/quote_model.dart';

class QuoteService {
  static const String _primaryUrl = 'https://api.quotable.io/random';
  static const String _fallbackUrl = 'https://zenquotes.io/api/random';

  Future<QuoteModel?> fetchRandomQuote() async {
    try {
      final primaryResponse = await http
          .get(Uri.parse(_primaryUrl))
          .timeout(const Duration(seconds: 8));

      final primaryQuote = _parsePrimaryQuote(primaryResponse);
      if (primaryQuote != null) {
        return primaryQuote;
      }
    } catch (_) {
      // Fall through to fallback provider.
    }

    try {
      final fallbackResponse = await http
          .get(Uri.parse(_fallbackUrl))
          .timeout(const Duration(seconds: 8));

      return _parseFallbackQuote(fallbackResponse);
    } catch (_) {
      return null;
    }
  }

  QuoteModel? _parsePrimaryQuote(http.Response response) {
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    return QuoteModel(
      content: data['content'] as String? ?? '',
      author: data['author'] as String? ?? '',
    );
  }

  QuoteModel? _parseFallbackQuote(http.Response response) {
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data is! List || data.isEmpty) return null;
    final first = data.first;
    if (first is! Map<String, dynamic>) return null;

    return QuoteModel(
      content: first['q'] as String? ?? '',
      author: first['a'] as String? ?? '',
    );
  }
}
