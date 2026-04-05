import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/providers/auth_provider.dart';

final confessionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.confessionRecords);
  return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
});

class ConfessionManagementScreen extends ConsumerWidget {
  const ConfessionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confessions = ref.watch(confessionsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الاعتراف'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الكل'),
              Tab(text: 'لم يعترف'),
              Tab(text: 'متأخر'),
            ],
          ),
        ),
        body: confessions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (data) {
            final notConfessed = data.where((c) => c['has_confessed'] == false).toList();
            final overdue = data.where((c) => c['is_overdue'] == true).toList();

            return TabBarView(
              children: [
                _ConfessionList(records: data),
                _ConfessionList(records: notConfessed),
                _ConfessionList(records: overdue),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConfessionList extends ConsumerWidget {
  final List<Map<String, dynamic>> records;
  const _ConfessionList({required this.records});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPriest = ref.watch(authStateProvider).value?.role == 'priest';

    if (records.isEmpty) {
      return Center(child: Text('لا توجد سجلات', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final c = records[index];
        final hasConfessed = c['has_confessed'] ?? false;
        final isOverdue = c['is_overdue'] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isOverdue ? AppColors.error.withOpacity(0.3) : (hasConfessed ? AppColors.present.withOpacity(0.2) : AppColors.divider)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (hasConfessed ? AppColors.present : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasConfessed ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: hasConfessed ? AppColors.present : AppColors.error, size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['member_name'] ?? '', style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      hasConfessed ? 'آخر اعتراف: ${c['last_confession_date'] ?? '—'}' : 'لم يعترف بعد',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  margin: const EdgeInsets.only(left: 8),
                  child: const Text('متأخر', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              if (isPriest)
                IconButton(
                  icon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
                  tooltip: 'تسجيل اعتراف',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('تأكيد'),
                        content: Text('هل متأكد من تسجيل اعتراف لـ ${c['member_name']}؟'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await ref.read(dioProvider).patch(
                          '${ApiConstants.confessionRecords}${c['id']}/',
                          data: {
                            'has_confessed': true,
                            'last_confession_date': DateTime.now().toIso8601String().split('T')[0],
                          },
                        );
                        ref.invalidate(confessionsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تسجيل الاعتراف بنجاح!'), backgroundColor: AppColors.present),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
