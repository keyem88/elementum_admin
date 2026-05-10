import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../controller/admin_controller.dart';
import '../../auth/auth_controller.dart';
import '../../../core/config/app_config.dart';

String _formatDate(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(controller),

          // Main Content
          Expanded(
            child: Obx(
              () => _buildContent(controller.currentView.value, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(AdminController controller) {
    final isProd = AppConfig.current.isProd;

    return Container(
      width: 250,
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'ELEMENTUM ADMIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isProd
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isProd ? Colors.red : Colors.green),
            ),
            child: Text(
              isProd ? 'PROD - LIVE' : 'DEV - SANDBOX',
              style: TextStyle(
                color: isProd ? Colors.red : Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _sidebarItem(controller, 'Dashboard', Icons.dashboard),
          _sidebarItem(controller, 'Players', Icons.people),
          _sidebarItem(controller, 'Cards', Icons.style),
          _sidebarItem(controller, 'Packs', Icons.card_giftcard),
          _sidebarItem(controller, 'Economy', Icons.monetization_on),
          _sidebarItem(controller, 'Quests', Icons.assignment),
          _sidebarItem(controller, 'Rewards', Icons.event_available),
          _sidebarItem(controller, 'Achievements', Icons.emoji_events),
          _sidebarItem(controller, 'Environment', Icons.wb_sunny),
          _sidebarItem(controller, 'Messaging', Icons.message),
          _sidebarItem(controller, 'Announcements', Icons.campaign),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => AuthController.to.logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(AdminController controller, String title, IconData icon) {
    return Obx(() {
      final isSelected = controller.currentView.value == title;
      return ListTile(
        leading: Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => controller.setView(title),
        selected: isSelected,
        selectedTileColor: Colors.orange.withValues(alpha: 0.1),
      );
    });
  }

  Widget _buildContent(String view, AdminController controller) {
    switch (view) {
      case 'Dashboard':
        return _DashboardView(controller: controller);
      case 'Players':
        return _PlayersView(controller: controller);
      case 'Cards':
        return _CardEditorView(controller: controller);
      case 'Packs':
        return _PacksView(controller: controller);
      case 'Economy':
        return _EconomyView(controller: controller);
      case 'Messaging':
        return _MessagingView(controller: controller);
      case 'Quests':
        return _QuestsView(controller: controller);
      case 'Announcements':
        return _AnnouncementsView(controller: controller);
      case 'Rewards':
        return _RewardsView(controller: controller);
      case 'Environment':
        return _EnvironmentView(controller: controller);
      case 'Achievements':
        return _AchievementsView(controller: controller);
      default:
        return Center(
          child: Text(
            'View: $view',
            style: const TextStyle(color: Colors.white),
          ),
        );
    }
  }
}

class _DashboardView extends StatelessWidget {
  final AdminController controller;
  const _DashboardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  final updatedAt = controller.extendedStats['updated_at'] ?? 'Never';
                  return Text(
                    'Last Updated: $updatedAt',
                    style: const TextStyle(color: Colors.white24, fontSize: 12),
                  );
                }),
              ],
            ),
            const SizedBox(height: 32),

            // Top Quick Stats
            Obx(() {
              return GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                childAspectRatio: 1.6,
                children: controller.stats.entries
                    .map((e) => _statCard(e.key, _formatValue(e.value)))
                    .toList(),
              );
            }),
            const SizedBox(height: 48),

            // Deep Dive Rows
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Economy Section
                Expanded(
                  flex: 3,
                  child: _buildDeepDiveSection(
                    title: 'ECONOMY DEPTH',
                    subtitle: 'Card rarity distribution in circulation',
                    icon: Icons.account_balance_wallet,
                    child: Obx(() {
                      final rarity = controller.extendedStats['rarity'] as Map? ?? {};
                      final total = controller.extendedStats['total_cards'] ?? 0;
                      return Column(
                        children: [
                          _buildDistributionBar('Bronze', rarity['bronze'] ?? 0, Colors.brown, total),
                          _buildDistributionBar('Silver', rarity['silver'] ?? 0, Colors.grey, total),
                          _buildDistributionBar('Gold', rarity['gold'] ?? 0, Colors.orange, total),
                          _buildDistributionBar('Diamond', rarity['diamond'] ?? 0, Colors.lightBlueAccent, total),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 32),
                // Composition Section
                Expanded(
                  flex: 2,
                  child: _buildDeepDiveSection(
                    title: 'COMPOSITION',
                    subtitle: 'Player base breakdown',
                    icon: Icons.pie_chart,
                    child: Obx(() {
                      final reg = controller.extendedStats['registered'] ?? 0;
                      final anon = controller.extendedStats['anonymous'] ?? 0;
                      final banned = controller.extendedStats['banned'] ?? 0;
                      final total = controller.players.length;
                      return Column(
                        children: [
                          _buildCompositionItem('Registered', reg, Colors.blue, total),
                          _buildCompositionItem('Anonymous', anon, Colors.white24, total),
                          _buildCompositionItem('Banned', banned, Colors.red, total),
                          const Divider(color: Colors.white10, height: 24),
                          _simpleMetric('FCM Tokens', '${controller.extendedStats['fcm_tokens'] ?? 0}'),
                          _simpleMetric('New (7d)', '+${controller.extendedStats['new_7d'] ?? 0}'),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Element Power Section
            _buildDeepDiveSection(
              title: 'ELEMENT FOCUS',
              subtitle: 'Popularity of chosen elements among players',
              icon: Icons.auto_awesome,
              child: Obx(() {
                final elements = controller.extendedStats['elements'] as Map? ?? {};
                final total = controller.players.length;
                return Row(
                  children: [
                    _buildElementBox('Fire', elements['fire'] ?? 0, Colors.red, Icons.whatshot, total),
                    _buildElementBox('Water', elements['water'] ?? 0, Colors.blue, Icons.water_drop, total),
                    _buildElementBox('Earth', elements['earth'] ?? 0, Colors.green, Icons.landscape, total),
                    _buildElementBox('Air', elements['air'] ?? 0, Colors.purple, Icons.air, total),
                  ],
                );
              }),
            ),

            const SizedBox(height: 48),
            // Original Feedback Section shifted down
            const Text(
              'Recent Feedback',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.feedback.take(5).length,
                  itemBuilder: (context, index) {
                    final f = controller.feedback[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: Colors.orange, size: 20),
                        ),
                        title: Text(
                          f.playerName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          f.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        trailing: _buildTag(f.status, f.status == 'unread' ? Colors.orange : Colors.grey),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeepDiveSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildDistributionBar(String label, int count, Color color, int total) {
    final percentVal = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                '$count (${(percentVal * 100).toStringAsFixed(1)}%)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentVal,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildElementBox(String label, int count, Color color, IconData icon, int total) {
    final percentVal = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text('$label ($percentVal%)', style: const TextStyle(color: Colors.white24, fontSize: 9)),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompositionItem(String label, int count, Color color, int total) {
    final percentVal = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          Text(
            '$count ($percentVal%)',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _simpleMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatValue(dynamic val) {
    if (val is double) return val.toStringAsFixed(1);
    if (val is int) {
      if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
      if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}k';
      return val.toString();
    }
    return val.toString();
  }
}

class _PlayersView extends StatelessWidget {
  final AdminController controller;
  const _PlayersView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Player Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage user records and fix data inconsistencies',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('FIX DATES'),
                    onPressed: () => controller.fixMissingJoinedDates(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      onChanged: (val) =>
                          controller.playerSearchQuery.value = val,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by username or email...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bulk Action Bar
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.selectedPlayerIds.isNotEmpty ? 60 : 0,
              curve: Curves.easeInOut,
              child: controller.selectedPlayerIds.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${controller.selectedPlayerIds.length} players selected',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                controller.selectedPlayerIds.clear(),
                            child: const Text(
                              'Clear Selection',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete_sweep),
                            label: const Text('DELETE SELECTED'),
                            onPressed: () => _confirmBulkDelete(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final players = controller.filteredPlayers;
              if (players.isEmpty) {
                return const Center(
                  child: Text(
                    'No players found.',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.white10),
                  child: DataTable(
                    showCheckboxColumn: true,
                    onSelectAll: (val) =>
                        controller.selectAllPlayers(val ?? false),
                    sortColumnIndex: controller.playerSortColumn.value,
                    sortAscending: controller.playerSortAscending.value,
                    columns: [
                      DataColumn(
                        label: const Text(
                          'Name',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: (index, asc) {
                          controller.playerSortColumn.value = index;
                          controller.playerSortAscending.value = asc;
                        },
                      ),
                      DataColumn(
                        label: const Text(
                          'Type',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: (index, asc) {
                          controller.playerSortColumn.value = index;
                          controller.playerSortAscending.value = asc;
                        },
                      ),
                      DataColumn(
                        label: const Text(
                          'Quatrium',
                          style: TextStyle(color: Colors.orange),
                        ),
                        numeric: true,
                        onSort: (index, asc) {
                          controller.playerSortColumn.value = index;
                          controller.playerSortAscending.value = asc;
                        },
                      ),
                      DataColumn(
                        label: const Text(
                          'Points',
                          style: TextStyle(color: Colors.orange),
                        ),
                        numeric: true,
                        onSort: (index, asc) {
                          controller.playerSortColumn.value = index;
                          controller.playerSortAscending.value = asc;
                        },
                      ),
                      DataColumn(
                        label: const Text(
                          'Level',
                          style: TextStyle(color: Colors.orange),
                        ),
                        numeric: true,
                        onSort: (index, asc) {
                          controller.playerSortColumn.value = index;
                          controller.playerSortAscending.value = asc;
                        },
                      ),
                      DataColumn(
                        label: const Text(
                          'Status',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: (index, asc) {
                          controller.playerSortColumn.value = index;
                          controller.playerSortAscending.value = asc;
                        },
                      ),
                      DataColumn(
                        label: const Text(
                          'Joined',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: (index, asc) {
                          controller.playerSortColumn.value = index;
                          controller.playerSortAscending.value = asc;
                        },
                      ),
                      DataColumn(
                        label: const Text(
                          'Last Play',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: (index, asc) {
                          controller.playerSortColumn.value = index;
                          controller.playerSortAscending.value = asc;
                        },
                      ),
                      const DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                    rows: players
                        .map(
                          (p) => DataRow(
                            selected: controller.selectedPlayerIds.contains(
                              p.id,
                            ),
                            onSelectChanged: (val) =>
                                controller.togglePlayerSelection(p.id),
                            cells: [
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      p.email,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  p.isAnonymous ? '👤 Guest' : '✨ Registered',
                                  style: TextStyle(
                                    color: p.isAnonymous
                                        ? Colors.grey
                                        : Colors.blueAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  p.gold.toString(),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              DataCell(
                                Text(
                                  p.points.toString(),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              DataCell(
                                Text(
                                  p.level.toString(),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              DataCell(
                                Chip(
                                  label: Text(
                                    p.status,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: p.status == 'Active'
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.red.withValues(alpha: 0.2),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _formatDate(p.createdAt.toLocal()),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _formatDate(p.lastActive.toLocal()),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _showPlayerEditDialog(context, p),
                                      tooltip: 'Edit Player',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _confirmDeletePlayer(context, p),
                                      tooltip: 'Delete Player Completely',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showPlayerEditDialog(BuildContext context, AdminPlayer player) {
    final nameCtrl = TextEditingController(text: player.name);
    final goldCtrl = TextEditingController(text: player.gold.toString());
    final pointsCtrl = TextEditingController(text: player.points.toString());
    final levelCtrl = TextEditingController(text: player.level.toString());
    String status = player.status;

    // Reactive sync: Points -> Level
    pointsCtrl.addListener(() {
      final p = int.tryParse(pointsCtrl.text);
      final l = int.tryParse(levelCtrl.text);
      if (p != null && l != null) {
        final result = AdminController.syncPointsAndLevel(p, l);
        if (result.level != l || result.points != p) {
          // Update both controllers if they changed
          levelCtrl.text = result.level.toString();
          pointsCtrl.text = result.points.toString();
          // Keep selection at the end
          pointsCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: pointsCtrl.text.length),
          );
        }
      }
    });

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Edit Player: ${player.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditField(nameCtrl, 'Username'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditField(
                          goldCtrl,
                          'Quatrium (QTR)',
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEditField(
                          pointsCtrl,
                          'Points (XP)',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEditField(levelCtrl, 'Level', isNumber: true),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Account Status:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      DropdownButton<String>(
                        value: status,
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        underline: Container(height: 2, color: Colors.orange),
                        items: ['Active', 'Banned']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => status = val!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                player.name = nameCtrl.text;
                player.gold = int.tryParse(goldCtrl.text) ?? player.gold;
                player.points = int.tryParse(pointsCtrl.text) ?? player.points;
                player.level = int.tryParse(levelCtrl.text) ?? player.level;
                player.status = status;

                controller.updatePlayer(player);
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  void _confirmDeletePlayer(BuildContext context, AdminPlayer player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          '⚠️ Delete Player Completely?',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'This will permanently delete the player "${player.name}" and ALL associated data (Inventory, Quests, Feedback, Points). This action cannot be undone!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deletePlayer(player.id);
              Navigator.pop(ctx);
            },
            child: const Text('DELETE EVERYTHING'),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete(BuildContext context) {
    final count = controller.selectedPlayerIds.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          '⚠️ Bulk Delete $count Players?',
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(
          'You are about to permanently delete $count players and all their associated data from both the Database and Authentication. This action CANNOT be undone!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deletePlayersBulk();
              Navigator.pop(ctx);
            },
            child: const Text('YES, DELETE ALL'),
          ),
        ],
      ),
    );
  }
}

class _EconomyView extends StatelessWidget {
  final AdminController controller;
  const _EconomyView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Economy & Balancing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.saveBalancingConfig(),
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Obx(() {
                  final Map<String, String> explanations = {
                    'p2p_win_reward':
                        'Quatrium-Belohnung bei einem Sieg im P2P Spiel.',
                    'p2p_loss_reward':
                        'Quatrium-Belohnung bei einer Niederlage im P2P Spiel.',
                    'cooldown_bypass_cost':
                        'Quatrium-Kosten für die sofortige Reaktivierung einer Karte (Cooldown-Bypass).',
                    'recycling_min_level':
                        'Mindestlevel, ab dem ein Spieler Karten an das System verkaufen kann.',
                    'recycling_daily_limit':
                        'Maximale Anzahl an Karten, die ein Spieler pro Tag an das System verkaufen kann.',
                    'recycling_buyback_ratio':
                        'Prozentsatz vom Kartenwert, den das System beim Ankauf zahlt (z.B. 0.15 = 15%).',
                    'trade_min_level':
                        'Mindestlevel für den Tausch von Karten zwischen Spielern.',
                    'trade_fee_ratio':
                        'Gebühr, die bei einem Tausch/Handel vom System einbehalten wird (z.B. 0.10 = 10%).',
                    'trade_value_tolerance':
                        'Erlaubte Abweichung des Marktwertes beim Handel (0.5 = 50%). Verhindert unfaire Trades.',
                  };
                  final Map<String, List<String>> groups = {
                    'Kampf & Belohnungen': [
                      'win_points',
                      'loss_points',
                      'cooldown_bypass_cost',
                    ],
                    'Element-Balancing': [
                      'advantage_multiplier',
                      'disadvantage_multiplier',
                    ],
                    'Basis-Werte (Bronze)': [
                      'rarity_hp_bronze',
                      'rarity_points_bronze',
                    ],
                    'Seltenheit: Silber': [
                      'rarity_mult_silver',
                      'rarity_hp_silver',
                      'rarity_points_silver',
                    ],
                    'Seltenheit: Gold': [
                      'rarity_mult_gold',
                      'rarity_hp_gold',
                      'rarity_points_gold',
                    ],
                    'Seltenheit: Diamant': [
                      'rarity_mult_diamond',
                      'rarity_hp_diamond',
                      'rarity_points_diamond',
                    ],
                    'P2P Multiplayer': [
                      'p2p_stake',
                      'p2p_win_reward',
                      'p2p_loss_reward',
                    ],
                    'Recycling (System-Ankauf)': [
                      'recycling_min_level',
                      'recycling_daily_limit',
                      'recycling_buyback_ratio',
                    ],
                    'P2P Trading (Handel)': [
                      'trade_min_level',
                      'trade_fee_ratio',
                      'trade_value_tolerance',
                    ],
                  };

                  final List<Widget> children = [];

                  for (var entry in groups.entries) {
                    final sectionName = entry.key;
                    final keys = entry.value;

                    final availableKeys = keys;
                    if (availableKeys.isEmpty) continue;

                    children.add(
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Text(
                          sectionName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    );

                    for (var key in availableKeys) {
                      final val = controller.balancingConfig[key];
                      final isPoints =
                          key.contains('points') ||
                          key.contains('win') ||
                          key.contains('loss') ||
                          key.contains('reward') ||
                          key.contains('stake') ||
                          key.contains('cost') ||
                          key.contains('limit') ||
                          key.contains('level');
                      final isRatio =
                          key.contains('ratio') || key.contains('tolerance');

                      double minVal = isPoints ? 0.0 : 0.5;
                      double maxVal = isPoints ? 2000.0 : 5.0;

                      if (key.contains('level')) maxVal = 50.0;
                      if (key.contains('limit')) maxVal = 100.0;
                      if (isRatio) {
                        minVal = 0.0;
                        maxVal = 1.0;
                      }

                      double currentVal = (val is num) ? val.toDouble() : 1.0;
                      currentVal = currentVal.clamp(minVal, maxVal);

                      children.add(
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      key
                                          .replaceAll('_', ' ')
                                          .replaceAll('rarity ', '')
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: currentVal.toStringAsFixed(
                                          isRatio ? 2 : (isPoints ? 0 : 2),
                                        ),
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      onSubmitted: (newStr) {
                                        final newVal = double.tryParse(
                                          newStr.replaceAll(',', '.'),
                                        );
                                        if (newVal != null) {
                                          controller.updateMultiplierLocal(
                                            key,
                                            newVal.clamp(minVal, maxVal),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (explanations.containsKey(key)) ...[
                                const SizedBox(height: 4),
                                Text(
                                  explanations[key]!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Slider(
                                value: currentVal,
                                min: minVal,
                                max: maxVal,
                                divisions: isRatio
                                    ? 100
                                    : (isPoints
                                          ? (maxVal - minVal).toInt()
                                          : null),
                                onChanged: (newVal) {
                                  if (isPoints) {
                                    newVal = newVal.roundToDouble();
                                  }
                                  controller.updateMultiplierLocal(key, newVal);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  // Handle remaining keys
                  final handledKeys = groups.values.expand((x) => x).toList()
                    ..add('pack_cost_gold');
                  final remainingKeys = controller.balancingConfig.keys
                      .where((k) => !handledKeys.contains(k))
                      .toList();

                  if (remainingKeys.isNotEmpty) {
                    children.add(
                      const Padding(
                        padding: EdgeInsets.only(top: 24, bottom: 16),
                        child: Text(
                          'WEITERE OPTIONEN',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );

                    for (var key in remainingKeys) {
                      // Basic implementation for unknown keys
                      final val = controller.balancingConfig[key];
                      double currentVal = (val is num) ? val.toDouble() : 1.0;
                      children.add(
                        ListTile(
                          title: Text(
                            key,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: SizedBox(
                            width: 80,
                            child: TextField(
                              controller: TextEditingController(
                                text: currentVal.toString(),
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onSubmitted: (newStr) {
                                final newVal = double.tryParse(
                                  newStr.replaceAll(',', '.'),
                                );
                                if (newVal != null) {
                                  controller.updateMultiplierLocal(key, newVal);
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  return Column(children: children);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PacksView extends StatelessWidget {
  final AdminController controller;
  const _PacksView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pack Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showPackDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create New Pack'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() {
              if (controller.cardPacks.isEmpty) {
                return const Center(
                  child: Text(
                    'No packs available. Create one!',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: controller.cardPacks.length,
                itemBuilder: (context, index) {
                  final pack = controller.cardPacks[index];
                  return Card(
                    color: const Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: pack.isActive
                            ? Colors.orange.withValues(alpha: 0.5)
                            : Colors.grey.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pack.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (pack.isStarter) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.purple.withOpacity(0.5)),
                                        ),
                                        child: const Text(
                                          'STARTER',
                                          style: TextStyle(
                                            color: Colors.purpleAccent,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                pack.isActive
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: pack.isActive
                                    ? Colors.green
                                    : Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                          if (pack.hasCooldown) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.timer, color: Colors.blueAccent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Cooldown: ${pack.cooldownHours}h',
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '${pack.requiresAd ? 'Watch Ad' : '${pack.costGold} Gold'} | ${pack.cardsPerPack} Cards'
                            '${pack.purchaseLimit != -1 ? ' | Limit: ${pack.purchaseLimit}' : ''}',
                            style: const TextStyle(color: Colors.orange),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              pack.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _runPackSimulation(context, controller, pack.id, 1),
                                tooltip: 'Simulate 1x Opening',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.analytics,
                                  color: Colors.purpleAccent,
                                ),
                                onPressed: () =>
                                    _runPackSimulation(context, controller, pack.id, 100),
                                tooltip: 'Simulate 100x Opening (Stats)',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _showPackDialog(context, pack: pack),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(context, pack),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminCardPack pack) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Pack', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${pack.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteCardPack(pack.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPackDialog(BuildContext context, {AdminCardPack? pack}) {
    final isNew = pack == null;
    final nameCtrl = TextEditingController(text: pack?.name ?? '');
    final descCtrl = TextEditingController(text: pack?.description ?? '');
    final costCtrl = TextEditingController(
      text: pack?.costGold.toString() ?? '100',
    );
    final countCtrl = TextEditingController(
      text: pack?.cardsPerPack.toString() ?? '3',
    );
    bool isActive = pack?.isActive ?? true;
    bool requiresAd = pack?.requiresAd ?? false;
    bool hasCooldown = pack?.hasCooldown ?? false;
    final cooldownHoursCtrl = TextEditingController(
      text: pack?.cooldownHours.toString() ?? '24.0',
    );
    final purchaseLimitCtrl = TextEditingController(
      text: pack?.purchaseLimit.toString() ?? '-1',
    );
    bool isStarter = pack?.isStarter ?? false;

    String? guaranteedRarity = pack?.guaranteedRarity;
    String? elementFocus = pack?.elementFocus;

    final rates =
        pack?.dropRates ??
        {"bronze": 70, "silver": 20, "gold": 9, "diamond": 1};
    final bronzeCtrl = TextEditingController(
      text: (rates['bronze'] ?? rates['Common'])?.toString() ?? '70',
    );
    final silverCtrl = TextEditingController(
      text: (rates['silver'] ?? rates['Silver'])?.toString() ?? '20',
    );
    final goldCtrl = TextEditingController(
      text: (rates['gold'] ?? rates['Gold'])?.toString() ?? '9',
    );
    final diamondCtrl = TextEditingController(
      text: (rates['diamond'] ?? rates['Diamond'])?.toString() ?? '1',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text(
                isNew ? 'Create Pack' : 'Edit Pack',
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500, // Widened slightly for the 4 percentage fields
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(nameCtrl, 'Pack Name'),
                      _buildTextField(descCtrl, 'Description', maxLines: 2),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: costCtrl,
                              style: TextStyle(
                                color: requiresAd ? Colors.white24 : Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              readOnly: requiresAd,
                              decoration: InputDecoration(
                                labelText: 'Cost (Gold)',
                                labelStyle: const TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: requiresAd ? Colors.white10 : Colors.white24,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: requiresAd ? Colors.white10 : Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              countCtrl,
                              'Cards per Pack',
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        purchaseLimitCtrl,
                        'Purchase Limit (-1 = Unlimited)',
                        isNumber: true,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        value: guaranteedRarity,
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Guaranteed Rarity',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('None')),
                          DropdownMenuItem(
                            value: 'silver',
                            child: Text('Silver'),
                          ),
                          DropdownMenuItem(value: 'gold', child: Text('Gold')),
                          DropdownMenuItem(
                            value: 'diamond',
                            child: Text('Diamond'),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => guaranteedRarity = val),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        value: elementFocus,
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Element Focus',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('None (All Elements)'),
                          ),
                          DropdownMenuItem(value: 'Fire', child: Text('Fire')),
                          DropdownMenuItem(
                            value: 'Water',
                            child: Text('Water'),
                          ),
                          DropdownMenuItem(
                            value: 'Earth',
                            child: Text('Earth'),
                          ),
                          DropdownMenuItem(value: 'Air', child: Text('Air')),
                        ],
                        onChanged: (val) => setState(() => elementFocus = val),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Drop Rates (%)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              bronzeCtrl,
                              'Bronze (Common)',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              silverCtrl,
                              'Silver',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              goldCtrl,
                              'Gold',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              diamondCtrl,
                              'Diamond',
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Requires Ad View',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Players watch an ad to unlock this pack (Cost set to 0).',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        value: requiresAd,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          setState(() {
                            requiresAd = val;
                            if (requiresAd) {
                              costCtrl.text = '0';
                            }
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Has Cooldown',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Restrict how often this pack can be opened.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        value: hasCooldown,
                        activeColor: Colors.orange,
                        onChanged: (val) => setState(() => hasCooldown = val),
                      ),
                      if (hasCooldown)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: _buildTextField(
                            cooldownHoursCtrl,
                            'Cooldown Duration (Hours)',
                            isNumber: true,
                          ),
                        ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Active in Shop',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: isActive,
                        activeColor: Colors.orange,
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Is Starter Pack',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Show this pack as a starter option for new players.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        value: isStarter,
                        activeColor: Colors.purpleAccent,
                        onChanged: (val) => setState(() => isStarter = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (!isNew) ...[
                  TextButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Test 1x'),
                    onPressed: () =>
                        _runPackSimulation(ctx, controller, pack!.id, 1),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.analytics, size: 18),
                    label: const Text('Test 100x'),
                    onPressed: () =>
                        _runPackSimulation(ctx, controller, pack!.id, 100),
                  ),
                ],
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final newPack = AdminCardPack(
                      id: isNew ? 'new' : pack!.id,
                      name: nameCtrl.text,
                      description: descCtrl.text,
                      costGold: int.tryParse(costCtrl.text) ?? 100,
                      cardsPerPack: int.tryParse(countCtrl.text) ?? 3,
                      guaranteedRarity: guaranteedRarity,
                      elementFocus: elementFocus,
                      dropRates: {
                        "bronze": int.tryParse(bronzeCtrl.text) ?? 0,
                        "silver": int.tryParse(silverCtrl.text) ?? 0,
                        "gold": int.tryParse(goldCtrl.text) ?? 0,
                        "diamond": int.tryParse(diamondCtrl.text) ?? 0,
                      },
                      isActive: isActive,
                      requiresAd: requiresAd,
                      hasCooldown: hasCooldown,
                      cooldownHours: double.tryParse(cooldownHoursCtrl.text) ?? 0.0,
                      purchaseLimit: int.tryParse(purchaseLimitCtrl.text) ?? -1,
                      isStarter: isStarter,
                    );
                    controller.saveCardPack(newPack);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Pack'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
      ),
    );
  }
}

class _CardEditorView extends StatefulWidget {
  final AdminController controller;
  const _CardEditorView({required this.controller});

  @override
  State<_CardEditorView> createState() => _CardEditorViewState();
}

class _CardEditorViewState extends State<_CardEditorView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Card Templates (Base / Bronze)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCardDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('New Card Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search by name...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white10),
                    ),
                  ),
                  onChanged: (val) =>
                      widget.controller.cardSearchQuery.value = val,
                ),
              ),
              const SizedBox(width: 16),
              Obx(
                () => _buildFilterDropdown(
                  'Element',
                  widget.controller.cardElementFilter.value,
                  ['Fire', 'Water', 'Earth', 'Air', 'Neutral'],
                  (val) => widget.controller.cardElementFilter.value = val,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Expanded(
            child: Obx(() {
              final filtered = widget.controller.filteredCardTemplates;

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No cards found matching filters.',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.white10),
                  child: DataTable(
                    sortColumnIndex: widget.controller.cardSortColumn.value,
                    sortAscending: widget.controller.cardSortAscending.value,
                    columns: [
                      DataColumn(
                        label: const Text(
                          'Name',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: _onSort,
                      ),
                      DataColumn(
                        label: const Text(
                          'Element',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: _onSort,
                      ),
                      DataColumn(
                        label: const Text(
                          'Tier',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: _onSort,
                      ),
                      DataColumn(
                        label: const Text(
                          'Base ATK',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: _onSort,
                      ),
                      DataColumn(
                        label: const Text(
                          'Base DEF',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: _onSort,
                      ),
                      DataColumn(
                        label: const Text(
                          'Base AGI',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: _onSort,
                      ),
                      DataColumn(
                        label: const Text(
                          'Valuation',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onSort: _onSort,
                      ),
                      const DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                    rows: filtered
                        .map(
                          (c) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  c.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(_elementChip(c.element)),
                              DataCell(
                                Text(
                                  'T${c.tier}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.baseAtk.toString(),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.baseDef.toString(),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.baseAgi.toString(),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              DataCell(_valuationSummary(c)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _showCardDialog(context, template: c),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _confirmDelete(context, c),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    widget.controller.cardSortColumn.value = columnIndex;
    widget.controller.cardSortAscending.value = ascending;
  }

  Widget _buildFilterDropdown(
    String label,
    String? current,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: current,
          hint: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          dropdownColor: const Color(0xFF2C2C2C),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
          style: const TextStyle(color: Colors.white),
          items: [
            const DropdownMenuItem(value: null, child: Text('All')),
            ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _elementChip(String element) {
    Color color;
    switch (element.toLowerCase()) {
      case 'fire':
        color = Colors.redAccent;
        break;
      case 'water':
        color = Colors.blueAccent;
        break;
      case 'earth':
        color = Colors.greenAccent;
        break;
      case 'air':
        color = Colors.purpleAccent;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        element,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color.withOpacity(0.5)),
    );
  }

  Widget _valuationSummary(AdminCardTemplate c) {
    if (c.valuation == null || c.valuation!.isEmpty) {
      return const Text(
        'N/A',
        style: TextStyle(color: Colors.white24, fontSize: 12),
      );
    }

    try {
      final bronzeMin = c.valuation!['bronze']?['min'] ?? '?';
      final diamondMax = c.valuation!['diamond']?['max'] ?? '?';

      String format(dynamic val) {
        if (val is num) {
          if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}k';
          return val.toString();
        }
        return val.toString();
      }

      return Text(
        '${format(bronzeMin)} - ${format(diamondMax)}',
        style: const TextStyle(
          color: Colors.orangeAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    } catch (e) {
      return const Text(
        'Err',
        style: TextStyle(color: Colors.redAccent, fontSize: 11),
      );
    }
  }

  void _confirmDelete(BuildContext context, AdminCardTemplate template) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Card Template',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete "${template.name}"? This will not affect cards already owned by players, but no new ones of this type can be generated.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              widget.controller.deleteCardTemplate(template.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCardDialog(BuildContext context, {AdminCardTemplate? template}) {
    final isNew = template == null;
    final nameCtrl = TextEditingController(text: template?.name ?? '');
    final archetypeCtrl = TextEditingController(
      text: template?.archetype ?? 'Warrior',
    );
    final loreCtrl = TextEditingController(text: template?.lore ?? '');
    final promptCtrl = TextEditingController(text: template?.imagePrompt ?? '');

    final atkCtrl = TextEditingController(
      text: template?.baseAtk.toString() ?? '10',
    );
    final defCtrl = TextEditingController(
      text: template?.baseDef.toString() ?? '10',
    );
    final agiCtrl = TextEditingController(
      text: template?.baseAgi.toString() ?? '10',
    );

    int tier = template?.tier ?? 1;
    String element = template?.element ?? 'Neutral';

    // Valuation Controllers
    final valCtrls = <String, Map<String, TextEditingController>>{};
    for (var r in ['bronze', 'silver', 'gold', 'diamond']) {
      valCtrls[r] = {
        'min': TextEditingController(
          text: template?.valuation?[r]?['min']?.toString() ?? '',
        ),
        'exp': TextEditingController(
          text: template?.valuation?[r]?['exp']?.toString() ?? '',
        ),
        'max': TextEditingController(
          text: template?.valuation?[r]?['max']?.toString() ?? '',
        ),
      };
    }

    // Translation Controllers
    final transNameCtrls = {
      'en': TextEditingController(
        text: template?.translations['en']?['name'] ?? '',
      ),
      'de': TextEditingController(
        text: template?.translations['de']?['name'] ?? '',
      ),
    };
    final transLoreCtrls = {
      'en': TextEditingController(
        text: template?.translations['en']?['lore'] ?? '',
      ),
      'de': TextEditingController(
        text: template?.translations['de']?['lore'] ?? '',
      ),
    };

    void resetToDefaults(Function setState) {
      final defaults = AdminController.defaultValuations[tier];
      if (defaults != null) {
        setState(() {
          for (var r in ['bronze', 'silver', 'gold', 'diamond']) {
            valCtrls[r]!['min']!.text = defaults[r]['min'].toString();
            valCtrls[r]!['exp']!.text = defaults[r]['exp'].toString();
            valCtrls[r]!['max']!.text = defaults[r]['max'].toString();
          }
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text(
                isNew ? 'New Card Template' : 'Edit Template',
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 600,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildField(nameCtrl, 'Name')),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              archetypeCtrl,
                              'Archetype (e.g. Phoenix, Golem)',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              'Element',
                              element,
                              ['Fire', 'Water', 'Earth', 'Air', 'Neutral'],
                              (val) => setState(() => element = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              'Tier',
                              tier.toString(),
                              ['1', '2', '3', '4', '5'],
                              (val) => setState(() => tier = int.parse(val!)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              atkCtrl,
                              'Base ATK',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              defCtrl,
                              'Base DEF',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              agiCtrl,
                              'Base AGI',
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      _buildField(
                        loreCtrl,
                        'Default Lore / Description',
                        maxLines: 3,
                      ),
                      _buildField(promptCtrl, 'AI Image Prompt', maxLines: 2),

                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),
                      const Text(
                        'TRANSLATIONS',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTranslationSection(
                        'English (en)',
                        transNameCtrls['en']!,
                        transLoreCtrls['en']!,
                      ),
                      _buildTranslationSection(
                        'German (de)',
                        transNameCtrls['de']!,
                        transLoreCtrls['de']!,
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'VALUATION MATRIX (min / exp / max)',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.1,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => resetToDefaults(setState),
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text(
                              'Reset to Tier Defaults',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          const TableRow(
                            children: [
                              SizedBox(),
                              Center(
                                child: Text(
                                  'MIN',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'EXP',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'MAX',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ...['bronze', 'silver', 'gold', 'diamond'].map((r) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    r.toUpperCase(),
                                    style: TextStyle(
                                      color: _getRarityColor(r),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                _buildValField(valCtrls[r]!['min']!),
                                _buildValField(valCtrls[r]!['exp']!),
                                _buildValField(valCtrls[r]!['max']!),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final newTemplate = AdminCardTemplate(
                      id: isNew ? 'new' : template!.id,
                      name: nameCtrl.text,
                      archetype: archetypeCtrl.text,
                      tier: tier,
                      element: element,
                      baseAtk: int.tryParse(atkCtrl.text) ?? 10,
                      baseDef: int.tryParse(defCtrl.text) ?? 10,
                      baseAgi: int.tryParse(agiCtrl.text) ?? 10,
                      lore: loreCtrl.text,
                      imagePrompt: promptCtrl.text,
                      valuation: {
                        for (var r in ['bronze', 'silver', 'gold', 'diamond'])
                          r: {
                            'min': int.tryParse(valCtrls[r]!['min']!.text) ?? 0,
                            'exp': int.tryParse(valCtrls[r]!['exp']!.text) ?? 0,
                            'max': int.tryParse(valCtrls[r]!['max']!.text) ?? 0,
                          },
                      },
                      translations: {
                        'en': {
                          'name': transNameCtrls['en']!.text,
                          'lore': transLoreCtrls['en']!.text,
                        },
                        'de': {
                          'name': transNameCtrls['de']!.text,
                          'lore': transLoreCtrls['de']!.text,
                        },
                      },
                    );
                    widget.controller.saveCardTemplate(newTemplate);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Template'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildValField(TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          fillColor: Colors.white.withOpacity(0.02),
          filled: true,
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.white;
    }
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationSection(
    String label,
    TextEditingController nameCtrl,
    TextEditingController loreCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildField(nameCtrl, 'Name ($label)'),
        _buildField(loreCtrl, 'Lore ($label)', maxLines: 2),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF2C2C2C),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
        ),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _QuestsView extends StatelessWidget {
  final AdminController controller;
  const _QuestsView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quest Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showQuestDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Quest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() {
              if (controller.quests.isEmpty) {
                return const Center(
                  child: Text(
                    'No quests defined yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.quests.length,
                itemBuilder: (context, index) {
                  final q = controller.quests[index];
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                q.questType,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getTypeColor(q.questType),
                              ),
                            ),
                            child: Text(
                              q.questType,
                              style: TextStyle(
                                color: _getTypeColor(q.questType),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            q.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            q.description ?? 'No description',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _infoLabel(
                                Icons.track_changes,
                                '${q.targetAction} (${q.targetAmount})',
                              ),
                              const SizedBox(width: 16),
                              _infoLabel(
                                Icons.monetization_on,
                                '${q.rewardGold} Gold',
                              ),
                              const SizedBox(width: 16),
                              _infoLabel(Icons.star, '${q.rewardPoints} Pkt'),
                              if (q.minLevel != null || q.maxLevel != null) ...[
                                const SizedBox(width: 16),
                                _infoLabel(
                                  Icons.trending_up,
                                  'Level: ${q.minLevel ?? 1}${q.maxLevel != null ? '-${q.maxLevel}' : '+'}',
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showQuestDialog(context, quest: q),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, q),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'NEW_PLAYER':
        return Colors.teal;
      case 'DAILY':
        return Colors.blue;
      case 'WEEKLY':
        return Colors.purple;
      case 'ACHIEVEMENT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _infoLabel(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.orange),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _showQuestDialog(BuildContext context, {AdminQuest? quest}) {
    final titleCtrl = TextEditingController(text: quest?.title ?? '');
    final descCtrl = TextEditingController(text: quest?.description ?? '');
    final targetAmntCtrl = TextEditingController(
      text: (quest?.targetAmount ?? 1).toString(),
    );
    final goldCtrl = TextEditingController(
      text: (quest?.rewardGold ?? 100).toString(),
    );
    final pointsCtrl = TextEditingController(
      text: (quest?.rewardPoints ?? 50).toString(),
    );
    final colorCtrl = TextEditingController(text: quest?.color ?? '#4CAF50');
    final minLevelCtrl = TextEditingController(
      text: quest?.minLevel?.toString() ?? '',
    );
    final maxLevelCtrl = TextEditingController(
      text: quest?.maxLevel?.toString() ?? '',
    );

    // Translation Controllers
    final transTitleCtrls = {
      'en': TextEditingController(
        text: quest?.translations['en']?['title'] ?? '',
      ),
      'de': TextEditingController(
        text: quest?.translations['de']?['title'] ?? '',
      ),
    };
    final transDescCtrls = {
      'en': TextEditingController(
        text: quest?.translations['en']?['description'] ?? '',
      ),
      'de': TextEditingController(
        text: quest?.translations['de']?['description'] ?? '',
      ),
    };

    String questType = quest?.questType ?? 'DAILY';
    String targetAction = quest?.targetAction ?? 'WIN_BATTLES';
    String questIcon = quest?.icon ?? 'task';

    final Map<String, IconData> iconMap = {
      'task': Icons.task_alt,
      'battle': Icons.flash_on,
      'pack': Icons.inventory_2,
      'card': Icons.style,
      'element': Icons.auto_awesome,
      'star': Icons.star,
      'social': Icons.people,
    };

    final List<String> targetActions = [
      'WIN_BATTLES',
      'OPEN_PACKS',
      'PLAY_CARDS',
      'WIN_WITH_ELEMENT',
      'PLAYED_GAMES',
      'HOSTED_GAMES',
      'JOINED_GAMES',
      'STREAK_DAYS',
    ];

    final List<String> colors = [
      '#4CAF50',
      '#2196F3',
      '#9C27B0',
      '#FF9800',
      '#F44336',
      '#E91E63',
      '#795548',
      '#607D8B',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            quest == null ? 'Create Quest' : 'Edit Quest',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(titleCtrl, 'Default Title'),
                  _buildField(descCtrl, 'Default Description', maxLines: 2),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  const Text(
                    'TRANSLATIONS',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuestTranslationSection(
                    'English (en)',
                    transTitleCtrls['en']!,
                    transDescCtrls['en']!,
                  ),
                  _buildQuestTranslationSection(
                    'German (de)',
                    transTitleCtrls['de']!,
                    transDescCtrls['de']!,
                  ),

                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Quest Type',
                    [
                          'NEW_PLAYER',
                          'DAILY',
                          'WEEKLY',
                          'ACHIEVEMENT',
                        ].contains(questType)
                        ? questType
                        : 'DAILY',
                    ['NEW_PLAYER', 'DAILY', 'WEEKLY', 'ACHIEVEMENT'],
                    (val) => setDialogState(() => questType = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Target Action',
                    targetActions.contains(targetAction)
                        ? targetAction
                        : 'WIN_BATTLES',
                    targetActions,
                    (val) => setDialogState(() => targetAction = val!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          targetAmntCtrl,
                          'Target Amount',
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          goldCtrl,
                          'Gold Reward',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  _buildField(pointsCtrl, 'Points Reward', isNumber: true),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          minLevelCtrl,
                          'Min. Level (Optional)',
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          maxLevelCtrl,
                          'Max. Level (Optional)',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: iconMap.containsKey(questIcon)
                              ? questIcon
                              : 'task',
                          dropdownColor: const Color(0xFF2C2C2C),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Icon',
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                          ),
                          items: iconMap.entries
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Row(
                                    children: [
                                      Icon(
                                        e.value,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(e.key),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setDialogState(() => questIcon = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Color',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: colors.map((c) {
                              final isSelected = colorCtrl.text == c;
                              return GestureDetector(
                                onTap: () =>
                                    setDialogState(() => colorCtrl.text = c),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      int.parse(c.replaceFirst('#', '0xFF')),
                                    ),
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final newQuest = AdminQuest(
                  id: quest?.id ?? 'new',
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  questType: questType,
                  targetAction: targetAction,
                  targetAmount: int.tryParse(targetAmntCtrl.text) ?? 1,
                  rewardGold: int.tryParse(goldCtrl.text) ?? 0,
                  rewardPoints: int.tryParse(pointsCtrl.text) ?? 0,
                  icon: questIcon,
                  color: colorCtrl.text,
                  minLevel: int.tryParse(minLevelCtrl.text),
                  maxLevel: int.tryParse(maxLevelCtrl.text),
                  isActive: quest?.isActive ?? true,
                  translations: {
                    'en': {
                      'title': transTitleCtrls['en']!.text,
                      'description': transDescCtrls['en']!.text,
                    },
                    'de': {
                      'title': transTitleCtrls['de']!.text,
                      'description': transDescCtrls['de']!.text,
                    },
                  },
                );
                controller.saveQuest(newQuest);
                Navigator.pop(ctx);
              },
              child: const Text('Save Quest'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminQuest quest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Quest?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${quest.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteQuest(quest.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF2C2C2C),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildQuestTranslationSection(
    String label,
    TextEditingController titleCtrl,
    TextEditingController descCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildField(titleCtrl, 'Title ($label)'),
        _buildField(descCtrl, 'Description ($label)', maxLines: 2),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AnnouncementsView extends StatelessWidget {
  final AdminController controller;
  const _AnnouncementsView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'In-App Announcements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAnnouncementDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('New Announcement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() {
              if (controller.announcements.isEmpty) {
                return const Center(
                  child: Text(
                    'No announcements found.',
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.announcements.length,
                itemBuilder: (context, index) {
                  final a = controller.announcements[index];
                  return Card(
                    color: const Color(0xFF2C2C2C),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: a.isActive
                            ? Colors.orange.withValues(alpha: 0.3)
                            : Colors.white10,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getTypeIcon(a.type),
                                    color: _getTypeColor(a.type),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    a.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Switch(
                                value: a.isActive,
                                activeColor: Colors.orange,
                                onChanged: (val) {
                                  a.isActive = val;
                                  controller.saveAnnouncement(a);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.content,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Created: ${a.createdAt.toString().substring(0, 16)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _showAnnouncementDialog(
                                      context,
                                      announcement: a,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDelete(context, a),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'event':
        return Icons.event;
      case 'warning':
        return Icons.warning_amber;
      case 'update':
        return Icons.system_update_rounded;
      default:
        return Icons.info_outline;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'event':
        return Colors.blue;
      case 'warning':
        return Colors.red;
      case 'update':
        return Colors.orange;
      default:
        return Colors.cyan;
    }
  }

  void _showAnnouncementDialog(
    BuildContext context, {
    AdminAnnouncement? announcement,
  }) {
    final isNew = announcement == null;
    final titleCtrl = TextEditingController(text: announcement?.title ?? '');
    final contentCtrl = TextEditingController(
      text: announcement?.content ?? '',
    );
    final requiredVersionCtrl = TextEditingController(
      text: announcement?.metadata['required_version'] ?? '1.1.0',
    );
    String type = announcement?.type ?? 'info';
    bool isActive = announcement?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            isNew ? 'Create Announcement' : 'Edit Announcement',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(titleCtrl, 'Title'),
                const SizedBox(height: 16),
                _buildTextField(contentCtrl, 'Content', maxLines: 5),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  dropdownColor: const Color(0xFF2C2C2C),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'info', child: Text('Information')),
                    DropdownMenuItem(value: 'event', child: Text('Event')),
                    DropdownMenuItem(
                      value: 'warning',
                      child: Text('Warning / Maintenance'),
                    ),
                    DropdownMenuItem(
                      value: 'update',
                      child: Text('App Update Required'),
                    ),
                  ],
                  onChanged: (val) => setDialogState(() => type = val!),
                ),
                if (type == 'update') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    requiredVersionCtrl,
                    'Required Version (e.g. 1.1.0)',
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Switch(
                      value: isActive,
                      activeColor: Colors.orange,
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final a = AdminAnnouncement(
                  id: announcement?.id ?? 'new',
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                  type: type,
                  isActive: isActive,
                  createdAt: announcement?.createdAt ?? DateTime.now(),
                  expiresAt: announcement?.expiresAt,
                  metadata: {
                    if (type == 'update')
                      'required_version': requiredVersionCtrl.text,
                  },
                );
                controller.saveAnnouncement(a);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminAnnouncement a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Announcement?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${a.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteAnnouncement(a.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }
}

class _MessagingView extends StatefulWidget {
  final AdminController controller;
  const _MessagingView({required this.controller});

  @override
  State<_MessagingView> createState() => _MessagingViewState();
}

class _MessagingViewState extends State<_MessagingView> {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  final presetNameCtrl = TextEditingController();
  
  String? selectedPlayerId;
  String targetMode = 'global'; // 'global', 'specific', 'filtered'
  
  // Filters
  int? minLevel;
  int? maxLevel;
  List<String> selectedElements = [];
  List<String> selectedLanguages = [];
  bool? isAnonymous;
  int? lastActiveDays;
  bool isBanned = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    bodyCtrl.dispose();
    presetNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Messaging Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => widget.controller.update(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'PUSH NOTIFICATIONS'),
                Tab(text: 'PLAYER FEEDBACK'),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: TabBarView(
                children: [_buildPushTab(), _buildFeedbackTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPushTab() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compose Column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COMPOSE MESSAGE',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLocalField(titleCtrl, 'Notification Title'),
                  const SizedBox(height: 16),
                  _buildLocalField(bodyCtrl, 'Message Body', maxLines: 3),
                  const SizedBox(height: 24),
                  const Text(
                    'TARGET AUDIENCE',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildModeChip('Global', 'global', Icons.language),
                      _buildModeChip('Filtered Group', 'filtered', Icons.filter_list),
                      _buildModeChip('Specific Player', 'specific', Icons.person),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (targetMode == 'filtered') ...[
                    _buildTargetingBuilder(),
                  ],

                  if (targetMode == 'specific') ...[
                    Obx(() {
                      final players = widget.controller.players;
                      return DropdownButtonFormField<String>(
                        value: selectedPlayerId,
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Select Player',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                        ),
                        items: players
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (${p.email})'),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedPlayerId = val),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _send,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isSending ? 'SENDING...' : 'SEND NOTIFICATION',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          // History Column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SENT HISTORY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 500,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Obx(() {
                    final history = widget.controller.pushNotifications;
                    if (history.isEmpty) {
                      return const Center(
                        child: Text(
                          'No past notifications found.',
                          style: TextStyle(color: Colors.white24),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: history.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white10),
                      itemBuilder: (context, index) {
                        final n = history[index];
                        return ListTile(
                          title: Text(
                            n.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.body,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildTag(
                                    n.targetAudience ?? 'Targeted',
                                    n.targetAudience == 'All'
                                        ? Colors.blue
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTag(
                                    '${n.deviceCount} Devices',
                                    Colors.green,
                                  ),
                                ],
                              ),
                              if (n.filters.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _summarizeFilters(n.filters),
                                  style: const TextStyle(
                                    color: Colors.white24,
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(n.sentAt),
                                style: const TextStyle(
                                  color: Colors.white24,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _summarizeFilters(Map<String, dynamic> filters) {
    if (filters.isEmpty) return 'Global Broadcast';
    
    List<String> parts = [];
    
    // Level
    if (filters['minLevel'] != null || filters['maxLevel'] != null) {
      final min = filters['minLevel'] ?? 1;
      final max = filters['maxLevel'] ?? 'Max';
      parts.add('Lvl $min-$max');
    }
    
    // Elements
    final el = filters['elements'] as List?;
    if (el != null && el.isNotEmpty) {
      parts.add('Elements: ${el.map((e) => e.toString().toUpperCase()).join(',')}');
    }
    
    // Languages
    final ln = filters['languages'] as List?;
    if (ln != null && ln.isNotEmpty) {
      parts.add('Langs: ${ln.map((l) => l.toString().toUpperCase()).join(',')}');
    }
    
    // Anonymous status
    if (filters['isAnonymous'] != null) {
      parts.add(filters['isAnonymous'] == true ? 'Guests' : 'Registered');
    }
    
    // Banned status
    if (filters['isBanned'] == true) {
      parts.add('BANNED USERS ONLY');
    }

    // Last Active
    if (filters['lastActiveDays'] != null) {
      parts.add('Active in ${filters['lastActiveDays']}d');
    }

    return parts.isEmpty ? 'Filtered Group' : parts.join(' • ');
  }

  Widget _buildFeedbackTab() {
    return Obx(() {
      if (widget.controller.feedback.isEmpty) {
        return const Center(
          child: Text(
            'Your inbox is empty.',
            style: TextStyle(color: Colors.white38),
          ),
        );
      }

      return ListView.separated(
        itemCount: widget.controller.feedback.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final f = widget.controller.feedback[index];
          final isUnread = f.status == 'unread';

          return Card(
            color: isUnread
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isUnread
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.white10,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white10,
                            child: Text(
                              f.playerName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.playerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                f.timestamp.toString().substring(0, 16),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          f.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _getStatusColor(
                          f.status,
                        ).withValues(alpha: 0.2),
                        labelStyle: TextStyle(color: _getStatusColor(f.status)),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    f.message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (f.replyText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ADMIN REPLY:',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f.replyText!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isUnread)
                        TextButton.icon(
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text('Mark as Read'),
                          onPressed: () => widget.controller
                              .updateFeedbackStatus(f.id, 'read'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.reply, size: 18),
                        label: const Text('Reply'),
                        onPressed: () => _showReplyDialog(context, f),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'unread':
        return Colors.orange;
      case 'read':
        return Colors.grey;
      case 'replied':
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  void _showReplyDialog(BuildContext context, AdminFeedback f) {
    final replyCtrl = TextEditingController(text: f.replyText);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Reply to ${f.playerName}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Original Message:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                f.message,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: replyCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type your reply here...',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.controller.updateFeedbackStatus(
                f.id,
                'replied',
                replyText: replyCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, String mode, IconData icon) {
    final isSelected = targetMode == mode;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.black : Colors.grey,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => targetMode = mode);
      },
      selectedColor: Colors.orange,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTargetingBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset Row
        Row(
          children: [
            Expanded(
              child: Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Load Preset',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  dropdownColor: const Color(0xFF2C2C2C),
                  style: const TextStyle(color: Colors.white),
                  items: widget.controller.pushPresets
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (id) {
                    if (id != null) {
                      final p = widget.controller.pushPresets.firstWhere((p) => p.id == id);
                      _applyPreset(p);
                    }
                  },
                );
              }),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.save, color: Colors.blue),
              onPressed: () => _showSavePresetDialog(),
              tooltip: 'Save current filters as preset',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Level Range
        Row(
          children: [
            Expanded(
              child: _buildLocalField(
                TextEditingController(text: minLevel?.toString()),
                'Min Level',
                isNumber: true,
                onChanged: (val) => minLevel = int.tryParse(val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLocalField(
                TextEditingController(text: maxLevel?.toString()),
                'Max Level',
                isNumber: true,
                onChanged: (val) => maxLevel = int.tryParse(val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Elements
        const Text('Elements', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        _buildFilterChips(
          ['fire', 'water', 'earth', 'air'],
          selectedElements,
          (val) => setState(() => selectedElements.contains(val)
              ? selectedElements.remove(val)
              : selectedElements.add(val)),
        ),
        const SizedBox(height: 16),

        // Languages
        const Text('Languages', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        _buildFilterChips(
          ['de', 'en'],
          selectedLanguages,
          (val) => setState(() => selectedLanguages.contains(val)
              ? selectedLanguages.remove(val)
              : selectedLanguages.add(val)),
        ),
        const SizedBox(height: 16),

        // Misc Toggles
        Row(
          children: [
            Expanded(
              child: _buildToggle(
                'Anonymous',
                isAnonymous,
                (val) => setState(() => isAnonymous = val),
              ),
            ),
            Expanded(
              child: _buildToggle(
                'Banned',
                isBanned,
                (val) => setState(() => isBanned = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLocalField(
          TextEditingController(text: lastActiveDays?.toString()),
          'Active in last X days',
          isNumber: true,
          onChanged: (val) => lastActiveDays = int.tryParse(val),
        ),
        const Divider(color: Colors.white10, height: 40),
      ],
    );
  }

  Widget _buildFilterChips(
    List<String> options,
    List<String> selected,
    Function(String) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return FilterChip(
          label: Text(opt.toUpperCase()),
          selected: isSelected,
          onSelected: (_) => onToggle(opt),
          selectedColor: Colors.orange.withValues(alpha: 0.3),
          checkmarkColor: Colors.orange,
          labelStyle: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey,
            fontSize: 10,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggle(String label, bool? value, Function(bool?)? onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value ?? false,
          tristate: label == 'Anonymous',
          activeColor: Colors.orange,
          onChanged: onChanged,
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  void _applyPreset(AdminPushPreset preset) {
    setState(() {
      final f = preset.filters;
      minLevel = f['minLevel'];
      maxLevel = f['maxLevel'];
      selectedElements = List<String>.from(f['elements'] ?? []);
      selectedLanguages = List<String>.from(f['languages'] ?? []);
      isAnonymous = f['isAnonymous'];
      lastActiveDays = f['lastActiveDays'];
      isBanned = f['isBanned'] ?? false;
      targetMode = 'filtered';
    });
  }

  void _showSavePresetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Save Preset', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: presetNameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Preset Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (presetNameCtrl.text.isNotEmpty) {
                final filters = {
                  'minLevel': minLevel,
                  'maxLevel': maxLevel,
                  'elements': selectedElements,
                  'languages': selectedLanguages,
                  'isAnonymous': isAnonymous,
                  'lastActiveDays': lastActiveDays,
                  'isBanned': isBanned,
                };
                widget.controller.savePushPreset(presetNameCtrl.text, filters);
                Navigator.pop(ctx);
                presetNameCtrl.clear();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  bool _isSending = false;

  void _send() async {
    if (titleCtrl.text.isEmpty || bodyCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please enter title and body');
      return;
    }

    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      Map<String, dynamic>? filters;

      if (targetMode == 'filtered') {
        filters = {
          'minLevel': minLevel,
          'maxLevel': maxLevel,
          'elements': selectedElements,
          'languages': selectedLanguages,
          'isAnonymous': isAnonymous,
          'lastActiveDays': lastActiveDays,
          'isBanned': isBanned,
        };
      }

      await widget.controller.sendPushNotification(
        title: titleCtrl.text,
        body: bodyCtrl.text,
        playerId: targetMode == 'specific' ? selectedPlayerId : null,
        isGlobal: targetMode == 'global',
        filters: filters,
      );

      titleCtrl.clear();
      bodyCtrl.clear();
    } catch (e) {
      debugPrint('❌ UI Error sending push: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _buildLocalField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }
}

Future<void> _runPackSimulation(
  BuildContext context,
  AdminController controller,
  String packId,
  int iterations,
) async {
  // Show loading
  Get.dialog(
    const Center(child: CircularProgressIndicator(color: Colors.orange)),
    barrierDismissible: false,
  );

  final result = await controller.simulatePackOpening(
    packId,
    iterations: iterations,
  );
  Get.back(); // close loading

  if (result != null && result['success'] == true) {
    showDialog(
      context: context,
      builder: (ctx) => _SimulationResultDialog(result: result),
    );
  }
}

class _SimulationResultDialog extends StatelessWidget {
  final Map<String, dynamic> result;
  const _SimulationResultDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final stats = result['stats'];
    final sample = List<dynamic>.from(result['sample_cards'] ?? []);
    final iterations = result['iterations'] ?? 1;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.orange),
          const SizedBox(width: 12),
          Text(
            iterations > 1 ? 'Simulation: $iterations Packs' : 'Simulation: 1 Pack',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (iterations > 1) ...[
                const Text(
                  'RARITY DISTRIBUTION',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatRow('Bronze', stats['rarity']['bronze'], iterations),
                _buildStatRow('Silver', stats['rarity']['silver'], iterations),
                _buildStatRow('Gold', stats['rarity']['gold'], iterations),
                _buildStatRow('Diamond', stats['rarity']['diamond'], iterations),
                const SizedBox(height: 24),
                const Text(
                  'ELEMENT DISTRIBUTION',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatRow('Fire', stats['element']['fire'], iterations),
                _buildStatRow('Water', stats['element']['water'], iterations),
                _buildStatRow('Earth', stats['element']['earth'], iterations),
                _buildStatRow('Air', stats['element']['air'], iterations),
              ],
              const SizedBox(height: 24),
              const Text(
                'SAMPLE PACK (What players would see)',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: sample
                    .map(
                      (c) => ListTile(
                        dense: true,
                        leading: _elementIcon(c['element']),
                        title: Text(
                          c['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: _rarityBadge(c['rarity']),
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Close', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int count, int iterations) {
    // Total cards = iterations * cardsPerPack (avg 3?)
    // Actually the SQL returns total_cards
    final total = result['total_cards'] ?? (iterations * 3);
    final percent = (count / total * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white70))),
          Expanded(
            child: LinearProgressIndicator(
              value: count / total,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                label == 'Bronze' ? Colors.brown :
                label == 'Silver' ? Colors.grey :
                label == 'Gold' ? Colors.orange :
                label == 'Diamond' ? Colors.lightBlueAccent :
                label == 'Fire' ? Colors.red :
                label == 'Water' ? Colors.blue :
                label == 'Earth' ? Colors.green : Colors.purple,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$count ($percent%)',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _elementIcon(String element) {
    IconData icon;
    Color color;
    switch (element.toLowerCase()) {
      case 'fire': icon = Icons.whatshot; color = Colors.red; break;
      case 'water': icon = Icons.water_drop; color = Colors.blue; break;
      case 'earth': icon = Icons.landscape; color = Colors.green; break;
      case 'air': icon = Icons.air; color = Colors.purple; break;
      default: icon = Icons.help_outline; color = Colors.grey;
    }
    return Icon(icon, color: color, size: 20);
  }

  Widget _rarityBadge(String rarity) {
    Color color;
    switch (rarity.toLowerCase()) {
      case 'diamond': color = Colors.lightBlueAccent; break;
      case 'gold': color = Colors.orange; break;
      case 'silver': color = Colors.grey; break;
      default: color = Colors.brown;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        rarity.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RewardsView extends StatelessWidget {
  final AdminController controller;
  const _RewardsView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Login Rewards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure the rewards for the 7-day login cycle.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() {
              if (controller.dailyRewards.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.separated(
                itemCount: controller.dailyRewards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final reward = controller.dailyRewards[index];
                  return _buildRewardCard(context, reward);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, AdminDailyReward reward) {
    IconData icon;
    Color color;

    switch (reward.rewardType) {
      case 'gold':
        icon = Icons.monetization_on;
        color = Colors.amber;
        break;
      case 'xp':
        icon = Icons.trending_up;
        color = Colors.blue;
        break;
      case 'pack':
        icon = Icons.card_giftcard;
        color = Colors.purple;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${reward.dayIndex}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.title ?? 'No Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.rewardType == 'pack'
                      ? 'Reward: Card Pack'
                      : 'Reward: ${reward.amount} ${reward.rewardType.toUpperCase()}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showRewardDialog(context, reward),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2C2C),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardDialog(BuildContext context, AdminDailyReward reward) {
    // ... existierender Code ...
    final titleCtrl = TextEditingController(text: reward.title ?? '');
    final amountCtrl = TextEditingController(text: reward.amount.toString());
    String rewardType = reward.rewardType;
    String? packId = reward.packId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text('Edit Day ${reward.dayIndex} Reward'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: rewardType,
                  dropdownColor: const Color(0xFF2C2C2C),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Reward Type'),
                  items: const [
                    DropdownMenuItem(value: 'gold', child: Text('Gold')),
                    DropdownMenuItem(value: 'xp', child: Text('Experience')),
                    DropdownMenuItem(value: 'pack', child: Text('Card Pack')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => rewardType = val);
                  },
                ),
                const SizedBox(height: 16),
                if (rewardType != 'pack')
                  TextField(
                    controller: amountCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Obx(() {
                    final packs = controller.cardPacks;
                    return DropdownButtonFormField<String?>(
                      value: packId,
                      dropdownColor: const Color(0xFF2C2C2C),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Select Pack'),
                      items: packs.map((p) {
                        return DropdownMenuItem(value: p.id, child: Text(p.name));
                      }).toList(),
                      onChanged: (val) => setState(() => packId = val),
                    );
                  }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                reward.title = titleCtrl.text;
                reward.rewardType = rewardType;
                reward.amount = int.tryParse(amountCtrl.text) ?? 0;
                reward.packId = packId;
                controller.saveDailyReward(reward);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsView extends StatelessWidget {
  final AdminController controller;
  const _AchievementsView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAchievementDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('New Achievement'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() {
              if (controller.achievements.isEmpty) {
                return const Center(
                  child: Text('No achievements found',
                      style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.separated(
                itemCount: controller.achievements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ach = controller.achievements[index];
                  return _buildAchievementCard(context, ach);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, AdminAchievement ach) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ach.isActive ? Colors.orange.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconContainer(ach.icon, ach.isActive),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ach.nameDe,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!ach.isActive)
                      const Text(
                        'INACTIVE',
                        style: TextStyle(color: Colors.red, fontSize: 10),
                      ),
                  ],
                ),
                Text(
                  ach.category.toUpperCase(),
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  ach.descriptionDe,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                      onPressed: () => _showAchievementDialog(context, achievement: ach),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () => _showDeleteConfirm(context, ach),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconContainer(String iconName, bool active) {
    IconData iconData;
    switch (iconName) {
      case 'emoji_events': iconData = Icons.emoji_events; break;
      case 'style': iconData = Icons.style; break;
      case 'local_fire_department': iconData = Icons.local_fire_department; break;
      case 'shield': iconData = Icons.shield; break;
      case 'stars': iconData = Icons.stars; break;
      case 'military_tech': iconData = Icons.military_tech; break;
      case 'trending_up': iconData = Icons.trending_up; break;
      case 'groups': iconData = Icons.groups; break;
      default: iconData = Icons.emoji_events;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: active ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: active ? Colors.orange : Colors.grey),
    );
  }

  void _showDeleteConfirm(BuildContext context, AdminAchievement ach) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Achievement'),
        content: Text('Are you sure you want to delete "${ach.nameDe}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteAchievement(ach.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAchievementDialog(BuildContext context, {AdminAchievement? achievement}) {
    final isNew = achievement == null;
    final nameDeCtrl = TextEditingController(text: achievement?.nameDe ?? '');
    final nameEnCtrl = TextEditingController(text: achievement?.nameEn ?? '');
    final descDeCtrl = TextEditingController(text: achievement?.descriptionDe ?? '');
    final descEnCtrl = TextEditingController(text: achievement?.descriptionEn ?? '');
    
    // Structured Criteria
    String criteriaType = achievement?.criteria['type'] ?? 'wins';
    final criteriaTargetCtrl = TextEditingController(
      text: (achievement?.criteria['target'] ?? 1).toString(),
    );
    final customCriteriaCtrl = TextEditingController(
      text: achievement != null ? jsonEncode(achievement.criteria) : '',
    );
    bool useRawJson = false;

    String icon = achievement?.icon ?? 'emoji_events';
    String category = achievement?.category ?? 'general';
    bool isActive = achievement?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(isNew ? 'New Achievement' : 'Edit Achievement'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(nameDeCtrl, 'Name (DE)'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(nameEnCtrl, 'Name (EN)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(descDeCtrl, 'Description (DE)', maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField(descEnCtrl, 'Description (EN)', maxLines: 2),
                  const SizedBox(height: 24),
                  
                  // Criteria Section
                  Row(
                    children: [
                      const Text('Condition / Criteria', 
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() => useRawJson = !useRawJson),
                        child: Text(useRawJson ? 'Switch to Simple' : 'Switch to Raw JSON',
                          style: const TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!useRawJson)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: criteriaType,
                            dropdownColor: const Color(0xFF2C2C2C),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Type'),
                            items: const [
                              DropdownMenuItem(value: 'wins', child: Text('Total Wins')),
                              DropdownMenuItem(value: 'cards', child: Text('Cards Owned')),
                              DropdownMenuItem(value: 'streak', child: Text('Login Streak')),
                              DropdownMenuItem(value: 'flawless_win', child: Text('Flawless Wins')),
                              DropdownMenuItem(value: 'level', child: Text('Player Level')),
                              DropdownMenuItem(value: 'packs_opened', child: Text('Packs Opened')),
                            ],
                            onChanged: (val) => setState(() => criteriaType = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(criteriaTargetCtrl, 'Target Value', isNumber: true),
                        ),
                      ],
                    )
                  else
                    _buildTextField(customCriteriaCtrl, 'Criteria (JSON)', maxLines: 2),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          dropdownColor: const Color(0xFF2C2C2C),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: const [
                            DropdownMenuItem(value: 'general', child: Text('General')),
                            DropdownMenuItem(value: 'combat', child: Text('Combat')),
                            DropdownMenuItem(value: 'collection', child: Text('Collection')),
                            DropdownMenuItem(value: 'social', child: Text('Social')),
                          ],
                          onChanged: (val) => setState(() => category = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: icon,
                          dropdownColor: const Color(0xFF2C2C2C),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Icon'),
                          items: const [
                            DropdownMenuItem(value: 'emoji_events', child: Text('Trophy')),
                            DropdownMenuItem(value: 'style', child: Text('Cards')),
                            DropdownMenuItem(value: 'local_fire_department', child: Text('Fire/Streak')),
                            DropdownMenuItem(value: 'shield', child: Text('Shield')),
                            DropdownMenuItem(value: 'stars', child: Text('Stars')),
                            DropdownMenuItem(value: 'military_tech', child: Text('Medal')),
                            DropdownMenuItem(value: 'trending_up', child: Text('Graph')),
                            DropdownMenuItem(value: 'groups', child: Text('Users')),
                          ],
                          onChanged: (val) => setState(() => icon = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Is Active', style: TextStyle(color: Colors.white)),
                    value: isActive,
                    activeColor: Colors.orange,
                    onChanged: (val) => setState(() => isActive = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> criteria = {};
                if (useRawJson) {
                  try {
                    criteria = jsonDecode(customCriteriaCtrl.text);
                  } catch (e) {
                    Get.snackbar('Fehler', 'Ungültiges JSON-Format für Criteria');
                    return;
                  }
                } else {
                  criteria = {
                    'type': criteriaType,
                    'target': int.tryParse(criteriaTargetCtrl.text) ?? 0,
                  };
                }

                final ach = AdminAchievement(
                  id: isNew ? 'temp_${DateTime.now().millisecondsSinceEpoch}' : achievement.id,
                  nameDe: nameDeCtrl.text,
                  nameEn: nameEnCtrl.text,
                  descriptionDe: descDeCtrl.text,
                  descriptionEn: descEnCtrl.text,
                  icon: icon,
                  category: category,
                  criteria: criteria,
                  isActive: isActive,
                  createdAt: achievement?.createdAt ?? DateTime.now(),
                );
                controller.saveAchievement(ach);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }
}

class _EnvironmentView extends StatefulWidget {
  final AdminController controller;
  const _EnvironmentView({required this.controller});

  @override
  State<_EnvironmentView> createState() => _EnvironmentViewState();
}

class _EnvironmentViewState extends State<_EnvironmentView> {
  late Map<String, dynamic> envRules;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  void _loadRules() {
    final raw = widget.controller.balancingConfig['env_mechanics_rules'];
    if (raw != null) {
      try {
        if (raw is String) {
          envRules = Map<String, dynamic>.from(jsonDecode(raw));
        } else {
          envRules = Map<String, dynamic>.from(raw);
        }
      } catch (e) {
        envRules = {};
      }
    } else {
      envRules = {};
    }
    setState(() => isLoaded = true);
  }

  void _saveRules() {
    final jsonStr = jsonEncode(envRules);
    widget.controller.balancingConfig['env_mechanics_rules'] = jsonStr;
    widget.controller.changedKeys.add('env_mechanics_rules');
    widget.controller.saveBalancingConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) return const Center(child: CircularProgressIndicator());

    return DefaultTabController(
      length: 4,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Environment Mechanics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveRules,
                  icon: const Icon(Icons.save),
                  label: const Text('Save All Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TabBar(
              isScrollable: true,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Biomes'),
                Tab(text: 'Time of Day'),
                Tab(text: 'Moon Phases'),
                Tab(text: 'Seasons'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCategoryList('biomes'),
                  _buildCategoryList('time_of_day'),
                  _buildCategoryList('moon_phases'),
                  _buildCategoryList('seasons'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(String category) {
    final Map<String, dynamic> items = envRules[category] ?? {};
    final keys = items.keys.toList();

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final data = Map<String, dynamic>.from(items[key]);
        return _buildRuleCard(category, key, data);
      },
    );
  }

  Widget _buildRuleCard(String category, String key, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              if (data.containsKey('target_element'))
                _buildDropdown(
                  'Target Element',
                  data['target_element'],
                  ['Feuer', 'Wasser', 'Erde', 'Luft'],
                  (val) => setState(() => data['target_element'] = val),
                ),
              if (data.containsKey('target_archetype'))
                _buildDropdown(
                  'Target Archetype',
                  data['target_archetype'],
                  ['Stürmer', 'Allrounder', 'Wall', 'Tänzer'],
                  (val) => setState(() => data['target_archetype'] = val),
                ),
              _buildDropdown(
                'Stat',
                data['stat'],
                [
                  'atk',
                  'def',
                  'agi',
                  'all',
                  'atk_percent',
                  'def_percent',
                  'agi_percent',
                  'all_percent'
                ],
                (val) => setState(() => data['stat'] = val),
              ),
              _buildNumberField(
                'Value',
                data['value'].toString(),
                (val) => setState(() => data['value'] = int.tryParse(val) ?? 0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF2C2C2C),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
        ),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }

  Widget _buildNumberField(String label, String value, Function(String) onChanged) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

