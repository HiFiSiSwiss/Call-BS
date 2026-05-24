import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/fact_check_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CallBSApp());
}

class CallBSApp extends StatelessWidget {
  const CallBSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FactCheckProvider(),
      child: MaterialApp(
        title: 'Call BS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A1A2E),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0D1A),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
