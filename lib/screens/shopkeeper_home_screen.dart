import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_agri_hub/screens/qr_scanner_screen.dart';
import 'package:integrated_agri_hub/services/user_service.dart';
import 'package:integrated_agri_hub/services/translation_service.dart';

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
  String _shopState = '';
  String _shopAddress = '';
  String _shopLicense = '';

  double _todaySales = 0.0;
  int _greenCoinsReceived = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check shopkeepers collection first, fallback to users
      var doc = await FirebaseFirestore.instance.collection('shopkeepers').doc(user.uid).get();
      if (!doc.exists) {
        doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      }
      if (mounted && doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _shopName = data['fullName'] ?? 'Shopkeeper';
          _shopEmail = data['email'] ?? user.email ?? '';
          _shopState = data['state'] ?? 'Maharashtra';
          _shopAddress = data['shopAddress'] ?? '';
          _shopLicense = data['shopLicense'] ?? '';
          _greenCoinsReceived = (data['greenCoinsReceived'] as num?)?.toInt() ?? 0;
        });
      }
    }
  }

  final List<Map<String, dynamic>> _ledgerEntries = [];

  void _addLedgerEntry(Map<String, dynamic> entry, double amount) {
    setState(() {
      _ledgerEntries.insert(0, entry);
      _todaySales += amount;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0: return _HomeView(
          todaySales: _todaySales,
          shopName: _shopName,
          shopEmail: _shopEmail,
          shopState: _shopState,
          shopAddress: _shopAddress,
          shopLicense: _shopLicense,
          greenCoinsReceived: _greenCoinsReceived,
        );
      case 1: return const _InventoryView();
      case 2: return _LedgerView(entries: _ledgerEntries, onAddEntry: _addLedgerEntry);
      case 3: return const _ScanSubsidyView();
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
                  _buildNavItem(Icons.home_outlined, Icons.home, TranslationService.tr('home'), 0),
                  _buildNavItem(Icons.inventory_2_outlined, Icons.inventory_2, TranslationService.tr('inventory'), 1),
                  _buildNavItem(Icons.menu_book_outlined, Icons.menu_book, TranslationService.tr('ledger'), 2),
                  _buildNavItem(Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, TranslationService.tr('scan'), 3),
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
            Text(label,
                style: TextStyle(
                    color: sel ? _kGreen : Colors.grey.shade400,
                    fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

void _showShopkeeperProfile({
  required BuildContext context,
  required String shopName,
  required String shopEmail,
  required String shopState,
  required String shopAddress,
  required String shopLicense,
  required int greenCoinsReceived,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, sc) => _ShopkeeperProfileModal(
        scrollController: sc,
        shopName: shopName,
        shopEmail: shopEmail,
        shopState: shopState,
        shopAddress: shopAddress,
        shopLicense: shopLicense,
        greenCoinsReceived: greenCoinsReceived,
      ),
    ),
  );
}

class _ShopkeeperProfileModal extends StatefulWidget {
  final ScrollController? scrollController;
  final String shopName;
  final String shopEmail;
  final String shopState;
  final String shopAddress;
  final String shopLicense;
  final int greenCoinsReceived;

  const _ShopkeeperProfileModal({
    this.scrollController,
    required this.shopName,
    required this.shopEmail,
    required this.shopState,
    required this.shopAddress,
    required this.shopLicense,
    required this.greenCoinsReceived,
  });

  @override
  State<_ShopkeeperProfileModal> createState() => _ShopkeeperProfileModalState();
}

class _ShopkeeperProfileModalState extends State<_ShopkeeperProfileModal> {
  bool _isEditing = false;
  late String _selectedState;
  final _states = ['Maharashtra', 'Punjab', 'Kerala', 'Other'];
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.shopState;
    _addressCtrl = TextEditingController(text: widget.shopAddress);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('shopkeepers').doc(user.uid).update({
        'state': _selectedState,
        'shopAddress': _addressCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store profile updated successfully!'),
            backgroundColor: _kGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Store QR Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
            const SizedBox(height: 24),
            Container(width: 200, height: 200, color: Colors.black, child: const Icon(Icons.qr_code, color: Colors.white, size: 150)),
            const SizedBox(height: 24),
            Text('Scan this to place a direct order with ${widget.shopName}.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _card({String? title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kDarkGreen)),
          const SizedBox(height: 16),
        ],
        ...children,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 20, color: _kGreen), const SizedBox(width: 12),
      Expanded(flex: 1, child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13))),
      Expanded(flex: 2, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: _kDarkGreen), textAlign: TextAlign.right)),
    ]);
  }

  Widget _dropRow(IconData icon, String label, String value, List<String> items, void Function(String?) onChanged) {
    return Row(children: [
      Icon(icon, size: 20, color: _kGreen), const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13))),
      DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontWeight: FontWeight.bold, color: _kDarkGreen)))).toList(),
        onChanged: onChanged,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Shopkeeper Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              TextButton.icon(
                onPressed: () {
                  if (_isEditing) {
                    _saveProfile();
                  }
                  setState(() => _isEditing = !_isEditing);
                },
                icon: Icon(_isEditing ? Icons.check_circle : Icons.edit, size: 16, color: _kGreen),
                label: Text(_isEditing ? 'Save' : 'Edit Profile', style: const TextStyle(color: _kGreen, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const SizedBox(height: 8),

          _card(children: [
            Row(children: [
              const CircleAvatar(radius: 30, backgroundColor: _kLightGreen, child: Icon(Icons.storefront, size: 32, color: _kGreen)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(widget.shopName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: _kGreen, size: 22),
                    onPressed: () => _showQr(context),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                ]),
                Text(widget.shopEmail, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20), border: Border.all(color: _kGreen.withValues(alpha: 0.4))),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified_user, size: 12, color: _kGreen), SizedBox(width: 4),
                    Text('License Verified', style: TextStyle(fontSize: 11, color: _kGreen, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ])),
            ]),
          ]),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]), borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.account_balance, color: Colors.white, size: 22), SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Bank Account Linked', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Settlements are processed directly to your linked bank.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ])),
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          _card(title: 'Store Details', children: [
            _isEditing
              ? _dropRow(Icons.map_outlined, 'State', _selectedState, _states, (v) => setState(() => _selectedState = v!))
              : _infoRow(Icons.map_outlined, 'State', _selectedState),
            const Divider(height: 20),
            _isEditing
              ? Row(children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: _kGreen), const SizedBox(width: 12),
                  const Expanded(flex: 1, child: Text('Address', style: TextStyle(color: Colors.black54, fontSize: 13))),
                  Expanded(flex: 2, child: TextField(controller: _addressCtrl, style: const TextStyle(fontWeight: FontWeight.bold, color: _kDarkGreen, fontSize: 13), textAlign: TextAlign.right, decoration: const InputDecoration(isDense: true))),
                ])
              : _infoRow(Icons.location_on_outlined, 'Address', _addressCtrl.text.isEmpty ? 'Not Provided' : _addressCtrl.text),
            const Divider(height: 20),
            _infoRow(Icons.assignment_outlined, 'License Number', widget.shopLicense.isEmpty ? 'Not Provided' : widget.shopLicense),
            const Divider(height: 20),
            _infoRow(Icons.people_outline, 'Connected Farmers', '142 Active'),
          ]),

          // 🌿 Green Coin Wallet Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4A7C59)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                  child: const Icon(Icons.eco, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Green Coin Wallet', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('${widget.greenCoinsReceived} Coins', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('Coins received from farmer redemptions', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ]),
                ),
              ],
            ),
          ),

          _card(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              onTap: () async {
                UserService().clearCache();
                await FirebaseAuth.instance.signOut();
                // AuthGate will automatically redirect to WelcomeScreen
              },
            ),
          ]),
        ],
      ),
    );
  }
}

