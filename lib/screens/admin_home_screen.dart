import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';
import '../widgets/youtube_player_widget.dart';
import 'welcome_screen.dart';

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

  // Education Media Hub State
  String _selectedCrop = 'Cotton';
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

  final TextEditingController _writtenGuideController = TextEditingController();
  final TextEditingController _audioUrlController = TextEditingController();
  final TextEditingController _ytUrlController = TextEditingController();
  final TextEditingController _ytTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _adminService.addListener(_onAdminServiceChange);
    _loadCropEduData(_selectedCrop);
  }

  @override
  void dispose() {
    _adminService.removeListener(_onAdminServiceChange);
    _tabController.dispose();
    _writtenGuideController.dispose();
    _audioUrlController.dispose();
    _ytUrlController.dispose();
    _ytTitleController.dispose();
    _csvInputController.dispose();
    super.dispose();
  }

  void _onAdminServiceChange() {
    if (mounted) setState(() {});
  }

  void _loadCropEduData(String crop) {
    final data = _adminService.getEducationDataForCrop(crop);
    if (data != null) {
      _writtenGuideController.text = data.writtenGuideText;
      _audioUrlController.text = data.audioUrl;
      _ytUrlController.text =
          data.relatedVideoUrls.isNotEmpty ? data.relatedVideoUrls.first : '';
      _ytTitleController.text =
          data.videoTitles.isNotEmpty ? data.videoTitles.first : '';
    } else {
      _writtenGuideController.text =
          'Farming Guide for $crop.\n\nBest Practices:\n1. Prepare well-drained fertile soil.\n2. Ensure proper row spacing & irrigation.\n3. Apply organic fertilizers.';
      _audioUrlController.text =
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      _ytUrlController.text = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      _ytTitleController.text = '$crop High Yield Farming Guide';
    }
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
        backgroundColor: const Color(0xFF1E3A8A), // Official Govt Navy
        elevation: 4,
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance,
                color: Color(0xFFFBBF24), // Gold emblem
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Government Admin Portal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Dept. of Agriculture & Agri-Market Services',
                    style: TextStyle(
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
          tabs: const [
            Tab(icon: Icon(Icons.currency_rupee), text: 'Market Prices'),
            Tab(icon: Icon(Icons.video_collection_outlined), text: 'Education'),
            Tab(icon: Icon(Icons.assignment_outlined), text: 'Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketPriceTab(prices),
          _buildEducationMediaTab(),
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
                      Text(
                        'Upload Market Price File (CSV / JSON)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
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
                            'Select & Import Market CSV File',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _showCsvUploadDialog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, color: Color(0xFF1E3A8A)),
                        label: const Text(
                          'Load Sample Rates',
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
              Expanded(
                child: const Text(
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
              width: 95,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final newPrice = double.tryParse(priceTextController.text) ?? item.currentPrice;
                _adminService.updateMarketPrice(item.id, newPrice);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated ${item.cropName} price to ₹${newPrice.toStringAsFixed(0)} / Quintal!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: EDUCATION & MEDIA HUB ---
  Widget _buildEducationMediaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Crop Selector Dropdown
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Target Crop for Education Module',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCrop,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _cropOptions.map((crop) {
                      return DropdownMenuItem<String>(
                        value: crop,
                        child: Text(
                          crop,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (newCrop) {
                      if (newCrop != null) {
                        setState(() {
                          _selectedCrop = newCrop;
                          _loadCropEduData(newCrop);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Written Guide Text Section
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
                      Icon(Icons.article_outlined, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '1. Written Farming Guide (Text)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _writtenGuideController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter best practices, soil guidelines, pest control steps...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Audio Guide Section
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
                      Icon(Icons.audiotrack, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '2. Audio Guide File / URL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _audioUrlController,
                    decoration: InputDecoration(
                      labelText: 'Audio Guide MP3 Link',
                      hintText: 'https://example.com/audio_guide.mp3',
                      prefixIcon: const Icon(Icons.link),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // YouTube Video Section with Live Preview
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
                      Icon(Icons.video_library, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '3. YouTube Video Link (Built-in Player Embed)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Farmers will watch this video directly inside the app with built-in playback controls.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ytTitleController,
                    decoration: InputDecoration(
                      labelText: 'Video Title',
                      hintText: 'e.g. Scientific Cotton Cultivation Guide',
                      prefixIcon: const Icon(Icons.title),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ytUrlController,
                    onChanged: (val) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: 'YouTube Video URL',
                      hintText: 'https://www.youtube.com/watch?v=...',
                      prefixIcon: const Icon(Icons.play_circle_fill, color: Colors.red),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // YouTube Player Live Preview Stage
                  if (_ytUrlController.text.trim().isNotEmpty) ...[
                    const Text(
                      'Live Video Preview:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    YoutubePlayerWidget(
                      videoUrl: _ytUrlController.text.trim(),
                      videoTitle: _ytTitleController.text.trim(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Publish Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            icon: const Icon(Icons.cloud_upload_rounded),
            label: Text(
              'Publish Educational Guide for $_selectedCrop',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: _publishEducationModule,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _publishEducationModule() {
    final writtenText = _writtenGuideController.text.trim();
    final audioUrl = _audioUrlController.text.trim();
    final ytUrl = _ytUrlController.text.trim();
    final ytTitle = _ytTitleController.text.trim();

    _adminService.saveCropEducationData(
      cropName: _selectedCrop,
      writtenGuideText: writtenText,
      audioUrl: audioUrl,
      youtubeUrls: ytUrl.isNotEmpty ? [ytUrl] : [],
      videoTitles: ytTitle.isNotEmpty ? [ytTitle] : [],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully published education content for $_selectedCrop!'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
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
            color: color.withOpacity(0.08),
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: TASKS MANAGEMENT ───────────────────────────────────
  Widget _buildTasksTab() {
    final _taskTitleController = TextEditingController();
    final _taskDescController  = TextEditingController();
    final _taskCoinsController = TextEditingController();
    String? _taskCrop = _cropOptions.first;

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
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.add_task, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 8),
                      Text('Publish New Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    ]),
                    const SizedBox(height: 20),
                    // Crop selector
                    DropdownButtonFormField<String>(
                      value: _taskCrop,
                      decoration: _inputDecor('Select Crop', Icons.eco_outlined),
                      items: _cropOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setLocal(() => _taskCrop = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _taskTitleController,
                      decoration: _inputDecor('Task Title', Icons.title),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _taskDescController,
                      maxLines: 3,
                      decoration: _inputDecor('Task Description', Icons.description_outlined),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _taskCoinsController,
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
                          final title = _taskTitleController.text.trim();
                          final desc  = _taskDescController.text.trim();
                          final coins = int.tryParse(_taskCoinsController.text.trim()) ?? 0;
                          if (title.isEmpty || desc.isEmpty || coins <= 0 || _taskCrop == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }
                          try {
                            await FirebaseFirestore.instance.collection('tasks').add({
                              'crop': _taskCrop,
                              'title': title,
                              'description': desc,
                              'coinsReward': coins,
                              'publishedAt': FieldValue.serverTimestamp(),
                              'active': true,
                            });
                            _taskTitleController.clear();
                            _taskDescController.clear();
                            _taskCoinsController.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task published for $_taskCrop!'), backgroundColor: Colors.green.shade700),
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
                                  Row(children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                                      child: Text(d['crop'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
                                      child: Text('+${d['coinsReward']} coins', style: const TextStyle(fontSize: 11, color: Color(0xFFB8860B), fontWeight: FontWeight.bold)),
                                    ),
                                  ]),
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
