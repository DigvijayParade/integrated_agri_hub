import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// DigitalLedgerScreen — form for recording a sale transaction
// Accepts optional pre-fill data from the Voucher Scanner flow.
// ---------------------------------------------------------------------------
class DigitalLedgerScreen extends StatefulWidget {
  const DigitalLedgerScreen({
    super.key,
    this.preFilledVoucherCode,
    this.isVoucherApplied = false,
  });

  /// Voucher code returned from the QR / manual voucher scan.
  final String? preFilledVoucherCode;

  /// When true, payment type is pre-set to "Cash/Voucher".
  final bool isVoucherApplied;

  @override
  State<DigitalLedgerScreen> createState() => _DigitalLedgerScreenState();
}

class _DigitalLedgerScreenState extends State<DigitalLedgerScreen> {
  late final TextEditingController _farmerIdController;
  late String _paymentType;

  @override
  void initState() {
    super.initState();
    // Initialize an empty controller so the shopkeeper can manually type the ID
    _farmerIdController = TextEditingController();
    // Pre-select payment type based on voucher flag
    _paymentType = widget.isVoucherApplied ? 'Cash/Voucher' : 'Cash/Voucher';
  }

  @override
  void dispose() {
    _farmerIdController.dispose();
    super.dispose();
  }

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
          'Digital Ledger',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ------- Section header -------
            Text(
              'New Sale Entry',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in the details below to record a transaction.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            // Voucher applied banner
            if (widget.isVoucherApplied) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Voucher verified — payment set to Cash / Voucher.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ------- Verified Voucher Green Box -------
            if (widget.preFilledVoucherCode != null && widget.preFilledVoucherCode!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✅ Verified Voucher: ${widget.preFilledVoucherCode}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

            // ------- Farmer ID -------
            _LedgerTextField(
              label: 'Farmer ID',
              hint: 'e.g. FRM-001',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.text,
              controller: _farmerIdController,
            ),
            const SizedBox(height: 20),

            // ------- Item Sold -------
            _LedgerTextField(
              label: 'Item Sold',
              hint: 'e.g. Wheat Seeds (10 kg)',
              prefixIcon: Icons.shopping_bag_outlined,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),

            // ------- Total Cost -------
            _LedgerTextField(
              label: 'Total Cost',
              hint: 'e.g. 1500',
              prefixIcon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),

            // ------- Payment Type -------
            Text(
              'Payment Type',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                segments: const [
                  ButtonSegment<String>(
                    value: 'Cash/Voucher',
                    label: Text('Cash / Voucher'),
                    icon: Icon(Icons.payments_outlined),
                  ),
                  ButtonSegment<String>(
                    value: 'Credit',
                    label: Text('Credit'),
                    icon: Icon(Icons.credit_card_outlined),
                  ),
                ],
                selected: {_paymentType},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _paymentType = selection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 36),

            // ------- Save Entry Button -------
            FilledButton.icon(
              onPressed: () {
                // TODO: save entry to database
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                'Save Entry',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable styled text field for the ledger form
// ---------------------------------------------------------------------------
class _LedgerTextField extends StatelessWidget {
  const _LedgerTextField({
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: colorScheme.primary),
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
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}