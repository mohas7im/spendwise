import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/unified_activity_card.dart';

class AllActivityScreen extends StatefulWidget {
  const AllActivityScreen({super.key});

  @override
  State<AllActivityScreen> createState() => _AllActivityScreenState();
}

class _AllActivityScreenState extends State<AllActivityScreen> {
  DateTimeRange? _dateRange;
  String _sortBy = 'Date (Newest)';

  final List<String> _sortOptions = [
    'Date (Newest)',
    'Date (Oldest)',
    'Amount (High to Low)',
    'Amount (Low to High)',
  ];

  void _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    
    // Apply Filtering
    var activities = financeProvider.recentActivity.toList();
    if (_dateRange != null) {
      activities = activities.where((act) {
        final d = act.date;
        // Ignore time by comparing just Y/M/D
        final actDate = DateTime(d.year, d.month, d.day);
        final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
        final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);
        return actDate.compareTo(start) >= 0 && actDate.compareTo(end) <= 0;
      }).toList();
    }

    // Apply Sorting
    activities.sort((a, b) {
      switch (_sortBy) {
        case 'Date (Newest)':
          return b.date.compareTo(a.date);
        case 'Date (Oldest)':
          return a.date.compareTo(b.date);
        case 'Amount (High to Low)':
          return b.amount.compareTo(a.amount);
        case 'Amount (Low to High)':
          return a.amount.compareTo(b.amount);
        default:
          return b.date.compareTo(a.date);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('All Activity', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.redAccent),
              onPressed: () => setState(() => _dateRange = null),
              tooltip: 'Clear Date Filter',
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDateRange,
            tooltip: 'Filter by Date',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Activities',
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (context) {
              return _sortOptions.map((opt) {
                return PopupMenuItem(
                  value: opt,
                  child: Row(
                    children: [
                      Icon(
                        _sortBy == opt ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: _sortBy == opt ? Theme.of(context).primaryColor : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(opt),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: activities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('No activities found for this filter.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return UnifiedActivityCard(activity: activities[index]);
              },
            ),
    );
  }
}
