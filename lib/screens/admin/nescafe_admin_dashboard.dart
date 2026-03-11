import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class NescafeAdminDashboard extends StatefulWidget {
  const NescafeAdminDashboard({super.key});

  @override
  State<NescafeAdminDashboard> createState() => _NescafeAdminDashboardState();
}

class _NescafeAdminDashboardState extends State<NescafeAdminDashboard> with TickerProviderStateMixin {
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
    final primaryColor = theme.primaryColor;
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.6),
                  radius: 1.2,
                  colors: [primaryColor.withValues(alpha: 0.1), theme.scaffoldBackgroundColor],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('orders')
                    .where('outlet', isEqualTo: 'Nescafe')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Connection Error", style: GoogleFonts.poppins(color: Colors.redAccent)));
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));

                  int totalOrders = snapshot.data?.docs.length ?? 0;
                  double dailyRevenue = 0;
                  for (var doc in snapshot.data!.docs) {
                    dailyRevenue += (doc.data() as Map<String, dynamic>)['total'] ?? 0.0;
                  }

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildHeader(context, theme),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Outlet Analytics", primaryColor, textColor),
                              const SizedBox(height: 20),
                              _buildStatsGrid(totalOrders, dailyRevenue, theme),
                              const SizedBox(height: 32),
                              _buildSectionTitle("Recent Orders", primaryColor, textColor),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      _buildOrdersList(snapshot.data!.docs, theme),
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

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 200, backgroundColor: Colors.transparent, elevation: 0, pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=2070&auto=format&fit=crop", fit: BoxFit.cover),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [theme.scaffoldBackgroundColor.withValues(alpha: 0.2), theme.scaffoldBackgroundColor]))),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text("NESCAFÉ", style: GoogleFonts.monoton(color: theme.primaryColor, fontSize: 42, letterSpacing: 4)),
                  Text("ADMINISTRATION HUB", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: theme.colorScheme.surface.withValues(alpha: 0.5), shape: BoxShape.circle, border: Border.all(color: theme.primaryColor.withValues(alpha: 0.5))), child: Icon(Icons.logout, color: theme.primaryColor, size: 20)),
          onPressed: () async {
            await context.read<AuthService>().logout();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color primary, Color text) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: primary),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.poppins(color: text, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatsGrid(int total, double revenue, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.5,
      children: [
        _buildStatCard("Total Revenue", "₹${revenue.toStringAsFixed(0)}", Icons.payments_outlined, theme),
        _buildStatCard("Total Orders", "$total", Icons.shopping_bag_outlined, theme),
        _buildStatCard("Active Queue", "Live", Icons.timer_outlined, theme),
        _buildStatCard("Outlet Status", "Open", Icons.storefront_outlined, theme),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)), boxShadow: [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: theme.primaryColor, size: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<QueryDocumentSnapshot> docs, ThemeData theme) {
    if (docs.isEmpty) return SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.only(top: 40), child: Text("No orders yet", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))))));
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
        final doc = docs[index];
        final order = doc.data() as Map<String, dynamic>;
        final List items = order['items'] ?? [];
        final String itemsSummary = items.map((i) => "${i['quantity']}x ${i['name']}").join(", ");
        final String status = order['status'] ?? 'Pending';

        Color statusColor = Colors.orange;
        if (status == 'Preparing') statusColor = Colors.blue;
        if (status == 'Completed') statusColor = Colors.green;

        return Container(
          margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.primaryColor.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.05), blurRadius: 10)]),
          child: Row(children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.coffee_maker, color: theme.primaryColor)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Order ${order['orderId']?.toString().split('-').last ?? '...'}", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
              Text(itemsSummary, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text("₹${order['total']}", style: GoogleFonts.poppins(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _updateOrderStatus(doc.id, status),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withValues(alpha: 0.5))),
                  child: Text(status, style: GoogleFonts.poppins(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ]),
        );
      }, childCount: docs.length)),
    );
  }
}
