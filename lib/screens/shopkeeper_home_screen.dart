import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:integrated_agri_hub/services/user_service.dart';
import 'package:integrated_agri_hub/services/translation_service.dart';
import 'package:integrated_agri_hub/screens/welcome_screen.dart';

const _kGreen = Color(0xFF4A7C59);
const _kDarkGreen = Color(0xFF2A5934);
const _kCream = Color(0xFFF9F6F0);
const _kLightGreen = Color(0xFFF0F5E8);

class ShopkeeperHomeScreen extends StatefulWidget {
  const ShopkeeperHomeScreen({super.key});
  @override
  State<ShopkeeperHomeScreen> createState() => _ShopkeeperHomeScreenState();
}

class _ShopkeeperHomeScreenState extends State<ShopkeeperHomeScreen> {
  int _currentIndex = 0;
  String _shopName = 'Loading...';
  String _shopEmail = '';
  int _greenCoinsReceived = 0;
  double _todaySales = 0.0; // Dummy value or fetched

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('shopkeepers').doc(user.uid).get();
      if (!doc.exists) {
        doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      }
      if (mounted && doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _shopName = data['fullName'] ?? 'Shopkeeper';
          _shopEmail = data['email'] ?? user.email ?? '';
          _greenCoinsReceived = (data['greenCoinsReceived'] as num?)?.toInt() ?? 0;
          _todaySales = (data['todaySales'] as num?)?.toDouble() ?? 0.0;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      UserService().clearCache();
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()), 
          (route) => false,
        );
      }
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0: return _HomeView(shopName: _shopName, greenCoins: _greenCoinsReceived, todaySales: _todaySales, onLogout: _logout);
      case 1: return const _MarketView();
      case 2: return const _HistoryView();
      case 3: return _MyQRView(shopName: _shopName);
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TranslationService(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _kCream,
          body: _buildCurrentScreen(),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            elevation: 12,
            shadowColor: Colors.black26,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                  _buildNavItem(Icons.storefront_outlined, Icons.storefront, 'Market', 1),
                  _buildNavItem(Icons.history_outlined, Icons.history, 'History', 2),
                  _buildNavItem(Icons.qr_code_outlined, Icons.qr_code, 'My QR', 3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final sel = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sel ? activeIcon : icon, color: sel ? _kGreen : Colors.grey.shade400, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: sel ? _kGreen : Colors.grey.shade400, fontWeight: sel ? FontWeight.bold : FontWeight.w500, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// === HOME VIEW ===
class _HomeView extends StatelessWidget {
  final String shopName;
  final int greenCoins;
  final double todaySales;
  final VoidCallback onLogout;

  const _HomeView({required this.shopName, required this.greenCoins, required this.todaySales, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back,', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text('$shopName \u{1F4C8}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: onLogout,
                )
              ],
            ),
            const SizedBox(height: 32),
            
            // Metrics
            Row(
              children: [
                Expanded(child: _metricCard('Today\'s Sales', '₹ ${todaySales.toStringAsFixed(0)}', Icons.trending_up, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _metricCard('Total Green Coins', '$greenCoins 🌿', Icons.eco, _kGreen)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _kDarkGreen)),
        ],
      ),
    );
  }
}

// === MARKET VIEW ===
class _MarketView extends StatefulWidget {
  const _MarketView();
  @override
  State<_MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<_MarketView> {
  // Dummy CSV data for agricultural products
  final List<Map<String, dynamic>> _products = [
    {'name': 'Neem Coated Urea (45kg)', 'price': 266, 'discountPercent': 10},
    {'name': 'DAP Fertilizer (50kg)', 'price': 1350, 'discountPercent': 15},
    {'name': 'Trichoderma Viride (1kg)', 'price': 120, 'discountPercent': 20},
    {'name': 'Cotton Seeds (Bt)', 'price': 850, 'discountPercent': 5},
    {'name': 'Drip Irrigation Pipe (Bundle)', 'price': 2500, 'discountPercent': 60},
  ];

  void _updateDiscount(int index, double val) {
    setState(() {
      _products[index]['discountPercent'] = val.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Market & Discounts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('Set the max Green Coin discount (up to 60%) for each CSV product.', style: TextStyle(color: Colors.black54, fontSize: 13)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final prod = _products[index];
                final discount = prod['discountPercent'] as int;
                final discountAmt = (prod['price'] * discount / 100).toStringAsFixed(0);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(prod['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _kDarkGreen))),
                          Text('₹ ${prod['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Accept up to $discount% in Green Coins (Save ₹ $discountAmt)', style: const TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('0%'),
                          Expanded(
                            child: Slider(
                              value: discount.toDouble(),
                              min: 0,
                              max: 60, // Maximum 60% as requested
                              divisions: 60,
                              activeColor: _kGreen,
                              label: '$discount%',
                              onChanged: (val) => _updateDiscount(index, val),
                            ),
                          ),
                          const Text('60%'),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// === HISTORY VIEW ===
class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    // PhonePe style history
    final dummyTransactions = [
      {'name': 'Ramesh Patil', 'time': 'Today, 2:30 PM', 'coins': 150, 'rs': 15},
      {'name': 'Suresh Kumar', 'time': 'Today, 11:15 AM', 'coins': 300, 'rs': 30},
      {'name': 'Dinesh Singh', 'time': 'Yesterday, 5:45 PM', 'coins': 50, 'rs': 5},
      {'name': 'Anil Sharma', 'time': 'Yesterday, 1:20 PM', 'coins': 420, 'rs': 42},
      {'name': 'Prakash Rao', 'time': '21 Sep 2026, 9:00 AM', 'coins': 120, 'rs': 12},
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Transaction History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: dummyTransactions.length,
              itemBuilder: (context, index) {
                final tx = dummyTransactions[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: _kLightGreen,
                        child: Text(tx['name'].toString().substring(0, 1), style: const TextStyle(color: _kGreen, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(tx['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(tx['time'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+${tx['coins']} 🌿', style: const TextStyle(color: _kGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Value: ₹ ${tx['rs']}', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Divider(height: 16),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// === MY QR VIEW ===
class _MyQRView extends StatelessWidget {
  final String shopName;
  const _MyQRView({required this.shopName});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_shop_id';
    final qrData = jsonEncode({'shopUid': uid, 'shopName': shopName});

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Store QR Code', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              const SizedBox(height: 16),
              const Text('Farmers will scan this QR Code from their app to instantly transfer Green Coins to your wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: _kGreen.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)],
                  border: Border.all(color: _kLightGreen, width: 4),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: _kDarkGreen),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: _kGreen),
                ),
              ),
              const SizedBox(height: 32),
              Text(shopName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              const SizedBox(height: 8),
              const Text('Show this to accept Green Coins', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
