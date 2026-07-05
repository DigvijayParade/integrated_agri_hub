import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ---------------------------------------------------------------------------
// VoucherScannerScreen — live QR camera with manual fallback
// ---------------------------------------------------------------------------
class VoucherScannerScreen extends StatefulWidget {
  const VoucherScannerScreen({super.key});

  @override
  State<VoucherScannerScreen> createState() => _VoucherScannerScreenState();
}

class _VoucherScannerScreenState extends State<VoucherScannerScreen> {
  late final MobileScannerController _controller;
  final TextEditingController _manualController = TextEditingController();

  /// Prevents multiple detections firing in rapid succession.
  bool _hasDetected = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // fire-and-forget — controller handles its own async cleanup
    _manualController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _hasDetected = true);

    // ✅ Print raw QR value to debug console for verification
    log('📦 QR Detected: $rawValue', name: 'VoucherScanner');

    // Stop camera then return the scanned value to the caller
    _controller.stop();
    if (context.mounted) Navigator.pop(context, rawValue);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: const Text(
          'Voucher Scanner',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        actions: [
          // Torch toggle
          IconButton(
            icon: const Icon(Icons.flashlight_on_rounded),
            tooltip: 'Toggle Torch',
            onPressed: () => _controller.toggleTorch(),
          ),
          // Flip camera
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded),
            tooltip: 'Flip Camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          // -------- Live camera preview area --------
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Live camera feed
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) {
                    return _CameraErrorView(
                      error: error,
                      onRetry: () async {
                        await _controller.stop();
                        await _controller.start();
                      },
                    );
                  },
                ),

                // Dark overlay with cutout + green corner brackets on top
                CustomPaint(
                  size: Size.infinite,
                  painter: _ScannerOverlayPainter(
                    borderColor: colorScheme.primary,
                  ),
                ),

                // Instruction text
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: 32,
                  child: Text(
                    'Align the farmer\'s voucher QR code\nwithin the frame to scan.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -------- Bottom section: divider + manual entry + button --------
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // OR divider
                Row(
                  children: [
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  ],
                ),
                const SizedBox(height: 20),

                // Manual voucher code input
                TextField(
                  controller: _manualController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Enter voucher code manually',
                    hintText: 'e.g. VCH-20260704-001',
                    prefixIcon: Icon(
                      Icons.keyboard_alt_outlined,
                      color: colorScheme.primary,
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
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Verify Voucher button
                FilledButton.icon(
                  onPressed: () {
                    final String typed = _manualController.text.trim();
                    if (typed.isEmpty) return;
                    _controller.stop();
                    if (context.mounted) Navigator.pop(context, typed);
                  },
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text(
                    'Verify Voucher',
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Camera permission / error fallback view
// ---------------------------------------------------------------------------
class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.error, required this.onRetry});

  final MobileScannerException error;
  final VoidCallback onRetry;

  String get _message {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Camera permission denied.\nPlease grant camera access in Settings to scan vouchers.';
      case MobileScannerErrorCode.unsupported:
        return 'Camera not supported on this device.';
      default:
        return 'Camera error: ${error.errorDetails?.message ?? 'Unknown error'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.no_photography_outlined,
                size: 64,
                color: colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 20),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter — dark overlay with clear cutout and green corner brackets
// ---------------------------------------------------------------------------
class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.borderColor});

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double scanSize = size.width * 0.65;
    final double left = (size.width - scanSize) / 2;
    final double top = (size.height - scanSize) / 2 - 20;
    final double right = left + scanSize;
    final double bottom = top + scanSize;
    const double radius = 16;
    const double cornerLen = 32;
    const double strokeWidth = 4;

    // Dark overlay with cutout
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, top, right, bottom),
      const Radius.circular(radius),
    );
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, overlayPaint);

    // Green corner brackets
    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset(left, top + radius + cornerLen), Offset(left, top + radius), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(left, top, radius * 2, radius * 2), 3.14159, 1.5708, false, cornerPaint);
    canvas.drawLine(Offset(left + radius, top), Offset(left + radius + cornerLen, top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(right - radius - cornerLen, top), Offset(right - radius, top), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(right - radius * 2, top, radius * 2, radius * 2), -1.5708, 1.5708, false, cornerPaint);
    canvas.drawLine(Offset(right, top + radius), Offset(right, top + radius + cornerLen), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, bottom - radius - cornerLen), Offset(left, bottom - radius), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(left, bottom - radius * 2, radius * 2, radius * 2), 1.5708, 1.5708, false, cornerPaint);
    canvas.drawLine(Offset(left + radius, bottom), Offset(left + radius + cornerLen, bottom), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(right - radius - cornerLen, bottom), Offset(right - radius, bottom), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(right - radius * 2, bottom - radius * 2, radius * 2, radius * 2), 0, 1.5708, false, cornerPaint);
    canvas.drawLine(Offset(right, bottom - radius), Offset(right, bottom - radius - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
