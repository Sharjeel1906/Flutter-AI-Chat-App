import 'package:ai_chat_app/provider/chat_provider.dart';
import 'package:ai_chat_app/provider/focus_provider.dart';
import 'package:ai_chat_app/provider/internet_provider.dart';
import 'package:ai_chat_app/provider/login_register_provider.dart';
import 'package:ai_chat_app/provider/selection_provider.dart';
import 'package:ai_chat_app/provider/sessions_provider.dart';
import 'package:ai_chat_app/provider/theme_provider.dart';
import 'package:ai_chat_app/UI_Theme/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=>Login_Register_Provider()),
          ChangeNotifierProvider(create: (_) => FocusProvider()),
          ChangeNotifierProvider(create: (_) => InternetProvider(),),
          ChangeNotifierProvider(create: (_) => ChatProvider(),),
          ChangeNotifierProvider(create: (_)=>ThemeProvider()),
          ChangeNotifierProvider(create: (_)=>SessionsProvider()),
          ChangeNotifierProvider(create: (_)=>SelectionProvider()),
        ],
      child:MyApp(),
  )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isdark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ai Chat App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const ProSplashScreen(),
    );
  }
}

