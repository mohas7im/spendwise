import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:io';
import '../providers/vault_provider.dart';
import '../models/vault_models.dart';

class DocumentVaultScreen extends StatefulWidget {
  final String? initialCategory;
  const DocumentVaultScreen({super.key, this.initialCategory});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Identity', 'Banking', 'Insurance', 'Vehicle', 'Financial', 'Other'];
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  void _showAddDocumentModal(BuildContext context, VaultProvider provider, {VaultDocument? existingDoc}) {
    final nameCtrl = TextEditingController(text: existingDoc?.name ?? '');
    final numCtrl = TextEditingController(text: existingDoc?.documentNumber ?? '');
    final authCtrl = TextEditingController(text: existingDoc?.issuingAuthority ?? '');
    final notesCtrl = TextEditingController(text: existingDoc?.notes ?? '');
    String cat = existingDoc?.category ?? (_selectedCategory == 'All' ? 'Identity' : _selectedCategory);
    DateTime? issueDate = existingDoc?.issueDate;
    DateTime? expiryDate = existingDoc?.expiryDate;
    String? frontImagePath = existingDoc?.frontImagePath;
    String? backImagePath = existingDoc?.backImagePath;
    String? pdfPath = existingDoc?.pdfPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(existingDoc == null ? 'Add Document' : 'Edit Document', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: cat,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setModalState(() => cat = val!),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Document Name (e.g. Aadhaar)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: numCtrl,
                        decoration: const InputDecoration(labelText: 'Document Number', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: authCtrl,
                        decoration: const InputDecoration(labelText: 'Issuing Authority', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      
                      // Dates
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Issue Date', style: TextStyle(fontSize: 12)),
                              subtitle: Text(issueDate != null ? '${issueDate!.day}/${issueDate!.month}/${issueDate!.year}' : 'Not Set'),
                              trailing: const Icon(Icons.calendar_today, size: 16),
                              onTap: () async {
                                final picked = await showDatePicker(context: context, initialDate: issueDate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                                if (picked != null) setModalState(() => issueDate = picked);
                              },
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Expiry Date', style: TextStyle(fontSize: 12)),
                              subtitle: Text(expiryDate != null ? '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}' : 'Not Set'),
                              trailing: const Icon(Icons.calendar_today, size: 16),
                              onTap: () async {
                                final picked = await showDatePicker(context: context, initialDate: expiryDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                                if (picked != null) setModalState(() => expiryDate = picked);
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      
                      // Files
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.image),
                        title: const Text('Front Image'),
                        subtitle: Text(frontImagePath != null ? 'Selected' : 'Tap to attach'),
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) setModalState(() => frontImagePath = image.path);
                        },
                        trailing: frontImagePath != null ? IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setModalState(() => frontImagePath = null)) : null,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.image),
                        title: const Text('Back Image'),
                        subtitle: Text(backImagePath != null ? 'Selected' : 'Tap to attach'),
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) setModalState(() => backImagePath = image.path);
                        },
                        trailing: backImagePath != null ? IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setModalState(() => backImagePath = null)) : null,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const Text('PDF Document'),
                        subtitle: Text(pdfPath != null ? 'Selected' : 'Tap to attach'),
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                          if (result != null) setModalState(() => pdfPath = result.files.single.path);
                        },
                        trailing: pdfPath != null ? IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setModalState(() => pdfPath = null)) : null,
                      ),
                      const Divider(),
                      
                      TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      final doc = VaultDocument(
                        id: existingDoc?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text,
                        category: cat,
                        documentNumber: numCtrl.text,
                        issuingAuthority: authCtrl.text,
                        notes: notesCtrl.text,
                        issueDate: issueDate,
                        expiryDate: expiryDate,
                        frontImagePath: frontImagePath,
                        backImagePath: backImagePath,
                        pdfPath: pdfPath,
                        isFavorite: existingDoc?.isFavorite ?? false,
                      );
                      if (existingDoc == null) {
                        provider.addDocument(doc);
                      } else {
                        provider.updateDocument(doc);
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(existingDoc == null ? 'Save Document' : 'Update Document'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentDetails(BuildContext context, VaultDocument doc, VaultProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(doc.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    Navigator.pop(ctx);
                    if (val == 'edit') {
                      _showAddDocumentModal(context, provider, existingDoc: doc);
                    } else if (val == 'delete') {
                      provider.deleteDocument(doc.id);
                    }
                  },
                  itemBuilder: (c) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (doc.documentNumber.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Document Number', style: TextStyle(color: Colors.grey)),
                      Text(doc.documentNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blueAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: doc.documentNumber));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                    },
                  ),
                ],
              ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Issue Date', style: TextStyle(color: Colors.grey)),
                      Text(doc.issueDate != null ? '${doc.issueDate!.day}/${doc.issueDate!.month}/${doc.issueDate!.year}' : '-'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expiry Date', style: TextStyle(color: Colors.grey)),
                      Text(doc.expiryDate != null ? '${doc.expiryDate!.day}/${doc.expiryDate!.month}/${doc.expiryDate!.year}' : '-', style: TextStyle(color: doc.expiryDate != null && doc.expiryDate!.isBefore(DateTime.now()) ? Colors.red : null)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (doc.issuingAuthority.isNotEmpty) ...[
              const Text('Issuing Authority', style: TextStyle(color: Colors.grey)),
              Text(doc.issuingAuthority),
              const SizedBox(height: 16),
            ],
            if (doc.notes.isNotEmpty) ...[
              const Text('Notes', style: TextStyle(color: Colors.grey)),
              Text(doc.notes),
              const SizedBox(height: 16),
            ],
            
            // Attachments summary
            if (doc.frontImagePath != null || doc.backImagePath != null) ...[
              const Divider(height: 32),
              const Text('Document Images (Tap to flip)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (doc.frontImagePath != null && doc.backImagePath != null)
                FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: _buildImageCard(doc.frontImagePath!, 'Front'),
                  back: _buildImageCard(doc.backImagePath!, 'Back'),
                )
              else if (doc.frontImagePath != null)
                _buildImageCard(doc.frontImagePath!, 'Front')
              else if (doc.backImagePath != null)
                _buildImageCard(doc.backImagePath!, 'Back'),
            ],
            if (doc.pdfPath != null) ...[
              const Divider(height: 16),
              const ListTile(leading: Icon(Icons.picture_as_pdf), title: Text('PDF attached'), contentPadding: EdgeInsets.zero),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath, String label) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    
    var docs = vaultProvider.documents.where((d) => _selectedCategory == 'All' || d.category == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) {
      docs = docs.where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()) || d.documentNumber.contains(_searchQuery)).toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Documents', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search documents...',
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
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
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
            child: docs.isEmpty
                ? const Center(child: Text('No documents found.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final isExpired = doc.expiryDate != null && doc.expiryDate!.isBefore(DateTime.now());
                      
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
                          onTap: () => _showDocumentDetails(context, doc, vaultProvider),
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            child: Icon(Icons.description, color: Theme.of(context).primaryColor),
                          ),
                          title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            isExpired ? 'Expired' : (doc.documentNumber.isNotEmpty ? doc.documentNumber : doc.category),
                            style: TextStyle(color: isExpired ? Colors.red : null),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (doc.frontImagePath != null || doc.pdfPath != null)
                                const Icon(Icons.attachment, color: Colors.grey, size: 16),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: doc.documentNumber));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDocumentModal(context, vaultProvider),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
