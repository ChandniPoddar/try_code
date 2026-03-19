import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';
import '../../providers/cart_provider.dart';
import 'cart_screen.dart';

class CanteenScreen extends StatefulWidget {
  const CanteenScreen({super.key});

  @override
  State<CanteenScreen> createState() => _CanteenScreenState();
}

class _CanteenScreenState extends State<CanteenScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryRed = theme.primaryColor;

    final List<FoodItem> canteenItems = [
      FoodItem(id: 'c1', name: 'Sandwich Plain', category: 'Canteen', description: 'Freshly sliced healthy vegetable sandwich', price: 20, imageUrl: 'assets/images/grill sandwich.jpeg'),
      FoodItem(id: 'c2', name: 'Sandwich Grilled', category: 'Canteen', description: 'Buttery toasted gourmet grilled sandwich', price: 30, imageUrl: 'assets/images/grill sandwich.jpeg'),
      FoodItem(id: 'c3', name: 'White Sauce Pasta', category: 'Canteen', description: 'Creamy Italian style white sauce pasta', price: 40, imageUrl: 'assets/images/pasta.jpeg'),
      FoodItem(id: 'c4', name: 'Noodles (Full)', category: 'Canteen', description: 'Stir-fried street style hakka noodles', price: 60, imageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=1984&auto=format&fit=crop'),
      FoodItem(id: 'c6', name: 'Classic Samosa', category: 'Canteen', description: 'Crispy golden fried potato pastry', price: 10, imageUrl: 'assets/images/samosa.jpeg'),
      FoodItem(id: 'c10', name: 'Bhatura Chana', category: 'Canteen', description: 'Fluffy fried bread with spicy curry', price: 40, imageUrl: 'assets/images/bhatura chana.jpeg'),
      FoodItem(id: 'c13', name: 'Premium Burger', category: 'Canteen', description: 'Juicy vegetable patty with fresh salad', price: 40, imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?q=80&w=2072&auto=format&fit=crop'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final canteenCount = cart.items.values.where((item) => cart.getNormalizedOutlet(item.foodItem.category) == 'Canteen').length;
          if (canteenCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: primaryRed,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen(outletName: 'Canteen'))),
            icon: const Icon(Icons.shopping_basket_rounded, color: Colors.white),
            label: Text(
              'View Cart ($canteenCount)',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true, expandedHeight: 220, backgroundColor: Colors.white, elevation: 0,
              iconTheme: IconThemeData(color: primaryRed),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text('CANTEEN MENU', style: GoogleFonts.metamorphous(color: primaryRed, fontSize: 18, fontWeight: FontWeight.bold)),
                background: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/canteen.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[100], child: Icon(Icons.restaurant, color: primaryRed, size: 50))),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.8), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Text('Dashing Campus Bites', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.75, mainAxisSpacing: 16, crossAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) => ProductCard(foodItem: canteenItems[index]), childCount: canteenItems.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
