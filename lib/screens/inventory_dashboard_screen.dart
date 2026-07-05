import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// InventoryDashboardScreen — browse & search shopkeeper stock
// ---------------------------------------------------------------------------
class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() =>
      _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Master list — never mutated.
  final List<_InventoryItem> _allItems = const [
    // ── Certified Seeds ──
    _InventoryItem(
      name: 'Wheat Seeds (HD-2967)',
      category: 'Certified Seeds',
      stock: 45,
      unitPrice: 85,
    ),
    _InventoryItem(
      name: 'Rice Seeds (Pusa-44)',
      category: 'Certified Seeds',
      stock: 8,
      unitPrice: 120,
    ),
    _InventoryItem(
      name: 'Maize Seeds (DHM-117)',
      category: 'Certified Seeds',
      stock: 32,
      unitPrice: 95,
    ),
    _InventoryItem(
      name: 'Mustard Seeds (Pusa Bold)',
      category: 'Certified Seeds',
      stock: 5,
      unitPrice: 110,
    ),

    // ── Organic Fertilizers ──
    _InventoryItem(
      name: 'Vermicompost (50 kg)',
      category: 'Organic Fertilizers',
      stock: 60,
      unitPrice: 350,
    ),
    _InventoryItem(
      name: 'Neem Cake (25 kg)',
      category: 'Organic Fertilizers',
      stock: 3,
      unitPrice: 280,
    ),
    _InventoryItem(
      name: 'Bio-NPK Granules',
      category: 'Organic Fertilizers',
      stock: 22,
      unitPrice: 190,
    ),
    _InventoryItem(
      name: 'Humic Acid Liquid (1 L)',
      category: 'Organic Fertilizers',
      stock: 15,
      unitPrice: 240,
    ),

    // ── Tool Components ──
    _InventoryItem(
      name: 'Sprayer Nozzle Set',
      category: 'Tool Components',
      stock: 18,
      unitPrice: 150,
    ),
    _InventoryItem(
      name: 'Drip Emitters (pack of 50)',
      category: 'Tool Components',
      stock: 7,
      unitPrice: 420,
    ),
    _InventoryItem(
      name: 'Pruning Blade (8″)',
      category: 'Tool Components',
      stock: 25,
      unitPrice: 175,
    ),
    _InventoryItem(
      name: 'Garden Hose Connector',
      category: 'Tool Components',
      stock: 2,
      unitPrice: 65,
    ),
  ];

  /// Filtered view driven by the search bar.
  List<_InventoryItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.of(_allItems);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.of(_allItems);
      } else {
        _filteredItems = _allItems.where((item) {
          return item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: const Text(
          'Inventory Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          // -------- Search bar --------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by item name or category…',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (_, value, __) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => _searchController.clear(),
                    );
                  },
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // -------- Summary chip row --------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _SummaryChip(
                  label: '${_filteredItems.length} items',
                  icon: Icons.inventory_2_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label:
                      '${_filteredItems.where((i) => i.isLowStock).length} low stock',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                ),
              ],
            ),
          ),

          // -------- Item list --------
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No items match your search.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _InventoryCard(item: _filteredItems[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data class for a single inventory item
// ---------------------------------------------------------------------------
class _InventoryItem {
  const _InventoryItem({
    required this.name,
    required this.category,
    required this.stock,
    required this.unitPrice,
  });

  final String name;
  final String category;
  final int stock;
  final double unitPrice;

  /// Items below 10 units are flagged as low stock.
  bool get isLowStock => stock < 10;
}

// ---------------------------------------------------------------------------
// Inventory item card
// ---------------------------------------------------------------------------
class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.item});

  final _InventoryItem item;

  IconData get _categoryIcon {
    switch (item.category) {
      case 'Certified Seeds':
        return Icons.grass_rounded;
      case 'Organic Fertilizers':
        return Icons.science_outlined;
      case 'Tool Components':
        return Icons.build_circle_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _categoryIcon,
                size: 26,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name
                  Text(
                    item.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Stock + Price row
                  Row(
                    children: [
                      // Stock quantity
                      if (item.isLowStock)
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                      if (item.isLowStock) const SizedBox(width: 4),
                      Text(
                        'Stock: ${item.stock}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: item.isLowStock
                              ? Colors.red.shade700
                              : colorScheme.onSurfaceVariant,
                          fontWeight: item.isLowStock
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),

                      // Unit price
                      Text(
                        '₹${item.unitPrice.toStringAsFixed(0)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small summary chip (e.g. "12 items", "4 low stock")
// ---------------------------------------------------------------------------
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
