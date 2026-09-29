import re

with open(r'd:\integrated_agri_hub\lib\screens\farmer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

replacement_market_view = """// === MARKET VIEW ===
class _MarketView extends StatefulWidget {
  const _MarketView();
  @override
  State<_MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<_MarketView> {
  String _searchQuery = '';
  String? _selectedDistrict;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _shopkeeperProducts = [];

  final _districts = [
    "Ahmednagar", "Akola", "Amravati", "Chhatrapati Sambhajinagar", "Beed", "Bhandara", "Buldhana", "Chandrapur", "Dhule", "Gadchiroli", "Gondia", "Hingoli", "Jalgaon", "Jalna", "Kolhapur", "Latur", "Mumbai City", "Mumbai Suburban", "Nagpur", "Nanded", "Nandurbar", "Nashik", "Osmanabad", "Palghar", "Parbhani", "Pune", "Raigad", "Ratnagiri", "Sangli", "Satara", "Sindhudurg", "Solapur", "Thane", "Wardha", "Washim", "Yavatmal"
  ];

  @override
  void initState() {
    super.initState();
    _loadShopkeeperProducts();
  }

  void _loadShopkeeperProducts() async {
    final db = FirebaseFirestore.instance;
    // 1. Get all shopkeepers
    final shopkeepersSnap = await db.collection('users').where('role', isEqualTo: 'shopkeeper').get();
    final shopkeepers = shopkeepersSnap.docs;
    
    // 2. Get all market prices (Master Products)
    final marketSnap = await db.collection('market_prices').get();
    final marketPrices = {for (var doc in marketSnap.docs) doc.id: doc.data()};

    // 3. Get all shopkeeper inventories
    final invSnap = await db.collection('shopkeeper_inventory').get();
    
    List<Map<String, dynamic>> productsList = [];
    
    for (var inv in invSnap.docs) {
      final invData = inv.data();
      final String shopkeeperId = invData['shopkeeper_id'] ?? '';
      final String productId = invData['product_id'] ?? '';
      final int discount = (invData['discountPercent'] as num?)?.toInt() ?? 0;
      
      final shop = shopkeepers.where((s) => s.id == shopkeeperId).firstOrNull;
      final market = marketPrices[productId];
      
      if (shop != null && market != null && discount > 0) {
        final originalPrice = (market['currentPrice'] as num).toDouble();
        final discountedPrice = originalPrice - (originalPrice * discount / 100);
        
        productsList.add({
          'id': inv.id, // inventory id
          'shopkeeper_id': shopkeeperId,
          'shop_name': shop.data()['fullName'] ?? 'Shop',
          'district': shop.data()['district'] ?? 'Maharashtra',
          'product_id': productId,
          'cropName': market['cropName'] ?? '',
          'original_price': originalPrice,
          'discount': discount,
          'discounted_price': discountedPrice,
        });
      }
    }

    if (mounted) {
      setState(() {
        _shopkeeperProducts = productsList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    final filtered = _shopkeeperProducts.where((item) {
      final matchesDist = _selectedDistrict == null || item['district'] == _selectedDistrict;
      final matchesQuery = _searchQuery.isEmpty ||
          (item['cropName'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item['shop_name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesDist && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: _kCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Local Shopkeeper Offers',
            style: TextStyle(color: _kDarkGreen, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDistrict,
                    isExpanded: true,
                    hint: const Row(children: [
                      Icon(Icons.map_outlined, size: 18, color: _kGreen), SizedBox(width: 8),
                      Text('Select your district...', style: TextStyle(color: Colors.black54, fontSize: 14)),
                    ]),
                    icon: const Icon(Icons.keyboard_arrow_down, color: _kGreen),
                    items: _districts.map((d) => DropdownMenuItem(
                      value: d,
                      child: Row(children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: _kGreen), const SizedBox(width: 8),
                        Text(d, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                    )).toList(),
                    onChanged: (v) => setState(() { _selectedDistrict = v; _searchQuery = ''; }),
                  ),
                ),
              ),
              if (_selectedDistrict != null) ...[
                const SizedBox(height: 10),
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search products or shops in $_selectedDistrict...',
                    prefixIcon: const Icon(Icons.search, color: _kGreen, size: 20),
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDistrict == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(color: _kLightGreen, shape: BoxShape.circle),
                          child: const Icon(Icons.storefront_outlined, size: 52, color: _kGreen),
                        ),
                        const SizedBox(height: 20),
                        const Text('Please select your district to view shopkeeper discounts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
                      ]),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('No offers match your search', style: TextStyle(color: Colors.black54)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _cropCard(filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _cropCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: _kGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: _kLightGreen, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.eco, size: 18, color: _kGreen),
                  ),
                  const SizedBox(width: 10),
                  Text(item['cropName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kDarkGreen)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text('${item['discount']}% OFF', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(item['shop_name'], style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Original: ₹ ${item['original_price']}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                  Text('Price: ₹ ${item['discounted_price'].toStringAsFixed(0)} (Pay in Coins)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _kGreen)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Go to Home and click Scan QR to purchase from this Shopkeeper!')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: _kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Buy Now', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
"""

content = re.sub(r'// === MARKET VIEW ===.*', replacement_market_view, content, flags=re.DOTALL)

with open(r'd:\integrated_agri_hub\lib\screens\farmer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated farmer market view successfully!")
