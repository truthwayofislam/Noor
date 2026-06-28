import 'package:flutter/material.dart';
import 'zakat_calculator_screen.dart';
import 'inheritance_calculator_screen.dart';
import 'murabaha_calculator_screen.dart';
import 'fidya_kaffarah_calculator_screen.dart';

class IslamicCalculatorScreen extends StatelessWidget {
  const IslamicCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Calculator - اسلامی کیلکولیٹر'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.calculate, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Islamic Calculators',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'According to Hanafi Fiqh',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    'امام ابو حنیفہ کے مطابق',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _CalculatorCard(
              title: 'Zakat Calculator',
              titleUrdu: 'زکوٰۃ کیلکولیٹر',
              description: 'Calculate your Zakat on wealth, gold, silver & business',
              icon: Icons.mosque,
              color: const Color(0xFF2E7D32),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _CalculatorCard(
              title: 'Inheritance Calculator',
              titleUrdu: 'میراث کیلکولیٹر',
              description: 'Calculate Islamic inheritance shares (Fara\'id)',
              icon: Icons.family_restroom,
              color: const Color(0xFF00897B),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InheritanceCalculatorScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _CalculatorCard(
              title: 'Murabaha Calculator',
              titleUrdu: 'مرابحہ کیلکولیٹر',
              description: 'Shariah-compliant financing calculator (Interest-free)',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF1976D2),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MurabahaCalculatorScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _CalculatorCard(
              title: 'Fidya & Kaffarah',
              titleUrdu: 'فدیہ اور کفارہ',
              description: 'Calculate Fidya for missed fasts & Kaffarah',
              icon: Icons.food_bank,
              color: const Color(0xFFD84315),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FidyaKaffarahCalculatorScreen()),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Important Note',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'These calculations are based on Hanafi school of jurisprudence. For complex situations, please consult with a qualified Islamic scholar.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                        ),
                      ],
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

class _CalculatorCard extends StatelessWidget {
  final String title;
  final String titleUrdu;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CalculatorCard({
    required this.title,
    required this.titleUrdu,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(titleUrdu, style: TextStyle(fontSize: 13, color: Colors.grey[600]), textDirection: TextDirection.rtl),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
