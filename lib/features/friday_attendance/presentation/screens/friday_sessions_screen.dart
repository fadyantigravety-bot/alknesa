import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/friday_repository.dart';

final fridayRepositoryProvider = Provider((ref) => FridayRepository(ref.watch(dioProvider)));
final fridaySessionsProvider = FutureProvider((ref) => ref.watch(fridayRepositoryProvider).getSessions());

class FridaySessionsScreen extends ConsumerWidget {
  const FridaySessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(fridaySessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('اجتماعات الجمعة')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم إضافة نموذج إنشاء جلسة جديدة قريباً')));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('جلسة جديدة'),
      ),
      body: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('لا توجد جلسات', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final session = data[index];
              final present = session['total_present'] ?? 0;
              final absent = session['total_absent'] ?? 0;
              final total = present + absent + (session['total_excused'] ?? 0);
              final rate = total > 0 ? (present / total * 100).round() : 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.event_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(session['title'] ?? 'اجتماع الجمعة', style: Theme.of(context).textTheme.titleSmall),
                              Text(session['date'] ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: rate >= 70 ? AppColors.present.withOpacity(0.1) : AppColors.absent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('$rate%', style: TextStyle(
                            color: rate >= 70 ? AppColors.present : AppColors.absent,
                            fontWeight: FontWeight.w700, fontSize: 13,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatChip(label: 'حاضر', value: '$present', color: AppColors.present),
                        const SizedBox(width: 8),
                        _StatChip(label: 'غائب', value: '$absent', color: AppColors.absent),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شاشة تحضير الجمعة قيد التطوير')));
                          },
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('تسجيل'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
