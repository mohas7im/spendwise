import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_hub_provider.dart';
import '../../models/finance_module_models.dart';

class SavingsGrowthModal extends StatelessWidget {
  const SavingsGrowthModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Savings Growth', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.teal, size: 28),
            onPressed: () => _showAddEditGrowthModal(context, null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
          Expanded(
            child: Consumer<FinanceHubProvider>(
              builder: (context, provider, child) {
                final items = provider.growthItems;
                if (items.isEmpty) {
                  return const Center(child: Text('No active investments.', style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return _buildGrowthCard(context, item, provider);
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

  Widget _buildGrowthCard(BuildContext context, SavingsGrowthItem item, FinanceHubProvider provider) {
    final profit = item.currentAmount - item.principal;
    final profitPercentage = item.principal > 0 ? (profit / item.principal) * 100 : 0.0;
    final isProfit = profit >= 0;
    final primaryColor = Color(item.colorValue);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteGrowthItem(item.id),
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
            onTap: () => _showAddEditGrowthModal(context, item),
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
                        child: Icon(Icons.trending_up, color: primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(item.type, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isProfit ? Colors.green : Colors.red).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${isProfit ? '+' : ''}${profitPercentage.toStringAsFixed(1)}%', 
                          style: TextStyle(color: isProfit ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
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
                          const Text('Invested', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('₹${item.principal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Current Value', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('₹${item.currentAmount.toStringAsFixed(0)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditGrowthModal(BuildContext context, SavingsGrowthItem? existingItem) {
    final nameCtrl = TextEditingController(text: existingItem?.name ?? '');
    final prinCtrl = TextEditingController(text: existingItem?.principal.toString() ?? '');
    final curCtrl = TextEditingController(text: existingItem?.currentAmount.toString() ?? '');
    final rateCtrl = TextEditingController(text: existingItem?.returnRate.toString() ?? '');
    String type = existingItem?.type ?? 'Fixed Deposit';
    int selectedColor = existingItem?.colorValue ?? Colors.teal.toARGB32();

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
                        Text(existingItem == null ? 'Add Investment' : 'Edit Investment',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                        TextButton(
                          onPressed: () {
                            if (nameCtrl.text.isNotEmpty && prinCtrl.text.isNotEmpty) {
                              final provider = Provider.of<FinanceHubProvider>(context, listen: false);
                              final item = SavingsGrowthItem(
                                id: existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameCtrl.text,
                                type: type,
                                principal: double.tryParse(prinCtrl.text) ?? 0,
                                currentAmount: double.tryParse(curCtrl.text) ?? 0,
                                returnRate: double.tryParse(rateCtrl.text) ?? 0,
                                colorValue: selectedColor,
                              );
                              if (existingItem == null) {
                                provider.addGrowthItem(item);
                              } else {
                                provider.updateGrowthItem(item);
                              }
                              Navigator.pop(ctx);
                            }
                          },
                          child: Text(existingItem == null ? 'Save' : 'Update', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
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
                          DropdownButtonFormField<String>(
                            initialValue: type,
                            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                            items: ['Fixed Deposit', 'Mutual Fund', 'Stock', 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => setModalState(() => type = val!),
                          ),
                          const SizedBox(height: 16),
                          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Investment Name', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          TextField(controller: prinCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Principal Amount', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          TextField(controller: curCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current Value', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Expected Return Rate (%)', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            children: [Colors.teal, Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.pink].map((c) => GestureDetector(
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
