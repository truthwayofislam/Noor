import '../models/zakat_model.dart';

class IslamicCalculatorService {
  // ══════════════════════════════════════════════════════════════════════════
  // ZAKAT CALCULATION - Hanafi Fiqh
  // ══════════════════════════════════════════════════════════════════════════
  
  /// Calculate Zakat based on Hanafi principles
  /// - Nisab: 7.5 tola gold (87.48g) or 52.5 tola silver (612.36g)
  /// - Rate: 2.5% of total wealth
  /// - Wealth must be possessed for full lunar year (Hawl)
  ZakatCalculation calculateZakat({
    required List<ZakatAsset> assets,
    required double goldPricePerGram,
    required double silverPricePerGram,
    String currency = 'PKR',
  }) {
    // Calculate total wealth
    double totalWealth = 0;
    for (var asset in assets) {
      totalWealth += asset.amount;
    }

    // Calculate Nisab (using silver - more beneficial for poor as per Hanafi)
    // 612.36 grams of silver
    final double nisabAmount = 612.36 * silverPricePerGram;

    // Check if Nisab is reached
    final reachedNisab = totalWealth >= nisabAmount;

    // Calculate Zakat (2.5%)
    final zakatDue = reachedNisab ? totalWealth * 0.025 : 0;

    return ZakatCalculation(
      totalWealth: totalWealth,
      nisabAmount: nisabAmount,
      reachedNisab: reachedNisab,
      zakatDue: zakatDue,
      currency: currency,
    );
  }

