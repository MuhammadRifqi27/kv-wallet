import '../../core/utils/json_parsing.dart';

/// Models for docs/mobile-api-report.md. Everything is computed server-side —
/// these only parse. Percentages are plain numbers (`91.52` = 91,52%) and
/// several are documented nullable; those stay `double?` so the UI can tell
/// "no baseline" from a real 0.

Map<String, dynamic> _map(Object? value) => value is Map<String, dynamic> ? value : const {};

Map<String, dynamic>? _mapOrNull(Object? value) => value is Map<String, dynamic> ? value : null;

List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) parse) =>
    parseList(value).whereType<Map<String, dynamic>>().map(parse).toList();

/// Unwraps the `{"data": {...}}` envelope.
Map<String, dynamic> unwrapReport(Object? body) => _map(_map(body)['data']);

// ---------------------------------------------------------------- cash flow

class CashFlowRow {
  const CashFlowRow({
    required this.date,
    required this.income,
    required this.expense,
    required this.net,
    required this.balance,
  });

  factory CashFlowRow.fromJson(Map<String, dynamic> json) => CashFlowRow(
        date: parseDate(json['date']),
        income: parseDouble(json['income']),
        expense: parseDouble(json['expense']),
        net: parseDouble(json['net']),
        balance: parseDouble(json['balance']),
      );

  final DateTime? date;
  final double income;
  final double expense;
  final double net;
  final double balance;
}

class CashFlowReport {
  const CashFlowReport({
    required this.start,
    required this.end,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.otherMovements,
    required this.rows,
  });

  factory CashFlowReport.fromJson(Map<String, dynamic> json) => CashFlowReport(
        start: parseDate(json['start']),
        end: parseDate(json['end']),
        openingBalance: parseDouble(json['opening_balance']),
        closingBalance: parseDouble(json['closing_balance']),
        totalIncome: parseDouble(json['total_income']),
        totalExpense: parseDouble(json['total_expense']),
        net: parseDouble(json['net']),
        otherMovements: parseDouble(json['other_movements']),
        rows: _list(json['rows'], CashFlowRow.fromJson),
      );

  final DateTime? start;
  final DateTime? end;
  final double openingBalance;
  final double closingBalance;
  final double totalIncome;
  final double totalExpense;
  final double net;

  /// Balance change that isn't income/expense (e.g. investment revaluation) —
  /// `opening + net + otherMovements = closing`.
  final double otherMovements;

  /// Only days that have transactions.
  final List<CashFlowRow> rows;
}

// ------------------------------------------------------------- savings rate

class SavingsRatePoint {
  const SavingsRatePoint({
    required this.label,
    required this.income,
    required this.expense,
    required this.saved,
    required this.rate,
  });

  factory SavingsRatePoint.fromJson(Map<String, dynamic> json) => SavingsRatePoint(
        label: json['label'] as String? ?? '-',
        income: parseDouble(json['income']),
        expense: parseDouble(json['expense']),
        saved: parseDouble(json['saved']),
        rate: parseDouble(json['rate']),
      );

  final String label;
  final double income;
  final double expense;
  final double saved;
  final double rate;
}

class SavingsRateReport {
  const SavingsRateReport({
    required this.target,
    required this.series,
    required this.currentRate,
    this.previousRate,
    this.rateChange,
    required this.averageRate,
    this.best,
    this.worst,
    required this.monthsOnTarget,
    required this.monthsCounted,
  });

  factory SavingsRateReport.fromJson(Map<String, dynamic> json) {
    final best = _mapOrNull(json['best']);
    final worst = _mapOrNull(json['worst']);
    return SavingsRateReport(
      target: parseDouble(json['target']),
      series: _list(json['series'], SavingsRatePoint.fromJson),
      currentRate: parseDouble(json['current_rate']),
      previousRate: parseDoubleOrNull(json['previous_rate']),
      rateChange: parseDoubleOrNull(json['rate_change']),
      averageRate: parseDouble(json['average_rate']),
      best: best == null ? null : SavingsRatePoint.fromJson(best),
      worst: worst == null ? null : SavingsRatePoint.fromJson(worst),
      monthsOnTarget: json['months_on_target'] as int? ?? 0,
      monthsCounted: json['months_counted'] as int? ?? 0,
    );
  }

