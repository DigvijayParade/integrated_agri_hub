import re

with open(r'd:\integrated_agri_hub\lib\screens\farmer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

replacement = """  void _showScanResultDialog(BuildContext context, String value) async {
    try {
      final Map<String, dynamic> data = jsonDecode(value);
      final shopUid = data['shopUid'];
      final shopName = data['shopName'];
      
      if (shopUid == null) throw Exception("Invalid QR");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch shopkeeper's discounted products
      final invSnap = await FirebaseFirestore.instance.collection('shopkeeper_inventory').where('shopkeeper_id', isEqualTo: shopUid).get();
      final marketSnap = await FirebaseFirestore.instance.collection('market_prices').get();
      final marketPrices = {for (var doc in marketSnap.docs) doc.id: doc.data()};

      if (!context.mounted) return;
      Navigator.pop(context); // pop loading

      List<Map<String, dynamic>> availableProducts = [];
      for (var inv in invSnap.docs) {
        final invData = inv.data();
        final productId = invData['product_id'];
        final discount = (invData['discountPercent'] as num?)?.toInt() ?? 0;
        final market = marketPrices[productId];
        
        if (market != null && discount > 0) {
          final originalPrice = (market['currentPrice'] as num).toDouble();
          final discountedPrice = originalPrice - (originalPrice * discount / 100);
          availableProducts.add({
            'product_id': productId,
            'cropName': market['cropName'],
            'original_price': originalPrice,
            'discount': discount,
            'discounted_price': discountedPrice.toInt(),
          });
        }
      }

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Purchase from \$shopName', style: const TextStyle(color: _kDarkGreen)),
            content: SizedBox(
              width: double.maxFinite,
              child: availableProducts.isEmpty 
                ? const Text("This shopkeeper has no active discounts.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableProducts.length,
                    itemBuilder: (_, i) {
                      final prod = availableProducts[i];
                      return ListTile(
                        title: Text(prod['cropName']),
                        subtitle: Text('Discount: \${prod['discount']}%, Pay: \${prod['discounted_price']} Coins'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _kGreen),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _processTransaction(context, shopUid, shopName, prod);
                          },
                          child: const Text("Buy", style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid QR Code scanned.')));
    }
  }

  void _processTransaction(BuildContext context, String shopUid, String shopName, Map<String, dynamic> prod) async {
    final farmerUid = FirebaseAuth.instance.currentUser?.uid;
    if (farmerUid == null) return;

    final coinsToDeduct = prod['discounted_price'] as int;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final db = FirebaseFirestore.instance;
      
      await db.runTransaction((transaction) async {
        final farmerRef = db.collection('users').doc(farmerUid);
        final shopRef = db.collection('shopkeepers').doc(shopUid); // or users
        
        // Ensure both exist and read them
        final farmerDoc = await transaction.get(farmerRef);
        var shopDoc = await transaction.get(shopRef);
        
        if (!shopDoc.exists) {
            shopDoc = await transaction.get(db.collection('users').doc(shopUid));
        }

        if (!farmerDoc.exists || !shopDoc.exists) {
          throw Exception("User data missing.");
        }

        final int farmerCoins = (farmerDoc.data()?['greenCoins'] as num?)?.toInt() ?? 0;
        final int shopCoins = (shopDoc.data()?['greenCoinsReceived'] as num?)?.toInt() ?? 0;
        final double shopSales = (shopDoc.data()?['todaySales'] as num?)?.toDouble() ?? 0.0;

        if (farmerCoins < coinsToDeduct) {
          throw Exception("Insufficient Green Coins.");
        }

        // Deduct from farmer
        transaction.update(farmerRef, {'greenCoins': farmerCoins - coinsToDeduct});
        
        // Add to shopkeeper
        transaction.update(shopDoc.reference, {
          'greenCoinsReceived': shopCoins + coinsToDeduct,
          'todaySales': shopSales + (coinsToDeduct * 0.1), // example logic
        });

        // Add Transaction record
        final txRef = db.collection('green_coin_transactions').doc();
        transaction.set(txRef, {
          'sender_id': farmerUid,
          'sender_name': farmerDoc.data()?['fullName'] ?? 'Farmer',
          'receiver_id': shopUid,
          'receiver_name': shopName,
          'amount_coins': coinsToDeduct,
          'equivalent_inr': coinsToDeduct * 0.1,
          'transaction_type': 'purchase',
          'product_name': prod['cropName'],
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (!context.mounted) return;
      Navigator.pop(context); // pop loading
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Successful!'), backgroundColor: Colors.green));
      _logTransaction(-coinsToDeduct, 'Bought \${prod['cropName']} from \$shopName');
      
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction Failed: \$e'), backgroundColor: Colors.red));
    }
  }
"""

content = re.sub(r'void _showScanResultDialog.*?\}\n\n// === TASKS DATA MODEL ===', replacement + '\n// === TASKS DATA MODEL ===', content, flags=re.DOTALL)

with open(r'd:\integrated_agri_hub\lib\screens\farmer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated Farmer QR Dialog")
