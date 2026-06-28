import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../models/vault_models.dart';
import '../../widgets/common/custom_bottom_sheet.dart';

class VaultNotesView extends StatefulWidget {
  const VaultNotesView({super.key});

  @override
  State<VaultNotesView> createState() => _VaultNotesViewState();
}

class _VaultNotesViewState extends State<VaultNotesView> {
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  void _showNoteModal({VaultNote? existingNote}) {
    final titleCtrl = TextEditingController(text: existingNote?.title ?? '');
    final descCtrl = TextEditingController(text: existingNote?.description ?? '');
    int selectedColor = existingNote?.colorValue ?? 0xFF1E1E1E; // Default dark
    bool isPinned = existingNote?.isPinned ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => CustomBottomSheet(
          title: existingNote == null ? 'Add Note' : 'Edit Note',
          backgroundColor: Color(selectedColor),
          headerTextColor: Colors.white,
          headerActions: [
            if (existingNote != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  context.read<VaultProvider>().deleteNote(existingNote.id);
                  Navigator.pop(ctx);
                },
              ),
            IconButton(
              icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: Colors.white),
              onPressed: () => setModalState(() => isPinned = !isPinned),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () {
                if (titleCtrl.text.isEmpty && descCtrl.text.isEmpty) {
                  Navigator.pop(ctx);
                  return;
                }
                final note = VaultNote(
                  id: existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text.isNotEmpty ? titleCtrl.text : 'Untitled Note',
                  description: descCtrl.text,
                  colorValue: selectedColor,
                  isPinned: isPinned,
                  createdDate: existingNote?.createdDate ?? DateTime.now(),
                  updatedDate: DateTime.now(),
                );
                if (existingNote == null) {
                  context.read<VaultProvider>().addNote(note);
                } else {
                  context.read<VaultProvider>().updateNote(note);
                }
                Navigator.pop(ctx);
              }
            )
          ],
          child: Column(
            children: [
              // Color Picker
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    0xFF1E1E1E, 0xFF77172E, 0xFF177759, 0xFF173C77, 0xFF651777, 0xFF774C17
                  ].map((colorVal) => GestureDetector(
                        onTap: () => setModalState(() => selectedColor = colorVal),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 40,
                          decoration: BoxDecoration(
                            color: Color(colorVal),
                            shape: BoxShape.circle,
                            border: Border.all(color: selectedColor == colorVal ? Colors.white : Colors.transparent, width: 2),
                          ),
                        ),
                      )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: 'Title', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: const InputDecoration(hintText: 'Type your note here...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VaultProvider>(context);
    var notes = provider.notes;
    
    if (_searchQuery.isNotEmpty) {
      notes = notes.where((n) => n.title.toLowerCase().contains(_searchQuery.toLowerCase()) || n.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Sort pinned first, then by updated date
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedDate.compareTo(a.updatedDate);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notes', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('No notes found.', style: TextStyle(color: Colors.grey)))
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
                        itemCount: notes.length,
                        itemBuilder: (context, index) => _buildNoteCard(notes[index]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notes.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNoteCard(notes[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteModal(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(VaultNote note) {
    return GestureDetector(
      onTap: () => _showNoteModal(existingNote: note),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(note.colorValue),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (note.isPinned) const Icon(Icons.push_pin, color: Colors.white, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(note.description, style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: _isGridView ? 5 : 3, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 8),
            Text(
              '${note.updatedDate.day}/${note.updatedDate.month}/${note.updatedDate.year}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