  /// Get Hanafi-specific Zakat rules
  List<String> getHanafiZakatRules() {
    return [
      '• Nisab is based on 612.36g silver (more beneficial for poor)',
      '• 2.5% of total zakatable wealth',
      '• Wealth must be in possession for one lunar year (Hawl)',
      '• Include: Cash, gold, silver, business goods, stocks, savings',
      '• Exclude: Personal residence, personal vehicle, daily use items',
      '• Debts reduce zakatable wealth',
      '• Business inventory is zakatable at market value',
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INHERITANCE CALCULATION - Hanafi Fiqh
  // ══════════════════════════════════════════════════════════════════════════

  /// Calculate inheritance shares according to Hanafi school
  InheritanceCalculation calculateInheritance({
    required double totalEstate,
    required List<Heir> heirs,
    bool hasWill = false,
    double willAmount = 0,
  }) {
    final Map<String, double> shares = {};
    final List<String> notes = [];

    // Deduct debts and funeral expenses first (Islamic principle)
    double distributableEstate = totalEstate;

    // Will can be max 1/3 of estate (Hanafi & general Islamic law)
    if (hasWill) {
      final maxWill = totalEstate / 3;
      final validWill = willAmount > maxWill ? maxWill : willAmount;
      distributableEstate -= validWill;
      notes.add('Will amount: ${validWill.toStringAsFixed(2)} (max 1/3 allowed)');
    }

    // Find primary heirs
    final hasSpouse = heirs.any((h) => h.relationship == 'spouse');
    final hasSon = heirs.any((h) => h.relationship == 'son');
    final hasDaughter = heirs.any((h) => h.relationship == 'daughter');
    final hasFather = heirs.any((h) => h.relationship == 'father');
    final hasMother = heirs.any((h) => h.relationship == 'mother');

    // HANAFI PRINCIPLES FOR INHERITANCE:
    
    // 1. Spouse's share (if present)
    if (hasSpouse) {
      final spouse = heirs.firstWhere((h) => h.relationship == 'spouse');
      double spouseShare;
      
      if (spouse.gender == Gender.female) {
        // Wife's share
        spouseShare = (hasSon || hasDaughter) 
            ? distributableEstate / 8  // 1/8 if children exist
            : distributableEstate / 4; // 1/4 if no children
        shares['Wife'] = spouseShare;
      } else {
        // Husband's share
        spouseShare = (hasSon || hasDaughter)
            ? distributableEstate / 4  // 1/4 if children exist
            : distributableEstate / 2; // 1/2 if no children
        shares['Husband'] = spouseShare;
      }
      distributableEstate -= spouseShare;
    }

    // 2. Parents' share
    if (hasFather) {
      double fatherShare;
      if (hasSon) {
        // Father gets 1/6 if son exists
        fatherShare = distributableEstate / 6;
        shares['Father'] = fatherShare;
        distributableEstate -= fatherShare;
      } else {
        // Father is residuary if no son
        notes.add('Father is residuary heir (will receive remaining)');
      }
    }

    if (hasMother) {
      double motherShare;
      if (hasSon || hasDaughter) {
        // Mother gets 1/6 if children exist
        motherShare = distributableEstate / 6;
      } else {
        // Mother gets 1/3 if no children
        motherShare = distributableEstate / 3;
      }
      shares['Mother'] = motherShare;
      distributableEstate -= motherShare;
    }

    // 3. Children's share (Asabah - residuary)
    if (hasSon || hasDaughter) {
      final sons = heirs.where((h) => h.relationship == 'son').fold(0, (sum, h) => sum + h.count);
      final daughters = heirs.where((h) => h.relationship == 'daughter').fold(0, (sum, h) => sum + h.count);

      // In Hanafi: Son gets double of daughter (2:1 ratio)
      // Total shares = sons*2 + daughters*1
      final totalShares = (sons * 2) + daughters;

      if (totalShares > 0) {
        final shareValue = distributableEstate / totalShares;
        
        if (sons > 0) {
          shares['Son(s) - $sons'] = shareValue * 2 * sons;
        }
        if (daughters > 0) {
          shares['Daughter(s) - $daughters'] = shareValue * daughters;
        }
        
        notes.add('Children inherit as residuary (Asabah)');
        notes.add('Male:Female ratio = 2:1 as per Quran 4:11');
      }
    }

    notes.add('Calculation based on Hanafi school of jurisprudence');
    notes.add('Complex cases may require consultation with scholar');

    return InheritanceCalculation(
      totalEstate: totalEstate,
      shares: shares,
      notes: notes,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MURABAHA (Islamic Finance) - Hanafi Fiqh
  // ══════════════════════════════════════════════════════════════════════════

  /// Calculate Murabaha (cost-plus financing) - Shariah compliant
  MurabahaCalculation calculateMurabaha({
    required double costPrice,
    required double profitAmount,
    required int months,
  }) {
    final sellingPrice = costPrice + profitAmount;
    final profitPercentage = (profitAmount / costPrice) * 100;
    final monthlyPayment = sellingPrice / months;

    return MurabahaCalculation(
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      profit: profitAmount,
      profitPercentage: profitPercentage,
      installments: months,
      monthlyPayment: monthlyPayment,
    );
  }

  List<String> getMurabahaRules() {
    return [
      '• Murabaha is cost-plus-profit sale (Halal)',
      '• Seller must own asset before selling',
      '• Profit must be clearly disclosed',
      '• No interest (Riba) - only markup on cost',
      '• Late payment penalty is NOT allowed in Hanafi fiqh',
      '• Asset risk transfers to buyer upon possession',
      '• Both parties must agree on terms before contract',
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FIDYA & KAFFARAH - Hanafi Fiqh
  // ══════════════════════════════════════════════════════════════════════════

  /// Calculate Fidya for missed fasts (for those permanently unable to fast)
  FidyaCalculation calculateFidya({
    required int missedFasts,
    required double wheatPricePerKg,
  }) {
    // Hanafi: Fidya = Sadaqah al-Fitr amount
    // Feed one poor person with 1.6kg wheat (or its value) per missed fast
    final fidyaPerFast = 1.6 * wheatPricePerKg;
    final totalFidya = missedFasts * fidyaPerFast;

    return FidyaCalculation(
      missedFasts: missedFasts,
      fidyaPerFast: fidyaPerFast,
      totalFidya: totalFidya,
      method: 'monetary',
    );
  }

  /// Calculate Kaffarah (expiation) for various violations
  KaffarahCalculation calculateKaffarah({
    required KaffarahType type,
    required double wheatPricePerKg,
  }) {
    switch (type) {
      case KaffarahType.fastingBroken:
        // Breaking Ramadan fast deliberately requires:
        // 1. Fast 60 consecutive days, OR
        // 2. Feed 60 poor people
        return KaffarahCalculation(
          type: type,
          requirement: 'Fast 60 consecutive days OR Feed 60 poor people',
          monetaryValue: 60 * 1.6 * wheatPricePerKg,
          steps: [
            '1. Fast for 60 consecutive days (preferred)',
            '2. If unable, feed 60 poor people (1.6kg wheat each)',
            '3. Monetary value: ${(60 * 1.6 * wheatPricePerKg).toStringAsFixed(2)}',
            'Note: This is for DELIBERATELY breaking fast',
          ],
        );

      case KaffarahType.oath:
        // Breaking oath requires:
        // Feed 10 poor people OR clothe them OR fast 3 days
        return KaffarahCalculation(
          type: type,
          requirement: 'Feed/Clothe 10 poor OR Fast 3 days',
          monetaryValue: 10 * 1.6 * wheatPricePerKg,
          steps: [
            '1. Feed 10 poor people (1.6kg wheat each), OR',
            '2. Clothe 10 poor people, OR',
            '3. If unable, fast for 3 days',
            '4. Monetary value: ${(10 * 1.6 * wheatPricePerKg).toStringAsFixed(2)}',
          ],
        );

      case KaffarahType.zihar:
        // Zihar requires: Fast 60 consecutive days OR feed 60 poor
        return KaffarahCalculation(
          type: type,
          requirement: 'Free a slave (N/A today), Fast 60 days, OR Feed 60 poor',
          monetaryValue: 60 * 1.6 * wheatPricePerKg,
          steps: [
            '1. Fast 60 consecutive days, OR',
            '2. Feed 60 poor people (1.6kg wheat each)',
            '3. Monetary value: ${(60 * 1.6 * wheatPricePerKg).toStringAsFixed(2)}',
            'Note: Consult scholar for specific cases',
          ],
        );
    }
  }

  List<String> getFidyaKaffarahRules() {
    return [
      '• Fidya: For those permanently unable to fast (old age, illness)',
      '• Kaffarah: Expiation for deliberate violations',
      '• Hanafi standard: 1.6kg wheat per person',
      '• Can give monetary equivalent to poor',
      '• Must be given to eligible recipients (poor Muslims)',
      '• Fasting is preferred over monetary when able',
    ];
  }
}
