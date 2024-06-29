


class Goal {
  int? id;
  String? hrUserId;
  String? description;
  int? score;
  String? createdAt;

  Goal({this.id, this.hrUserId, this.description, this.score, this.createdAt});

  Goal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hrUserId = json['hrUserId'];
    description = json['description'];
    score = json['score'] ?? 1; // Ensure score is not null
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hrUserId'] = this.hrUserId;
    data['description'] = this.description;
    data['score'] = this.score;
    data['createdAt'] = this.createdAt;
    return data;
  }
}