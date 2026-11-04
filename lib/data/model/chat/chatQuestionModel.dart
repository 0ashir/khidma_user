class ChatQuestion {
  final int id;
  final String question;

  ChatQuestion({required this.id, required this.question});

  factory ChatQuestion.fromJson(Map<String, dynamic> json) {
    return ChatQuestion(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      question: json['question']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
    };
  }
}
