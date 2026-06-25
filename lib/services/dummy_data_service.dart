import '../models/transaction.dart';
import '../models/income_source.dart';

class DummyDataService {
  static List<IncomeSource> getDummyIncomes() {
    return [
      IncomeSource(id: '1', name: 'Company Salary', amount: 5000, type: IncomeType.salary, frequency: IncomeFrequency.monthly),
      IncomeSource(id: '2', name: 'Freelance Design', amount: 1200, type: IncomeType.freelance, frequency: IncomeFrequency.monthly),
    ];
  }

  static List<TransactionModel> getDummyTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 't1', 
        title: 'Starbucks Reserve', 
        amount: 8.40, 
        date: now, 
        category: 'Food & Drink', 
        type: TransactionType.expense
      ),
      TransactionModel(
        id: 't2', 
        title: 'Salary Deposit', 
        amount: 4210.00, 
        date: now, 
        category: 'Income', 
        type: TransactionType.income
      ),
      TransactionModel(
        id: 't3', 
        title: 'Whole Foods Market', 
        amount: 67.84, 
        date: now.subtract(const Duration(days: 1)), 
        category: 'Groceries', 
        type: TransactionType.expense
      ),
    ];
  }
}
