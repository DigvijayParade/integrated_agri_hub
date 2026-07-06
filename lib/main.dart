import 'package:flutter/material.dart';
import 'screens/digital_ledger_screen.dart';
import 'screens/inventory_dashboard_screen.dart';
import 'screens/role_selector_screen.dart';
import 'screens/voucher_scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

// ---------------------------------------------------------------------------
// App root
// ---------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integrated Agri Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // earthy green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const RoleSelectorScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// ShopkeeperDashboard — the main merchant landing screen
// ---------------------------------------------------------------------------
class ShopkeeperDashboard extends StatelessWidget {
  const ShopkeeperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: const Text(
          'Welcome, Merchant',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardCard(
                icon: Icons.qr_code_scanner,
                label: 'Scan Farmer QR',
                onTap: () async {
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoucherScannerScreen(),
                    ),
                  );
                  // Guard against using context after an async gap
                  if (!context.mounted) return;
                  if (result != null && result.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DigitalLedgerScreen(
                          preFilledVoucherCode: result, // FIXED LINE
                          isVoucherApplied: true,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _DashboardCard(
                icon: Icons.menu_book_rounded,
                label: 'Digital Ledger',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DigitalLedgerScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _DashboardCard(
                icon: Icons.inventory_2_rounded,
                label: 'Inventory Dashboard',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryDashboardScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable dashboard card widget
// ---------------------------------------------------------------------------
class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: colorScheme.primary),
              ),
              const SizedBox(width: 20),

              // Label
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // Trailing chevron
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}