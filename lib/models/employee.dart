class Employee {
  int? id;
  int? jobFormId;
  String? userId;
  String? userEmail;
  String? userFullName;
  String? filePath;

  Employee({
    this.id,
    this.jobFormId,
    this.userId,
    this.userEmail,
    this.userFullName,
    this.filePath,
  });

  Employee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    jobFormId = json['jobFormId'];
    userId = json['userId'];
    userEmail = json['userEmail'];
    userFullName = json['userFullName'];
    filePath = json['filePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['jobFormId'] = this.jobFormId;
    data['userId'] = this.userId;
    data['userEmail'] = this.userEmail;
    data['userFullName'] = this.userFullName;
    data['filePath'] = this.filePath;
    return data;
  }
}
