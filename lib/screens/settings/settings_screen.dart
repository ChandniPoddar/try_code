import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryRed = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("SETTINGS", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black)),
        iconTheme: IconThemeData(color: primaryRed),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          _buildSectionHeader("Dining Preferences", primaryRed),
          const SizedBox(height: 16),
          _buildZomatoTile(Icons.restaurant_menu_rounded, "Dietary Choices", "Veg, Vegan, Non-Veg", primaryRed),
          _buildZomatoTile(Icons.bolt_rounded, "Quick Checkout", "Enable fast campus payments", primaryRed, isSwitch: true),
          
          const SizedBox(height: 40),
          _buildSectionHeader("Account & Security", primaryRed),
          const SizedBox(height: 16),
          _buildZomatoTile(Icons.person_outline_rounded, "Personal Details", "Edit name and contact", primaryRed),
          _buildZomatoTile(Icons.history_rounded, "Order History", "Review your past dining", primaryRed),
          _buildZomatoTile(Icons.security_rounded, "Privacy Center", "Manage your data", primaryRed),
          
          const SizedBox(height: 40),
          _buildSectionHeader("App Support", primaryRed),
          const SizedBox(height: 16),
          _buildZomatoTile(Icons.help_outline_rounded, "Help & FAQs", "Get instant campus support", primaryRed),
          _buildZomatoTile(Icons.info_outline_rounded, "About Global Eats", "App version 1.0.0", primaryRed),
          
          const SizedBox(height: 60),
          Center(
            child: Text("Designed with Excellence by Chandni", style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: color,
        ),
      ),
    );
  }

  Widget _buildZomatoTile(IconData icon, String title, String subtitle, Color color, {bool isSwitch = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
        trailing: isSwitch 
          ? Switch.adaptive(value: true, activeColor: color, onChanged: (v){}) 
          : Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
        onTap: () {},
      ),
    );
  }
}
