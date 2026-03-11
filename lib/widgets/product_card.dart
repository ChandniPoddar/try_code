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
    final primaryColor = theme.primaryColor;
    final textColor = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  foodItem.imageUrl.isEmpty
                      ? _buildPlaceholder(primaryColor)
                      : foodItem.imageUrl.startsWith('assets')
                          ? Image.asset(foodItem.imageUrl, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: foodItem.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: theme.scaffoldBackgroundColor.withValues(alpha: 0.1)),
                              errorWidget: (context, url, error) => _buildPlaceholder(primaryColor),
                            ),
                  // Stylish Price Tag
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '₹${foodItem.price}',
                        style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      foodItem.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: textColor.withValues(alpha: 0.6), fontSize: 10),
                    ),
                  ),

                  // Add to Cart Button - Themed
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        context.read<CartProvider>().addItem(foodItem);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: primaryColor,
                            content: Text(
                              '${foodItem.name} added to cart',
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.fastfood_rounded, color: color.withValues(alpha: 0.3), size: 40),
    );
  }
}
