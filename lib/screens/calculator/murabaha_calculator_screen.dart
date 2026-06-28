import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/islamic_calculator_service.dart';

class MurabahaCalculatorScreen extends StatefulWidget {
  const MurabahaCalculatorScreen({super.key});

  @override
  State<MurabahaCalculatorScreen> createState() => _MurabahaCalculatorScreenState();
}

class _MurabahaCalculatorScreenState extends State<MurabahaCalculatorScreen> {
  final _service = IslamicCalculatorService();
  final _costController = TextEditingController();
  final _profitController = TextEditingController();
  final _monthsController = TextEditingController(text: '12');

  MurabahaCalculation? _result;

  @override
  void dispose() {
    _costController.dispose();
    _profitController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final cost = double.tryParse(_costController.text) ?? 0;
    final profit = double.tryParse(_profitController.text) ?? 0;
    final months = int.tryParse(_monthsController.text) ?? 12;

    if (cost <= 0 || profit <= 0 || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields with valid values')),
      );
      return;
    }

    setState(() {
      _result = _service.calculateMurabaha(
        costPrice: cost,
        profitAmount: profit,
        months: months,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Murabaha Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'What is Murabaha?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Murabaha is a Shariah-compliant sale where the seller discloses the cost and adds a profit markup. This is HALAL as it\'s a transparent sale, not interest-based lending.',
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
                      'Enter Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price',
                        prefixText: 'PKR ',
                        border: OutlineInputBorder(),
                        helperText: 'The actual cost of the asset',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _profitController,
                      decoration: const InputDecoration(
                        labelText: 'Profit Amount',
                        prefixText: 'PKR ',
                        border: OutlineInputBorder(),
                        helperText: 'Agreed profit (disclosed to buyer)',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _monthsController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Months',
                        border: OutlineInputBorder(),
                        helperText: 'Payment period',
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
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF1976D2),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResult(),
            ],

            const SizedBox(height: 24),
            _buildHanafiRules(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Card(
      color: const Color(0xFF1976D2).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 64, color: Color(0xFF1976D2)),
            const SizedBox(height: 16),
            const Text(
              'Payment Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _ResultRow('Cost Price:', 'PKR ${_result.costPrice.toStringAsFixed(2)}'),
            const Divider(),
            _ResultRow('Profit:', 'PKR ${_result.profit.toStringAsFixed(2)}'),
            const Divider(),
            _ResultRow('Profit Percentage:', '${_result.profitPercentage.toStringAsFixed(2)}%'),
            const Divider(),
            _ResultRow(
              'Total Selling Price:',
              'PKR ${_result.sellingPrice.toStringAsFixed(2)}',
              highlight: true,
            ),
            const Divider(),
            _ResultRow('Payment Period:', '${_result.installments} months'),
            const Divider(),
            _ResultRow(
              'Monthly Payment:',
              'PKR ${_result.monthlyPayment.toStringAsFixed(2)}',
              highlight: true,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is a Shariah-compliant transaction as profit is disclosed upfront',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHanafiRules() {
    final rules = _service.getMurabahaRules();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book, color: Color(0xFF1976D2)),
                SizedBox(width: 8),
                Text(
                  'Murabaha Rules (Hanafi Fiqh)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...rules.map((rule) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(rule, style: const TextStyle(fontSize: 13, height: 1.4)),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Difference from Riba: In Murabaha, you\'re buying an asset with disclosed markup. In Riba, you\'re borrowing money with compound interest. The first is Halal, the second is Haram.',
                      style: TextStyle(fontSize: 12),
                    ),
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
              color: highlight ? const Color(0xFF1976D2) : null,
            ),
          ),
        ],
      ),
    );
  }
}
