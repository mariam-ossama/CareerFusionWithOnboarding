class PostCandidateTelephoneInterview {
  int? postCVId;
  int? postId;
  String? userId;
  String? userEmail;
  String? userFullName;
  String? filePath;

  PostCandidateTelephoneInterview(
      {this.postCVId,
      this.postId,
      this.userId,
      this.userEmail,
      this.userFullName,
      this.filePath});

  PostCandidateTelephoneInterview.fromJson(Map<String, dynamic> json) {
    postCVId = json['postCVId'];
    postId = json['postId'];
    userId = json['userId'];
    userEmail = json['userEmail'];
    userFullName = json['userFullName'];
    filePath = json['filePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postCVId'] = this.postCVId;
    data['postId'] = this.postId;
    data['userId'] = this.userId;
    data['userEmail'] = this.userEmail;
    data['userFullName'] = this.userFullName;
    data['filePath'] = this.filePath;
    return data;
  }
}
