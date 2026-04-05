import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/stat_card.dart';

class LeaderDashboardScreen extends ConsumerWidget {
  const LeaderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  Text(user?.fullName ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('مسؤول الخدمة', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white60)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: const [
                StatCard(title: 'المخدومين', value: '—', icon: Icons.people_rounded, color: Color(0xFF2E7D32)),
                StatCard(title: 'الخدام', value: '—', icon: Icons.volunteer_activism_rounded, color: AppColors.accent),
                StatCard(title: 'حضور الجمعة', value: '—', icon: Icons.event_available_rounded, color: AppColors.present),
                StatCard(title: 'متابعات', value: '—', icon: Icons.assignment_rounded, color: AppColors.warning),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
