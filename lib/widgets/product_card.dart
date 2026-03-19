import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ggi_canteen/models/food_item.dart';
import 'package:ggi_canteen/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final FoodItem foodItem;

  const ProductCard({
    super.key,
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryRed = theme.primaryColor;
    final textColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌟 Dashing Image Section with Badges
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: foodItem.imageUrl.startsWith('assets')
                      ? Image.asset(foodItem.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                      : CachedNetworkImage(imageUrl: foodItem.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                // Veg Indicator (Zomato Style)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 1.5), borderRadius: BorderRadius.circular(4)),
                    child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  ),
                ),
                // Rating Badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        Text("4.2", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, color: Colors.green, size: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🌟 Professional Info Section
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    foodItem.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${foodItem.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      // 🌟 Unique Zomato-style "ADD" Button
                      GestureDetector(
                        onTap: () {
                          context.read<CartProvider>().addItem(foodItem);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.black87,
                              content: Text('${foodItem.name} added to cart', style: const TextStyle(fontWeight: FontWeight.bold)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryRed.withValues(alpha: 0.2)),
                            boxShadow: [BoxShadow(color: primaryRed.withValues(alpha: 0.1), blurRadius: 8)],
                          ),
                          child: Text(
                            "ADD",
                            style: GoogleFonts.poppins(color: primaryRed, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
