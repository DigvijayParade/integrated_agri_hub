import 'package:flutter/material.dart';

class GovernmentAdminDashboard extends StatelessWidget {
  const GovernmentAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Authoritative institutional color palette
    const Color primarySlateBlue = Color(0xFF2C3E50);
    const Color secondaryTeal = Color(0xFF008080);
    const Color backgroundGray = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: primarySlateBlue,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Directorate of Agricultural Administration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'State Level Operations Panel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operational Overview Cards (Top Summary Row)
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Pending Field\nVerifications',
                    value: '12',
                    icon: Icons.pending_actions,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Active Disaster\nBroadcasts',
                    value: '2',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section Title
            const Text(
              'Core Administration Action Matrix',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: primarySlateBlue,
              ),
            ),
            const SizedBox(height: 16),

            // Task 1: Visual Moderation Workspace
            _ActionCard(
              title: 'Visual Moderation Workspace',
              subtitle: 'Review pending farmer field photo uploads and execute green coin reward allocations.',
              icon: Icons.gavel,
              iconColor: primarySlateBlue,
              onTap: () {
                // TODO: Navigate to Visual Moderation Workspace
              },
            ),
            const SizedBox(height: 16),

            // Task 2: Disaster Alert Broadcast Engine
            _ActionCard(
              title: 'Disaster Alert Broadcast Engine',
              subtitle: 'Dispatch localized high-priority weather and anomaly emergency alerts targeted by district sub-clusters.',
              icon: Icons.campaign,
              iconColor: secondaryTeal,
              onTap: () {
                // TODO: Navigate to Disaster Alert Broadcast Engine
              },
            ),
            const SizedBox(height: 16),

            // Task 3: Content Publishing Terminal
            _ActionCard(
              title: 'Content Publishing Terminal',
              subtitle: 'Author and publish text lessons, configure multi-choice quiz sets, and link instructional video streams.',
              icon: Icons.assignment,
              iconColor: primarySlateBlue,
              onTap: () {
                // TODO: Navigate to Content Publishing Terminal
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Align(
                alignment: Alignment.center,
                child: Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
