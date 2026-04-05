import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/prayer_provider.dart';

class PrayerScheduleScreen extends ConsumerWidget {
  const PrayerScheduleScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return AppColors.completed;
      case 'missed': return AppColors.missed;
      case 'snoozed': return AppColors.snoozed;
      default: return AppColors.pending;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed': return Icons.check_circle_rounded;
      case 'missed': return Icons.cancel_rounded;
      case 'snoozed': return Icons.snooze_rounded;
      default: return Icons.radio_button_unchecked_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed': return 'تمت ✓';
      case 'missed': return 'فائتة';
      case 'snoozed': return 'مؤجلة';
      case 'pending_confirmation': return 'في الانتظار';
      default: return 'لم تبدأ';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayPrayers = ref.watch(todayPrayersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('صلوات اليوم')),
      body: todayPrayers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ في تحميل الصلوات', style: TextStyle(color: AppColors.error))),
        data: (prayers) {
          if (prayers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mosque_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('لا توجد صلوات مجدولة اليوم', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: prayers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final prayer = prayers[index];
              final color = _statusColor(prayer.status);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(_statusIcon(prayer.status), color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prayer.prayerName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(_statusLabel(prayer.status), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
                        ],
                      ),
                    ),
                    if (prayer.status == 'pending' || prayer.status == 'pending_confirmation')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            label: 'صليت',
                            color: AppColors.completed,
                            onTap: () async {
                              await ref.read(prayerRepositoryProvider).updateStatus(prayer.id, 'completed');
                              ref.invalidate(todayPrayersProvider);
                            },
                          ),
                          const SizedBox(width: 6),
                          _ActionButton(
                            label: 'لاحقاً',
                            color: AppColors.snoozed,
                            onTap: () async {
                              await ref.read(prayerRepositoryProvider).updateStatus(prayer.id, 'snoozed');
                              ref.invalidate(todayPrayersProvider);
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
