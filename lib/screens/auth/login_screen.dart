import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../consumer/home_screen.dart';
import 'signup_screen.dart';
import 'operator_user.dart';
import '../admin/nescafe_admin_dashboard.dart';
import '../admin/lipton_admin_dashboard.dart';
import '../admin/canteen_admin_dashboard.dart';
import '../admin/fruit_admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToDashboard(String email) {
    Widget dashboard;
    final lowEmail = email.toLowerCase();
    if (lowEmail == 'nescafe@gmail.com') dashboard = const NescafeAdminDashboard();
    else if (lowEmail == 'lipton@gmail.com') dashboard = const LiptonAdminDashboard();
    else if (lowEmail == 'canteen@gmail.com') dashboard = const CanteenAdminDashboard();
    else if (lowEmail == 'fruit@gmail.com') dashboard = const FruitAdminDashboard();
    else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dashboard));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    const Color zomatoRed = Color(0xFFE23744);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=1974&auto=format&fit=crop",
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.4),
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          Positioned.fill(
            child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.9), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: zomatoRed.withOpacity(0.1), blurRadius: 20, spreadRadius: 10)]),
                        child: const Icon(Icons.restaurant_menu_rounded, size: 60, color: zomatoRed),
                      ),
                      const SizedBox(height: 24),
                      Text("Welcome Back", style: GoogleFonts.poppins(color: const Color(0xFF1C1C1C), fontSize: 32, fontWeight: FontWeight.w800)),
                      Text("Login to your delicious world", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 50),
                      _buildTextField(controller: _emailController, hint: "Email", icon: Icons.email_rounded),
                      const SizedBox(height: 20),
                      _buildTextField(controller: _passwordController, hint: "Password", icon: Icons.lock_rounded, obscure: _obscurePassword, suffix: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: zomatoRed), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
                      const SizedBox(height: 40),
                      auth.loading ? const CircularProgressIndicator(color: zomatoRed) : SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        if (email.isEmpty || password.isEmpty) {
                          Fluttertoast.showToast(msg: "Please fill all fields");
                          return;
                        }
                        final msg = await auth.signIn(email: email, password: password);
                        if (msg != null) Fluttertoast.showToast(msg: msg);
                        else { if (!mounted) return; if (auth.isAdmin) _navigateToDashboard(email); else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())); }
                      }, child: const Text("LOGIN"))),
                      const SizedBox(height: 30),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Don't have an account?", style: GoogleFonts.poppins(color: Colors.grey[600])),
                        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())), child: Text("Sign Up", style: GoogleFonts.poppins(color: zomatoRed, fontWeight: FontWeight.bold))),
                      ]),
                      const SizedBox(height: 10),
                      TextButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OperatorUserScreen()), (r) => false), child: Text("Back to Selection", style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF4F4F2), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller, obscureText: obscure,
        style: GoogleFonts.poppins(color: const Color(0xFF1C1C1C), fontSize: 16),
        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16), border: InputBorder.none, hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 15), prefixIcon: Icon(icon, color: const Color(0xFFE23744), size: 22), suffixIcon: suffix),
      ),
    );
  }
}
