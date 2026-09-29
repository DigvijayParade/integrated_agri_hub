import re
import os

with open(r'd:\integrated_agri_hub\lib\screens\shopkeeper_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# I need to change `_MarketView` to fetch `market_prices` from Firebase and `shopkeeper_inventory`.
replacement_market_view = """// === MARKET VIEW ===
class _MarketView extends StatefulWidget {
  const _MarketView();
  @override
  State<_MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<_MarketView> {
  List<Map<String, dynamic>> _products = [];
  Map<String, int> _discounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarketAndInventory();
  }

  void _loadMarketAndInventory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final marketSnap = await FirebaseFirestore.instance.collection('market_prices').get();
    final invSnap = await FirebaseFirestore.instance.collection('shopkeeper_inventory').where('shopkeeper_id', isEqualTo: uid).get();
    
    final Map<String, int> discountsMap = {};
    for (var doc in invSnap.docs) {
      final data = doc.data();
      discountsMap[data['product_id'] as String] = (data['discountPercent'] as num).toInt();
    }

    final List<Map<String, dynamic>> loadedProds = [];
    for (var doc in marketSnap.docs) {
      final data = doc.data();
      loadedProds.add({
        'id': doc.id,
        'name': data['cropName'] ?? '',
        'price': data['currentPrice'] ?? 0.0,
      });
      if (!discountsMap.containsKey(doc.id)) {
        discountsMap[doc.id] = 0;
      }
    }

    if (mounted) {
      setState(() {
        _products = loadedProds;
        _discounts = discountsMap;
        _isLoading = false;
      });
    }
  }

  void _updateDiscount(String prodId, double val) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final int newDiscount = val.toInt();
    setState(() {
      _discounts[prodId] = newDiscount;
    });

    final invRef = FirebaseFirestore.instance.collection('shopkeeper_inventory');
    final qSnap = await invRef.where('shopkeeper_id', isEqualTo: uid).where('product_id', isEqualTo: prodId).get();
    
    if (qSnap.docs.isNotEmpty) {
      await invRef.doc(qSnap.docs.first.id).update({'discountPercent': newDiscount});
    } else {
      await invRef.add({
        'shopkeeper_id': uid,
        'product_id': prodId,
        'discountPercent': newDiscount,
        'stock_quantity': 100, // default
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
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
                final prodId = prod['id'] as String;
                final discount = _discounts[prodId] ?? 0;
                final price = prod['price'] as num;
                final discountAmt = (price * discount / 100).toStringAsFixed(0);
                
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
                          Text('₹ $price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
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
                              max: 60,
                              divisions: 60,
                              activeColor: _kGreen,
                              label: '$discount%',
                              onChanged: (val) => _updateDiscount(prodId, val),
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
}"""

replacement_history_view = """// === HISTORY VIEW ===
class _HistoryView extends StatefulWidget {
  const _HistoryView();
  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    FirebaseFirestore.instance
      .collection('green_coin_transactions')
      .where('receiver_id', isEqualTo: uid)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen((snap) {
        if (!mounted) return;
        final list = snap.docs.map((doc) => doc.data()).toList();
        setState(() {
          _transactions = list;
          _loading = false;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Transaction History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
          ),
          Expanded(
            child: _transactions.isEmpty ? const Center(child: Text("No transactions yet.")) : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final name = tx['sender_name'] ?? 'Unknown Farmer';
                final coins = tx['amount_coins'] ?? 0;
                final rs = tx['equivalent_inr'] ?? 0;
                final ts = (tx['timestamp'] as Timestamp?)?.toDate();
                final timeStr = ts != null ? '\${ts.day}/\${ts.month}/\${ts.year} \${ts.hour}:\${ts.minute.toString().padLeft(2, '0')}' : 'Unknown Time';

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: _kLightGreen,
                        child: Text(name.toString().substring(0, 1), style: const TextStyle(color: _kGreen, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+\$coins 🌿', style: const TextStyle(color: _kGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Value: ₹ \$rs', style: const TextStyle(color: Colors.black54, fontSize: 11)),
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
}"""

content = re.sub(r'// === MARKET VIEW ===.*?// === HISTORY VIEW ===', replacement_market_view + '\n\n' + '// === HISTORY VIEW ===', content, flags=re.DOTALL)
content = re.sub(r'// === HISTORY VIEW ===.*?// === MY QR VIEW ===', replacement_history_view + '\n\n' + '// === MY QR VIEW ===', content, flags=re.DOTALL)

with open(r'd:\integrated_agri_hub\lib\screens\shopkeeper_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated shopkeeper successfully!")
