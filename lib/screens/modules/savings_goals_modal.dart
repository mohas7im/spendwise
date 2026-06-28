import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/finance_hub_provider.dart';
import '../../models/finance_module_models.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/custom_bottom_sheet.dart';

class SavingsGoalsModal extends StatefulWidget {
  const SavingsGoalsModal({super.key});

  @override
  State<SavingsGoalsModal> createState() => _SavingsGoalsModalState();
}

class _SavingsGoalsModalState extends State<SavingsGoalsModal> {
  int _summaryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditGoalModal(context, null),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Consumer<FinanceHubProvider>(
          builder: (context, provider, child) {
            final goals = provider.savingsGoals;
            
            double totalTarget = goals.fold(0.0, (sum, item) => sum + item.targetAmount);
            double totalSaved = goals.fold(0.0, (sum, item) => sum + item.currentSaved);
            double totalPending = totalTarget - totalSaved;
            
            double displayValue = 0.0;
            String displayTitle = '';
            if (_summaryIndex == 0) {
              displayTitle = 'Total Saved';
              displayValue = totalSaved;
            } else if (_summaryIndex == 1) {
              displayTitle = 'Total Target';
              displayValue = totalTarget;
            } else {
              displayTitle = 'Remaining Goal';
              displayValue = totalPending;
            }

            return Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text('Savings Goals', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                // Interactive Summary Box
                GestureDetector(
                  onTap: () => setState(() => _summaryIndex = (_summaryIndex + 1) % 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayTitle,
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.swap_horiz, size: 12, color: Colors.white70),
                                  SizedBox(width: 4),
                                  Text('Tap', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₹${displayValue.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Your Records Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Records', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.trending_up, color: Theme.of(context).primaryColor, size: 22),
                        onPressed: () => _showSavingsTrendModal(context, goals),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Goals List
                Expanded(
                  child: goals.isEmpty
                      ? const Center(child: Text('No active savings goals.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: goals.length,
                          itemBuilder: (ctx, i) => _buildGoalCard(context, goals[i], provider),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoalItem goal, FinanceHubProvider provider) {
    final progress = goal.targetAmount > 0 ? goal.currentSaved / goal.targetAmount : 0.0;
    final primaryColor = Color(goal.colorValue);
    final pendingAmount = goal.targetAmount - goal.currentSaved;

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this goal?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteSavingsGoal(goal.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              title: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Remaining: ₹${pendingAmount.toStringAsFixed(0)}',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  if (goal.deadline.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('Deadline: ${goal.deadline}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saved: ₹${goal.currentSaved.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('Target: ₹${goal.targetAmount.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showAddEditGoalModal(context, goal),
              ),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Funds'),
                    onPressed: () => _showLogDepositModal(context, goal, provider),
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.grey.withValues(alpha: 0.15)),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('History'),
                    onPressed: () => _showHistoryModal(context, goal),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryModal(BuildContext context, SavingsGoalItem goal) {
    final history = List<Map<String, dynamic>>.from(goal.depositHistory);
    history.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Deposit History',
        isScrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No history yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: history.length,
                  itemBuilder: (ctx, i) {
                    final item = history[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                      ),
                      title: Text('Added Funds', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(item['date']))),
                      trailing: Text('+₹${item['amount'].toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSavingsTrendModal(BuildContext context, List<SavingsGoalItem> goals) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Savings Growth',
        isScrollable: false,
        child: _buildSavingsTrendChart(goals, context),
      ),
    );
  }

  Widget _buildSavingsTrendChart(List<SavingsGoalItem> goals, BuildContext context) {
    final now = DateTime.now();
    List<FlSpot> spots = [];
    List<String> labels = [];

    List<double> monthlySums = List.filled(6, 0.0);

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      labels.add(DateFormat('MMM').format(targetDate));
      
      // Calculate total savings up to this month
      double sumUpToMonth = 0;
      for (final goal in goals) {
        for (final deposit in goal.depositHistory) {
          final dDate = DateTime.parse(deposit['date']);
          if (dDate.isBefore(DateTime(targetDate.year, targetDate.month + 1, 1))) {
            sumUpToMonth += deposit['amount'];
          }
        }
      }
      monthlySums[5 - i] = sumUpToMonth;
      spots.add(FlSpot((5 - i).toDouble(), sumUpToMonth));
    }

    double maxY = monthlySums.isEmpty ? 1000 : monthlySums.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 1000;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('Total Savings', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: LineChart(
              LineChartData(
                maxY: maxY * 1.2,
                minY: 0,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (group) => isDark ? Colors.white : Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '₹${spot.y.round()}',
                          TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(labels[index], style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.greenAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.greenAccent.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showLogDepositModal(BuildContext context, SavingsGoalItem goal, FinanceHubProvider provider) {
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Add Funds',
        saveText: 'Add to Goal',
        onSave: () {
          final val = double.tryParse(amountCtrl.text) ?? 0;
          if (val > 0) {
            double newSaved = goal.currentSaved + val;
            
            final newHistory = List<Map<String, dynamic>>.from(goal.depositHistory)
              ..add({
                'date': DateTime.now().toIso8601String(),
                'amount': val,
              });

            provider.updateSavingsGoal(goal.copyWith(currentSaved: newSaved, depositHistory: newHistory));
            Navigator.pop(ctx);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add funds to ${goal.name}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddEditGoalModal(BuildContext context, SavingsGoalItem? existingGoal) {
    final nameCtrl = TextEditingController(text: existingGoal?.name ?? '');
    final targetCtrl = TextEditingController(text: existingGoal?.targetAmount.toString() ?? '');
    final savedCtrl = TextEditingController(text: existingGoal?.currentSaved.toString() ?? '0');
    final deadCtrl = TextEditingController(text: existingGoal?.deadline ?? '');
    int selectedColor = existingGoal?.colorValue ?? Colors.blue.toARGB32();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return AnimatedPadding(
            padding: EdgeInsets.only(bottom: bottomInset),
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              height: (MediaQuery.of(context).size.height * 0.92 - bottomInset).clamp(300.0, double.infinity),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                        Text(existingGoal == null ? 'Add Goal' : 'Edit Goal',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                        TextButton(
                          onPressed: () {
                            if (nameCtrl.text.isNotEmpty && targetCtrl.text.isNotEmpty) {
                              final provider = Provider.of<FinanceHubProvider>(context, listen: false);
                              final item = SavingsGoalItem(
                                id: existingGoal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameCtrl.text,
                                targetAmount: double.tryParse(targetCtrl.text) ?? 0,
                                currentSaved: double.tryParse(savedCtrl.text) ?? 0,
                                deadline: deadCtrl.text,
                                colorValue: selectedColor,
                              );
                              if (existingGoal == null) {
                                provider.addSavingsGoal(item);
                              } else {
                                provider.updateSavingsGoal(item);
                              }
                              Navigator.pop(ctx);
                            }
                          },
                          child: Text(existingGoal == null ? 'Save' : 'Update', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Goal Name (e.g. Vacation)', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          TextField(controller: savedCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Currently Saved', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          TextField(controller: deadCtrl, decoration: const InputDecoration(labelText: 'Deadline (e.g. Dec 2026)', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            children: [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.teal, Colors.red].map((c) => GestureDetector(
                              onTap: () => setModalState(() => selectedColor = c.toARGB32()),
                              child: CircleAvatar(
                                backgroundColor: c,
                                radius: 20,
                                child: selectedColor == c.toARGB32() ? const Icon(Icons.check, color: Colors.white) : null,
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
