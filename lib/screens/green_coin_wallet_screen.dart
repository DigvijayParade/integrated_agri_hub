import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const _kWalletGreen = Color(0xFF4A7C59);
const _kWalletDarkGreen = Color(0xFF2A5934);
const _kWalletGold = Color(0xFFFFB800);
const _kWalletCream = Color(0xFFF9F6F0);
const _kWalletLightGreen = Color(0xFFF0F5E8);

class GreenCoinWalletScreen extends StatefulWidget {
  final int greenCoins;
  final int streak;
  final String farmerName;
  final List<String> completedTasks;

  const GreenCoinWalletScreen({
    super.key,
    required this.greenCoins,
    required this.streak,
    required this.farmerName,
    required this.completedTasks,
  });

  @override
  State<GreenCoinWalletScreen> createState() => _GreenCoinWalletScreenState();
}

class _GreenCoinWalletScreenState extends State<GreenCoinWalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _coinAnimController;
  late Animation<double> _coinScaleAnim;

  List<_TxItem> _transactions = [];
  bool _loadingTx = true;

  @override
  void initState() {
    super.initState();
    _coinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _coinScaleAnim = CurvedAnimation(
      parent: _coinAnimController,
      curve: Curves.elasticOut,
    );
    _coinAnimController.forward();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loadingTx = false); return; }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final items = snap.docs.map((d) {
        final data = d.data();
        return _TxItem(
          name: data['name'] ?? 'Transaction',
          amount: data['amount']?.toString() ?? '0',
          isCredit: data['credit'] == true,
          dt: data['dt']?.toString() ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
        );
      }).toList();

      if (mounted) setState(() { _transactions = items; _loadingTx = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingTx = false);
    }
  }

  @override
  void dispose() {
    _coinAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kWalletCream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildStreakCard()),
          SliverToBoxAdapter(child: _buildHowToEarn()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: _kWalletGreen, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _kWalletDarkGreen),
                  ),
                  const Spacer(),
                  if (_transactions.isNotEmpty)
                    Text(
                      '${_transactions.length} records',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
          ),
          _buildTransactionList(),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kWalletDarkGreen, _kWalletGreen, Color(0xFF6FAE7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24, right: 24, bottom: 32,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Green Coin Wallet',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.farmerName.split(' ').first,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ScaleTransition(
              scale: _coinScaleAnim,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kWalletGold,
                  boxShadow: [BoxShadow(color: _kWalletGold.withValues(alpha: 0.5), blurRadius: 28, spreadRadius: 4)],
                ),
                child: const Center(child: Text('🌿', style: TextStyle(fontSize: 42))),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              NumberFormat('#,##0').format(widget.greenCoins),
              style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w900, height: 1),
            ),
            const SizedBox(height: 4),
            const Text(
              'Green Coins',
              style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ── STATS ROW ────────────────────────────────────────────
  Widget _buildStatsRow() {
    final daysLeft = (29 - widget.streak).clamp(0, 29);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          _statCard('Tasks Done', '${widget.completedTasks.length}', Icons.task_alt, Colors.teal),
          const SizedBox(width: 10),
          _statCard('Streak', '${widget.streak} 🔥', Icons.local_fire_department, Colors.deepOrange),
          const SizedBox(width: 10),
          _statCard('Bonus In', '$daysLeft days', Icons.emoji_events, _kWalletGold),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            FittedBox(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _kWalletDarkGreen))),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── STREAK CARD ──────────────────────────────────────────
  Widget _buildStreakCard() {
    final progress = (widget.streak / 29).clamp(0.0, 1.0);
    final remaining = (29 - widget.streak).clamp(0, 29);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kWalletGold.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: _kWalletGold.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '29-Day Streak Bonus',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF7A5500)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _kWalletGold, borderRadius: BorderRadius.circular(12)),
                child: const Text('+100 🌿', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(_kWalletGold),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day ${widget.streak}/29',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A5500), fontSize: 13)),
              Text(
                remaining > 0 ? '$remaining more days!' : '🎉 Bonus earned!',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── HOW TO EARN ──────────────────────────────────────────
  Widget _buildHowToEarn() {
    final ways = [
      ('✅', 'Complete Task', 'Upload camera proof. AI/Admin verifies it.', 'Up to 500 🌿'),
      ('📝', 'Daily Quiz', 'Answer 5 crop questions correctly.', '+100 🌿'),
      ('🌅', 'Daily Login', 'Simply open the app each day.', '+10 🌿'),
      ('🔥', '29-Day Streak', 'Stay active for 29 days straight.', '+100 🌿 Bonus'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: _kWalletGreen, size: 20),
              SizedBox(width: 8),
              Text('How to Earn Coins',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _kWalletDarkGreen)),
            ],
          ),
        ),
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ways.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final (emoji, title, desc, reward) = ways[i];
              return Container(
                width: 158,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _kWalletDarkGreen),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(desc,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, height: 1.3),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _kWalletLightGreen, borderRadius: BorderRadius.circular(8)),
                      child: Text(reward,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kWalletGreen)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── TRANSACTIONS ─────────────────────────────────────────
  Widget _buildTransactionList() {
    if (_loadingTx) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator(color: _kWalletGreen)),
        ),
      );
    }
    if (_transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              const Text('🌱', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('No transactions yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Complete tasks or quizzes to earn coins!',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final tx = _transactions[i];
            final isFirst = i == 0;
            final isLast = i == _transactions.length - 1;
            return _TxTile(tx: tx, isFirst: isFirst, isLast: isLast);
          },
          childCount: _transactions.length,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// TX TILE
// ──────────────────────────────────────────────────────────
class _TxTile extends StatelessWidget {
  final _TxItem tx;
  final bool isFirst;
  final bool isLast;
  const _TxTile({required this.tx, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = tx.isCredit ? Colors.green.shade600 : Colors.red.shade400;
    final bg = tx.isCredit ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08);
    final icon = tx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final dateLabel = tx.timestamp != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(tx.timestamp!)
        : tx.dt;
    final amountClean = tx.amount.replaceAll(RegExp(r'[+\-]'), '').trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
        boxShadow: isFirst
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2A2A2A)),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                if (dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(dateLabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tx.isCredit ? '+' : '-',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(amountClean,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 3),
                const Text('🌿', style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TxItem {
  final String name;
  final String amount;
  final bool isCredit;
  final String dt;
  final DateTime? timestamp;
  _TxItem({required this.name, required this.amount, required this.isCredit, required this.dt, this.timestamp});
}
