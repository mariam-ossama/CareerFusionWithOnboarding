class RecommendedJob {
  final int jobId;
  final String jobTitle;
  final double similarity;

  RecommendedJob({required this.jobId, required this.jobTitle, required this.similarity});

  factory RecommendedJob.fromJson(Map<String, dynamic> json) {
    return RecommendedJob(
      jobId: json['JobId'],
      jobTitle: json['JobTitle'],
      similarity: json['Similarity'],
    );
  }
}