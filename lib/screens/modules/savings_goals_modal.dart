import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_hub_provider.dart';
import '../../models/finance_module_models.dart';

class SavingsGoalsModal extends StatelessWidget {
  const SavingsGoalsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Savings Goals', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditGoalModal(context, null),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
          Expanded(
            child: Consumer<FinanceHubProvider>(
              builder: (context, provider, child) {
                final goals = provider.savingsGoals;
                if (goals.isEmpty) {
                  return const Center(child: Text('No active savings goals.', style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: goals.length,
                  itemBuilder: (ctx, i) {
                    final goal = goals[i];
                    return _buildGoalCard(context, goal, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoalItem goal, FinanceHubProvider provider) {
    final progress = goal.targetAmount > 0 ? goal.currentSaved / goal.targetAmount : 0.0;
    final primaryColor = Color(goal.colorValue);

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteSavingsGoal(goal.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAddEditGoalModal(context, goal),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.track_changes, color: primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Deadline: ${goal.deadline}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Saved', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('₹${goal.currentSaved.toStringAsFixed(0)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Goal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('₹${goal.targetAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
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
