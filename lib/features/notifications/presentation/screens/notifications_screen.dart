import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.notifications);
  return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _typeIcon(String type) {
    switch (type) {
      case 'prayer_alert': return Icons.mosque_rounded;
      case 'birthday': return Icons.cake_rounded;
      case 'message': return Icons.chat_rounded;
      case 'announcement': return Icons.campaign_rounded;
      case 'followup_due': return Icons.assignment_late_rounded;
      case 'absence_alert': return Icons.person_off_rounded;
      case 'confession_overdue': return Icons.church_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'prayer_alert': return AppColors.primary;
      case 'birthday': return AppColors.accent;
      case 'message': return AppColors.info;
      case 'announcement': return AppColors.warning;
      case 'followup_due': return AppColors.error;
      case 'absence_alert': return AppColors.absent;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(dioProvider).post('${ApiConstants.notifications}mark_all_read/');
              ref.invalidate(notificationsProvider);
            },
            child: const Text('قراءة الكل'),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('لا توجد إشعارات', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final n = data[index];
              final isRead = n['is_read'] ?? false;
              final type = n['notification_type'] ?? 'system';
              final color = _typeColor(type);

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isRead ? Colors.white : color.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: isRead ? null : Border.all(color: color.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(_typeIcon(type), color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['title'] ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                          )),
                          const SizedBox(height: 2),
                          Text(n['body'] ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary), maxLines: 2),
                        ],
                      ),
                    ),
                    if (!isRead)
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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
