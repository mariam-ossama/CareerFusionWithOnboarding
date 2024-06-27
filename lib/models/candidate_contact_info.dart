class ContactInfo {
  final String? phoneNumber;
  final String? email;
  final String? filePath;

  ContactInfo({
    this.phoneNumber,
    this.email,
    this.filePath,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phoneNumber: json['contact_info']['phone_number'],
      email: json['contact_info']['email'],
      filePath: json['file_path'],
    );
  }
}
