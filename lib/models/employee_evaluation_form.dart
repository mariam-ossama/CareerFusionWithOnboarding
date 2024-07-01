import 'package:career_fusion/models/evaluation_question.dart';

class EmployeeEvaluationForm {
  String? userId;
  double? overallScore; // Change from int? to double?
  List<EvaluationQuestion>? questions;
  String? comparisonResult;

  EmployeeEvaluationForm({
    this.userId,
    this.overallScore,
    this.questions,
    this.comparisonResult,
  });

  EmployeeEvaluationForm.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    overallScore = json['overallScore']?.toDouble(); // Convert to double
    if (json['questions'] != null) {
      questions = <EvaluationQuestion>[];
      json['questions'].forEach((v) {
        questions!.add(EvaluationQuestion.fromJson(v));
      });
    }
    comparisonResult = json['comparisonResult'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['overallScore'] = overallScore;
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    data['comparisonResult'] = comparisonResult;
    return data;
  }
}