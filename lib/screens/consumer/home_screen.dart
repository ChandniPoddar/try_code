import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/auth_service.dart';
import '../auth/operator_user.dart';
import '../../models/food_item.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart'; 
import 'cart_screen.dart'; 
import 'product_list_screen.dart';
import 'canteen_screen.dart';
import 'lipton_screen.dart';
import 'fruitcorner_screen.dart';
import 'nescafe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<FoodItem> _allFoodItems;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  int _currentDishIndex = 0;
  late Timer _timer;
  final PageController _dishPageController = PageController(viewportFraction: 0.9);

  late AnimationController _fadeController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _allFoodItems = FoodItem.getMockItems();
    
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    // 🌟 Auto-swapper for Top Dishes
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentDishIndex < 3) {
        _currentDishIndex++;
      } else {
        _currentDishIndex = 0;
      }
      if (_dishPageController.hasClients) {
        _dishPageController.animateToPage(
          _currentDishIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _dishPageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _openCategory(BuildContext context, String category) {
    if (category == 'Lipton') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiptonScreen()));
    } else if (category == 'Nescafe') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NescafeScreen()));
    } else if (category == 'Fruit Corner') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FruitCornerScreen()));
    } else if (category == 'Canteen') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CanteenScreen()));
    } else {
      final filteredProducts = _allFoodItems.where((item) => item.category.trim() == category).toList();
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(category: category, products: filteredProducts)));
    }
  }

  void _showSearchHub(BuildContext context, Color primaryRed) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: TextField(
                  autofocus: true,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search for outlets or dishes...",
                    prefixIcon: Icon(Icons.search, color: primaryRed),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    Text("QUICK OUTLET PICK", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.4,
                      children: [
                        _buildOutletPickCard(context, "Nescafe", Icons.coffee_rounded, primaryRed),
                        _buildOutletPickCard(context, "Lipton", Icons.local_cafe_rounded, primaryRed),
                        _buildOutletPickCard(context, "Canteen", Icons.restaurant_rounded, primaryRed),
                        _buildOutletPickCard(context, "Fruit Corner", Icons.apple_rounded, primaryRed),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text("POPULAR SEARCHES", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 15),
                    _buildPopularSearchItem("Cappuccino", primaryRed),
                    _buildPopularSearchItem("Cold Coffee", primaryRed),
                    _buildPopularSearchItem("Classic Maggie", primaryRed),
                    _buildPopularSearchItem("Veg Burger", primaryRed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutletPickCard(BuildContext context, String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _openCategory(context, name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSearchItem(String text, Color primaryColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.trending_up_rounded, color: primaryColor, size: 18),
      title: Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.north_west_rounded, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }

  void _showDiningMenu(BuildContext context, Color primaryRed) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Campus Dining Outlets", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMenuIcon(Icons.coffee_rounded, "Nescafe", () => _openCategory(context, 'Nescafe'), primaryRed),
                _buildMenuIcon(Icons.local_cafe_rounded, "Lipton", () => _openCategory(context, 'Lipton'), primaryRed),
                _buildMenuIcon(Icons.restaurant_rounded, "Canteen", () => _openCategory(context, 'Canteen'), primaryRed),
                _buildMenuIcon(Icons.apple_rounded, "Juices", () => _openCategory(context, 'Fruit Corner'), primaryRed),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryRed = theme.primaryColor;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildDrawer(context, theme),
      extendBody: true, 
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDiningMenu(context, primaryRed),
        backgroundColor: Colors.black,
        elevation: 10,
        icon: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 20),
        label: Text("DINE-IN MENU", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildDiningBottomNav(theme),
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildDiningAppBar(theme, primaryRed),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showSearchHub(context, primaryRed),
                    child: _buildDiningSearch(primaryRed),
                  ),
                  _buildTopDishesSwapper(primaryRed),
                  Padding(padding: const EdgeInsets.fromLTRB(24, 25, 24, 15), child: Text('What would you like to eat?', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18))),
                  _buildCuisineScroll(primaryRed),
                  _buildPromotionalCarousel(),
                  _buildQuickFilters(primaryRed),
                ],
              ),
            ),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 30, 24, 15), child: Text('Visit Top Campus Hubs', style: theme.textTheme.titleLarge))),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 18, crossAxisSpacing: 18, childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _buildZomatoCategoryCard(theme, 'Nescafe', "assets/images/nescaffe.jpeg", "Premium Hot Brews"),
                  _buildZomatoCategoryCard(theme, 'Lipton', "assets/images/lipton_image.jpeg", "Tea & Quick Bites"),
                  _buildZomatoCategoryCard(theme, 'Canteen', "assets/images/canteen.jpeg", "Full Dining Meals"),
                  _buildZomatoCategoryCard(theme, 'Fruit Corner', "assets/images/fruit_corner.jpeg", "Fresh Health Bar"),
                ]),
              ),
            ),
            _buildTrendingSection(theme, primaryRed),
            const SliverPadding(padding: EdgeInsets.only(bottom: 150)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiningAppBar(ThemeData theme, Color primaryRed) {
    return SliverAppBar(
      pinned: true, expandedHeight: 120, backgroundColor: theme.scaffoldBackgroundColor, elevation: 0,
      leading: IconButton(icon: Icon(Icons.menu_rounded, color: primaryRed), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text("GGI Dining Hub", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
              Icon(Icons.keyboard_arrow_down_rounded, color: primaryRed, size: 18),
            ]),
            Text("Campus Main Block • Open for Dine-in", style: GoogleFonts.poppins(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: CircleAvatar(backgroundColor: primaryRed.withValues(alpha: 0.1), child: Icon(Icons.person_rounded, color: primaryRed, size: 20)),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildDiningSearch(Color primaryRed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: IgnorePointer(
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Search for dishes, coffee, or snacks",
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
              prefixIcon: Icon(Icons.search, color: primaryRed, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopDishesSwapper(Color primaryRed) {
    final List<Map<String, String>> topDishes = [
      {"name": "Masala Maggie", "outlet": "Nescafe", "image": "assets/images/maggie.jpeg", "price": "₹30"},
      {"name": "Ice Tea Lemon", "outlet": "Lipton", "image": "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500", "price": "₹25"},
      {"name": "Bhatura Chana", "outlet": "Canteen", "image": "assets/images/bhatura chana.jpeg", "price": "₹40"},
      {"name": "Mix Fruit Juice", "outlet": "Fruit Corner", "image": "https://images.unsplash.com/photo-1622597467827-43b0ef3c9a22?w=500", "price": "₹40"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 15, 24, 15),
          child: Row(
            children: [
              Text("Top Rated Delights", style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(width: 8),
              Icon(Icons.stars_rounded, color: primaryRed, size: 20),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _dishPageController,
            itemCount: topDishes.length,
            onPageChanged: (index) => setState(() => _currentDishIndex = index),
            itemBuilder: (context, index) {
              final dish = topDishes[index];
              return AnimatedBuilder(
                animation: _dishPageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_dishPageController.position.haveDimensions) {
                    value = _dishPageController.page! - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeInOut.transform(value),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () => _openCategory(context, dish['outlet']!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: dish['image']!.startsWith('assets') ? AssetImage(dish['image']!) as ImageProvider : NetworkImage(dish['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text(dish['outlet']!, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dish['name']!, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text(dish['price']!, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineScroll(Color primaryRed) {
    final List<Map<String, dynamic>> cuisines = [
      {"name": "Burger", "icon": Icons.lunch_dining_rounded},
      {"name": "Pizza", "icon": Icons.local_pizza_rounded},
      {"name": "Coffee", "icon": Icons.coffee_rounded},
      {"name": "Tea", "icon": Icons.emoji_food_beverage_rounded},
      {"name": "Juice", "icon": Icons.liquor_rounded},
      {"name": "Meals", "icon": Icons.flatware_rounded},
    ];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cuisines.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 20),
          child: Column(children: [
            CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(cuisines[index]['icon'], color: primaryRed, size: 28)),
            const SizedBox(height: 8),
            Text(cuisines[index]['name'], style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _buildPromotionalCarousel() {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(top: 20),
      child: PageView(
        children: [
          _buildBanner("Dine-in Combo", "Get 20% OFF on Group Bookings", const Color(0xFF4CAF50)),
          _buildBanner("Instant Coffee", "Pre-order now & skip the queue", const Color(0xFFE91E63)),
        ],
      ),
    );
  }

  Widget _buildBanner(String title, String sub, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          Text(sub, style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildQuickFilters(Color primaryRed) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 25, 0, 10),
      child: Row(children: [
        _buildFilterChip("Available Now", Icons.check_circle_outline_rounded, primaryRed),
        _buildFilterChip("Self-Pickup", Icons.hail_rounded, primaryRed),
        _buildFilterChip("Healthy", Icons.spa_outlined, primaryRed),
      ]),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildTrendingSection(ThemeData theme, Color primaryRed) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 40, 24, 15), child: Text('Must Try on Campus ✨', style: theme.textTheme.titleLarge)),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _allFoodItems.length,
            itemBuilder: (context, index) {
              final item = _allFoodItems[index];
              return Container(
                width: 150, margin: const EdgeInsets.only(right: 15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: item.imageUrl, height: 150, width: 150, fit: BoxFit.cover)),
                  const SizedBox(height: 8),
                  Text(item.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                  Text("₹${item.price}", style: GoogleFonts.poppins(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 12)),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildDiningBottomNav(ThemeData theme) {
    return Container(
      height: 75,
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildNavItem(theme, 0, Icons.flatware_rounded, "Dining"),
        _buildNavItem(theme, 1, Icons.bolt_rounded, "Quick Picks"),
        _buildNavItem(theme, 2, Icons.hub_outlined, "Campus Hub"),
        _buildNavItem(theme, 3, Icons.person_rounded, "Account"),
      ]),
    );
  }

  Widget _buildNavItem(ThemeData theme, int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (label == "Account") Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        if (label == "Campus Hub") Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        if (label == "Quick Picks") Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: isSelected ? theme.primaryColor : Colors.grey[400], size: 24),
        Text(label, style: GoogleFonts.poppins(color: isSelected ? theme.primaryColor : Colors.grey[400], fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  Widget _buildZomatoCategoryCard(ThemeData theme, String title, String imagePath, String subtitle) {
    return GestureDetector(
      onTap: () => _openCategory(context, title),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity))),
        const SizedBox(height: 10),
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(children: [
        DrawerHeader(decoration: BoxDecoration(color: theme.primaryColor), child: Center(child: Text("GLOBAL EATS", style: GoogleFonts.metamorphous(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
        ListTile(leading: Icon(Icons.settings_outlined, color: theme.primaryColor), title: const Text("Settings"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        const Spacer(),
        ListTile(leading: const Icon(Icons.logout_rounded, color: Colors.red), title: const Text("Logout"), onTap: () async {
          await context.read<AuthService>().logout();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OperatorUserScreen()), (_) => false);
        }),
        const SizedBox(height: 20),
      ]),
    );
  }
}
