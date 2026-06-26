import 'package:flutter/material.dart';
import '../../models/split_bill.dart';
import '../../providers/split_provider.dart';

class AddSplitExpenseModal extends StatefulWidget {
  final SplitProvider provider;
  const AddSplitExpenseModal({super.key, required this.provider});

  @override
  State<AddSplitExpenseModal> createState() => _AddSplitExpenseModalState();
}

class _AddSplitExpenseModalState extends State<AddSplitExpenseModal> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController(text: 'General');
  final _notesController = TextEditingController();
  
  late String _selectedPayerId;
  SplitMethod _splitMethod = SplitMethod.equal;
  
  List<String> _selectedSharers = [];
  Map<String, TextEditingController> _customInputControllers = {};
  
  List<FoodItem> _foodItems = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.provider.people.isNotEmpty) {
      _selectedPayerId = widget.provider.people.first.id;
      _selectedSharers = widget.provider.people.map((p) => p.id).toList();
    }
    _initCustomControllers();
  }

  void _initCustomControllers() {
    for (var p in widget.provider.people) {
      _customInputControllers[p.id] = TextEditingController();
    }
  }

  void _addFoodItem() {
    setState(() {
      _foodItems.add(FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Item ${_foodItems.length + 1}',
        price: 0.0,
        sharedByPersonIds: List.from(_selectedSharers),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider.people.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("Please add participants first."),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Add Expense', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Expense Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Total Amount', prefixText: '₹ ', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPayerId,
                      decoration: const InputDecoration(labelText: 'Who Paid?', border: OutlineInputBorder()),
                      items: widget.provider.people.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _selectedPayerId = v); },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Split Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    // Split Method Selector
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SplitMethod.values.map((m) => ChoiceChip(
                        label: Text(m.name.toUpperCase()),
                        selected: _splitMethod == m,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _splitMethod = m;
                              if (m == SplitMethod.itemized && _foodItems.isEmpty) {
                                _addFoodItem();
                              }
                            });
                          }
                        },
                      )).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Dynamic Form based on SplitMethod
                    _buildDynamicSplitForm(),
                    
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            
            // Save Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveExpense,
                  child: const Text('Save Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSplitForm() {
    switch (_splitMethod) {
      case SplitMethod.equal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Who is sharing this cost?'),
            ...widget.provider.people.map((p) => CheckboxListTile(
              title: Text(p.name),
              value: _selectedSharers.contains(p.id),
              onChanged: (val) {
                setState(() {
                  if (val == true) _selectedSharers.add(p.id);
                  else _selectedSharers.remove(p.id);
                });
              },
            )),
          ],
        );
      
      case SplitMethod.exact:
      case SplitMethod.percentage:
      case SplitMethod.shares:
        String label = _splitMethod == SplitMethod.exact ? '₹ Amount' : (_splitMethod == SplitMethod.percentage ? '%' : 'Shares');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter $label for each person:'),
            const SizedBox(height: 12),
            ...widget.provider.people.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _customInputControllers[p.id],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${p.name} ($label)',
                  border: const OutlineInputBorder(),
                ),
              ),
            )),
          ],
        );
        
      case SplitMethod.itemized:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Itemized Bill (Food/Drinks)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            ..._foodItems.asMap().entries.map((entry) {
              int idx = entry.key;
              FoodItem item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: item.name,
                            decoration: const InputDecoration(labelText: 'Item Name', isDense: true),
                            onChanged: (v) => item.name = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.price > 0 ? item.price.toString() : '',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Price (₹)', isDense: true),
                            onChanged: (v) => item.price = double.tryParse(v) ?? 0.0,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => setState(() => _foodItems.removeAt(idx)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Align(alignment: Alignment.centerLeft, child: Text('Shared by:', style: TextStyle(fontSize: 12))),
                    Wrap(
                      spacing: 8,
                      children: widget.provider.people.map((p) {
                        bool isSelected = item.sharedByPersonIds.contains(p.id);
                        return FilterChip(
                          label: Text(p.name, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              if (val) item.sharedByPersonIds.add(p.id);
                              else item.sharedByPersonIds.remove(p.id);
                            });
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addFoodItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Food Item'),
            )
          ],
        );
    }
  }

  void _saveExpense() {
    double totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (_nameController.text.isEmpty || (totalAmount <= 0 && _splitMethod != SplitMethod.itemized)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and amount')));
      return;
    }

    Map<String, double> rawValues = {};
    Map<String, double> exactAmounts = {};
    
    if (_splitMethod == SplitMethod.equal) {
      if (_selectedSharers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one person')));
        return;
      }
      double perPerson = totalAmount / _selectedSharers.length;
      for (var id in _selectedSharers) {
        exactAmounts[id] = perPerson;
      }
    } 
    else if (_splitMethod == SplitMethod.exact) {
      double sum = 0;
      for (var p in widget.provider.people) {
        double val = double.tryParse(_customInputControllers[p.id]!.text) ?? 0.0;
        rawValues[p.id] = val;
        exactAmounts[p.id] = val;
        sum += val;
      }
      if ((sum - totalAmount).abs() > 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exact amounts must sum up to total amount!')));
        return;
      }
    }
    else if (_splitMethod == SplitMethod.percentage) {
      double pctSum = 0;
      for (var p in widget.provider.people) {
        double pct = double.tryParse(_customInputControllers[p.id]!.text) ?? 0.0;
        rawValues[p.id] = pct;
        pctSum += pct;
        exactAmounts[p.id] = totalAmount * (pct / 100.0);
      }
      if ((pctSum - 100).abs() > 0.1) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Percentages must sum up to 100!')));
        return;
      }
    }
    else if (_splitMethod == SplitMethod.shares) {
      double totalShares = 0;
      for (var p in widget.provider.people) {
        double share = double.tryParse(_customInputControllers[p.id]!.text) ?? 0.0;
        rawValues[p.id] = share;
        totalShares += share;
      }
      if (totalShares <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total shares must be greater than 0!')));
        return;
      }
      for (var p in widget.provider.people) {
        double share = rawValues[p.id]!;
        exactAmounts[p.id] = totalAmount * (share / totalShares);
      }
    }
    else if (_splitMethod == SplitMethod.itemized) {
      // Calculate total amount from food items if not specified
      double calculatedTotal = 0;
      for (var item in _foodItems) {
        if (item.sharedByPersonIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item "${item.name}" has no one sharing it.')));
          return;
        }
        calculatedTotal += item.total;
        
        double costPerPerson = item.total / item.sharedByPersonIds.length;
        for (var personId in item.sharedByPersonIds) {
          exactAmounts[personId] = (exactAmounts[personId] ?? 0.0) + costPerPerson;
        }
      }
      if (totalAmount <= 0) {
        totalAmount = calculatedTotal;
      }
    }

    final expense = SplitItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      amount: totalAmount,
      paidByPersonId: _selectedPayerId,
      date: DateTime.now(),
      category: _categoryController.text,
      notes: _notesController.text,
      splitMethod: _splitMethod,
      sharedByPersonIds: _selectedSharers,
      splitValues: rawValues,
      exactAmountsOwed: exactAmounts,
      foodItems: _splitMethod == SplitMethod.itemized ? _foodItems : [],
    );

    widget.provider.addItem(expense);
    Navigator.pop(context);
  }
}
