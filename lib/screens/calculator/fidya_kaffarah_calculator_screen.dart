import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/islamic_calculator_service.dart';
import '../../models/zakat_model.dart';

class FidyaKaffarahCalculatorScreen extends StatefulWidget {
  const FidyaKaffarahCalculatorScreen({super.key});

  @override
  State<FidyaKaffarahCalculatorScreen> createState() => _FidyaKaffarahCalculatorScreenState();
}

class _FidyaKaffarahCalculatorScreenState extends State<FidyaKaffarahCalculatorScreen> with SingleTickerProviderStateMixin {
  final _service = IslamicCalculatorService();
  late TabController _tabController;

  // Fidya
  final _missedFastsController = TextEditingController();
  final _wheatPriceController = TextEditingController(text: '150');
  FidyaCalculation? _fidyaResult;

  // Kaffarah
  KaffarahType _selectedKaffarah = KaffarahType.fastingBroken;
  KaffarahCalculation? _kaffarahResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _missedFastsController.dispose();
    _wheatPriceController.dispose();
    super.dispose();
  }

  void _calculateFidya() {
    final missedFasts = int.tryParse(_missedFastsController.text) ?? 0;
    final wheatPrice = double.tryParse(_wheatPriceController.text) ?? 0;

    if (missedFasts <= 0 || wheatPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values')),
      );
      return;
    }

    setState(() {
      _fidyaResult = _service.calculateFidya(
        missedFasts: missedFasts,
        wheatPricePerKg: wheatPrice,
      );
    });
  }

  void _calculateKaffarah() {
    final wheatPrice = double.tryParse(_wheatPriceController.text) ?? 0;

    if (wheatPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter wheat price')),
      );
      return;
    }

    setState(() {
      _kaffarahResult = _service.calculateKaffarah(
        type: _selectedKaffarah,
        wheatPricePerKg: wheatPrice,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fidya & Kaffarah'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Fidya - فدیہ'),
            Tab(text: 'Kaffarah - کفارہ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFidyaTab(),
          _buildKaffarahTab(),
        ],
      ),
    );
  }

  Widget _buildFidyaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: const Color(0xFFD84315).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.food_bank, color: Color(0xFFD84315), size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'What is Fidya?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fidya is a compensation for those who are PERMANENTLY unable to fast (elderly, chronically ill). For each missed fast, feed one poor person with 1.6kg wheat or its monetary value.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calculate Fidya',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _wheatPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Wheat Price (per kg)',
                      prefixText: 'Price: ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _missedFastsController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Missed Fasts',
                      border: OutlineInputBorder(),
                      helperText: 'How many fasts were missed?',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _calculateFidya,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Fidya'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: const Color(0xFFD84315),
            ),
          ),

          if (_fidyaResult != null) ...[
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFFD84315).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, size: 64, color: Color(0xFFD84315)),
                    const SizedBox(height: 16),
                    const Text(
                      'Fidya Amount',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _ResultRow('Missed Fasts:', '${_fidyaResult!.missedFasts}'),
                    const Divider(),
                    _ResultRow('Fidya per Fast:', 'PKR ${_fidyaResult!.fidyaPerFast.toStringAsFixed(2)}'),
                    const Divider(),
                    _ResultRow(
                      'Total Fidya:',
                      'PKR ${_fidyaResult!.totalFidya.toStringAsFixed(2)}',
                      highlight: true,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Give this amount to poor/needy Muslims',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'You can give 1.6kg wheat per fast or its monetary equivalent',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFD84315)),
                      SizedBox(width: 8),
                      Text('Important Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('• Fidya is ONLY for those permanently unable to fast', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 4),
                  Text('• If you can make up fasts later, you must fast (Qadha)', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 4),
                  Text('• Hanafi standard: 1.6kg wheat per missed fast', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 4),
                  Text('• Can be given as food or monetary equivalent', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaffarahTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: const Color(0xFFD84315).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFD84315), size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'What is Kaffarah?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kaffarah is an expiation for specific violations like deliberately breaking a Ramadan fast or breaking an oath. It requires fasting or feeding the poor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Violation Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<KaffarahType>(
                    value: _selectedKaffarah,
                    decoration: const InputDecoration(
                      labelText: 'Kaffarah Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: KaffarahType.fastingBroken,
                        child: Text('Deliberately Breaking Ramadan Fast'),
                      ),
                      DropdownMenuItem(
                        value: KaffarahType.oath,
                        child: Text('Breaking an Oath'),
                      ),
                      DropdownMenuItem(
                        value: KaffarahType.zihar,
                        child: Text('Zihar (Divorce Statement)'),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedKaffarah = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _wheatPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Wheat Price (per kg)',
                      prefixText: 'Price: ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _calculateKaffarah,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Kaffarah'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: const Color(0xFFD84315),
            ),
          ),

          if (_kaffarahResult != null) ...[
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFFD84315).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.list_alt, size: 64, color: Color(0xFFD84315)),
                          const SizedBox(height: 16),
                          Text(
                            _getKaffarahName(_kaffarahResult!.type),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Requirement:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _kaffarahResult!.requirement,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Steps to Fulfill:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ..._kaffarahResult!.steps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(step, style: const TextStyle(fontSize: 13)),
                    )),
                    const SizedBox(height: 16),
                    const Divider(),
                    _ResultRow(
                      'Monetary Value:',
                      'PKR ${_kaffarahResult!.monetaryValue.toStringAsFixed(2)}',
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          _buildKaffarahRules(),
        ],
      ),
    );
  }

  Widget _buildKaffarahRules() {
    final rules = _service.getFidyaKaffarahRules();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book, color: Color(0xFFD84315)),
                SizedBox(width: 8),
                Text('Hanafi Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...rules.map((rule) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(rule, style: const TextStyle(fontSize: 13, height: 1.4)),
            )),
          ],
        ),
      ),
    );
  }

  String _getKaffarahName(KaffarahType type) {
    switch (type) {
      case KaffarahType.fastingBroken:
        return 'Kaffarah for Breaking Fast';
      case KaffarahType.oath:
        return 'Kaffarah for Breaking Oath';
      case KaffarahType.zihar:
        return 'Kaffarah for Zihar';
    }
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResultRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: highlight ? 16 : 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: highlight ? const Color(0xFFD84315) : null,
            ),
          ),
        ],
      ),
    );
  }
}
