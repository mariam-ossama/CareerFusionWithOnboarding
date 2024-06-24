class TelephoneInterviewQuestion {
  late int id;
  late String question;
  late String jobTitle;

  TelephoneInterviewQuestion(this.id, this.question, this.jobTitle);

  TelephoneInterviewQuestion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    jobTitle = json['jobTitle'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'jobTitle': jobTitle,
      };
}
