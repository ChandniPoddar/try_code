import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ggi_canteen/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartScreen extends StatefulWidget {
  final String? outletName; 

  const CartScreen({super.key, this.outletName});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late Razorpay _razorpay;
  late AnimationController _controller;
  late Animation<double> _fade;

  final String razorpayKey = 'rzp_test_SAodWBg2uq2dkh'; 

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  String _getOutletImage() {
    switch (widget.outletName) {
      case 'Nescafe':
        return "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=2070&auto=format&fit=crop";
      case 'Lipton':
        return "https://images.unsplash.com/photo-1544787210-2213d84ad960?q=80&w=1974&auto=format&fit=crop";
      case 'Canteen':
        return "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1974&auto=format&fit=crop";
      case 'Fruit Corner':
        return "https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=2070&auto=format&fit=crop";
      default:
        return "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?q=80&w=1974&auto=format&fit=crop";
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _controller.dispose();
    super.dispose();
  }

  void _openCheckout(double amount) {
    var options = {
      'key': razorpayKey,
      'amount': (amount * 100).toInt(),
      'name': widget.outletName ?? 'Global Eats',
      'description': 'Payment for Order',
      'prefill': {'contact': '9876543210', 'email': 'user@globaleats.com'},
      'external': {'wallets': ['paytm']}
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final cart = context.read<CartProvider>();
    final error = await cart.placeOrder(specificOutlet: widget.outletName);

    if (error == null) {
      Fluttertoast.showToast(msg: "Payment Successful! Order placed.");
      if (!mounted) return;
      Navigator.pop(context); 
    } else {
      Fluttertoast.showToast(msg: "Order Database Error: $error");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = textColor.withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final items = widget.outletName == null 
              ? cart.items.values.toList()
              : cart.items.values.where((item) => cart.getNormalizedOutlet(item.foodItem.category) == widget.outletName).toList();

          final totalAmount = items.fold(0.0, (sum, item) => sum + (item.foodItem.price * item.quantity));

          return FadeTransition(
            opacity: _fade,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 240,
                  backgroundColor: theme.appBarTheme.backgroundColor,
                  iconTheme: theme.appBarTheme.iconTheme,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      widget.outletName == null ? 'GLOBAL CART' : '${widget.outletName!.toUpperCase()} CART',
                      style: GoogleFonts.monoton(color: primaryColor, fontSize: 16, letterSpacing: 2),
                    ),
                    background: Stack(fit: StackFit.expand, children: [
                      CachedNetworkImage(imageUrl: _getOutletImage(), fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.scaffoldBackgroundColor.withValues(alpha: 0.2),
                              Colors.transparent,
                              theme.scaffoldBackgroundColor
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                if (items.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 80, color: primaryColor.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text('Your cart is clear and elegant.', style: GoogleFonts.poppins(color: subTextColor, fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cartItem = items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: primaryColor.withValues(alpha: 0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Row(children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 10)]
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: CachedNetworkImage(
                                    imageUrl: cartItem.foodItem.imageUrl,
                                    width: 85,
                                    height: 85,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Icon(Icons.fastfood, color: primaryColor, size: 30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(cartItem.foodItem.name, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('₹${cartItem.foodItem.price} per unit', style: GoogleFonts.poppins(color: subTextColor, fontSize: 13)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildQuantityBtn(Icons.remove, () => cart.removeSingleItem(cartItem.foodItem.id), theme),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Text('${cartItem.quantity}', style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                      _buildQuantityBtn(Icons.add, () => cart.addItem(cartItem.foodItem), theme),
                                    ],
                                  ),
                                ]),
                              ),
                              Text(
                                '₹${(cartItem.foodItem.price * cartItem.quantity).toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ]),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),
                if (items.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.15), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 25, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Order Total', style: GoogleFonts.poppins(color: subTextColor, fontSize: 16, fontWeight: FontWeight.w500)),
                          Text('₹${totalAmount.toStringAsFixed(2)}', style: GoogleFonts.poppins(color: primaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (Platform.isAndroid || Platform.isIOS) {
                                _openCheckout(totalAmount);
                              } else {
                                final error = await cart.placeOrder(specificOutlet: widget.outletName);
                                if (error == null) {
                                  Fluttertoast.showToast(msg: "Order Placed! Bon Appétit.");
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text('COMPLETE PAYMENT'),
                          ),
                        ),
                      ]),
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.primaryColor, size: 18),
      ),
    );
  }
}
