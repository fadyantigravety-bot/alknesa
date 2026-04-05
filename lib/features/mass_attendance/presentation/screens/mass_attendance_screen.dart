import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

final massRecordsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.massRecords);
  return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
});

class MassAttendanceScreen extends ConsumerWidget {
  const MassAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(massRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حضور القداس')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () { /* TODO: add record */ },
        icon: const Icon(Icons.add_rounded),
        label: const Text('تسجيل حضور'),
      ),
      body: records.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.church_rounded, size: 64, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text('لا توجد سجلات', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final r = data[index];
              final attended = r['attended'] ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (attended ? AppColors.present : AppColors.absent).withOpacity(0.2)),
                ),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: (attended ? AppColors.present : AppColors.absent).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(attended ? Icons.check_rounded : Icons.close_rounded,
                      color: attended ? AppColors.present : AppColors.absent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['member_name'] ?? '', style: Theme.of(context).textTheme.titleSmall),
                    Text(r['date'] ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    if (r['mass_type'] != null) Text(r['mass_type'], style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textHint)),
                  ])),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