  final double target;

  /// Oldest first; length = requested `cycles`.
  final List<SavingsRatePoint> series;
  final double currentRate;
  final double? previousRate;

  /// Percentage-point difference, not a relative percent.
  final double? rateChange;
  final double averageRate;
  final SavingsRatePoint? best;
  final SavingsRatePoint? worst;
  final int monthsOnTarget;
  final int monthsCounted;
}

// ------------------------------------------------------------------ compare

class CompareCycle {
  const CompareCycle({required this.month, required this.year, this.start, this.end});

  factory CompareCycle.fromJson(Map<String, dynamic> json) => CompareCycle(
        month: json['month'] as int? ?? 1,
        year: json['year'] as int? ?? DateTime.now().year,
        start: parseDate(json['start']),
        end: parseDate(json['end']),
      );

  final int month;
  final int year;
  final DateTime? start;
  final DateTime? end;
}

/// One row of metrics/categories — `diff = b − a`, [diffPct] is relative to
/// `a` and null when `a` is 0.
class CompareMetric {
  const CompareMetric({this.name, required this.a, required this.b, required this.diff, this.diffPct});

  factory CompareMetric.fromJson(Map<String, dynamic> json) => CompareMetric(
        name: json['name'] as String?,
        a: parseDouble(json['a']),
        b: parseDouble(json['b']),
        diff: parseDouble(json['diff']),
        diffPct: parseDoubleOrNull(json['diff_pct']),
      );

  final String? name;
  final double a;
  final double b;
  final double diff;
  final double? diffPct;
}

class CompareReport {
  const CompareReport({
    required this.a,
    required this.b,
    required this.income,
    required this.expense,
    required this.net,
    required this.savingsRate,
    required this.categories,
  });

  factory CompareReport.fromJson(Map<String, dynamic> json) {
    final metrics = _map(json['metrics']);
    return CompareReport(
      a: CompareCycle.fromJson(_map(json['a'])),
      b: CompareCycle.fromJson(_map(json['b'])),
      income: CompareMetric.fromJson(_map(metrics['income'])),
      expense: CompareMetric.fromJson(_map(metrics['expense'])),
      net: CompareMetric.fromJson(_map(metrics['net'])),
      savingsRate: CompareMetric.fromJson(_map(metrics['savings_rate'])),
      categories: _list(json['categories'], CompareMetric.fromJson),
    );
  }

  /// Comparison cycle.
  final CompareCycle a;

  /// Main cycle (the selected month/year).
  final CompareCycle b;
  final CompareMetric income;
  final CompareMetric expense;
  final CompareMetric net;
  final CompareMetric savingsRate;

  /// Expense categories only, largest first.
  final List<CompareMetric> categories;
}

// ----------------------------------------------------------------- category

class ReportCategoryOption {
  const ReportCategoryOption({required this.id, required this.name, required this.type});

  factory ReportCategoryOption.fromJson(Map<String, dynamic> json) => ReportCategoryOption(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '-',
        type: json['type'] as String? ?? 'expense',
      );

  final int id;
  final String name;
  final String type;
}

class CategorySeriesPoint {
  const CategorySeriesPoint({required this.label, required this.total, required this.count});

  factory CategorySeriesPoint.fromJson(Map<String, dynamic> json) => CategorySeriesPoint(
        label: json['label'] as String? ?? '-',
        total: parseDouble(json['total']),
        count: json['count'] as int? ?? 0,
      );

  final String label;
  final double total;
  final int count;
}

class CategoryTransaction {
  const CategoryTransaction({this.date, required this.description, required this.account, required this.amount});

  factory CategoryTransaction.fromJson(Map<String, dynamic> json) => CategoryTransaction(
        date: parseDate(json['date']),
        description: json['description'] as String? ?? '-',
        account: json['account'] as String? ?? '-',
        amount: parseDouble(json['amount']),
      );

  final DateTime? date;
  final String description;
  final String account;
  final double amount;
}

