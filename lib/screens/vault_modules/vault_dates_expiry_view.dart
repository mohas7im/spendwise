import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../models/vault_models.dart';
import '../../widgets/common/custom_bottom_sheet.dart';

class VaultDatesExpiryView extends StatefulWidget {
  const VaultDatesExpiryView({super.key});

  @override
  State<VaultDatesExpiryView> createState() => _VaultDatesExpiryViewState();
}

class _VaultDatesExpiryViewState extends State<VaultDatesExpiryView> {
  void _showAddDateModal({ImportantDate? existingDate}) {
    final titleCtrl = TextEditingController(text: existingDate?.title ?? '');
    final notesCtrl = TextEditingController(text: existingDate?.notes ?? '');
    DateTime selectedDate = existingDate?.date ?? DateTime.now();
    String recurringType = existingDate?.recurringType ?? 'Yearly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => CustomBottomSheet(
          title: existingDate == null ? 'New Important Date' : 'Edit Date',
          saveText: existingDate == null ? 'Add' : 'Update',
          onSave: () {
            if (titleCtrl.text.isEmpty) return;
            final d = ImportantDate(
              id: existingDate?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: titleCtrl.text,
              date: selectedDate,
              recurringType: recurringType,
              notes: notesCtrl.text,
            );
            if (existingDate == null) {
              context.read<VaultProvider>().addImportantDate(d);
            } else {
              context.read<VaultProvider>().updateImportantDate(d);
            }
            Navigator.pop(ctx);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: 'Title (e.g. Anniversary)', filled: true, fillColor: Colors.black12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black12, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 50)),
                icon: const Icon(Icons.calendar_today),
                label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(1900), lastDate: DateTime(2100));
                  if (d != null) setModalState(() => selectedDate = d);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: recurringType,
                decoration: InputDecoration(labelText: 'Recurring', filled: true, fillColor: Colors.black12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                items: ['None', 'Monthly', 'Yearly'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModalState(() => recurringType = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(labelText: 'Notes', filled: true, fillColor: Colors.black12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VaultProvider>(context);
    final dates = provider.importantDates;
    final expirations = provider.upcomingExpirations;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Expiry & Dates', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expiry Tracker Section
            if (expirations.isNotEmpty) ...[
              const Text('Upcoming Expirations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent)),
              const SizedBox(height: 8),
              ...expirations.map((exp) {
                final date = exp['date'] as DateTime;
                final diff = date.difference(DateTime.now()).inDays;
                final item = exp['item'];
                String title = '';
                if (item is VaultDocument) title = item.name;
                if (item is VaultCertificate) title = item.name;
                if (item is PaymentCard) title = item.cardName;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.red.shade900.withValues(alpha: 0.1),
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.red.shade900),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${exp['type']} - Expires on ${date.day}/${date.month}/${date.year}'),
                    trailing: Text('$diff days', style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Important Dates Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Important Dates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            if (dates.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No important dates added.', style: TextStyle(color: Colors.grey))))
            else
              ...dates.map((d) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.black12,
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.cake, color: Colors.blueAccent)),
                      title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${d.date.day}/${d.date.month}/${d.date.year} (${d.recurringType})'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'edit') _showAddDateModal(existingDate: d);
                          if (val == 'delete') provider.deleteImportantDate(d.id);
                        },
                        itemBuilder: (c) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDateModal(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
