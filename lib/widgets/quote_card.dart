import 'package:flutter/material.dart';
import '../services/quote_service.dart';
import '../models/quote_model.dart';

class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  final QuoteService _quoteService = QuoteService();
  QuoteModel? _quote;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final quote = await _quoteService.fetchRandomQuote();
    if (mounted) {
      setState(() {
        _quote = quote;
        _isLoading = false;
        _hasError = quote == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            )
          : _hasError
              ? Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white70),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Could not load quote',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _fetchQuote,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _fetchQuote,
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _quote?.content ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— ${_quote?.author ?? ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
    );
  }
}