class FrequentItem {
  const FrequentItem({required this.description, required this.count, required this.total});

  factory FrequentItem.fromJson(Map<String, dynamic> json) => FrequentItem(
        description: json['description'] as String? ?? '-',
        count: json['count'] as int? ?? 0,
        total: parseDouble(json['total']),
      );

  final String description;
  final int count;
  final double total;
}

class CategoryReport {
  const CategoryReport({
    this.category,
    required this.options,
    required this.cycles,
    this.start,
    this.end,
    this.series = const [],
    this.currentTotal = 0,
    this.currentCount = 0,
    this.previousTotal = 0,
    this.changePct,
    this.average = 0,
    this.sharePct = 0,
    this.topTransactions = const [],
    this.frequent = const [],
    this.transactions = const [],
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    final category = _mapOrNull(json['category']);
    return CategoryReport(
      category: category == null ? null : ReportCategoryOption.fromJson(category),
      options: _list(json['options'], ReportCategoryOption.fromJson),
      cycles: json['cycles'] as int? ?? 6,
      start: parseDate(json['start']),
      end: parseDate(json['end']),
      series: _list(json['series'], CategorySeriesPoint.fromJson),
      currentTotal: parseDouble(json['current_total']),
      currentCount: json['current_count'] as int? ?? 0,
      previousTotal: parseDouble(json['previous_total']),
      changePct: parseDoubleOrNull(json['change_pct']),
      average: parseDouble(json['average']),
      sharePct: parseDouble(json['share_pct']),
      topTransactions: _list(json['top_transactions'], CategoryTransaction.fromJson),
      frequent: _list(json['frequent'], FrequentItem.fromJson),
      transactions: _list(json['transactions'], CategoryTransaction.fromJson),
    );
  }

  /// Null when the user has no categories at all ("belum ada data").
  final ReportCategoryOption? category;
  final List<ReportCategoryOption> options;
  final int cycles;
  final DateTime? start;
  final DateTime? end;
  final List<CategorySeriesPoint> series;
  final double currentTotal;
  final int currentCount;
  final double previousTotal;
  final double? changePct;
  final double average;
  final double sharePct;
  final List<CategoryTransaction> topTransactions;
  final List<FrequentItem> frequent;
  final List<CategoryTransaction> transactions;
}

// --------------------------------------------------------------- unexpected

class UnexpectedExpenseItem {
  const UnexpectedExpenseItem({
    this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.categoryAverage,
    required this.ratio,
  });

  factory UnexpectedExpenseItem.fromJson(Map<String, dynamic> json) => UnexpectedExpenseItem(
        date: parseDate(json['date']),
        category: json['category'] as String? ?? '-',
        description: json['description'] as String? ?? '-',
        amount: parseDouble(json['amount']),
        categoryAverage: parseDouble(json['category_average']),
        ratio: parseDouble(json['ratio']),
      );

  final DateTime? date;
  final String category;
  final String description;
  final double amount;
  final double categoryAverage;

  /// `amount / categoryAverage` — `4.41` means 4,41×, not a percent.
  final double ratio;
}

class UnexpectedExpensesReport {
  const UnexpectedExpensesReport({
    this.start,
    this.end,
    required this.baselineCycles,
    required this.factor,
    required this.minSamples,
    required this.categoriesAnalyzed,
    required this.items,
    required this.totalFlagged,
  });

  factory UnexpectedExpensesReport.fromJson(Map<String, dynamic> json) => UnexpectedExpensesReport(
        start: parseDate(json['start']),
        end: parseDate(json['end']),
        baselineCycles: json['baseline_cycles'] as int? ?? 6,
        factor: parseDouble(json['factor']),
        minSamples: json['min_samples'] as int? ?? 3,
        categoriesAnalyzed: json['categories_analyzed'] as int? ?? 0,
        items: _list(json['items'], UnexpectedExpenseItem.fromJson),
        totalFlagged: parseDouble(json['total_flagged']),
      );

