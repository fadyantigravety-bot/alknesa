import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/stat_card.dart';
import '../widgets/dashboard_section.dart';

class PriestDashboardScreen extends ConsumerWidget {
  const PriestDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: Text(
                          user?.firstName.characters.first ?? 'أ',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً أبونا',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                            Text(
                              user?.fullName ?? '',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                        onPressed: () => context.push('/priest/notifications'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                        onPressed: () => ref.read(authStateProvider.notifier).logout(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: const [
                StatCard(
                  title: 'إجمالي المخدومين',
                  value: '—',
                  icon: Icons.people_rounded,
                  color: AppColors.primary,
                ),
                StatCard(
                  title: 'حضور الجمعة',
                  value: '—',
                  icon: Icons.event_available_rounded,
                  color: AppColors.present,
                ),
                StatCard(
                  title: 'الصلوات اليوم',
                  value: '—',
                  icon: Icons.mosque_rounded,
                  color: AppColors.accent,
                ),
                StatCard(
                  title: 'متابعات معلقة',
                  value: '—',
                  icon: Icons.follow_the_signs_rounded,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: DashboardSection(
              title: 'إجراءات سريعة',
              children: [
                _QuickAction(icon: Icons.church_rounded, label: 'الاعتراف', onTap: () => context.push('/priest/confessions')),
                _QuickAction(icon: Icons.event_note_rounded, label: 'الجمعة', onTap: () => context.push('/priest/friday')),
                _QuickAction(icon: Icons.search_rounded, label: 'الأعضاء', onTap: () => context.push('/priest/members')),
                _QuickAction(icon: Icons.pie_chart_rounded, label: 'التقارير', onTap: () => context.push('/priest/reports')),
              ],
            ),
          ),

          // Recent Activity (placeholder)
          SliverToBoxAdapter(
            child: DashboardSection(
              title: 'آخر النشاطات',
              children: [
                _ActivityTile(title: 'نظام جاهز', subtitle: 'تم تهيئة النظام بنجاح', time: 'الآن'),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            const Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _ActivityTile({required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.present.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.check_circle_rounded, color: AppColors.present, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text(time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
    );
  }
}
