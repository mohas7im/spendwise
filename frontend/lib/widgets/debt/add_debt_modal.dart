import 'package:flutter/material.dart';
import '../../models/debt.dart';
import '../../providers/finance_provider.dart';
import '../common/custom_bottom_sheet.dart';

class AddDebtModal extends StatefulWidget {
  final FinanceProvider provider;
  const AddDebtModal({super.key, required this.provider});

  @override
  State<AddDebtModal> createState() => _AddDebtModalState();
}

class _AddDebtModalState extends State<AddDebtModal> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _emiController = TextEditingController();
  
  DebtType _debtType = DebtType.iOwe;
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    bool isLoanOrEmi = _debtType == DebtType.loanGiven || _debtType == DebtType.loanTaken || _debtType == DebtType.emiLoan;

    return CustomBottomSheet(
      title: 'Add Debt / Loan',
      saveText: 'Save Debt/Loan',
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Person / Bank Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Principal Amount (₹)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DebtType>(
            initialValue: _debtType,
            decoration: const InputDecoration(labelText: 'Debt Type', border: OutlineInputBorder()),
            items: DebtType.values.map((t) => DropdownMenuItem(value: t, child: Text(_formatDebtType(t)))).toList(),
            onChanged: (v) { if (v != null) setState(() => _debtType = v); },
          ),
          
          if (isLoanOrEmi) ...[
            const SizedBox(height: 24),
            const Text('Loan Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _interestRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Interest % (p.a.)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tenure (Months)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_debtType == DebtType.emiLoan)
              TextField(
                controller: _emiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly EMI (₹)', border: OutlineInputBorder()),
              ),
          ],

          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start Date'),
            trailing: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (date != null) setState(() => _startDate = date);
            },
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  String _formatDebtType(DebtType type) {
    switch (type) {
      case DebtType.iOwe: return 'I Owe Someone';
      case DebtType.theyOwe: return 'Someone Owes Me';
      case DebtType.loanGiven: return 'Loan Given By Me';
      case DebtType.loanTaken: return 'Loan Taken By Me';
      case DebtType.emiLoan: return 'EMI Loan';
    }
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_nameController.text.isEmpty || amount <= 0) return;

    double? interest = double.tryParse(_interestRateController.text);
    int? tenure = int.tryParse(_tenureController.text);
    double? emi = double.tryParse(_emiController.text);

    DateTime? nextDue;
    if (_debtType == DebtType.emiLoan || tenure != null) {
      // First due date is 1 month from start
      nextDue = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
    }

    final debt = DebtModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      personName: _nameController.text,
      amount: amount,
      type: _debtType,
      date: _startDate,
      note: _noteController.text,
      interestRate: interest,
      tenureMonths: tenure,
      emiAmount: emi,
      nextDueDate: nextDue,
    );

    widget.provider.addDebt(debt);
    Navigator.pop(context);
  }
}
