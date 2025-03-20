import 'package:chatbotbnn/model/chatbot_info.dart';
import 'package:flutter/material.dart';

class ChatbotnameProvider with ChangeNotifier {
  List<ChatbotInfo> _chatbotList = [];

  List<ChatbotInfo> get chatbotList => _chatbotList;

  void updateChatbotList(List<ChatbotInfo> newChatbotList) {
    _chatbotList = newChatbotList;
    notifyListeners();
  }
}
