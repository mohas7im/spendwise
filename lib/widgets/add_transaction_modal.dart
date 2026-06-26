import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';

class AddTransactionModal extends StatefulWidget {
  final TransactionModel? editingTransaction;
  const AddTransactionModal({super.key, this.editingTransaction});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  late bool isExpense;
  late String selectedCategory;
  late String selectedPaymentMethod;
  late DateTime selectedDate;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food & Drink', 'emoji': '🍔'},
    {'name': 'Groceries', 'emoji': '🛒'},
    {'name': 'Rent', 'emoji': '🏠'},
    {'name': 'Transport', 'emoji': '🚕'},
    {'name': 'Shopping', 'emoji': '🛍️'},
    {'name': 'Entertainment', 'emoji': '🎬'},
    {'name': 'Health', 'emoji': '💊'},
    {'name': 'Bills', 'emoji': '📄'},
    {'name': 'Invest', 'emoji': '📈'},
    {'name': 'Income', 'emoji': '💰'},
    {'name': 'Other', 'emoji': '📦'},
  ];

  final List<String> paymentMethods = ['UPI', 'Card', 'Cash', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    final tx = widget.editingTransaction;
    isExpense = tx == null ? true : tx.type == TransactionType.expense;
    selectedCategory = tx?.category ?? 'Food & Drink';
    selectedPaymentMethod = tx?.paymentMethod ?? 'UPI';
    selectedDate = tx?.date ?? DateTime.now();
    _amountController = TextEditingController(text: tx != null ? tx.amount.toStringAsFixed(0) : '');
    _noteController = TextEditingController(text: tx?.title ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a description')));
      return;
    }

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final tx = TransactionModel(
      id: widget.editingTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _noteController.text.trim(),
      amount: amount,
      date: selectedDate,
      category: selectedCategory,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      paymentMethod: selectedPaymentMethod,
    );

    if (widget.editingTransaction != null) {
      provider.updateTransaction(tx);
    } else {
      provider.addTransaction(tx);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isEditing = widget.editingTransaction != null;

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
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                  Text(isEditing ? 'Edit Transaction' : 'Add Transaction',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton(
                    onPressed: _save,
                    child: Text(isEditing ? 'Update' : 'Save', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
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
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Expanded(child: GestureDetector(
                            onTap: () => setState(() => isExpense = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isExpense ? const Color(0xFFB71C1C) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text('Expense', style: TextStyle(fontWeight: FontWeight.bold, color: isExpense ? Colors.white : null))),
                            ),
                          )),
                          Expanded(child: GestureDetector(
                            onTap: () => setState(() => isExpense = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isExpense ? const Color(0xFF10B981) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text('Income', style: TextStyle(fontWeight: FontWeight.bold, color: !isExpense ? Colors.white : null))),
                            ),
                          )),
                        ],
                      ),
                    ),
                    // Amount Input
                    Center(
                      child: Column(
                        children: [
                          Text('Amount', style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 14)),
                          const SizedBox(height: 8),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.4)),
                                prefixText: '₹ ',
                                prefixStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.6)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Description
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                      child: TextField(
                        controller: _noteController,
                        decoration: InputDecoration(border: InputBorder.none, hintText: 'Description...', hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)), icon: Icon(Icons.notes, color: Colors.grey.withOpacity(0.6))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Payment Method
                    Text('Payment Method', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: paymentMethods.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final method = paymentMethods[i];
                          final isSelected = selectedPaymentMethod == method;
                          return GestureDetector(
                            onTap: () => setState(() => selectedPaymentMethod = method),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2)),
                              ),
                              child: Center(child: Text(method, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Theme.of(context).colorScheme.onPrimary : null))),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Date Picker
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.grey.withOpacity(0.7), size: 20),
                            const SizedBox(width: 12),
                            Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Category Grid
                    Text('Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category['name'];
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = category['name']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.12) : Theme.of(context).cardColor,
                              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(category['emoji'], style: const TextStyle(fontSize: 22)),
                                const SizedBox(height: 4),
                                Text(category['name'], style: TextStyle(fontSize: 9, color: isSelected ? Theme.of(context).primaryColor : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
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
  }
}
