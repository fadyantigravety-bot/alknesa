import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/stat_card.dart';

class ServantDashboardScreen extends ConsumerWidget {
  const ServantDashboardScreen({super.key});

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
                  colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
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
                  Text('خادم', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white60)),
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
                StatCard(title: 'مخدومين مسؤول عنهم', value: '—', icon: Icons.people_rounded, color: Color(0xFF5C6BC0)),
                StatCard(title: 'حضور الجمعة', value: '—', icon: Icons.event_available_rounded, color: AppColors.present),
                StatCard(title: 'متابعات مطلوبة', value: '—', icon: Icons.pending_actions_rounded, color: AppColors.warning),
                StatCard(title: 'رسائل جديدة', value: '—', icon: Icons.chat_rounded, color: AppColors.info),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
