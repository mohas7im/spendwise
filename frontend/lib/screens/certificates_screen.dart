import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/vault_provider.dart';
import '../models/vault_models.dart';
import '../widgets/common/custom_bottom_sheet.dart';

class CertificatesScreen extends StatefulWidget {
  final bool embedded;
  const CertificatesScreen({super.key, this.embedded = false});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  void _showAddCertificateModal(BuildContext context, VaultProvider provider, {VaultCertificate? existingCert}) {
    final nameCtrl = TextEditingController(text: existingCert?.name ?? '');
    final orgCtrl = TextEditingController(text: existingCert?.organization ?? '');
    final numCtrl = TextEditingController(text: existingCert?.certNumber ?? '');
    final notesCtrl = TextEditingController(text: existingCert?.notes ?? '');
    DateTime? issueDate = existingCert?.issueDate;
    DateTime? expiryDate = existingCert?.expiryDate;
    String? filePath = existingCert?.filePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => CustomBottomSheet(
          title: existingCert == null ? 'Add Certificate' : 'Edit Certificate',
          saveText: existingCert == null ? 'Save' : 'Update',
          onSave: () {
            if (nameCtrl.text.isNotEmpty) {
              final cert = VaultCertificate(
                id: existingCert?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text,
                organization: orgCtrl.text,
                certNumber: numCtrl.text,
                issueDate: issueDate,
                expiryDate: expiryDate,
                filePath: filePath,
                notes: notesCtrl.text,
                isFavorite: existingCert?.isFavorite ?? false,
              );
              existingCert == null ? provider.addCertificate(cert) : provider.updateCertificate(cert);
              Navigator.pop(ctx);
            }
          },
          child: Column(
            children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Certificate Name (e.g. B.Tech)', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: orgCtrl, decoration: const InputDecoration(labelText: 'Organization / University', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: numCtrl, decoration: const InputDecoration(labelText: 'Certificate Number (Optional)', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
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
                              title: const Text('Expiry Date (Opt)', style: TextStyle(fontSize: 12)),
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
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const Text('Certificate File (PDF/Image)'),
                        subtitle: Text(filePath != null ? 'Selected' : 'Tap to attach'),
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.pickFiles(type: FileType.any);
                          if (result != null) setModalState(() => filePath = result.files.single.path);
                        },
                        trailing: filePath != null ? IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setModalState(() => filePath = null)) : null,
                      ),
                      const Divider(),
                      TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
                      const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showCertificateDetails(BuildContext context, VaultCertificate cert, VaultProvider provider) {
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
                Expanded(child: Text(cert.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    Navigator.pop(ctx);
                    if (val == 'edit') {
                      _showAddCertificateModal(context, provider, existingCert: cert);
                    } else if (val == 'delete') {
                      provider.deleteCertificate(cert.id);
                    }
                  },
                  itemBuilder: (c) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(cert.organization, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            if (cert.certNumber.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Certificate Number', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(cert.certNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.blueAccent),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: cert.certNumber));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                      },
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Issue Date', style: TextStyle(color: Colors.grey)),
                      Text(cert.issueDate != null ? '${cert.issueDate!.day}/${cert.issueDate!.month}/${cert.issueDate!.year}' : '-'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expiry Date', style: TextStyle(color: Colors.grey)),
                      Text(cert.expiryDate != null ? '${cert.expiryDate!.day}/${cert.expiryDate!.month}/${cert.expiryDate!.year}' : '-', style: TextStyle(color: cert.expiryDate != null && cert.expiryDate!.isBefore(DateTime.now()) ? Colors.red : null)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (cert.notes.isNotEmpty) ...[
              const Text('Notes', style: TextStyle(color: Colors.grey)),
              Text(cert.notes),
              const SizedBox(height: 16),
            ],
            if (cert.filePath != null) ...[
              const Divider(height: 32),
              const ListTile(leading: Icon(Icons.file_present), title: Text('File attached'), contentPadding: EdgeInsets.zero),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);

    var certs = vaultProvider.certificates;
    if (_searchQuery.isNotEmpty) {
      certs = certs.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || c.organization.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      backgroundColor: widget.embedded ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.embedded ? null : AppBar(
        title: Text('Certificates', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
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
                hintText: 'Search certificates...',
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
          Expanded(
            child: certs.isEmpty
                ? const Center(child: Text('No certificates found.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: certs.length,
                    itemBuilder: (context, index) {
                      final cert = certs[index];
                      final isExpired = cert.expiryDate != null && cert.expiryDate!.isBefore(DateTime.now());

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
                          onTap: () => _showCertificateDetails(context, cert, vaultProvider),
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withValues(alpha: 0.1),
                            child: const Icon(Icons.workspace_premium, color: Colors.orange),
                          ),
                          title: Text(cert.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(cert.organization),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isExpired) const Icon(Icons.warning, color: Colors.red, size: 16),
                              if (cert.filePath != null) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.attachment, color: Colors.grey, size: 16)),
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
        onPressed: () => _showAddCertificateModal(context, vaultProvider),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