// === HOME VIEW ===
class _HomeView extends StatelessWidget {
  final double todaySales;
  final String shopName;
  final String shopEmail;
  final String shopState;
  final String shopAddress;
  final String shopLicense;
  final int greenCoinsReceived;

  const _HomeView({
    required this.todaySales,
    required this.shopName,
    required this.shopEmail,
    required this.shopState,
    required this.shopAddress,
    required this.shopLicense,
    required this.greenCoinsReceived,
  });

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
                GestureDetector(
                  onTap: () => _showShopkeeperProfile(
                    context: context,
                    shopName: shopName,
                    shopEmail: shopEmail,
                    shopState: shopState,
                    shopAddress: shopAddress,
                    shopLicense: shopLicense,
                    greenCoinsReceived: greenCoinsReceived,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome back,', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text('$shopName \u{1F4C8}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showShopkeeperProfile(
                    context: context,
                    shopName: shopName,
                    shopEmail: shopEmail,
                    shopState: shopState,
                    shopAddress: shopAddress,
                    shopLicense: shopLicense,
                    greenCoinsReceived: greenCoinsReceived,
                  ),
                  child: const CircleAvatar(
                    backgroundColor: _kLightGreen,
                    radius: 24,
                    child: Icon(Icons.storefront, color: _kGreen),
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            
            // Metrics
            Row(
              children: [
                Expanded(child: _metricCard('Today\'s Sales', '\u20b9 ${todaySales.toStringAsFixed(0)}', Icons.trending_up, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _metricCard('Green Coins', '$greenCoinsReceived 🌿', Icons.eco, _kGreen)),
              ],
            ),
            const SizedBox(height: 32),

            // Demand Insights
            const Text('Local Demand Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('High Demand Alert!', style: TextStyle(fontWeight: FontWeight.bold, color: _kDarkGreen)),
                        SizedBox(height: 4),
                        Text('70% of farmers in your 10km radius have planted Cotton. Stock up on Fall Armyworm pesticides.', style: TextStyle(color: Colors.black87, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Active Subsidies
            const Text('Active Govt Subsidies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
            const SizedBox(height: 16),
            _subsidyCard('Neem Coated Urea', '50% Govt Subsidy (DBT) applicable for small farmers.', Icons.agriculture),
            _subsidyCard('Drip Irrigation Pipes', '80% State Subsidy. Verify Farmer ID to process.', Icons.water_drop),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _kDarkGreen)),
        ],
      ),
    );
  }

  Widget _subsidyCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kLightGreen, borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white, child: Icon(icon, color: _kGreen)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: _kDarkGreen)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// === INVENTORY VIEW ===
class _InventoryView extends StatefulWidget {
  const _InventoryView();
  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  final List<Map<String, dynamic>> _inventory = [];

  void _showAddEditProductDialog({Map<String, dynamic>? product, int? index}) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(text: product?['price'] ?? '');
    final stockController = TextEditingController(text: product != null ? product['stock'].toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product', style: const TextStyle(color: _kDarkGreen, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (\u20b9)'), keyboardType: TextInputType.number),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Initial Stock Quantity'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newProduct = {
                'name': nameController.text,
                'price': priceController.text,
                'stock': int.tryParse(stockController.text) ?? 0,
                'lowStock': (int.tryParse(stockController.text) ?? 0) < 10,
              };

