//import 'package:flutter/material.dart';

class Candidate {
  String? userName;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? password;

  Candidate({
    this.userName,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.password,
  });

  String? username() => userName;
  String? fullname() => fullName;
  String? eMail() => email;
  String? phonenumber() => phoneNumber;
  String? passWord() => password;

  set user_name(String newName) {
    userName = newName;
  }

  set full_name(String newName) {
    fullName = newName;
  }

  set e_Mail(String newEmail) {
    email = newEmail;
  }

  set phone_number(String newNumber) {
    phoneNumber = newNumber;
  }

  set pass_Word(String newPassword) {
    password = newPassword;
  }

  Map<String, dynamic> toJson() {
    return {
      "FullName": fullName,
      "UserName": userName,
      "Email": email,
      "PhoneNumber": phoneNumber,
      "Password": password,
    };
  }

  Candidate.fromMap(Map<String, dynamic> map) {
    this.fullName = map["FullName"];
    this.userName = map["UserName"];
    this.email = map["Email"];
    this.phoneNumber = map["PhoneNumber"];
    this.password = map["Password"];
  }
}
