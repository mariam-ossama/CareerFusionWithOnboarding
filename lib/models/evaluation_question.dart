

class EvaluationQuestion {
  int? id;
  String? hrId;
  String? question;
  int? defaultScore;

  EvaluationQuestion({
    this.id,
    this.hrId,
    this.question,
    this.defaultScore,
  });

  EvaluationQuestion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hrId = json['hrId'];
    question = json['question'];
    defaultScore = json['defaultScore'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['hrId'] = hrId;
    data['question'] = question;
    data['defaultScore'] = defaultScore;
    return data;
  }
}