import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint("Firebase initialization error: \$e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // 🌟 Unique Gourmet Palette
          const Color gourmetCream = Color(0xFFFDF8F5); 
          const Color velvetBurgundy = Color(0xFF6B0F1A);
          const Color warmTerracotta = Color(0xFFBC4749);
          const Color deepSlate = Color(0xFF2D3436);

          return MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
              ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Global Eats',
              themeMode: themeProvider.themeMode,
              
              // 🌟 Unique & Professional Light Theme
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                primaryColor: velvetBurgundy,
                scaffoldBackgroundColor: gourmetCream,
                
                colorScheme: ColorScheme.light(
                  primary: velvetBurgundy,
                  secondary: warmTerracotta,
                  surface: Colors.white,
                  onSurface: deepSlate,
                  surfaceContainerHighest: Colors.white,
                ),

                // Professional Typography
                textTheme: GoogleFonts.poppinsTextTheme().apply(
                  bodyColor: deepSlate,
                  displayColor: velvetBurgundy,
                ).copyWith(
                  headlineLarge: GoogleFonts.monoton(color: velvetBurgundy, letterSpacing: 2),
                  titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: deepSlate),
                  bodyLarge: GoogleFonts.poppins(color: deepSlate, letterSpacing: 0.2),
                ),

                appBarTheme: AppBarTheme(
                  backgroundColor: gourmetCream,
                  elevation: 0,
                  centerTitle: true,
                  titleTextStyle: GoogleFonts.poppins(
                    color: velvetBurgundy, 
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1
                  ),
                  iconTheme: const IconThemeData(color: velvetBurgundy),
                ),

                cardTheme: CardThemeData(
                  color: Colors.white,
                  elevation: 8,
                  shadowColor: velvetBurgundy.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: velvetBurgundy.withValues(alpha: 0.05)),
                  ),
                ),

                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: velvetBurgundy,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: velvetBurgundy.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),

                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: velvetBurgundy.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: velvetBurgundy.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: velvetBurgundy, width: 1.5),
                  ),
                ),
              ),

              // 🌟 Premium Dark Theme
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                primaryColor: const Color(0xFFD4AF37),
                scaffoldBackgroundColor: const Color(0xFF121212),
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFD4AF37),
                  secondary: Color(0xFFE5C76B),
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),
                textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF121212),
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
                ),
                cardTheme: CardThemeData(
                  color: const Color(0xFF1E1E1E),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              home: const SplashScreen(),
            ),
          );
        }
      ),
    );
  }
}