  final DateTime? start;
  final DateTime? end;
  final int baselineCycles;
  final double factor;
  final int minSamples;
  final int categoriesAnalyzed;
  final List<UnexpectedExpenseItem> items;
  final double totalFlagged;
}

// ------------------------------------------------------------ year in review

class YearMonthPoint {
  const YearMonthPoint({
    required this.label,
    required this.income,
    required this.expense,
    required this.net,
    required this.rate,
  });

  factory YearMonthPoint.fromJson(Map<String, dynamic> json) => YearMonthPoint(
        label: json['label'] as String? ?? '-',
        income: parseDouble(json['income']),
        expense: parseDouble(json['expense']),
        net: parseDouble(json['net']),
        rate: parseDouble(json['rate']),
      );

  final String label;
  final double income;
  final double expense;
  final double net;
  final double rate;
}

class YearBudgetMonth {
  const YearBudgetMonth({
    required this.label,
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.usedPct,
    required this.categories,
    required this.overCount,
  });

  factory YearBudgetMonth.fromJson(Map<String, dynamic> json) => YearBudgetMonth(
        label: json['label'] as String? ?? '-',
        budget: parseDouble(json['budget']),
        spent: parseDouble(json['spent']),
        remaining: parseDouble(json['remaining']),
        usedPct: parseDouble(json['used_pct']),
        categories: json['categories'] as int? ?? 0,
        overCount: json['over_count'] as int? ?? 0,
      );

  final String label;
  final double budget;
  final double spent;
  final double remaining;
  final double usedPct;

  /// 0 = no budget was set this month — don't show "0% used".
  final int categories;
  final int overCount;
}

class YearBudgetOverItem {
  const YearBudgetOverItem({
    required this.month,
    required this.category,
    required this.budget,
    required this.spent,
    required this.over,
    required this.overPct,
  });

  factory YearBudgetOverItem.fromJson(Map<String, dynamic> json) => YearBudgetOverItem(
        month: json['month'] as String? ?? '-',
        category: json['category'] as String? ?? '-',
        budget: parseDouble(json['budget']),
        spent: parseDouble(json['spent']),
        over: parseDouble(json['over']),
        overPct: parseDouble(json['over_pct']),
      );

  final String month;
  final String category;
  final double budget;
  final double spent;
  final double over;
  final double overPct;
}

class YearOverCategory {
  const YearOverCategory({required this.name, required this.times, required this.totalOver});

  factory YearOverCategory.fromJson(Map<String, dynamic> json) => YearOverCategory(
        name: json['name'] as String? ?? '-',
        times: json['times'] as int? ?? 0,
        totalOver: parseDouble(json['total_over']),
      );

  final String name;
  final int times;
  final double totalOver;
}

class YearBudget {
  const YearBudget({
    required this.hasData,
    required this.months,
    required this.totalBudget,
    required this.totalSpent,
    required this.monthsOver,
    required this.monthsWithBudget,
    required this.overItems,
    required this.overCategories,
  });

  factory YearBudget.fromJson(Map<String, dynamic> json) => YearBudget(
        hasData: json['has_data'] as bool? ?? false,
        months: _list(json['months'], YearBudgetMonth.fromJson),
        totalBudget: parseDouble(json['total_budget']),
        totalSpent: parseDouble(json['total_spent']),
        monthsOver: json['months_over'] as int? ?? 0,
        monthsWithBudget: json['months_with_budget'] as int? ?? 0,
        overItems: _list(json['over_items'], YearBudgetOverItem.fromJson),
        overCategories: _list(json['over_categories'], YearOverCategory.fromJson),
      );

  /// False = the user never set a budget this year; hide the whole section.
  final bool hasData;
  final List<YearBudgetMonth> months;
  final double totalBudget;
  final double totalSpent;
  final int monthsOver;
  final int monthsWithBudget;
  final List<YearBudgetOverItem> overItems;
  final List<YearOverCategory> overCategories;
}

class NamedTotal {
  const NamedTotal({required this.name, required this.total});

  factory NamedTotal.fromJson(Map<String, dynamic> json) =>
      NamedTotal(name: json['name'] as String? ?? '-', total: parseDouble(json['total']));

  final String name;
  final double total;
}

class BiggestExpense {
  const BiggestExpense({this.date, required this.category, required this.description, required this.amount});

