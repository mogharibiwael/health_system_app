import '../model/exchange_model.dart';

/// Converts macro targets (carbs, protein, fat grams) to daily exchange servings.
class ExchangeCalculator {
  /// Default: vegetables 3, fruit 2, milk 1-2
  static DailyExchangePlan fromMacros({
    required double targetCarbsG,
    required double targetProteinG,
    required double targetFatG,
    int vegetablesMin = 3,
    int fruitMin = 2,
    int milkServings = 1,
    MilkType milkType = MilkType.lowFat,
    MeatType meatType = MeatType.lean,
  }) {
    final milk = ExchangeDefinitions.getMilk(milkType);
    final meat = ExchangeDefinitions.getMeat(meatType);
    final veg = ExchangeDefinitions.vegetables;
    final fru = ExchangeDefinitions.fruit;
    final fatDef = ExchangeDefinitions.fat;

    int vegS = vegetablesMin;
    int fruS = fruitMin;
    int milkS = milkServings.clamp(1, 2);

    double carbsUsed = (vegS * veg.carbsG + fruS * fru.carbsG + milkS * milk.carbsG).toDouble();
    double proteinUsed = (vegS * veg.proteinG + fruS * fru.proteinG + milkS * milk.proteinG).toDouble();
    double fatUsed = (vegS * veg.fatG + fruS * fru.fatG + milkS * milk.fatG).toDouble();

    double proteinRemaining = (targetProteinG - proteinUsed).clamp(0.0, 999.0);
    int meatS = (proteinRemaining / meat.proteinG).round().clamp(0, 15);

    proteinUsed += (meatS * meat.proteinG).toDouble();
    fatUsed += (meatS * meat.fatG).toDouble();

    double fatRemaining = (targetFatG - fatUsed).clamp(0.0, 999.0);
    int fatS = (fatRemaining / fatDef.fatG).round().clamp(0, 10);

    fatUsed += (fatS * fatDef.fatG).toDouble();

    double carbsRemaining = (targetCarbsG - carbsUsed).clamp(0.0, 999.0);
    int starchS = (carbsRemaining / ExchangeDefinitions.starch.carbsG).round().clamp(0, 15);

    return DailyExchangePlan(
      starch: starchS,
      fruit: fruS,
      vegetables: vegS,
      milk: milkS,
      meat: meatS,
      fat: fatS,
      milkType: milkType,
      meatType: meatType,
    );
  }
}
