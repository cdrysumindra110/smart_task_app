class QuoteModel {
  final String content;
  final String author;

  QuoteModel({
    required this.content,
    required this.author,
  });
  
  factory QuoteModel.fromJson(Map<String, dynamic> json){
    return QuoteModel(
      content: json['content'] as String? ?? '', 
      author: json['author'] as String? ?? ''
      );
  }
}