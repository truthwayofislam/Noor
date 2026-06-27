import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/halal_checker_service.dart';

class HalalScannerScreen extends StatefulWidget {
  const HalalScannerScreen({super.key});

  @override
  State<HalalScannerScreen> createState() => _HalalScannerScreenState();
}

class _HalalScannerScreenState extends State<HalalScannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  bool _isScanning = true;
  bool _isLoading = false;
  bool _torchOn = false;
  ProductResult? _result;
  String? _error;
  String? _lastScanned;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    _manualController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _checkBarcode(String barcode) async {
    if (barcode == _lastScanned || _isLoading) return;
    _lastScanned = barcode;

    setState(() {
      _isLoading = true;
      _isScanning = false;
      _error = null;
      _result = null;
    });

    final result = await HalalCheckerService.checkBarcode(barcode);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result == null) {
          _error = 'Product not found in database.\nTry manual ingredient check.';
        } else {
          _result = result;
        }
      });
    }
  }

  void _checkManual() {
    final text = _manualController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _result = HalalCheckerService.checkManualIngredients(text);
      _error = null;
    });
  }

  void _reset() {
    setState(() {
      _result = null;
      _error = null;
      _lastScanned = null;
      _isScanning = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halal Scanner - حلال'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan'),
            Tab(icon: Icon(Icons.edit_note), text: 'Manual'),
            Tab(icon: Icon(Icons.info_outline), text: 'E-Numbers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildScanTab(),
          _buildManualTab(),
          _buildENumbersTab(),
        ],
      ),
    );
  }

  // ── TAB 1: Scanner ──────────────────────────────────────────────────────────

  Widget _buildScanTab() {
    if (_isLoading) return _buildLoading();
    if (_result != null) return _buildResult(_result!);
    if (_error != null) return _buildScanError();

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull?.rawValue;
                  if (barcode != null) _checkBarcode(barcode);
                },
              ),
              // Scan overlay
              CustomPaint(
                painter: _ScanOverlayPainter(),
                child: Container(),
              ),
              // Top bar
              Positioned(
                top: 12,
                right: 12,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  icon: Icon(
                    _torchOn ? Icons.flash_on : Icons.flash_off,
                    color: _torchOn ? Colors.yellow : Colors.white,
                  ),
                  onPressed: () {
                    _scannerController.toggleTorch();
                    setState(() => _torchOn = !_torchOn);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Point camera at product barcode',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Or enter barcode manually',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter barcode number...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final code = _barcodeController.text.trim();
                        if (code.isNotEmpty) _checkBarcode(code);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Check'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Checking ingredients...'),
          SizedBox(height: 8),
          Text(
            'Looking up Open Food Facts database',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildScanError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Product Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Again'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Manual Check'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 2: Manual Input ─────────────────────────────────────────────────────

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.blue, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Paste or type the ingredients list from the product packaging',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _manualController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText:
                  'e.g. Sugar, Water, E471, Gelatin, Natural Flavors...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _checkManual,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Check Ingredients'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: () {
                  _manualController.clear();
                  setState(() => _result = null);
                },
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            _buildResult(_result!),
          ],
        ],
      ),
    );
  }

  // ── Result Card ─────────────────────────────────────────────────────────────

  Widget _buildResult(ProductResult result) {
    final isManual = result.barcode == 'manual';

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusSubtext;

    switch (result.overallStatus) {
      case HalalStatus.halal:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'HALAL ✅';
        statusSubtext = 'No haram ingredients detected';
        break;
      case HalalStatus.haram:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'HARAM ❌';
        statusSubtext = 'Contains haram ingredients';
        break;
      case HalalStatus.doubtful:
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber;
        statusText = 'DOUBTFUL ⚠️';
        statusSubtext = 'Some ingredients need verification';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'UNKNOWN';
        statusSubtext = 'Could not determine status';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4), width: 2),
            ),
            child: Column(
              children: [
                Icon(statusIcon, color: statusColor, size: 56),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusSubtext,
                  style: TextStyle(color: statusColor.withOpacity(0.8)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Product info
          if (!isManual) ...[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (result.imageUrl != null)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            result.imageUrl!,
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      result.productName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (result.brand.isNotEmpty)
                      Text(result.brand,
                          style: TextStyle(color: Colors.grey[600])),
                    Text(
                      'Barcode: ${result.barcode}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Flagged ingredients
          if (result.flaggedIngredients.isNotEmpty) ...[
            const Text(
              'Flagged Ingredients',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.flaggedIngredients.map((ing) => _FlaggedIngredientTile(ingredient: ing)),
            const SizedBox(height: 12),
          ],

          // All ingredients
          if (result.ingredients.isNotEmpty) ...[
            const Text(
              'All Ingredients',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result.ingredients.join(', '),
                style: const TextStyle(fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is an automated check. Always verify with a certified halal authority for absolute certainty. Product formulations may change.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isManual
                  ? () => setState(() => _result = null)
                  : _reset,
              icon: Icon(
                  isManual ? Icons.edit : Icons.qr_code_scanner),
              label: Text(isManual ? 'Check Another' : 'Scan Another'),
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 3: E-Numbers Reference ──────────────────────────────────────────────

  Widget _buildENumbersTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Haram ❌'),
              Tab(text: 'Doubtful ⚠️'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildENumberList(HalalCheckerService.haramENumbers, Colors.red),
                _buildENumberList(HalalCheckerService.doubtfulENumbers, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildENumberList(Map<String, String> numbers, Color color) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: numbers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = numbers.entries.elementAt(index);
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              entry.key.toUpperCase(),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          title: Text(
            entry.value.split('—').first.trim(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: entry.value.contains('—')
              ? Text(
                  entry.value.split('—').last.trim(),
                  style: const TextStyle(fontSize: 12),
                )
              : null,
        );
      },
    );
  }
}

class _FlaggedIngredientTile extends StatelessWidget {
  final IngredientResult ingredient;
  const _FlaggedIngredientTile({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (ingredient.status) {
      case HalalStatus.haram:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case HalalStatus.doubtful:
        color = Colors.orange;
        icon = Icons.warning_amber;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  ingredient.reason,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Scan overlay painter
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    const boxSize = 250.0;
    final left = (size.width - boxSize) / 2;
    final top = (size.height - boxSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, boxSize, boxSize);

    // Dark overlay with hole
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Corner markers
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const cornerLen = 24.0;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLen, top), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(left + boxSize - cornerLen, top), Offset(left + boxSize, top), cornerPaint);
    canvas.drawLine(Offset(left + boxSize, top), Offset(left + boxSize, top + cornerLen), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(left, top + boxSize - cornerLen), Offset(left, top + boxSize), cornerPaint);
    canvas.drawLine(Offset(left, top + boxSize), Offset(left + cornerLen, top + boxSize), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(left + boxSize - cornerLen, top + boxSize), Offset(left + boxSize, top + boxSize), cornerPaint);
    canvas.drawLine(Offset(left + boxSize, top + boxSize), Offset(left + boxSize, top + boxSize - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
