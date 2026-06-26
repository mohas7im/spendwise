import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/split_provider.dart';
import '../split_calculator_screen.dart';

class TripsListScreen extends StatelessWidget {
  const TripsListScreen({super.key});

  void _showCreateTripDialog(BuildContext context, SplitProvider provider) {
    final nameCtrl = TextEditingController();
    String currency = '₹';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Trip Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: currency,
              decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: '₹', child: Text('INR (₹)')),
                DropdownMenuItem(value: '\$', child: Text('USD (\$)' )),
                DropdownMenuItem(value: '€', child: Text('EUR (€)' )),
              ],
              onChanged: (val) {
                if (val != null) currency = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                provider.createTrip(nameCtrl.text.trim(), currency);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips & Events', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<SplitProvider>(
        builder: (context, provider, child) {
          if (provider.trips.isEmpty) {
            return const Center(child: Text('No trips found. Create one!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.trips.length,
            itemBuilder: (context, index) {
              final trip = provider.trips[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    provider.setActiveTrip(trip.id);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitCalculatorScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(Icons.flight_takeoff, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('${trip.date.day}/${trip.date.month}/${trip.date.year} • ${trip.participants.length} people', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Expense', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            Text('${trip.currency}${trip.totalExpense.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTripDialog(context, Provider.of<SplitProvider>(context, listen: false)),
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),
    );
  }
}
