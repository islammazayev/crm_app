import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'manager_home_page.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  String _officeLabel = '';

  @override
  void initState() {
    super.initState();
    _loadOfficeLabel();
  }

  /// Hämtar land och stad för managerns kontor till rubriken.
  Future<void> _loadOfficeLabel() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final db = FirebaseFirestore.instance;

      final userSnap = await db.collection('users').doc(user.uid).get();
      final officeId = userSnap.data()?['officeId']?.toString();
      if (officeId == null || officeId.isEmpty) return;

      final listing = await db.collection('officeListings').doc(officeId).get();
      final data = listing.data();
      if (data == null) return;

      final label = [data['country'], data['city']]
          .map((e) => (e ?? '').toString())
          .where((e) => e.isNotEmpty)
          .join(' – ');
      if (mounted) setState(() => _officeLabel = label);
    } catch (_) {
      // Rubriken är bara en bekvämlighet, fel här ska inte störa något.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_officeLabel.isEmpty
            ? 'CRM – Manager'
            : 'CRM – Manager ($_officeLabel)'),
        actions: [
          IconButton(
            tooltip: 'Logga ut',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Manager-panel'),
            const SizedBox(height: 8),
            const Text(
              'Välj vad du vill arbeta med. Här ser du snabbt nya, pågående och färdiga transaktioner.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;
                return GridView.count(
                  crossAxisCount: isWide ? 2 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 2.5 : 2.1,
                  children: [
                    _ActionCard(
                      icon: Icons.add_circle_outline,
                      iconColor: AppColors.primary,
                      title: 'Skapa ny transaktion',
                      subtitle:
                          'Starta en ny manuell transaktion direkt från manager-vyn.',
                      badge: '1',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Här kopplar vi senare formuläret för ny transaktion.'),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.mark_email_unread_outlined,
                      iconColor: AppColors.warning,
                      title: 'Nya kundtransaktioner',
                      subtitle:
                          'Se nya beställningar från kunder som ännu inte har påbörjats.',
                      badge: '2',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerHomePage(),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.sync_alt,
                      iconColor: AppColors.info,
                      title: 'Pågående transaktioner',
                      subtitle:
                          'Öppna alla ärenden som behandlas just nu och följ statusen.',
                      badge: '3',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Här visar vi senare pågående transaktioner.'),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.task_alt,
                      iconColor: AppColors.success,
                      title: 'Färdiga transaktioner',
                      subtitle:
                          'Se slutförda transaktioner och kontrollera avslutade ärenden.',
                      badge: '4',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Här visar vi senare färdiga transaktioner.'),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: iconColor.withOpacity(0.25)),
                  ),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDim,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textFaint,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
