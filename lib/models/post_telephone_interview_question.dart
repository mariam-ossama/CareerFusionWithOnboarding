class PostTelephoneInterviewQuestion {
  int? questionId;
  String question;

  PostTelephoneInterviewQuestion({this.questionId, required this.question});

  factory PostTelephoneInterviewQuestion.fromJson(Map<String, dynamic> json) {
    return PostTelephoneInterviewQuestion(
      questionId: json['questionId'] != null
          ? int.tryParse(json['questionId'].toString())
          : null,
      question: json['questions'],
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId ?? 0, // Ensure questionId is an integer
        'questions': question,
      };
}
