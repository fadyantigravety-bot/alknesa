import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.dashboardStats);
  return res.data;
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير والتحليلات')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (data) {
          final prayer = data['prayer_completion_today'] as Map<String, dynamic>? ?? {};
          final friday = data['latest_friday'] as Map<String, dynamic>?;
          final confession = data['confession'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview
                _ReportCard(
                  title: 'نظرة عامة',
                  icon: Icons.dashboard_rounded,
                  color: AppColors.primary,
                  children: [
                    _DataRow(label: 'إجمالي المخدومين', value: '${data['total_members'] ?? 0}'),
                    _DataRow(label: 'أعياد الميلاد اليوم', value: '${data['birthdays_today'] ?? 0}'),
                    _DataRow(label: 'رسائل غير مقروءة', value: '${data['unread_messages'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: 12),

                // Prayer Completion
                _ReportCard(
                  title: 'التزام الصلاة اليوم',
                  icon: Icons.mosque_rounded,
                  color: AppColors.accent,
                  children: [
                    _DataRow(label: 'إجمالي', value: '${prayer['total'] ?? 0}'),
                    _DataRow(label: 'مكتملة', value: '${prayer['completed'] ?? 0}'),
                    _ProgressBar(value: (prayer['rate'] ?? 0).toDouble(), color: AppColors.completed),
                  ],
                ),
                const SizedBox(height: 12),

                // Friday Attendance
                if (friday != null)
                  _ReportCard(
                    title: 'حضور آخر جمعة (${friday['date']})',
                    icon: Icons.event_available_rounded,
                    color: AppColors.present,
                    children: [
                      _DataRow(label: 'حاضر', value: '${friday['present']}'),
                      _DataRow(label: 'غائب', value: '${friday['absent']}'),
                      _DataRow(label: 'إجمالي', value: '${friday['total']}'),
                      _ProgressBar(
                        value: (friday['total'] > 0 ? friday['present'] / friday['total'] * 100 : 0).toDouble(),
                        color: AppColors.present,
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                // Follow-ups
                _ReportCard(
                  title: 'المتابعات',
                  icon: Icons.assignment_rounded,
                  color: AppColors.warning,
                  children: [
                    _DataRow(label: 'معلقة', value: '${data['pending_followups'] ?? 0}'),
                    _DataRow(label: 'متأخرة', value: '${data['overdue_followups'] ?? 0}', valueColor: AppColors.error),
                  ],
                ),
                const SizedBox(height: 12),

                // Confession (priest only)
                if (confession != null)
                  _ReportCard(
                    title: 'الاعتراف',
                    icon: Icons.church_rounded,
                    color: AppColors.primary,
                    children: [
                      _DataRow(label: 'اعترفوا', value: '${confession['confessed']}'),
                      _DataRow(label: 'متأخرين', value: '${confession['overdue']}', valueColor: AppColors.error),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  const _ReportCard({required this.title, required this.icon, required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DataRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: valueColor, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${value.round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: value / 100, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 6),
        ),
      ]),
    );
  }
}
