import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInfo {
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? phoneNumber;

  UserInfo({
    this.displayName,
    this.email,
    this.photoUrl,
    this.phoneNumber,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      displayName: json['name'],
      email: json['email'],
      photoUrl: json['picture'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

Future<UserInfo?> getUserInfo(String accessToken) async {
  try {
    // Lấy thông tin cơ bản
    final profileResponse = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (profileResponse.statusCode == 200) {
      final profileData = json.decode(profileResponse.body);
      
      // Lấy thông tin số điện thoại từ People API
      final peopleResponse = await http.get(
        Uri.parse('https://people.googleapis.com/v1/people/me?personFields=phoneNumbers'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      String? phoneNumber;
      if (peopleResponse.statusCode == 200) {
        final peopleData = json.decode(peopleResponse.body);
        if (peopleData['phoneNumbers'] != null && peopleData['phoneNumbers'].isNotEmpty) {
          phoneNumber = peopleData['phoneNumbers'][0]['value'];
        }
      }

      return UserInfo(
        displayName: profileData['name'],
        email: profileData['email'],
        photoUrl: profileData['picture'],
        phoneNumber: phoneNumber,
      );
    }
    return null;
  } catch (e) {
    debugPrint('Error getting user info: $e');
    return null;
  }
}