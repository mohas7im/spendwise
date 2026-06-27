import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import '../models/vault_models.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  void _showAddCertificateModal(BuildContext context, VaultProvider provider) {
    final nameCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    final numCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Certificate', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Certificate Name (e.g. B.Tech)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orgCtrl,
                decoration: const InputDecoration(labelText: 'Organization / University', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numCtrl,
                decoration: const InputDecoration(labelText: 'Certificate Number (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
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
                      provider.addCertificate(VaultCertificate(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text,
                        organization: orgCtrl.text,
                        certNumber: numCtrl.text,
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save Certificate'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Certificates'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: vaultProvider.certificates.isEmpty
          ? const Center(child: Text('No certificates found.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vaultProvider.certificates.length,
              itemBuilder: (context, index) {
                final cert = vaultProvider.certificates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      child: const Icon(Icons.workspace_premium, color: Colors.orange),
                    ),
                    title: Text(cert.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(cert.organization),
                    trailing: const Icon(Icons.file_present, color: Colors.grey),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCertificateModal(context, vaultProvider),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
