class QuestionActualScore {
  String? userId;
  int? questionId;
  int? score;

  QuestionActualScore({this.userId, this.questionId, this.score});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['questionId'] = this.questionId;
    data['score'] = this.score;
    return data;
  }
}