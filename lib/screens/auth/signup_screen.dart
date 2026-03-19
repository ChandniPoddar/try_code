import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../consumer/home_screen.dart';
import 'operator_user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
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
              imageUrl: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070&auto=format&fit=crop",
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
                        child: const Icon(Icons.person_add_alt_1_rounded, size: 60, color: zomatoRed),
                      ),
                      const SizedBox(height: 24),
                      Text("Create Account", style: GoogleFonts.poppins(color: const Color(0xFF1C1C1C), fontSize: 32, fontWeight: FontWeight.w800)),
                      Text("Join the Global Eats community", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 50),
                      _buildTextField(controller: _emailController, hint: "Enter Email", icon: Icons.email_rounded),
                      const SizedBox(height: 20),
                      _buildTextField(controller: _passwordController, hint: "Create Password", icon: Icons.lock_rounded, obscure: _obscurePassword, suffix: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: zomatoRed), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
                      const SizedBox(height: 40),
                      auth.loading ? const CircularProgressIndicator(color: zomatoRed) : SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        if (email.isEmpty || password.isEmpty) {
                          Fluttertoast.showToast(msg: "Please fill all fields");
                          return;
                        }
                        final msg = await auth.signUp(email: email, password: password);
                        if (msg != null) Fluttertoast.showToast(msg: msg);
                        else { if (!mounted) return; Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false); }
                      }, child: const Text("SIGN UP"))),
                      const SizedBox(height: 30),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Already have an account?", style: GoogleFonts.poppins(color: Colors.grey[600])),
                        TextButton(onPressed: () => Navigator.pop(context), child: Text("Login", style: GoogleFonts.poppins(color: zomatoRed, fontWeight: FontWeight.bold))),
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
