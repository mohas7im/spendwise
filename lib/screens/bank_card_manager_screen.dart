import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import '../providers/vault_provider.dart';
import '../models/vault_models.dart';

class BankCardManagerScreen extends StatefulWidget {
  const BankCardManagerScreen({super.key});

  @override
  State<BankCardManagerScreen> createState() => _BankCardManagerScreenState();
}

class _BankCardManagerScreenState extends State<BankCardManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showAddBankModal(BuildContext context, VaultProvider provider) {
    final bankCtrl = TextEditingController();
    final accCtrl = TextEditingController();
    final holderCtrl = TextEditingController();

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
              Text('Add Bank Account', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: bankCtrl,
                decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: holderCtrl,
                decoration: const InputDecoration(labelText: 'Holder Name', border: OutlineInputBorder()),
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
                    if (bankCtrl.text.isNotEmpty) {
                      provider.addBankAccount(BankAccount(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        bankName: bankCtrl.text,
                        accountNumber: accCtrl.text,
                        holderName: holderCtrl.text,
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save Account'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCardModal(BuildContext context, VaultProvider provider) {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    int selectedColor = Colors.deepPurple.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Payment Card', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Bank / Card Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: numCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Card Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: expCtrl,
                  decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: [Colors.deepPurple, Colors.black87, Colors.indigo, Colors.redAccent].map((c) => GestureDetector(
                    onTap: () => setModalState(() => selectedColor = c.value),
                    child: CircleAvatar(
                      backgroundColor: c,
                      radius: 20,
                      child: selectedColor == c.value ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  )).toList(),
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
                        provider.addPaymentCard(PaymentCard(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          cardName: nameCtrl.text,
                          bank: nameCtrl.text,
                          cardType: 'Credit',
                          cardNumber: numCtrl.text,
                          holderName: 'Your Name',
                          expiryDate: expCtrl.text,
                          network: 'Visa',
                          colorValue: selectedColor,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Save Card'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
        title: const Text('Banks & Cards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Bank Accounts'),
            Tab(text: 'Payment Cards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Bank Accounts Tab
          vaultProvider.bankAccounts.isEmpty
              ? const Center(child: Text('No bank accounts found.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vaultProvider.bankAccounts.length,
                  itemBuilder: (ctx, i) {
                    final acc = vaultProvider.bankAccounts[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                          child: const Icon(Icons.account_balance, color: Colors.indigo),
                        ),
                        title: Text(acc.bankName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('A/C: **** ${acc.accountNumber.length > 4 ? acc.accountNumber.substring(acc.accountNumber.length - 4) : acc.accountNumber}'),
                      ),
                    );
                  },
                ),
          
          // Payment Cards Tab
          vaultProvider.paymentCards.isEmpty
              ? const Center(child: Text('No payment cards found.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vaultProvider.paymentCards.length,
                  itemBuilder: (ctx, i) {
                    final card = vaultProvider.paymentCards[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        front: _buildCardFront(card),
                        back: _buildCardBack(card),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddBankModal(context, vaultProvider);
          } else {
            _showAddCardModal(context, vaultProvider);
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardFront(PaymentCard card) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: card.color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card.bank, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Icon(Icons.wifi, color: Colors.white),
            ],
          ),
          const Spacer(),
          Text(
            card.cardNumber.isNotEmpty ? '**** **** **** ${card.cardNumber.length > 4 ? card.cardNumber.substring(card.cardNumber.length - 4) : card.cardNumber}' : '**** **** **** ****',
            style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CARD HOLDER', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(card.holderName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EXPIRES', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(card.expiryDate, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(PaymentCard card) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: card.color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            height: 40,
            color: Colors.black87,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(card.cvv.isNotEmpty ? card.cvv : '***', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Authorized Signature', style: TextStyle(color: Colors.white54, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
