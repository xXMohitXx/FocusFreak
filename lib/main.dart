import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FocusFreak',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.interTextTheme(),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: themeProvider.themeMode,
            home: const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
