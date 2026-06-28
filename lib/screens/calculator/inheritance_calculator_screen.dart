import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/islamic_calculator_service.dart';
import '../../models/zakat_model.dart';

class InheritanceCalculatorScreen extends StatefulWidget {
  const InheritanceCalculatorScreen({super.key});

  @override
  State<InheritanceCalculatorScreen> createState() => _InheritanceCalculatorScreenState();
}

class _InheritanceCalculatorScreenState extends State<InheritanceCalculatorScreen> {
  final _service = IslamicCalculatorService();
  final _estateController = TextEditingController();
  final _willController = TextEditingController();
  
  final List<Heir> _heirs = [];
  bool _hasWill = false;
  InheritanceCalculation? _result;

  @override
  void dispose() {
    _estateController.dispose();
    _willController.dispose();
    super.dispose();
  }

  void _addHeir(String relationship, int count, Gender gender) {
    setState(() {
      _heirs.add(Heir(relationship: relationship, count: count, gender: gender));
      _result = null;
    });
  }

  void _removeHeir(int index) {
    setState(() {
      _heirs.removeAt(index);
      _result = null;
    });
  }

  void _calculate() {
    final estate = double.tryParse(_estateController.text) ?? 0;
    final will = double.tryParse(_willController.text) ?? 0;

    if (estate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter estate amount')),
      );
      return;
    }

    if (_heirs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one heir')),
      );
      return;
    }

    setState(() {
      _result = _service.calculateInheritance(
        totalEstate: estate,
        heirs: _heirs,
        hasWill: _hasWill,
        willAmount: will,
      );
    });
  }

  void _showAddHeirDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddHeirDialog(onAdd: _addHeir),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inheritance - میراث'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEstateInput(),
            const SizedBox(height: 16),
            _buildWillSection(),
            const SizedBox(height: 24),
            _buildHeirsList(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddHeirDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Heir'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF00897B),
              ),
            ),
            if (_heirs.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Shares'),
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
            _buildHanafiNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstateInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Estate Value',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _estateController,
              decoration: const InputDecoration(
                labelText: 'Estate Amount',
                prefixText: 'Amount: ',
                border: OutlineInputBorder(),
                helperText: 'After deducting debts & funeral expenses',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWillSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Was there a Will?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Switch(
                  value: _hasWill,
                  onChanged: (val) => setState(() {
                    _hasWill = val;
                    _result = null;
                  }),
                ),
              ],
            ),
            if (_hasWill) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _willController,
                decoration: const InputDecoration(
                  labelText: 'Will Amount',
                  prefixText: 'Amount: ',
                  border: OutlineInputBorder(),
                  helperText: 'Maximum 1/3 of estate allowed',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeirsList() {
    if (_heirs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.family_restroom, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No heirs added yet', style: TextStyle(color: Colors.grey[600])),
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
            const Text('Heirs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _heirs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final heir = _heirs[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    heir.gender == Gender.male ? Icons.man : Icons.woman,
                    color: const Color(0xFF00897B),
                  ),
                  title: Text('${heir.count} ${heir.relationship}${heir.count > 1 ? 's' : ''}'),
                  subtitle: Text(heir.gender == Gender.male ? 'Male' : 'Female'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeHeir(index),
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
      color: const Color(0xFF00897B).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.pie_chart, size: 64, color: Color(0xFF00897B)),
            const SizedBox(height: 16),
            const Text(
              'Inheritance Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'توزیع میراث',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            ..._result!.shares.entries.map((entry) {
              final percentage = (entry.value / _result!.totalEstate) * 100;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text(
                        '${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00897B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFF00897B),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
            if (_result!.notes.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text('Important Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._result!.notes.map((note) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $note', style: const TextStyle(fontSize: 12)),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHanafiNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book, color: Color(0xFF00897B)),
                SizedBox(width: 8),
                Text('Hanafi Inheritance Principles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('• Quran 4:11 - "Allah instructs you concerning your children..."', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            const Text('• Male heir receives double the share of female heir', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            const Text('• Will limited to 1/3 of estate maximum', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            const Text('• Debts must be paid before distribution', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            const Text('• Spouses, parents, and children are primary heirs', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Note: Complex cases (e.g., multiple wives, siblings, grandparents) require consultation with an Islamic scholar.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddHeirDialog extends StatefulWidget {
  final Function(String, int, Gender) onAdd;

  const _AddHeirDialog({required this.onAdd});

  @override
  State<_AddHeirDialog> createState() => _AddHeirDialogState();
}

class _AddHeirDialogState extends State<_AddHeirDialog> {
  String _relationship = 'son';
  int _count = 1;
  Gender _gender = Gender.male;

  final List<String> _relationships = ['son', 'daughter', 'spouse', 'father', 'mother'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Heir'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _relationship,
            decoration: const InputDecoration(labelText: 'Relationship', border: OutlineInputBorder()),
            items: _relationships.map((r) => DropdownMenuItem(value: r, child: Text(r.capitalize()))).toList(),
            onChanged: (val) {
              setState(() {
                _relationship = val!;
                if (_relationship == 'son' || _relationship == 'father') _gender = Gender.male;
                if (_relationship == 'daughter' || _relationship == 'mother') _gender = Gender.female;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Count', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) => _count = int.tryParse(val) ?? 1,
            controller: TextEditingController(text: '1'),
          ),
          if (_relationship == 'spouse') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<Gender>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: Gender.male, child: Text('Husband')),
                DropdownMenuItem(value: Gender.female, child: Text('Wife')),
              ],
              onChanged: (val) => setState(() => _gender = val!),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            widget.onAdd(_relationship, _count, _gender);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
