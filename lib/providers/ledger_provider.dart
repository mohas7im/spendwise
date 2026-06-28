import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../models/global_transaction.dart';
import '../providers/finance_provider.dart';
import '../providers/split_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/vault_provider.dart';
import '../models/debt.dart';

class LedgerProvider extends ChangeNotifier {
  final List<GlobalTransaction> _allTransactions = [];
  List<GlobalTransaction> _filteredTransactions = [];
  
  // Filters
  String _searchQuery = '';
  GlobalTransactionType? _typeFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _categoryFilter = [];
  String? _paymentMethodFilter;
  double? _minAmount;
  double? _maxAmount;
  List<String> _tagsFilter = [];

  // Sorting
  String _sortField = 'date'; // 'date', 'amount', 'category', 'alphabetical'
  bool _sortAscending = false;

  // Selection for bulk actions
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  // Analytics
  double _totalIncome = 0;
  double _totalExpense = 0;

  List<GlobalTransaction> get transactions => _filteredTransactions;
  
  // Getters for filters/sort
  String get searchQuery => _searchQuery;
  GlobalTransactionType? get typeFilter => _typeFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  List<String> get categoryFilter => _categoryFilter;
  String? get paymentMethodFilter => _paymentMethodFilter;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  List<String> get tagsFilter => _tagsFilter;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;
  
  Set<String> get selectedIds => _selectedIds;
  bool get isSelectionMode => _isSelectionMode;

  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get netBalance => _totalIncome - _totalExpense;

  void buildLedger(
    FinanceProvider finance,
    SplitProvider split,
    FuelProvider fuel,
    VaultProvider vault,
  ) {
    _allTransactions.clear();

    // 1. Finance Provider Transactions
    for (var t in finance.transactions) {
      _allTransactions.add(GlobalTransaction(
        id: 'fin_${t.id}',
        title: t.title,
        category: t.category,
        amount: t.amount,
        type: t.amount > 0 ? GlobalTransactionType.income : GlobalTransactionType.expense,
        date: t.date,
        paymentMethod: t.paymentMethod,
        attachments: t.attachments,
        sourceModule: 'Transactions',
      ));
    }

    // 2. Debts / Loans
    for (var d in finance.debts) {
      for (var p in d.paymentHistory) {
        _allTransactions.add(GlobalTransaction(
          id: 'debt_${d.id}_${p.date.millisecondsSinceEpoch}',
          title: 'Payment: ${d.personName}',
          category: 'Debt',
          amount: p.amount,
          type: (d.type == DebtType.iOwe || d.type == DebtType.loanTaken) ? GlobalTransactionType.expense : GlobalTransactionType.income,
          date: p.date,
          person: d.personName,
          sourceModule: 'Debts',
        ));
      }
    }

    // 3. Subscriptions
    for (var s in finance.subscriptions) {
      for (var p in s.paymentHistory) {
        _allTransactions.add(GlobalTransaction(
          id: 'sub_${s.id}_${p.date.millisecondsSinceEpoch}',
          title: s.name,
          category: 'Subscriptions',
          amount: p.amount,
          type: GlobalTransactionType.expense,
          date: p.date,
          sourceModule: 'Subscriptions',
        ));
      }
    }

    // 4. Split Provider (Groups/Trips)
    for (var trip in split.trips) {
      for (var exp in trip.expenses) {
        _allTransactions.add(GlobalTransaction(
          id: 'split_${exp.id}',
          title: exp.name,
          category: 'Group Split',
          amount: exp.amount,
          type: GlobalTransactionType.expense,
          date: exp.date,
          sourceModule: 'Trips & Splits',
        ));
      }
    }

    // 5. Fuel Provider
    for (var f in fuel.entries) {
      _allTransactions.add(GlobalTransaction(
        id: 'fuel_${f.id}',
        title: 'Fuel Refill',
        category: 'Transport',
        amount: f.totalCost,
        type: GlobalTransactionType.expense,
        date: f.date,
        sourceModule: 'Fuel',
      ));
    }

    // Sort by newest first
    _allTransactions.sort((a, b) => b.date.compareTo(a.date));
    
    _applyFilters();
  }


