import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common/custom_bottom_sheet.dart';
import '../widgets/common/premium_gradient_card.dart';
import '../providers/budget_provider.dart';
import '../providers/finance_provider.dart';

class SmartSpendingPlannerScreen extends StatefulWidget {
  const SmartSpendingPlannerScreen({super.key});
  
  @override
  State<SmartSpendingPlannerScreen> createState() => _SmartSpendingPlannerScreenState();
}

class _SmartSpendingPlannerScreenState extends State<SmartSpendingPlannerScreen> {
  final _incomeCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController();
  final _catNameCtrl = TextEditingController();
  final _catBudgetCtrl = TextEditingController();
  final _catIconCtrl = TextEditingController();

  double monthlyIncome = 0;
  double savingsGoal = 0;
  DateTime? _nextSalaryDate;
  bool _isDynamicCalculation = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': '🍔', 'budget': 4000.0, 'spent': 2500.0, 'enabled': false},
    {'name': 'Transport', 'icon': '🚌', 'budget': 2000.0, 'spent': 1800.0, 'enabled': false},
    {'name': 'Shopping', 'icon': '🛍️', 'budget': 2000.0, 'spent': 600.0, 'enabled': false},
    {'name': 'Entertainment', 'icon': '🎮', 'budget': 1500.0, 'spent': 900.0, 'enabled': false},
    {'name': 'Bills', 'icon': '💡', 'budget': 1500.0, 'spent': 1500.0, 'enabled': false},
    {'name': 'Healthcare', 'icon': '💊', 'budget': 500.0, 'spent': 200.0, 'enabled': false},
    {'name': 'Misc', 'icon': '📦', 'budget': 500.0, 'spent': 150.0, 'enabled': false},
  ];



  List<Map<String, dynamic>> get enabledCats => _categories.where((c) => c['enabled'] as bool).toList();
  double get availableBudget => monthlyIncome - savingsGoal;
  double get totalSpent => enabledCats.fold(0.0, (s, c) => s + (c['spent'] as double));
  double get remainingBudget => availableBudget - totalSpent;
  double get savingsActual => (monthlyIncome - totalSpent).clamp(0, double.infinity);
  double get budgetUsedPct => availableBudget > 0 ? (totalSpent / availableBudget).clamp(0.0, 1.0) : 0;
  double get savingsPct => savingsGoal > 0 ? (savingsActual / savingsGoal).clamp(0.0, 1.0) : 0;
  int get remainingDays {
    if (_nextSalaryDate != null) {
      final diff = _nextSalaryDate!.difference(DateTime.now()).inDays;
      return diff >= 0 ? diff + 1 : 0;
    }
    final now = DateTime.now();
    final end = DateTime(now.year, now.month + 1, 0);
    return end.difference(now).inDays + 1;
  }
  double get dailyRec => remainingDays > 0 && remainingBudget > 0 ? remainingBudget / remainingDays : 0;





  @override
  void initState() {
    super.initState();
    monthlyIncome = 15000;
    savingsGoal = 3000;
    _incomeCtrl.text = monthlyIncome.toStringAsFixed(0);
    _savingsCtrl.text = savingsGoal.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _incomeCtrl.dispose(); _savingsCtrl.dispose();
    _catNameCtrl.dispose(); _catBudgetCtrl.dispose(); _catIconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final pColor = Theme.of(context).primaryColor;

    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        if (_isDynamicCalculation) {
          for (var c in _categories) {
            try {
              final limit = budgetProvider.budget.categoryLimits.firstWhere((l) => l.category == c['name']);
              c['budget'] = limit.effectiveLimit;
              c['spent'] = limit.spentAmount;
            } catch (_) {}
          }
        }
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Planner', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                Text('${DateTime.now().year} • ${_monthName(DateTime.now().month)}', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showPlannerSetupSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: isDark ? Colors.white : Colors.black, shape: BoxShape.circle),
                    child: Icon(Icons.add, size: 20, color: isDark ? Colors.black : Colors.white),
                  ),
                ),
              ),
            ],
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _sliver(Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _heroCard(context, pColor))),
              _gap(12),
              _sliver(Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _dailyCard(context, cardBg, pColor))),
              _gap(20),
              _sliver(_sectionHeader(context, 'Category Daily Spending')),
              _sliver(Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _categoryCards(context, cardBg, pColor, budgetProvider))),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        );
      },
    );
  }

  SliverToBoxAdapter _sliver(Widget child) => SliverToBoxAdapter(child: child);
  SliverToBoxAdapter _gap(double h) => SliverToBoxAdapter(child: SizedBox(height: h));


  Widget _heroCard(BuildContext context, Color pColor) {
    Color healthColor = budgetUsedPct < 0.6 ? Colors.greenAccent : budgetUsedPct < 0.85 ? Colors.orangeAccent : Colors.redAccent;
    return PremiumGradientCard(
      builder: (context, textColor, subTextColor) => Column(children: [
        Row(children: [
          SizedBox(width: 90, height: 90, child: Stack(fit: StackFit.expand, children: [
            CircularProgressIndicator(value: budgetUsedPct, strokeWidth: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(healthColor), strokeCap: StrokeCap.round),
            Center(child: Text('${(budgetUsedPct * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
          ])),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Available to Spend', style: TextStyle(color: subTextColor, fontSize: 12)),
            const SizedBox(height: 4),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text('₹${remainingBudget.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: remainingBudget >= 0 ? Colors.greenAccent : Colors.redAccent))),
            const SizedBox(height: 4),
            Text(remainingBudget >= 0 ? '₹${remainingBudget.toStringAsFixed(0)} left this month.' : 'Over by ₹${(-remainingBudget).toStringAsFixed(0)}!',
              style: TextStyle(fontSize: 11, color: subTextColor, height: 1.4)),
          ])),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Colors.white24),
        const SizedBox(height: 14),
        Row(children: [
          _miniStat('Budget', '₹${availableBudget.toStringAsFixed(0)}', pColor, textColor, subTextColor),
          _miniStat('Amount to Save', '₹${savingsGoal.toStringAsFixed(0)}', Colors.orangeAccent, textColor, subTextColor),
        ]),
      ]));
  }

  Widget _miniStat(String label, String value, Color color, Color textColor, Color subTextColor) {
    return Expanded(child: Column(children: [
      FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color))),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10, color: subTextColor)),
    ]));
  }

  Widget _dailyCard(BuildContext context, Color cardBg, Color pColor) {
    return Container(decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: pColor.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(Icons.today_outlined, color: pColor, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Daily Spending Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 3),
          Text('₹${dailyRec.toStringAsFixed(0)}/day for $remainingDays days left.', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${dailyRec.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: pColor)),
          Text('per day', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        ]),
      ]));
  }


  Widget _categoryCards(BuildContext context, Color cardBg, Color pColor, BudgetProvider budgetProvider) {
    if (enabledCats.isEmpty) return const SizedBox();
    return Column(
      children: enabledCats.map((c) => _categoryCard(context, cardBg, pColor, c, budgetProvider)).toList(),
    );
  }

  Widget _categoryCard(BuildContext context, Color cardBg, Color pColor, Map<String, dynamic> c, BudgetProvider budgetProvider) {
    final name = c['name'] as String;
    final icon = c['icon'] as String;
    final budget = c['budget'] as double;
    final spent = c['spent'] as double;
    
    final remaining = budget - spent;
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    
    int days = remainingDays;
    double daily = days > 0 && remaining > 0 ? remaining / days : 0.0;
    String status = "✅ On Track";
    if (pct >= 1.0) {
      status = "🔴 Budget Exceeded";
    } else if (pct >= 0.8) {
      status = "🟡 Near Budget Limit";
    }
    
    if (_isDynamicCalculation) {
      try {
        final limit = budgetProvider.budget.categoryLimits.firstWhere((l) => l.category == name);
        days = limit.remainingDays(DateTime.now(), nextSalaryDate: _nextSalaryDate);
        daily = limit.recommendedDailySpend(DateTime.now(), nextSalaryDate: _nextSalaryDate);
        status = limit.status;
      } catch (_) {}
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: pColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                      Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: pct >= 1.0 ? Colors.redAccent : pct >= 0.8 ? Colors.orangeAccent : Colors.green)),
                    ],
                  )),
                ],
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${remaining > 0 ? remaining.toStringAsFixed(0) : '0'}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: remaining <= 0 ? Colors.redAccent : null)),
                  Text('Remaining', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(
              pct >= 1.0 ? Colors.redAccent : pct >= 0.8 ? Colors.orangeAccent : Colors.greenAccent,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _microStat('Budget', '₹${budget.toStringAsFixed(0)}'),
              _microStat('Spent', '₹${spent.toStringAsFixed(0)}', color: pct >= 1.0 ? Colors.redAccent : null),
              _microStat('Daily Rec', '₹${daily.toStringAsFixed(0)}/d', color: pColor),
              _microStat('Days Left', '$days days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _microStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, {Widget? trailing}) {
    return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 16, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        trailing ?? const SizedBox(),
      ]));
  }

  void _showPlannerSetupSheet(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final globalLimits = budgetProvider.budget.categoryLimits;
    
    final initialInc = monthlyIncome > 0 ? monthlyIncome : financeProvider.totalBalance;
    final incCtrl = TextEditingController(text: initialInc.toStringAsFixed(0));
    final savCtrl = TextEditingController(text: savingsGoal.toStringAsFixed(0));
    final daysCtrl = TextEditingController(text: remainingDays.toString());
    DateTime? tempSalaryDate = _nextSalaryDate;
    bool tempDynamicCalculation = _isDynamicCalculation;
    
    final Map<String, bool> tempEnabled = {};
    final Map<String, double> tempBudgets = {};
    final Map<String, TextEditingController> manualBudgetCtrls = {};
    
    for (var c in _categories) {
      final name = c['name'] as String;
      tempEnabled[name] = c['enabled'] as bool;
      tempBudgets[name] = c['budget'] as double;
      manualBudgetCtrls[name] = TextEditingController(
        text: (c['budget'] as double) > 0 ? (c['budget'] as double).toStringAsFixed(0) : ''
      );
    }

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final inc = double.tryParse(incCtrl.text) ?? 0.0;
          final sav = double.tryParse(savCtrl.text) ?? 0.0;
          
          double allocated = 0.0;
          for (var c in _categories) {
            final name = c['name'] as String;
            final isEnabled = tempEnabled[name] ?? false;
            if (isEnabled) {
               double catB = tempBudgets[name] ?? 0.0;
               if (tempDynamicCalculation) {
                  try {
                    final limit = globalLimits.firstWhere((l) => l.category == name);
                    catB = limit.effectiveLimit;
                  } catch (_) {
                    catB = 0.0;
                  }
               }
               allocated += catB;
            }
          }
          
          final remaining = inc - sav - allocated;

          return CustomBottomSheet(
            title: 'Planner Setup',
            saveText: 'Save Planner',
            onSave: () {
              setState(() {
                monthlyIncome = inc;
                savingsGoal = sav;
                _nextSalaryDate = tempSalaryDate;
                _isDynamicCalculation = tempDynamicCalculation;
                
                for (var c in _categories) {
                  final name = c['name'] as String;
                  c['enabled'] = tempEnabled[name] ?? false;
                  
                  if (_isDynamicCalculation) {
                    try {
                      final limit = globalLimits.firstWhere((l) => l.category == name);
                      c['budget'] = limit.effectiveLimit;
                      c['spent'] = limit.spentAmount;
                    } catch (_) {}
                  } else {
                    c['budget'] = tempBudgets[name] ?? c['budget'];
                  }
                }
              });
              Navigator.pop(ctx);
            },
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: incCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setS(() {}),
                decoration: const InputDecoration(
                  labelText: 'Available to Spend (₹)',
                  hintText: 'e.g. 15000',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: savCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setS(() {}),
                decoration: const InputDecoration(
                  labelText: 'Amount to Save (₹)',
                  hintText: 'e.g. 3000',
                  prefixIcon: Icon(Icons.savings_outlined),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: daysCtrl,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Days Until Salary',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempSalaryDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setS(() {
                        tempSalaryDate = picked;
                        daysCtrl.text = (picked.difference(DateTime.now()).inDays + 1).toString();
                      });
                    }
                  },
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Pick Date'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3))
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Remaining to Allocate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('₹${remaining.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: remaining >= 0 ? Theme.of(context).primaryColor : Colors.redAccent)),
                ]),
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dynamic Calculation'),
                subtitle: const Text('Automatically fetch budget limits from global configurations.'),
                value: tempDynamicCalculation,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (val) {
                  setS(() => tempDynamicCalculation = val ?? false);
                },
              ),
              const SizedBox(height: 12),
              const Text('Add Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (tempSalaryDate == null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(child: Text('Please pick your Next Salary Date first to unlock category allocations.')),
                  ]),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final name = c['name'] as String;
                    final isEnabled = tempEnabled[name] ?? false;
                    double catBudget = tempBudgets[name] ?? (c['budget'] as double);
                    double catSpent = c['spent'] as double;
                    
                    if (tempDynamicCalculation) {
                      try {
                        final limit = globalLimits.firstWhere((l) => l.category == name);
                        catBudget = limit.effectiveLimit;
                        catSpent = limit.spentAmount;
                      } catch (_) {
                        catBudget = 0.0;
                      }
                    }
                    
                    final catRemaining = catBudget - catSpent;
                    
                    return GestureDetector(
                      onTap: () {
                        final v = !isEnabled;
                        if (v) {
                          if (tempDynamicCalculation) {
                            bool hasLimit = globalLimits.any((l) => l.category == name);
                            if (!hasLimit) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('No global limit set for $name. (Budget will be ₹0)'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 2),
                              ));
                              setS(() => tempEnabled[name] = true);
                            } else if (catRemaining <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('No budget remaining for $name! (Limit reached)'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                              ));
                              return;
                            } else {
                              setS(() => tempEnabled[name] = true);
                            }
                          } else {
                            setS(() => tempEnabled[name] = true);
                          }
                        } else {
                          setS(() => tempEnabled[name] = false);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isEnabled 
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                              : Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isEnabled 
                                ? Theme.of(context).primaryColor 
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(c['icon'] as String, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                                    color: isEnabled ? Theme.of(context).primaryColor : null,
                                  ),
                                ),
                              ],
                            ),
                            if (!(tempDynamicCalculation && catBudget == 0)) ...[
                               const SizedBox(height: 4),
                               Text(
                                 '₹${catBudget.toStringAsFixed(0)}', 
                                 style: TextStyle(
                                   fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal, 
                                   fontSize: 12, 
                                   color: isEnabled ? Theme.of(context).primaryColor : Colors.grey[600],
                                 ),
                               ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (!tempDynamicCalculation && tempEnabled.values.any((e) => e == true)) ...[
                const SizedBox(height: 24),
                const Text('Set Category Budgets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ..._categories.where((c) => tempEnabled[c['name']] == true).map((c) {
                  final name = c['name'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: manualBudgetCtrls[name],
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setS(() {
                           tempBudgets[name] = double.tryParse(val) ?? 0.0;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Budget for $name (₹)',
                        prefixIcon: Container(
                          width: 48,
                          alignment: Alignment.center,
                          child: Text(c['icon'] as String, style: const TextStyle(fontSize: 20)),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
            ]),
          );
        }
      )
    );
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }
}

