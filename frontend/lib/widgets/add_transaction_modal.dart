import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/finance_provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction.dart';
import 'common/custom_bottom_sheet.dart';

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
  List<String> _attachments = [];

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
    if (widget.editingTransaction != null) {
      final t = widget.editingTransaction!;
      isExpense = t.type == TransactionType.expense;
      selectedCategory = t.category;
      selectedPaymentMethod = t.paymentMethod;
      selectedDate = t.date;
      _amountController = TextEditingController(text: t.amount.toString());
      _noteController = TextEditingController(text: t.title);
      _attachments = t.attachments != null ? List.from(t.attachments!) : [];
    } else {
      isExpense = true;
      selectedCategory = 'Food & Drink';
      selectedPaymentMethod = 'UPI';
      selectedDate = DateTime.now();
      _amountController = TextEditingController();
      _noteController = TextEditingController();
    }
    super.initState();
  }

  Future<void> _pickAttachment() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
        if (image != null) {
          setState(() {
            _attachments.add(image.path);
          });
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
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
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    if (isExpense) {
      final amountDifference = widget.editingTransaction != null 
          ? amount - widget.editingTransaction!.amount 
          : amount;

      try {
        final catLimit = budgetProvider.budget.categoryLimits.firstWhere((l) => l.category == selectedCategory);
        if (catLimit.enforceLimit && amountDifference > catLimit.remainingAmount) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Budget limit reached for $selectedCategory! No remaining budget.'),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }
      } catch (_) {}

      for (var gl in budgetProvider.budget.globalLimits) {
        if (gl.enforceLimit && amountDifference > gl.remainingAmount) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Global budget limit reached! No remaining budget.'),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }
      }
    }
    final tx = TransactionModel(
      id: widget.editingTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _noteController.text.trim(),
      amount: amount,
      date: selectedDate,
      category: selectedCategory,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      paymentMethod: selectedPaymentMethod,
      attachments: _attachments.isEmpty ? null : _attachments,
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
    final bool isEditing = widget.editingTransaction != null;

    return CustomBottomSheet(
      title: isEditing ? 'Edit Transaction' : 'Add Transaction',
      onSave: _save,
      saveText: isEditing ? 'Update Transaction' : 'Save Transaction',
      saveIcon: isEditing ? Icons.check : Icons.add,
      saveButtonColor: Theme.of(context).primaryColor,
      saveTextColor: Theme.of(context).colorScheme.onPrimary,
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
                                color: isExpense ? Colors.redAccent : Colors.transparent,
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
                          Text('Amount', style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 14)),
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
                                hintStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.grey.withValues(alpha: 0.4)),
                                prefixText: '₹ ',
                                prefixStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.grey.withValues(alpha: 0.6)),
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
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
                      child: TextField(
                        controller: _noteController,
                        decoration: InputDecoration(border: InputBorder.none, hintText: 'Description...', hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)), icon: Icon(Icons.notes, color: Colors.grey.withValues(alpha: 0.6))),
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
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                                border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.2)),
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
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.grey.withValues(alpha: 0.7), size: 20),
                            const SizedBox(width: 12),
                            Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: Colors.grey.withValues(alpha: 0.5)),
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
                              color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.12) : Theme.of(context).cardColor,
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
                    const SizedBox(height: 20),
                    // Attachments Section
                    Text('Attachments', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ..._attachments.map((path) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.startsWith('/')) 
                                  ? Image.file(File(path), fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Center(child: Icon(Icons.broken_image, color: Theme.of(context).primaryColor)))
                                  : Center(child: Icon(Icons.insert_drive_file, color: Theme.of(context).primaryColor)),
                              ),
                              Positioned(
                                right: -4,
                                top: -4,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                  onPressed: () => setState(() => _attachments.remove(path)),
                                ),
                              ),
                            ],
                          ),
                        )),
                        GestureDetector(
                          onTap: _pickAttachment,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5), style: BorderStyle.solid),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor),
                                const SizedBox(height: 4),
                                Text('Add', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
      ),
    );
  }
}
