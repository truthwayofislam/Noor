import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/islamic_calculator_service.dart';
import '../../models/zakat_model.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _service = IslamicCalculatorService();
  final List<ZakatAsset> _assets = [];
  
  final _goldPriceController = TextEditingController(text: '2000');
  final _silverPriceController = TextEditingController(text: '25');
  String _selectedCurrency = 'USD';
  
  final Map<String, String> _currencies = {
    'USD': '\$ (US Dollar)',
    'EUR': '€ (Euro)',
    'GBP': '£ (British Pound)',
    'PKR': 'Rs (Pakistani Rupee)',
    'INR': '₹ (Indian Rupee)',
    'SAR': 'SR (Saudi Riyal)',
    'AED': 'AED (UAE Dirham)',
    'MYR': 'RM (Malaysian Ringgit)',
    'IDR': 'Rp (Indonesian Rupiah)',
    'TRY': '₺ (Turkish Lira)',
    'EGP': 'E£ (Egyptian Pound)',
    'BDT': '৳ (Bangladeshi Taka)',
  };
  
  ZakatCalculation? _result;

  @override
  void dispose() {
    _goldPriceController.dispose();
    _silverPriceController.dispose();
    super.dispose();
  }

  void _addAsset(AssetType type, String name, double amount) {
    setState(() {
      _assets.add(ZakatAsset(name: name, amount: amount, type: type));
      _result = null;
    });
  }

  void _removeAsset(int index) {
    setState(() {
      _assets.removeAt(index);
      _result = null;
    });
  }

  void _calculate() {
    final goldPrice = double.tryParse(_goldPriceController.text) ?? 0;
    final silverPrice = double.tryParse(_silverPriceController.text) ?? 0;

    if (_assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one asset')),
      );
      return;
    }

    setState(() {
      _result = _service.calculateZakat(
        assets: _assets,
        goldPricePerGram: goldPrice,
        silverPricePerGram: silverPrice,
        currency: _selectedCurrency,
      );
    });
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddAssetDialog(onAdd: _addAsset),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Calculator - زکوٰۃ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPriceInputs(),
            const SizedBox(height: 24),
            _buildAssetsList(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddAssetDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Asset'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF2E7D32),
              ),
            ),
            if (_assets.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Zakat'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFF1976D2),
                ),
              ),
            ],
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

  Widget _buildPriceInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Market Prices',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              items: _currencies.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCurrency = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _goldPriceController,
              decoration: InputDecoration(
                labelText: 'Gold Price (per gram)',
                prefixText: '$_selectedCurrency ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _silverPriceController,
              decoration: InputDecoration(
                labelText: 'Silver Price (per gram)',
                prefixText: '$_selectedCurrency ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsList() {
    if (_assets.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No assets added yet', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Assets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assets.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final asset = _assets[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_getAssetIcon(asset.type), color: const Color(0xFF2E7D32)),
                  title: Text(asset.name),
                  subtitle: Text(_getAssetTypeName(asset.type)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_selectedCurrency ${asset.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeAsset(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Card(
      color: _result!.reachedNisab ? const Color(0xFF2E7D32).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              _result!.reachedNisab ? Icons.check_circle : Icons.info_outline,
              size: 64,
              color: _result!.reachedNisab ? const Color(0xFF2E7D32) : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _result!.reachedNisab ? 'Zakat is Due' : 'Nisab Not Reached',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _result!.reachedNisab ? const Color(0xFF2E7D32) : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            _ResultRow('Total Wealth:', '$_selectedCurrency ${_result!.totalWealth.toStringAsFixed(2)}'),
            const Divider(),
            _ResultRow('Nisab (Silver):', '$_selectedCurrency ${_result!.nisabAmount.toStringAsFixed(2)}'),
            const Divider(),
            _ResultRow(
              'Zakat Due (2.5%):',
              '$_selectedCurrency ${_result!.zakatDue.toStringAsFixed(2)}',
              highlight: true,
            ),
            if (_result!.reachedNisab) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make sure this wealth was in your possession for a full lunar year (Hawl)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHanafiRules() {
    final rules = _service.getHanafiZakatRules();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Hanafi Zakat Rules',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.cash: return Icons.money;
      case AssetType.gold: return Icons.diamond;
      case AssetType.silver: return Icons.currency_exchange;
      case AssetType.business: return Icons.business;
      case AssetType.stocks: return Icons.trending_up;
      case AssetType.savingsAccount: return Icons.savings;
      case AssetType.receivables: return Icons.receipt_long;
    }
  }

  String _getAssetTypeName(AssetType type) {
    switch (type) {
      case AssetType.cash: return 'Cash';
      case AssetType.gold: return 'Gold';
      case AssetType.silver: return 'Silver';
      case AssetType.business: return 'Business Inventory';
      case AssetType.stocks: return 'Stocks/Shares';
      case AssetType.savingsAccount: return 'Savings Account';
      case AssetType.receivables: return 'Money Owed to You';
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
              color: highlight ? const Color(0xFF2E7D32) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAssetDialog extends StatefulWidget {
  final Function(AssetType, String, double) onAdd;

  const _AddAssetDialog({required this.onAdd});

  @override
  State<_AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<_AddAssetDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  AssetType _selectedType = AssetType.cash;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Asset'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<AssetType>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Asset Type', border: OutlineInputBorder()),
            items: AssetType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(_getTypeName(type)));
            }).toList(),
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Asset Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(labelText: 'Amount ($_selectedCurrency)', border: const OutlineInputBorder()),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text) ?? 0;
            if (_nameController.text.isEmpty || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }
            widget.onAdd(_selectedType, _nameController.text, amount);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _getTypeName(AssetType type) {
    switch (type) {
      case AssetType.cash: return 'Cash';
      case AssetType.gold: return 'Gold';
      case AssetType.silver: return 'Silver';
      case AssetType.business: return 'Business Inventory';
      case AssetType.stocks: return 'Stocks/Shares';
      case AssetType.savingsAccount: return 'Savings Account';
      case AssetType.receivables: return 'Money Owed to You';
    }
  }
}
