import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

final followupsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.followupRecords);
  return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
});

class FollowupsScreen extends ConsumerWidget {
  const FollowupsScreen({super.key});

  Color _priorityColor(String p) {
    switch (p) { case 'urgent': return AppColors.error; case 'high': return AppColors.warning; case 'medium': return AppColors.info; default: return AppColors.textSecondary; }
  }

  Color _statusColor(String s) {
    switch (s) { case 'completed': return AppColors.present; case 'overdue': return AppColors.error; case 'pending': return AppColors.warning; default: return AppColors.textSecondary; }
  }

  String _statusLabel(String s) {
    switch (s) { case 'completed': return 'مكتملة'; case 'overdue': return 'متأخرة'; case 'pending': return 'معلقة'; default: return 'ملغاة'; }
  }

  String _typeLabel(String t) {
    switch (t) { case 'phone_call': return 'مكالمة'; case 'visit': return 'زيارة'; case 'chat_message': return 'رسالة'; case 'meeting': return 'اجتماع'; default: return 'أخرى'; }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followups = ref.watch(followupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المتابعات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () { /* TODO */ },
        icon: const Icon(Icons.add_rounded),
        label: const Text('متابعة جديدة'),
      ),
      body: followups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.checklist_rounded, size: 64, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text('لا توجد متابعات', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final f = data[index];
              final status = f['status'] ?? 'pending';
              final priority = f['priority'] ?? 'medium';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(right: BorderSide(color: _priorityColor(priority), width: 3)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(_statusLabel(status), style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(_typeLabel(f['type'] ?? ''), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ),
                      const Spacer(),
                      Text(f['date']?.toString().split('T').first ?? '', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textHint)),
                    ]),
                    const SizedBox(height: 8),
                    Text(f['member_name'] ?? '', style: Theme.of(context).textTheme.titleSmall),
                    if (f['summary'] != null) ...[
                      const SizedBox(height: 4),
                      Text(f['summary'], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
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
