import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(Icons.support_agent, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            Text(
              'Get in Touch',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Have any questions, feedback, or need support? We\'re here to help you out.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 48),

            // Email Contact Option
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'mohammedhashim530@gmail.com',
              onTap: () => _copyToClipboard(context, 'mohammedhashim530@gmail.com', 'Email address'),
            ),
            const SizedBox(height: 16),

            // GitHub Contact Option
            _buildContactCard(
              context,
              icon: Icons.code,
              title: 'GitHub',
              subtitle: 'github.com/mohas7im',
              onTap: () => _copyToClipboard(context, 'https://github.com/mohas7im', 'GitHub link'),
            ),
            const SizedBox(height: 16),

            // Twitter/X Contact Option (Example placeholder)
            _buildContactCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Twitter / X',
              subtitle: '@mohas7im',
              onTap: () => _copyToClipboard(context, '@mohas7im', 'Twitter handle'),
            ),

            const SizedBox(height: 48),
            const Text(
              'We usually respond within 24-48 hours.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500)),
        ),
        trailing: Icon(Icons.copy, color: Colors.grey.shade400, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
