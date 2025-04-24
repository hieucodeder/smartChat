import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:smart_chat/firebase_options.dart';
import 'package:smart_chat/page/slaps_page.dart';
import 'package:smart_chat/provider/chat_provider.dart';
import 'package:smart_chat/provider/chatbot_provider.dart';
import 'package:smart_chat/provider/chatbotcolors_provider.dart';
import 'package:smart_chat/provider/chatbotname_provider.dart';
import 'package:smart_chat/provider/config_chat_provider.dart';
import 'package:smart_chat/provider/draw_selected_color_provider.dart';
import 'package:smart_chat/provider/historyid_provider.dart';
import 'package:smart_chat/provider/menu_state_provider.dart';
import 'package:smart_chat/provider/navigation_provider.dart';
import 'package:smart_chat/provider/platform_provider.dart';
import 'package:smart_chat/provider/provider_color.dart';
import 'package:smart_chat/provider/selected_history_provider.dart';
import 'package:smart_chat/provider/selected_item_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Kiểm tra trạng thái đăng nhập
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Providercolor()),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ChangeNotifierProvider(create: (_) => ChatbotcolorsProvider()),
      ChangeNotifierProvider(create: (_) => HistoryidProvider()),
      ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
      ChangeNotifierProvider(create: (_) => SelectedHistoryProvider()),
      ChangeNotifierProvider(create: (_) => ConfigChatProvider()),
      ChangeNotifierProvider(create: (_) => ChatbotnameProvider()),
      ChangeNotifierProvider(create: (_) => DrawSelectedColorProvider()),
      ChangeNotifierProvider(create: (_) => SelectedItemProvider()),
      ChangeNotifierProvider(create: (_) => MenuStateProvider()),
      ChangeNotifierProvider(create: (_) => PlatformProvider())
    ],
    child: const MyApp(),
  ));
}

// Hàm kiểm tra kết nối với tài khoản Google Cloud
Future<void> checkGoogleCloudConnection() async {
  var clientId = ClientId(
      '85145469352-55nhrp8gaifj5qc0cmf1q5opifnngahj.apps.googleusercontent.com');
  const scopes = [
    DriveApi.driveScope
  ]; // Thêm quyền truy cập vào API mà bạn muốn sử dụng

  try {
    // Xác thực người dùng và lấy quyền truy cập
    var authClient = await clientViaUserConsent(clientId, scopes, prompt);

    // Khởi tạo API Google Drive (hoặc API khác mà bạn muốn sử dụng)
    var driveApi = DriveApi(authClient);

    // Lấy thông tin về tài khoản Google (xác nhận kết nối)
    var about = await driveApi.about.get();
    print('User Info: ${about.user?.displayName}');

    // Đóng client sau khi sử dụng
    authClient.close();
  } catch (e) {
    print('Error: $e');
  }
}

// Hàm này sẽ hiển thị hộp thoại xác thực nếu cần
void prompt(String url) {
  print('Please go to the following URL and grant access:');
  print('  => $url');

  // Yêu cầu người dùng nhập mã xác thực mà họ nhận được sau khi cấp quyền
  print('After granting access, please enter the code you received:');
  // Đọc mã từ người dùng
  String? code = stdin.readLineSync(); // Thay đổi theo cách đọc mã bạn sử dụng
  if (code != null && code.isNotEmpty) {
    print('Code entered: $code');
  } else {
    print('No code entered.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smart Chat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const SlapsPage());
  }
}
