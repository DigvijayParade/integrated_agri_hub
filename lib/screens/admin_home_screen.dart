import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../services/admin_service.dart';
import '../services/translation_service.dart';
import '../services/task_verification_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();

  // Market Price Controllers & State
  String _marketSearchQuery = '';
  final TextEditingController _csvInputController = TextEditingController();

  // Animation Controllers
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

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

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _adminService.removeListener(_onAdminServiceChange);
    _tabController.dispose();
    _csvInputController.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2744), Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
        shadowColor: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
        toolbarHeight: 82,
        title: Row(
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        TranslationService.tr('admin'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF34D399), width: 0.8),
                        ),
                        child: const Text('LIVE', style: TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    TranslationService().currentLanguage == AppLanguage.hindi
                        ? 'कृषि एवं कृषि-बाज़ार सेवा विभाग'
                        : TranslationService().currentLanguage == AppLanguage.marathi
                            ? 'कृषी आणि कृषी-बाजार सेवा विभाग'
                            : 'Dept. of Agriculture & Market Services',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.8),
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
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
            ),
            onPressed: _showSignOutDialog,
          ),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFBBF24),
          indicatorWeight: 3.5,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(icon: const Icon(Icons.currency_rupee_rounded), text: TranslationService.tr('market_prices')),
            Tab(icon: const Icon(Icons.assignment_outlined), text: TranslationService.tr('tasks')),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMarketPriceTab(prices),
            _buildTasksTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: MARKET PRICE MANAGEMENT ---
  Widget _buildMarketPriceTab(List<MarketPriceItem> prices) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat Cards Header with Gradient Glow
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Active APMC Mandis',
                  value: '${_adminService.marketPrices.length}',
                  icon: Icons.store_mall_directory_rounded,
                  color: const Color(0xFF1E3A8A),
                  gradientColors: [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Live Price Feeds',
                  value: 'Real-time Sync',
                  icon: Icons.cloud_done_rounded,
                  color: const Color(0xFF059669),
                  gradientColors: [const Color(0xFF059669), const Color(0xFF10B981)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // File Upload / Dropzone Section Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.upload_file_rounded, color: Color(0xFF1E3A8A), size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upload Market Price File (CSV / Text)',
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
                const SizedBox(height: 6),
                const Text(
                  'Broadcast official Government APMC mandi rates across all connected farmer and buyer devices instantaneously.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.3),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.file_upload_outlined, size: 18),
                        label: const Text(
                          'Import CSV Data',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: _showCsvUploadDialog,
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      label: const Text(
                        'Load Sample',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                            content: Text('Successfully imported $count sample mandi rates!'),
                            backgroundColor: const Color(0xFF059669),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Live Mandi Price Editor Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Live Mandi Rates (Interactive Editor)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F2744),
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
                      'Live Broadcast',
                      style: TextStyle(
                        fontSize: 11.5,
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
            onChanged: (val) => setState(() => _marketSearchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search commodity, APMC mandi, or district...',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1E3A8A)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Mandi Price List
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Icon(Icons.grass_rounded, color: Color(0xFF1E3A8A), size: 22),
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
                    fontSize: 14.5,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.mandiName} • ${item.district}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Price input box
          Container(
            width: 96,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: priceTextController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669)),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final newPrice = double.tryParse(priceTextController.text) ?? item.currentPrice;
              _adminService.updateMarketPrice(item.id, newPrice);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Updated ${item.cropName} to ₹${newPrice.toStringAsFixed(0)}'),
                  backgroundColor: const Color(0xFF059669),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  void _showCsvUploadDialog() {
    _csvInputController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.file_present_rounded, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Expanded(child: Text('Import Market Rates CSV', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste CSV data lines in format:\nCropName, MandiName, District, PricePerQuintal',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _csvInputController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Cotton (Kapas),Nagpur APMC,Nagpur,7500\nSoybean,Latur APMC,Latur,4900\nOnion,Lasalgaon,Nashik,2300',
                  hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final text = _csvInputController.text.trim();
                if (text.isNotEmpty) {
                  final count = _adminService.importMarketPricesFromCsv(text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Imported $count mandi price records successfully!'),
                      backgroundColor: const Color(0xFF059669),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: const Text('Import Data', style: TextStyle(fontWeight: FontWeight.bold)),
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
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out Admin Session?'),
        content: const Text('Are you sure you want to exit the Government Admin Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
              }
            },
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: TASKS MANAGEMENT ───────────────────────────────────────────────
  Widget _buildTasksTab() {
    final taskTitleController = TextEditingController();
    final taskDescController = TextEditingController();
    final taskCoinsController = TextEditingController();
    String? taskCrop = _cropOptions.first;

    return StatefulBuilder(
      builder: (context, setLocal) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Publish New Task Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.add_task_rounded, color: Color(0xFF1E3A8A), size: 22),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Publish New Farmer Task & Reward',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: taskCrop,
                      decoration: _inputDecor('Select Target Crop', Icons.eco_outlined),
                      items: _cropOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setLocal(() => taskCrop = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taskTitleController,
                      decoration: _inputDecor('Task Title (e.g. Apply Organic Fertilizer)', Icons.title_rounded),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taskDescController,
                      maxLines: 3,
                      decoration: _inputDecor('Task Description & Instructions for Farmer', Icons.description_outlined),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taskCoinsController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecor('Green Coin Reward (e.g. 50)', Icons.monetization_on_outlined),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.publish_rounded, color: Colors.white, size: 20),
                        label: const Text('Publish Task & Broadcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        onPressed: () async {
                          final title = taskTitleController.text.trim();
                          final desc = taskDescController.text.trim();
                          final coins = int.tryParse(taskCoinsController.text.trim()) ?? 0;
                          if (title.isEmpty || desc.isEmpty || coins <= 0 || taskCrop == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields properly'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
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
                                SnackBar(
                                  content: Text('Task published successfully for $taskCrop!'),
                                  backgroundColor: const Color(0xFF059669),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error publishing task: $e'),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
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

              // Pending Verifications Section
              _buildPendingVerificationsSection(),
              
              const SizedBox(height: 24),

              // Live Published Tasks List Header
              const Text(
                'Active Published Tasks',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F2744)),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .orderBy('publishedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text(
                          'No tasks published yet. Create the first task above.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ),
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
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFA5D6A7)),
                                        ),
                                        child: Text(
                                          d['crop'] ?? '',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF8E1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFFFE082)),
                                        ),
                                        child: Text(
                                          '+${d['coinsReward']} Coins',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFFB8860B), fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    d['title'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    d['description'] ?? '',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
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
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
      prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }

  Widget _buildPendingVerificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pending Task Verifications',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F2744)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting AI batch verification...'), backgroundColor: Color(0xFF1E3A8A)),
                );
                final results = await TaskVerificationService().batchVerifyAllPendingWithAI();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Processed ${results['total']} tasks (Approved: ${results['approved']}, Rejected: ${results['rejected']})'),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              label: const Text('AI Auto-Verify All', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('task_submissions')
              .where('status', isEqualTo: 'pending')
              .orderBy('submittedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'No pending task submissions.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
              );
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                final item = TaskSubmissionItem.fromFirestore(doc);
                return _buildVerificationCard(item);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVerificationCard(TaskSubmissionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.taskTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2744)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
                child: Text('+${item.coinsReward} Coins', style: const TextStyle(color: Color(0xFFB8860B), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Farmer: ${item.farmerName} • ${item.farmerDistrict}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          if (item.imageBase64 != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(item.imageBase64!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectTask(item),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Reject', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveTask(item),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Approve', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI is verifying...')));
                final res = await TaskVerificationService().verifySingleSubmissionWithAI(item);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.isApproved ? 'AI Approved: ${res.reasonEnglish}' : 'AI Rejected: ${res.reasonEnglish}'),
                      backgroundColor: res.isApproved ? const Color(0xFF059669) : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome, color: Color(0xFF1E3A8A)),
              label: const Text('Verify with AI (Gemini)', style: TextStyle(color: Color(0xFF1E3A8A))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDBEAFE),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _approveTask(TaskSubmissionItem item) async {
    await TaskVerificationService().approveSubmission(
      submissionId: item.id,
      farmerId: item.farmerId,
      taskId: item.taskId,
      coinsReward: item.coinsReward,
      taskTitle: item.taskTitle,
    );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task Approved!')));
  }

  void _rejectTask(TaskSubmissionItem item) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Task'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: 'Enter rejection reason...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (reasonCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await TaskVerificationService().rejectSubmission(
                submissionId: item.id,
                farmerId: item.farmerId,
                taskId: item.taskId,
                taskTitle: item.taskTitle,
                reason: reasonCtrl.text.trim(),
              );
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task Rejected')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
