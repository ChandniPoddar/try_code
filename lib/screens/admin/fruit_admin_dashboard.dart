import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class FruitAdminDashboard extends StatefulWidget {
  const FruitAdminDashboard({super.key});

  @override
  State<FruitAdminDashboard> createState() => _FruitAdminDashboardState();
}

class _FruitAdminDashboardState extends State<FruitAdminDashboard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _updateOrderStatus(String docId, String currentStatus) async {
    String nextStatus = 'Pending';
    if (currentStatus == 'Pending') nextStatus = 'Preparing';
    else if (currentStatus == 'Preparing') nextStatus = 'Completed';
    else if (currentStatus == 'Completed') nextStatus = 'Pending';

    await _db.collection('orders').doc(docId).update({'status': nextStatus});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryRed = theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('orders')
                    .where('outlet', isEqualTo: 'Fruit Corner')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFE23744)));

                  int totalOrders = snapshot.data?.docs.length ?? 0;
                  double dailyRevenue = 0;
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      dailyRevenue += (doc.data() as Map<String, dynamic>)['total'] ?? 0.0;
                    }
                  }

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildHeader(context, primaryRed),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Freshness Hub Analytics", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 20),
                              _buildStatsGrid(totalOrders, dailyRevenue, primaryRed),
                              const SizedBox(height: 32),
                              Text("Live Order Queue", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      _buildOrdersList(snapshot.data?.docs ?? [], primaryRed),
                    ],
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryRed) {
    return SliverAppBar(
      expandedHeight: 180, backgroundColor: Colors.white, pinned: true, elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text("FRUIT CORNER", style: GoogleFonts.metamorphous(color: primaryRed, fontSize: 18, fontWeight: FontWeight.bold)),
        background: Container(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout_rounded, color: primaryRed),
          onPressed: () async {
            await context.read<AuthService>().logout();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildStatsGrid(int total, double revenue, Color primaryRed) {
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.6,
      children: [
        _buildStatCard("Revenue", "₹${revenue.toStringAsFixed(0)}", Icons.payments_outlined, primaryRed),
        _buildStatCard("Total Juices", "$total", Icons.local_drink_outlined, primaryRed),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color primaryRed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: primaryRed, size: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<QueryDocumentSnapshot> docs, Color primaryRed) {
    if (docs.isEmpty) return SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.only(top: 40), child: Text("No orders yet", style: GoogleFonts.poppins(color: Colors.grey)))));
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
        final doc = docs[index];
        final order = doc.data() as Map<String, dynamic>;
        final String status = order['status'] ?? 'Pending';
        return Container(
          margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
          child: Row(children: [
            Icon(Icons.waves_outlined, color: primaryRed, size: 30),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Order #${order['orderId']?.toString().split('-').last ?? '...'}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text("${order['items']?.length ?? 0} items • ₹${order['total']}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            ])),
            GestureDetector(
              onTap: () => _updateOrderStatus(doc.id, status),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: primaryRed.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: GoogleFonts.poppins(color: primaryRed, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        );
      }, childCount: docs.length)),
    );
  }
}
