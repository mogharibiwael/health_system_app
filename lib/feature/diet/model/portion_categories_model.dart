import 'exchange_model.dart';

/// Extended portion plan matching reference app: main categories with portions + fat per serving.
/// Used for "تحديد الحصص للوجبات" (Determine portions for meals) table.
class PortionCategoriesPlan {
  int milkSkim;
  int milkLowFat;
  int milkWhole;
  int vegetables;
  int fruit;
  int starch;
  int otherCarbs;
  int meatVeryLean;
  int meatLean;
  int meatMediumFat;
  int meatHighFat;
  int fat;

  PortionCategoriesPlan({
    this.milkSkim = 0,
    this.milkLowFat = 0,
    this.milkWhole = 0,
    this.vegetables = 0,
    this.fruit = 0,
    this.starch = 0,
    this.otherCarbs = 0,
    this.meatVeryLean = 0,
    this.meatLean = 0,
    this.meatMediumFat = 0,
    this.meatHighFat = 0,
    this.fat = 0,
  });

  int get totalMilk => milkSkim + milkLowFat + milkWhole;
  int get totalCarbs => starch + otherCarbs;
  int get totalMeat => meatVeryLean + meatLean + meatMediumFat + meatHighFat;

  /// Fat grams per serving (from ExchangeDefinitions)
  static double fatPerServing(String key) {
    final d = definition(key);
    return d?.fatG.toDouble() ?? 0;
  }

  /// Carbs, protein, fat, calories per serving. otherCarbs uses starch-like values.
  static ExchangeServingDefinition? definition(String key) {
    switch (key) {
      case 'milkSkim':
        return ExchangeDefinitions.milkSkim;
      case 'milkLowFat':
        return ExchangeDefinitions.milkLowFat;
      case 'milkWhole':
        return ExchangeDefinitions.milkWhole;
      case 'vegetables':
        return ExchangeDefinitions.vegetables;
      case 'fruit':
        return ExchangeDefinitions.fruit;
      case 'starch':
        return ExchangeDefinitions.starch;
      case 'otherCarbs':
        return ExchangeDefinitions.starch; // same as starch for display
      case 'meatVeryLean':
        return ExchangeDefinitions.meatVeryLean;
      case 'meatLean':
        return ExchangeDefinitions.meatLean;
      case 'meatMediumFat':
        return ExchangeDefinitions.meatMediumFat;
      case 'meatHighFat':
        return ExchangeDefinitions.meatHighFat;
      case 'fat':
        return ExchangeDefinitions.fat;
      default:
        return null;
    }
  }

  /// Convert from DailyExchangePlan (single milk/meat type) to PortionCategoriesPlan
  static PortionCategoriesPlan fromDailyExchange(DailyExchangePlan plan) {
    final p = PortionCategoriesPlan(
      vegetables: plan.vegetables,
      fruit: plan.fruit,
      fat: plan.fat,
    );
    switch (plan.milkType) {
      case MilkType.skim:
        p.milkSkim = plan.milk;
        break;
      case MilkType.lowFat:
        p.milkLowFat = plan.milk;
        break;
      case MilkType.whole:
        p.milkWhole = plan.milk;
        break;
    }
    switch (plan.meatType) {
      case MeatType.veryLean:
        p.meatVeryLean = plan.meat;
        break;
      case MeatType.lean:
        p.meatLean = plan.meat;
        break;
      case MeatType.mediumFat:
        p.meatMediumFat = plan.meat;
        break;
      case MeatType.highFat:
        p.meatHighFat = plan.meat;
        break;
    }
    p.starch = plan.starch;
    p.otherCarbs = 0;
    return p;
  }

  /// Convert to DailyExchangePlan (uses first non-zero milk/meat for type)
  DailyExchangePlan toDailyExchange() {
    MilkType milkType = MilkType.lowFat;
    if (milkSkim > 0) milkType = MilkType.skim;
    else if (milkLowFat > 0) milkType = MilkType.lowFat;
    else if (milkWhole > 0) milkType = MilkType.whole;

    MeatType meatType = MeatType.lean;
    if (meatVeryLean > 0) meatType = MeatType.veryLean;
    else if (meatLean > 0) meatType = MeatType.lean;
    else if (meatMediumFat > 0) meatType = MeatType.mediumFat;
    else if (meatHighFat > 0) meatType = MeatType.highFat;

    final milk = totalMilk;
    final meat = totalMeat;
    final starchTotal = starch + otherCarbs;

    return DailyExchangePlan(
      starch: starchTotal,
      fruit: fruit,
      vegetables: vegetables,
      milk: milk,
      meat: meat,
      fat: fat,
      milkType: milkType,
      meatType: meatType,
    );
  }

  Map<String, int> toGroupMap() => {
        'milkSkim': milkSkim,
        'milkLowFat': milkLowFat,
        'milkWhole': milkWhole,
        'vegetables': vegetables,
        'fruit': fruit,
        'starch': starch,
        'otherCarbs': otherCarbs,
        'meatVeryLean': meatVeryLean,
        'meatLean': meatLean,
        'meatMediumFat': meatMediumFat,
        'meatHighFat': meatHighFat,
        'fat': fat,
      };

  static const List<String> categoryKeys = [
    'milkSkim',
    'milkLowFat',
    'milkWhole',
    'vegetables',
    'fruit',
    'starch',
    'otherCarbs',
    'meatVeryLean',
    'meatLean',
    'meatMediumFat',
    'meatHighFat',
    'fat',
  ];
}
