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
    final primaryOrange = theme.primaryColor;
    final secondaryBlue = theme.colorScheme.secondary;
    final textColor = theme.colorScheme.onSurface;

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
                  expandedHeight: 200,
                  backgroundColor: Colors.white,
                  iconTheme: IconThemeData(color: textColor),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      widget.outletName == null ? 'GLOBAL CART' : '${widget.outletName!.toUpperCase()} ITEMS',
                      style: GoogleFonts.poppins(color: textColor, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    background: CachedNetworkImage(imageUrl: _getOutletImage(), fit: BoxFit.cover),
                  ),
                ),
                if (items.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('Cart is empty. Time to refill!', style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cartItem = items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: Row(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(imageUrl: cartItem.foodItem.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(cartItem.foodItem.name, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('₹${cartItem.foodItem.price}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                ]),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(children: [
                                  IconButton(icon: Icon(Icons.remove, size: 16, color: primaryOrange), onPressed: () => cart.removeSingleItem(cartItem.foodItem.id)),
                                  Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(icon: Icon(Icons.add, size: 16, color: primaryOrange), onPressed: () => cart.addItem(cartItem.foodItem)),
                                ]),
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
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('To Pay', style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w800, fontSize: 18)),
                          Text('₹${totalAmount.toStringAsFixed(2)}', style: GoogleFonts.poppins(color: secondaryBlue, fontSize: 20, fontWeight: FontWeight.w900)),
                        ]),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (Platform.isAndroid || Platform.isIOS) {
                                _openCheckout(totalAmount);
                              } else {
                                final error = await cart.placeOrder(specificOutlet: widget.outletName);
                                if (error == null) {
                                  Fluttertoast.showToast(msg: "Order Placed! Arriving soon.");
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text('PROCEED TO PAY'),
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
}
