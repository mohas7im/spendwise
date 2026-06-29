import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../models/vault_models.dart';
import '../../widgets/common/custom_bottom_sheet.dart';

class VaultRemindersView extends StatefulWidget {
  const VaultRemindersView({super.key});

  @override
  State<VaultRemindersView> createState() => _VaultRemindersViewState();
}

class _VaultRemindersViewState extends State<VaultRemindersView> {
  final List<String> _categories = ['All', 'Bills', 'EMI', 'Loan', 'Insurance', 'Vehicle Service', 'Shopping', 'Birthday', 'Meeting', 'Other'];
  String _selectedCategory = 'All';

  void _showReminderModal({VaultReminder? existingReminder}) {
    final titleCtrl = TextEditingController(text: existingReminder?.title ?? '');
    final descCtrl = TextEditingController(text: existingReminder?.description ?? '');
    DateTime selectedDate = existingReminder?.date ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(existingReminder?.date ?? DateTime.now());
    String category = existingReminder?.category ?? 'Bills';
    String priority = existingReminder?.priority ?? 'Medium';
    String repeat = existingReminder?.repeat ?? 'None';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => CustomBottomSheet(
          title: existingReminder == null ? 'New Reminder' : 'Edit Reminder',
          saveText: existingReminder == null ? 'Add' : 'Update',
          onSave: () {
            if (titleCtrl.text.isEmpty) return;
            final dt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
            final rem = VaultReminder(
              id: existingReminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: titleCtrl.text,
              description: descCtrl.text,
              date: dt,
              category: category,
              priority: priority,
              repeat: repeat,
              isCompleted: existingReminder?.isCompleted ?? false,
            );
            if (existingReminder == null) {
              context.read<VaultProvider>().addReminder(rem);
            } else {
              context.read<VaultProvider>().updateReminder(rem);
            }
            Navigator.pop(ctx);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Match standard OutlineInputBorder radius
                        side: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)) // Match standard border color
                      ),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                      onPressed: () async {
                        final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (d != null) setModalState(() => selectedDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.2))
                      ),
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(selectedTime.format(context)),
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: selectedTime);
                        if (t != null) setModalState(() => selectedTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: category,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Category', 
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                ),
                items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setModalState(() => category = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: priority,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Priority', 
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                      ),
                      items: ['Low', 'Medium', 'High'].map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setModalState(() => priority = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: repeat,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Repeat', 
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                      ),
                      items: ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly'].map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setModalState(() => repeat = v!),
                    ),
                  ),
                ],
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
    var reminders = provider.reminders;
    if (_selectedCategory != 'All') {
      reminders = reminders.where((r) => r.category == _selectedCategory).toList();
    }
    
    // Sort uncompleted first, then by date
    reminders.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      return a.date.compareTo(b.date);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Reminders', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (provider.reminders.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
                      showCheckmark: false,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: reminders.isEmpty
                ? const Center(child: Text('No reminders found.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final rem = reminders[index];
                      Color priorityColor = Colors.green;
                      if (rem.priority == 'Medium') priorityColor = Colors.orange;
                      if (rem.priority == 'High') priorityColor = Colors.red;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Checkbox(
                            value: rem.isCompleted,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (val) {
                              rem.isCompleted = val ?? false;
                              provider.updateReminder(rem);
                            },
                          ),
                          title: Text(rem.title, style: TextStyle(fontWeight: FontWeight.bold, decoration: rem.isCompleted ? TextDecoration.lineThrough : null)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (rem.description.isNotEmpty) Text(rem.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 12, color: rem.date.isBefore(DateTime.now()) && !rem.isCompleted ? Colors.red : Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${rem.date.day}/${rem.date.month}/${rem.date.year} ${TimeOfDay.fromDateTime(rem.date).format(context)}', 
                                    style: TextStyle(color: rem.date.isBefore(DateTime.now()) && !rem.isCompleted ? Colors.red : Colors.grey, fontSize: 12)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.flag, size: 12, color: priorityColor),
                                  const SizedBox(width: 4),
                                  Text(rem.priority, style: TextStyle(color: priorityColor, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'edit') _showReminderModal(existingReminder: rem);
                              if (val == 'delete') provider.deleteReminder(rem.id);
                            },
                            itemBuilder: (c) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                          onTap: () => _showReminderModal(existingReminder: rem),
                        ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReminderModal(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