  void setTypeFilter(GlobalTransactionType? type) {
    _typeFilter = type;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setAdvancedFilters({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryFilter,
    String? paymentMethodFilter,
    double? minAmount,
    double? maxAmount,
    List<String>? tagsFilter,
  }) {
    _startDate = startDate;
    _endDate = endDate;
    if (categoryFilter != null) _categoryFilter = categoryFilter;
    _paymentMethodFilter = paymentMethodFilter;
    _minAmount = minAmount;
    _maxAmount = maxAmount;
    if (tagsFilter != null) _tagsFilter = tagsFilter;
    _applyFilters();
  }

  void setSort(String field, bool ascending) {
    _sortField = field;
    _sortAscending = ascending;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTransactions = _allTransactions.where((t) {
      if (_typeFilter != null && t.type != _typeFilter) return false;
      
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(query) && 
            !(t.person?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      if (_startDate != null && t.date.isBefore(_startDate!)) return false;
      if (_endDate != null && t.date.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
      if (_categoryFilter.isNotEmpty && !_categoryFilter.contains(t.category)) return false;
      if (_paymentMethodFilter != null && t.paymentMethod != _paymentMethodFilter) return false;
      if (_minAmount != null && t.amount < _minAmount!) return false;
      if (_maxAmount != null && t.amount > _maxAmount!) return false;
      
      if (_tagsFilter.isNotEmpty) {
        bool hasMatch = false;
        for (var tag in _tagsFilter) {
          if (t.tags.contains(tag)) {
            hasMatch = true;
            break;
          }
        }
        if (!hasMatch) return false;
      }

      return true;
    }).toList();

    // Sorting
    _filteredTransactions.sort((a, b) {
      int cmp = 0;
      switch (_sortField) {
        case 'amount':
          cmp = a.amount.compareTo(b.amount);
          break;
        case 'category':
          cmp = a.category.compareTo(b.category);
          break;
        case 'alphabetical':
          cmp = a.title.compareTo(b.title);
          break;
        case 'date':
        default:
          cmp = a.date.compareTo(b.date);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    _calculateAnalytics();
    notifyListeners();
  }

  void _calculateAnalytics() {
    _totalIncome = 0;
    _totalExpense = 0;
    for (var t in _filteredTransactions) {
      if (t.type == GlobalTransactionType.income) {
        _totalIncome += t.amount.abs();
      } else if (t.type == GlobalTransactionType.expense) {
        _totalExpense += t.amount.abs();
      }
    }
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    _isSelectionMode = _selectedIds.isNotEmpty;
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> exportToCSV(BuildContext context) async {
    final transactionsToExport = _isSelectionMode 
      ? _filteredTransactions.where((t) => _selectedIds.contains(t.id)).toList()
      : _filteredTransactions;

    List<List<dynamic>> rows = [];
    rows.add(["Date", "Title", "Category", "Amount", "Type", "Payment Method", "Person", "Module", "Notes"]);
    
    for (var t in transactionsToExport) {
      rows.add([
        t.date.toIso8601String(),
        t.title,
        t.category,
        t.amount.toStringAsFixed(2),
        t.type.name,
        t.paymentMethod,
        t.person ?? '',
        t.sourceModule,
        t.notes
      ]);
    }

    String csv = rows.map((row) => row.map((item) => '"${item.toString().replaceAll('"', '""')}"').join(',')).join('\n');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/transactions_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to ${file.path}')));
    clearSelection();
  }

  Future<void> exportToPDF(BuildContext context) async {
    final transactionsToExport = _isSelectionMode 
      ? _filteredTransactions.where((t) => _selectedIds.contains(t.id)).toList()
      : _filteredTransactions;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Transaction History', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Title', 'Category', 'Amount', 'Type'],
                data: transactionsToExport.map((t) => [
                  '${t.date.day}/${t.date.month}/${t.date.year}',
                  t.title,
                  t.category,
                  t.amount.toStringAsFixed(2),
                  t.type.name.toUpperCase(),
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/transactions_export_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported PDF to ${file.path}')));
    clearSelection();
  }
}
