import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/vault_provider.dart';
import '../models/vault_models.dart';
import '../widgets/common/custom_bottom_sheet.dart';

class BankCardManagerScreen extends StatefulWidget {
  final bool embedded;
  const BankCardManagerScreen({super.key, this.embedded = false});

  @override
  State<BankCardManagerScreen> createState() => _BankCardManagerScreenState();
}

class _BankCardManagerScreenState extends State<BankCardManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _revealSensitiveInfo = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showAddBankModal(BuildContext context, VaultProvider provider, {BankAccount? existingAcc}) {
    final bankCtrl = TextEditingController(text: existingAcc?.bankName ?? '');
    final accCtrl = TextEditingController(text: existingAcc?.accountNumber ?? '');
    final holderCtrl = TextEditingController(text: existingAcc?.holderName ?? '');
    final ifscCtrl = TextEditingController(text: existingAcc?.ifscCode ?? '');
    final branchCtrl = TextEditingController(text: existingAcc?.branch ?? '');
    final upiCtrl = TextEditingController(text: existingAcc?.upiId ?? '');
    final notesCtrl = TextEditingController(text: existingAcc?.notes ?? '');
    String accType = existingAcc?.accountType.isNotEmpty == true ? existingAcc!.accountType : 'Savings';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => CustomBottomSheet(
          title: existingAcc == null ? 'Add Bank Account' : 'Edit Bank Account',
          saveText: existingAcc == null ? 'Save' : 'Update',
          headerActions: [
            if (existingAcc != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  provider.deleteBankAccount(existingAcc.id);
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Close details sheet too
                },
              ),
          ],
          onSave: () {
            if (bankCtrl.text.isNotEmpty && accCtrl.text.isNotEmpty) {
              final acc = BankAccount(
                id: existingAcc?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                bankName: bankCtrl.text,
                accountNumber: accCtrl.text,
                holderName: holderCtrl.text,
                ifscCode: ifscCtrl.text,
                branch: branchCtrl.text,
                accountType: accType,
                upiId: upiCtrl.text,
                notes: notesCtrl.text,
              );
              existingAcc == null ? provider.addBankAccount(acc) : provider.updateBankAccount(acc);
              Navigator.pop(ctx);
              if (existingAcc != null) Navigator.pop(context);
            }
          },
          child: Column(
            children: [
                      TextField(controller: bankCtrl, decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: accCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: ifscCtrl, decoration: const InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: branchCtrl, decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: accType,
                              decoration: const InputDecoration(labelText: 'Account Type', border: OutlineInputBorder()),
                              items: ['Savings', 'Current', 'Salary', 'Fixed Deposit'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) => setModalState(() => accType = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: holderCtrl, decoration: const InputDecoration(labelText: 'Holder Name', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: upiCtrl, decoration: const InputDecoration(labelText: 'UPI ID (Optional)', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
                      const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCardModal(BuildContext context, VaultProvider provider, {PaymentCard? existingCard}) {
    final nameCtrl = TextEditingController(text: existingCard?.cardName ?? '');
    final numCtrl = TextEditingController(text: existingCard?.cardNumber ?? '');
    final expCtrl = TextEditingController(text: existingCard?.expiryDate ?? '');
    final cvvCtrl = TextEditingController(text: existingCard?.cvv ?? '');
    final holderCtrl = TextEditingController(text: existingCard?.holderName ?? '');
    final notesCtrl = TextEditingController(text: existingCard?.notes ?? '');
    int selectedColor = existingCard?.colorValue ?? Colors.indigo.toARGB32();
    String cardType = existingCard?.cardType.isNotEmpty == true ? existingCard!.cardType : 'Credit';
    String network = existingCard?.network.isNotEmpty == true ? existingCard!.network : 'Visa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => CustomBottomSheet(
          title: existingCard == null ? 'Add Payment Card' : 'Edit Payment Card',
          saveText: existingCard == null ? 'Save' : 'Update',
          headerActions: [
            if (existingCard != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  provider.deletePaymentCard(existingCard.id);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
          ],
          onSave: () {
            if (nameCtrl.text.isNotEmpty) {
              final card = PaymentCard(
                id: existingCard?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                cardName: nameCtrl.text,
                bank: nameCtrl.text,
                cardType: cardType,
                cardNumber: numCtrl.text,
                holderName: holderCtrl.text,
                expiryDate: expCtrl.text,
                network: network,
                colorValue: selectedColor,
                cvv: cvvCtrl.text,
                notes: notesCtrl.text,
              );
              existingCard == null ? provider.addPaymentCard(card) : provider.updatePaymentCard(card);
              Navigator.pop(ctx);
              if (existingCard != null) Navigator.pop(context);
            }
          },
          child: Column(
            children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Bank / Card Name', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: numCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Card Number', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: expCtrl, decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', border: OutlineInputBorder()))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: cvvCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: holderCtrl, decoration: const InputDecoration(labelText: 'Card Holder Name', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: cardType,
                              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                              items: ['Credit', 'Debit', 'Prepaid'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) => setModalState(() => cardType = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: network,
                              decoration: const InputDecoration(labelText: 'Network', border: OutlineInputBorder()),
                              items: ['Visa', 'Mastercard', 'RuPay', 'Amex'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) => setModalState(() => network = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        children: [Colors.deepPurple, Colors.black87, Colors.indigo, Colors.redAccent, Colors.teal, Colors.orange].map((c) => GestureDetector(
                          onTap: () => setModalState(() => selectedColor = c.toARGB32()),
                          child: CircleAvatar(
                            backgroundColor: c,
                            radius: 20,
                            child: selectedColor == c.toARGB32() ? const Icon(Icons.check, color: Colors.white) : null,
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showBankDetails(BuildContext context, BankAccount acc, VaultProvider provider) {
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
                Expanded(child: Text(acc.bankName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      tooltip: 'Edit',
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAddBankModal(context, provider, existingAcc: acc);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: () {
                        provider.deleteBankAccount(acc.id);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(acc.accountType, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            _buildDetailRow('Holder Name', acc.holderName),
            _buildDetailRow('Account No', _revealSensitiveInfo ? acc.accountNumber : _mask(acc.accountNumber), copyText: acc.accountNumber),
            _buildDetailRow('IFSC Code', acc.ifscCode, copyText: acc.ifscCode),
            _buildDetailRow('Branch', acc.branch),
            _buildDetailRow('UPI ID', acc.upiId, copyText: acc.upiId),
            if (acc.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Notes', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(acc.notes),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCardDetails(BuildContext context, PaymentCard card, VaultProvider provider) {
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
                Expanded(child: Text(card.cardName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      tooltip: 'Edit',
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAddCardModal(context, provider, existingCard: card);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: () {
                        provider.deletePaymentCard(card.id);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${card.network} • ${card.cardType}', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            _buildDetailRow('Holder Name', card.holderName),
            _buildDetailRow('Card Number', _revealSensitiveInfo ? card.cardNumber : _mask(card.cardNumber, visible: 4), copyText: card.cardNumber),
            _buildDetailRow('Expiry', card.expiryDate),
            _buildDetailRow('CVV', _revealSensitiveInfo ? card.cvv : '***'),
            if (card.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Notes', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(card.notes),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {String? copyText}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          if (copyText != null && copyText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.blueAccent, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyText));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied')));
              },
            ),
        ],
      ),
    );
  }

  String _mask(String text, {int visible = 4}) {
    if (text.length <= visible) return text;
    return '${'*' * (text.length - visible)}${text.substring(text.length - visible)}';
  }

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);

    var banks = vaultProvider.bankAccounts;
    var cards = vaultProvider.paymentCards;
    
    if (_searchQuery.isNotEmpty) {
      banks = banks.where((b) => b.bankName.toLowerCase().contains(_searchQuery.toLowerCase()) || b.accountNumber.contains(_searchQuery)).toList();
      cards = cards.where((c) => c.cardName.toLowerCase().contains(_searchQuery.toLowerCase()) || c.cardNumber.contains(_searchQuery)).toList();
    }

    return Scaffold(
      backgroundColor: widget.embedded ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.embedded ? null : AppBar(
        title: Text('Banks & Cards', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_revealSensitiveInfo ? Icons.visibility : Icons.visibility_off, color: _revealSensitiveInfo ? Colors.red : Colors.grey),
            onPressed: () => setState(() => _revealSensitiveInfo = !_revealSensitiveInfo),
            tooltip: 'Reveal Sensitive Info',
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Payment Cards'),
            Tab(text: 'Bank Accounts'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.embedded)
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Payment Cards'),
                Tab(text: 'Bank Accounts'),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search accounts & cards...',
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
            child: TabBarView(
              controller: _tabController,
              children: [
                // Payment Cards Tab
                cards.isEmpty
                    ? const Center(child: Text('No payment cards found.', style: TextStyle(color: Colors.grey)))
                    : _StackedCardsView(
                        cards: cards,
                        onCardLongPress: (card) => _showCardDetails(context, card, vaultProvider),
                        buildFront: _buildCardFront,
                        buildBack: _buildCardBack,
                      ),
                
                // Bank Accounts Tab
                banks.isEmpty
                    ? const Center(child: Text('No bank accounts found.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: banks.length,
                        itemBuilder: (ctx, i) {
                          final acc = banks[i];
                          return Dismissible(
                            key: Key(acc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Account'),
                                  content: const Text('Are you sure you want to delete this bank account?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) => vaultProvider.deleteBankAccount(acc.id),
                            child: Container(
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
                              onTap: () => _showBankDetails(context, acc, vaultProvider),
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                                child: const Icon(Icons.account_balance, color: Colors.indigo),
                              ),
                              title: Text(acc.bankName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('A/C: ${_revealSensitiveInfo ? acc.accountNumber : _mask(acc.accountNumber)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: acc.accountNumber));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account number copied')));
                                },
                              ),
                              ),
                            ),
                           ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddCardModal(context, vaultProvider);
          } else {
            _showAddBankModal(context, vaultProvider);
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
            card.cardNumber.isNotEmpty ? (_revealSensitiveInfo ? card.cardNumber : _mask(card.cardNumber, visible: 4)) : '**** **** **** ****',
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
                  child: Text(card.cvv.isNotEmpty ? (_revealSensitiveInfo ? card.cvv : '***') : '***', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
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

class _StackedCardsView extends StatefulWidget {
  final List<PaymentCard> cards;
  final Function(PaymentCard) onCardLongPress;
  final Widget Function(PaymentCard) buildFront;
  final Widget Function(PaymentCard) buildBack;

  const _StackedCardsView({
    required this.cards,
    required this.onCardLongPress,
    required this.buildFront,
    required this.buildBack,
  });

  @override
  State<_StackedCardsView> createState() => _StackedCardsViewState();
}

class _StackedCardsViewState extends State<_StackedCardsView> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            if (expandedIndex != null) {
              setState(() => expandedIndex = null);
            }
          },
          child: Container(
            color: Colors.transparent,
            height: constraints.maxHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(widget.cards.length, (i) {
                final card = widget.cards[i];
                final isExpanded = expandedIndex == i;
                final isOtherExpanded = expandedIndex != null && expandedIndex != i;
                
                double topOffset = i * 60.0;
                if (isExpanded) {
                  topOffset = 20.0;
                } else if (isOtherExpanded) {
                  topOffset = constraints.maxHeight + 100; // Slide off screen
                }

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  top: topOffset,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      if (isExpanded) {
                        widget.onCardLongPress(card);
                      } else {
                        setState(() {
                          expandedIndex = i;
                        });
                      }
                    },
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 400),
                      scale: isOtherExpanded ? 0.9 : 1.0,
                      child: widget.buildFront(card),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }
    );
  }
}
