// Zakat Model - Hanafi Fiqh
class ZakatCalculation {
  final double totalWealth;
  final double nisabAmount;
  final bool reachedNisab;
  final double zakatDue;
  final String currency;

  ZakatCalculation({
    required this.totalWealth,
    required this.nisabAmount,
    required this.reachedNisab,
    required this.zakatDue,
    this.currency = 'PKR',
  });
}

class ZakatAsset {
  final String name;
  final double amount;
  final AssetType type;

  ZakatAsset({
    required this.name,
    required this.amount,
    required this.type,
  });
}

enum AssetType {
  cash,
  gold,
  silver,
  business,
  stocks,
  savingsAccount,
  receivables,
}

// Inheritance Model - Hanafi Fiqh
class InheritanceCalculation {
  final double totalEstate;
  final Map<String, double> shares;
  final List<String> notes;

  InheritanceCalculation({
    required this.totalEstate,
    required this.shares,
    required this.notes,
  });
}

class Heir {
  final String relationship;
  final int count;
  final Gender gender;

  Heir({
    required this.relationship,
    required this.count,
    this.gender = Gender.male,
  });
}

enum Gender { male, female }

// Loan/Murabaha Model - Hanafi Fiqh (Interest-free)
class MurabahaCalculation {
  final double costPrice;
  final double sellingPrice;
  final double profit;
  final double profitPercentage;
  final int installments;
  final double monthlyPayment;

  MurabahaCalculation({
    required this.costPrice,
    required this.sellingPrice,
    required this.profit,
    required this.profitPercentage,
    required this.installments,
    required this.monthlyPayment,
  });
}

// Fidya/Kaffarah Model - Hanafi Fiqh
class FidyaCalculation {
  final int missedFasts;
  final double fidyaPerFast;
  final double totalFidya;
  final String method; // 'feed_poor' or 'monetary'

  FidyaCalculation({
    required this.missedFasts,
    required this.fidyaPerFast,
    required this.totalFidya,
    required this.method,
  });
}

class KaffarahCalculation {
  final KaffarahType type;
  final String requirement;
  final double monetaryValue;
  final List<String> steps;

  KaffarahCalculation({
    required this.type,
    required this.requirement,
    required this.monetaryValue,
    required this.steps,
  });
}

enum KaffarahType {
  fastingBroken, // Deliberately breaking fast in Ramadan
  oath, // Breaking an oath
  zihar, // Specific type of divorce statement
}