  factory BiggestExpense.fromJson(Map<String, dynamic> json) => BiggestExpense(
        date: parseDate(json['date']),
        category: json['category'] as String? ?? '-',
        description: json['description'] as String? ?? '-',
        amount: parseDouble(json['amount']),
      );

  final DateTime? date;
  final String category;
  final String description;
  final double amount;
}

class YearInReviewReport {
  const YearInReviewReport({
    required this.year,
    this.start,
    this.end,
    required this.months,
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.savingsRate,
    required this.averageMonthlyExpense,
    required this.budget,
    required this.topExpenses,
    required this.topIncome,
    this.bestMonth,
    this.worstMonth,
    this.biggestExpense,
  });

  factory YearInReviewReport.fromJson(Map<String, dynamic> json) {
    final best = _mapOrNull(json['best_month']);
    final worst = _mapOrNull(json['worst_month']);
    final biggest = _mapOrNull(json['biggest_expense']);
    return YearInReviewReport(
      year: json['year'] as int? ?? DateTime.now().year,
      start: parseDate(json['start']),
      end: parseDate(json['end']),
      months: _list(json['months'], YearMonthPoint.fromJson),
      totalIncome: parseDouble(json['total_income']),
      totalExpense: parseDouble(json['total_expense']),
      net: parseDouble(json['net']),
      savingsRate: parseDouble(json['savings_rate']),
      averageMonthlyExpense: parseDouble(json['average_monthly_expense']),
      budget: YearBudget.fromJson(_map(json['budget'])),
      topExpenses: _list(json['top_expenses'], NamedTotal.fromJson),
      topIncome: _list(json['top_income'], NamedTotal.fromJson),
      bestMonth: best == null ? null : YearMonthPoint.fromJson(best),
      worstMonth: worst == null ? null : YearMonthPoint.fromJson(worst),
      biggestExpense: biggest == null ? null : BiggestExpense.fromJson(biggest),
    );
  }

  final int year;
  final DateTime? start;
  final DateTime? end;

  /// Always 12 items (Jan–Des).
  final List<YearMonthPoint> months;
  final double totalIncome;
  final double totalExpense;
  final double net;
  final double savingsRate;
  final double averageMonthlyExpense;
  final YearBudget budget;
  final List<NamedTotal> topExpenses;
  final List<NamedTotal> topIncome;
  final YearMonthPoint? bestMonth;
  final YearMonthPoint? worstMonth;
  final BiggestExpense? biggestExpense;
}

// --------------------------------------------------------------------- tax

class TaxCategory {
  const TaxCategory({required this.id, required this.name, required this.spent, required this.deductible});

  factory TaxCategory.fromJson(Map<String, dynamic> json) => TaxCategory(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '-',
        spent: parseDouble(json['spent']),
        deductible: json['deductible'] as bool? ?? false,
      );

  final int id;
  final String name;
  final double spent;
  final bool deductible;
}

class TaxReport {
  const TaxReport({
    required this.year,
    this.start,
    this.end,
    required this.totalIncome,
    required this.categories,
    required this.deductibleCategories,
    required this.totalDeductible,
    required this.incomeAfterDeductions,
  });

  factory TaxReport.fromJson(Map<String, dynamic> json) => TaxReport(
        year: json['year'] as int? ?? DateTime.now().year,
        start: parseDate(json['start']),
        end: parseDate(json['end']),
        totalIncome: parseDouble(json['total_income']),
        categories: _list(json['categories'], TaxCategory.fromJson),
        deductibleCategories: _list(json['deductible_categories'], TaxCategory.fromJson),
        totalDeductible: parseDouble(json['total_deductible']),
        incomeAfterDeductions: parseDouble(json['income_after_deductions']),
      );

  final int year;
  final DateTime? start;
  final DateTime? end;
  final double totalIncome;

  /// All expense categories with yearly spend + checklist state — check
  /// marks come from here, not [deductibleCategories].
  final List<TaxCategory> categories;

  /// Marked AND spent > 0, largest first.
  final List<TaxCategory> deductibleCategories;
  final double totalDeductible;
  final double incomeAfterDeductions;
}
