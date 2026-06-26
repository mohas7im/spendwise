import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  bool isExpense = true;
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'emoji': '🍔'},
    {'name': 'Rent', 'emoji': '🏠'},
    {'name': 'Transport', 'emoji': '🚕'},
    {'name': 'Shopping', 'emoji': '🛍️'},
    {'name': 'Entertainment', 'emoji': '🎬'},
    {'name': 'Health', 'emoji': '💊'},
    {'name': 'Bills', 'emoji': '📄'},
    {'name': 'Invest', 'emoji': '📈'},
    {'name': 'Salary', 'emoji': '💰'},
    {'name': 'Other', 'emoji': '📦'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                Text('Add Transaction', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () {
                    // TODO: Save logic
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
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
                  // Type Toggle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isExpense = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isExpense ? const Color(0xFF2A2A2A) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isExpense ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                              ),
                              child: const Center(child: Text('Expense', style: TextStyle(fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isExpense = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isExpense ? const Color(0xFF2A2A2A) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: !isExpense ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                              ),
                              child: const Center(child: Text('Income', style: TextStyle(fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount Input
                  Center(
                    child: Column(
                      children: [
                        const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.00',
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                              prefixText: '\$ ',
                              prefixStyle: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Category Selector
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category['name'];
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = category['name']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
                            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(category['emoji'], style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(category['name'], style: TextStyle(fontSize: 10, color: isSelected ? Theme.of(context).primaryColor : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Note Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add a note...',
                        hintStyle: TextStyle(color: Colors.grey),
                        icon: Icon(Icons.notes, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
