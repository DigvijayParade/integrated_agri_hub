import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/admin_service.dart';
import '../services/translation_service.dart';
import '../widgets/youtube_player_widget.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();

  // Market Price Controllers & State
  String _marketSearchQuery = '';
  final TextEditingController _csvInputController = TextEditingController();

  // Tasks Crop Options
  final List<String> _cropOptions = [
    'Cotton',
    'Soybean',
    'Sugarcane',
    'Wheat',
    'Rice',
    'Turmeric',
    'Onion',
    'Mustard',
    'Coconut',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _adminService.addListener(_onAdminServiceChange);
  }

  @override
  void dispose() {
    _adminService.removeListener(_onAdminServiceChange);
    _tabController.dispose();
    _csvInputController.dispose();
    super.dispose();
  }

  void _onAdminServiceChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prices = _adminService.marketPrices.where((item) {
      final query = _marketSearchQuery.toLowerCase();
      return item.cropName.toLowerCase().contains(query) ||
          item.mandiName.toLowerCase().contains(query) ||
          item.district.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 4,
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance,
                color: Color(0xFFFBBF24),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationService.tr('admin'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    TranslationService().currentLanguage == AppLanguage.hindi
                        ? 'कृषि एवं कृषि-बाज़ार सेवा विभाग'
                        : TranslationService().currentLanguage == AppLanguage.marathi
                            ? 'कृषी आणि कृषी-बाजार सेवा विभाग'
                            : 'Dept. of Agriculture & Agri-Market Services',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showSignOutDialog,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFBBF24),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(icon: const Icon(Icons.currency_rupee), text: TranslationService.tr('market_prices')),
            Tab(icon: const Icon(Icons.assignment_outlined), text: TranslationService.tr('tasks')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketPriceTab(prices),
          _buildTasksTab(),
        ],
      ),
    );
  }

  // --- TAB 1: MARKET PRICE MANAGEMENT ---
  Widget _buildMarketPriceTab(List<MarketPriceItem> prices) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat Cards Header
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Active Mandis',
                  value: '${_adminService.marketPrices.length}',
                  icon: Icons.store_mall_directory,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Last Sync',
                  value: 'Today, 12:45 PM',
                  icon: Icons.sync,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // File Upload / Dropzone Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.upload_file, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Upload Market Price File (CSV / JSON)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload updated crop market rates file from Government Mandi Portal to broadcast live rates across all farmer apps.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.file_upload_outlined),
                          label: const Text(
                            'Select & Import CSV',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: _showCsvUploadDialog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, color: Color(0xFF1E3A8A)),
                        label: const Text(
                          'Load Sample',
                          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          const sampleCsv = '''Crop,Mandi,District,Price
Cotton (Kapas),Nagpur APMC,Nagpur,7650
Soybean,Latur APMC,Latur,4950
Sugarcane,Kolhapur Mandi,Kolhapur,3200
Turmeric,Sangli APMC,Sangli,14100
Onion,Lasalgaon Mandi,Nashik,2250''';
                          final count = _adminService.importMarketPricesFromCsv(sampleCsv);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Successfully imported $count mandi prices!'),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Live Mandi Price Editor Table Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Live Mandi Rates (Interactive Editor)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFF16A34A)),
                    SizedBox(width: 6),
                    Text(
                      'Sync Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Bar
          TextField(
            onChanged: (val) {
              setState(() {
                _marketSearchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search crop, mandi, or district...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Price Items Table
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final item = prices[index];
              return _buildMandiPriceRow(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMandiPriceRow(MarketPriceItem item) {
    final priceTextController = TextEditingController(
      text: item.currentPrice.toStringAsFixed(0),
    );

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.grass, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.cropName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.mandiName} • ${item.district}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Price input box
            Container(
              width: 90,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: priceTextController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final newPrice = double.tryParse(priceTextController.text) ?? item.currentPrice;
                _adminService.updateMarketPrice(item.id, newPrice);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated ${item.cropName} to ₹${newPrice.toStringAsFixed(0)}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }



  void _showCsvUploadDialog() {
    _csvInputController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.file_present, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Expanded(child: Text('Import Market Rates CSV')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste CSV data lines format:\nCropName, MandiName, District, PricePerQuintal',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _csvInputController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Cotton (Kapas),Nagpur APMC,Nagpur,7500\nSoybean,Latur APMC,Latur,4900\nOnion,Lasalgaon,Nashik,2300',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
              onPressed: () {
                final text = _csvInputController.text.trim();
                if (text.isNotEmpty) {
                  final count = _adminService.importMarketPricesFromCsv(text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Imported $count mandi price records successfully!'),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                }
              },
              child: const Text('Import Data', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out Admin Session?'),
        content: const Text('Are you sure you want to exit the Government Admin Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              // AuthGate will automatically redirect to WelcomeScreen
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: TASKS MANAGEMENT ───────────────────────────────────
  Widget _buildTasksTab() {
    final taskTitleController = TextEditingController();
    final taskDescController  = TextEditingController();
    final taskCoinsController = TextEditingController();
    String? taskCrop = _cropOptions.first;

    return StatefulBuilder(
      builder: (context, setLocal) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Publish New Task Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.add_task, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Publish New Task',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: taskCrop,
                      decoration: _inputDecor('Select Crop', Icons.eco_outlined),
                      items: _cropOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setLocal(() => taskCrop = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taskTitleController,
                      decoration: _inputDecor('Task Title', Icons.title),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taskDescController,
                      maxLines: 3,
                      decoration: _inputDecor('Task Description', Icons.description_outlined),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taskCoinsController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecor('Green Coin Reward', Icons.monetization_on_outlined),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.publish, color: Colors.white),
                        label: const Text('Publish Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          final title = taskTitleController.text.trim();
                          final desc  = taskDescController.text.trim();
                          final coins = int.tryParse(taskCoinsController.text.trim()) ?? 0;
                          if (title.isEmpty || desc.isEmpty || coins <= 0 || taskCrop == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }
                          try {
                            await FirebaseFirestore.instance.collection('tasks').add({
                              'crop': taskCrop,
                              'title': title,
                              'description': desc,
                              'coinsReward': coins,
                              'publishedAt': FieldValue.serverTimestamp(),
                              'active': true,
                            });
                            taskTitleController.clear();
                            taskDescController.clear();
                            taskCoinsController.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task published for $taskCrop!'), backgroundColor: Colors.green.shade700),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ── Live Tasks List ──
              const Text('Published Tasks', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .orderBy('publishedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('No tasks published yet.', style: TextStyle(color: Colors.black45))),
                    );
                  }
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                                        child: Text(d['crop'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
                                        child: Text('+${d['coinsReward']} coins', style: const TextStyle(fontSize: 11, color: Color(0xFFB8860B), fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(d['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(d['description'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: 'Delete Task',
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('tasks').doc(doc.id).delete();
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF4F6F9),
    );
  }
}