              setState(() {
                if (index != null) {
                  _inventory[index] = newProduct;
                } else {
                  _inventory.insert(0, newProduct);
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kGreen),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Inventory Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _inventory.length,
                itemBuilder: (context, index) {
                  final item = _inventory[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: item['lowStock'] ? Border.all(color: Colors.redAccent.withValues(alpha: 0.5)) : null,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: _kLightGreen, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.inventory_2, color: _kGreen),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _kDarkGreen)),
                              const SizedBox(height: 4),
                              Text('\u20b9 ${item['price']} / unit', style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.inventory, size: 14, color: item['lowStock'] ? Colors.redAccent : Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Stock: ${item['stock']}', style: TextStyle(color: item['lowStock'] ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: _kGreen),
                          onPressed: () => _showAddEditProductDialog(product: item, index: index),
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEditProductDialog,
        backgroundColor: _kGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// === LEDGER VIEW ===
class _LedgerView extends StatefulWidget {
  final List<Map<String, dynamic>> entries;
  final void Function(Map<String, dynamic>, double) onAddEntry;
  const _LedgerView({required this.entries, required this.onAddEntry});

  @override
  State<_LedgerView> createState() => _LedgerViewState();
}

class _LedgerViewState extends State<_LedgerView> {
  void _showAddEntryDialog() {
    final farmerController = TextEditingController();
    final itemsController = TextEditingController();
    final discountController = TextEditingController();
    final totalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Ledger Entry', style: TextStyle(color: _kDarkGreen, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: farmerController, decoration: const InputDecoration(labelText: 'Farmer Name')),
              TextField(controller: itemsController, decoration: const InputDecoration(labelText: 'Items Bought (e.g. 2x Urea)')),
              TextField(controller: discountController, decoration: const InputDecoration(labelText: 'Discount Applied (e.g. \u20b9 50)')),
              TextField(controller: totalController, decoration: const InputDecoration(labelText: 'Total Amount (\u20b9)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(totalController.text) ?? 0.0;
              widget.onAddEntry({
                'date': 'Today',
                'farmer': farmerController.text.isEmpty ? 'Unknown Farmer' : farmerController.text,
                'items': itemsController.text.isEmpty ? 'General Items' : itemsController.text,
                'discount': discountController.text.isEmpty ? 'None' : discountController.text,
                'total': '\u20b9 ${totalController.text.isEmpty ? '0' : totalController.text}',
                'amount': amt,
              }, amt);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kGreen),
            child: const Text('Save Entry', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Digital Ledger', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: widget.entries.length,
                itemBuilder: (context, index) {
                  final entry = widget.entries[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry['date'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: _kLightGreen, borderRadius: BorderRadius.circular(12)),
                              child: const Text('Completed', style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const CircleAvatar(radius: 16, backgroundColor: _kCream, child: Icon(Icons.person, size: 16, color: _kGreen)),
                            const SizedBox(width: 12),
                            Text(entry['farmer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _kDarkGreen)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Items: ${entry['items']}', style: const TextStyle(color: Colors.black87)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Discount: ${entry['discount']}', style: const TextStyle(color: Colors.orange, fontSize: 13)),
                            Text('Total: ${entry['total']}', style: const TextStyle(fontWeight: FontWeight.bold, color: _kDarkGreen, fontSize: 16)),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        backgroundColor: _kGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// === SCAN & SUBSIDY VIEW ===
class _ScanSubsidyView extends StatelessWidget {
  const _ScanSubsidyView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(color: _kLightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.qr_code_scanner, size: 80, color: _kGreen),
              ),
              const SizedBox(height: 32),
              const Text('Verify & Apply Subsidy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              const SizedBox(height: 16),
              const Text('Scan a farmer\'s digital ID or a product QR code to verify authenticity and process government subsidies.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text('Open Scanner', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: _kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen()));
                    if (result != null && context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(
                            children: [
                              Icon(Icons.verified, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Verified', style: TextStyle(color: _kDarkGreen)),
                            ],
                          ),
                          content: Text('Scanned Data: $result\n\nSubsidy successfully applied to this transaction.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK', style: TextStyle(color: _kGreen, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
