class PostTelephoneInterviewQuestion {
  int? questionId;
  String question;

  PostTelephoneInterviewQuestion({this.questionId, required this.question});

  factory PostTelephoneInterviewQuestion.fromJson(Map<String, dynamic> json) {
    return PostTelephoneInterviewQuestion(
      questionId: json['questionId'] != null
          ? int.tryParse(json['questionId'].toString())
          : null,
      question: json['question'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'question': question,
    };
    if (questionId != null) {
      data['questionId'] = questionId;
    }
    return data;
  }
}
