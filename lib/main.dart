import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';
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
    // 🌟 Zomato-Inspired Dashing Dining Palette
    const Color zomatoRed = Color(0xFFE23744); 
    const Color softPearl = Color(0xFFFDFBF7); // Anti-glare soft background
    const Color pureWhite = Color(0xFFFFFFFF);
    const Color textDeep = Color(0xFF2D3436);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Global Eats',
        themeMode: ThemeMode.light, // 🌟 Force Light Mode only
        
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: zomatoRed,
          scaffoldBackgroundColor: softPearl,
          
          colorScheme: const ColorScheme.light(
            primary: zomatoRed,
            secondary: Color(0xFF006491), // Domino's Blue for accents
            surface: pureWhite,
            onSurface: textDeep,
          ),

          // Professional Stylish Typography
          textTheme: GoogleFonts.poppinsTextTheme().apply(
            bodyColor: textDeep,
            displayColor: textDeep,
          ).copyWith(
            displayLarge: GoogleFonts.metamorphous(color: zomatoRed, fontWeight: FontWeight.bold),
            titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: textDeep, fontSize: 22),
            bodyLarge: GoogleFonts.poppins(color: textDeep, letterSpacing: 0.1),
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: softPearl,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(color: textDeep, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: zomatoRed),
          ),

          cardTheme: CardThemeData(
            color: pureWhite,
            elevation: 2,
            shadowColor: zomatoRed.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: textDeep.withOpacity(0.05), width: 1),
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: zomatoRed,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, letterSpacing: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: pureWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textDeep.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: zomatoRed, width: 1.5),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
