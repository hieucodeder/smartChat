import 'package:chatbotbnn/firebase_options.dart';
import 'package:chatbotbnn/page/slaps_page.dart';
import 'package:chatbotbnn/provider/chat_provider.dart';
import 'package:chatbotbnn/provider/chatbot_provider.dart';
import 'package:chatbotbnn/provider/chatbotcolors_provider.dart';
import 'package:chatbotbnn/provider/chatbotname_provider.dart';
import 'package:chatbotbnn/provider/config_chat_provider.dart';
import 'package:chatbotbnn/provider/draw_selected_color_provider.dart';
import 'package:chatbotbnn/provider/historyid_provider.dart';
import 'package:chatbotbnn/provider/menu_state_provider.dart';
import 'package:chatbotbnn/provider/navigation_provider.dart';
import 'package:chatbotbnn/provider/platform_provider.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:chatbotbnn/provider/selected_history_provider.dart';
import 'package:chatbotbnn/provider/selected_item_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
