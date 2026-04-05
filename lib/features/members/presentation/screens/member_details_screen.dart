import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

final memberPrayersProvider = FutureProvider.family<List<dynamic>, String>((ref, id) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.prayerLogs, queryParameters: {'member': id});
  return res.data['results'] ?? res.data;
});

final memberConfessionsProvider = FutureProvider.family<List<dynamic>, String>((ref, id) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.confessionRecords, queryParameters: {'member': id});
  return res.data['results'] ?? res.data;
});

final memberFollowupsProvider = FutureProvider.family<List<dynamic>, String>((ref, id) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.followupRecords, queryParameters: {'member': id});
  return res.data['results'] ?? res.data;
});

final memberFridayProvider = FutureProvider.family<List<dynamic>, String>((ref, id) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.fridayRecords, queryParameters: {'member': id});
  return res.data['results'] ?? res.data;
});

class MemberDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> member;
  const MemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberId = member['id'].toString();
    final prayers = ref.watch(memberPrayersProvider(memberId));
    final confessions = ref.watch(memberConfessionsProvider(memberId));
    final followups = ref.watch(memberFollowupsProvider(memberId));
    final friday = ref.watch(memberFridayProvider(memberId));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(member['full_name'] ?? '${member['first_name']} ${member['last_name']}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الصلوات'),
              Tab(text: 'الاعتراف'),
              Tab(text: 'المتابعات'),
              Tab(text: 'الجمعة'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Quick Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      (member['first_name'] as String? ?? 'م').characters.first,
                      style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member['phone'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.male_rounded, size: 16, color: AppColors.primary), // simplify
                            const SizedBox(width: 4),
                            Text('عضو نشط', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tabs View
            Expanded(
              child: TabBarView(
                children: [
                  // Prayers Tab
                  prayers.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('خطأ: $e')),
                    data: (data) => data.isEmpty 
                      ? const Center(child: Text('لا يوجد سجل صلوات'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: data.length,
                          itemBuilder: (ctx, i) => ListTile(
                            leading: const Icon(Icons.mosque_rounded, color: AppColors.accent),
                            title: Text(data[i]['prayer_name'] ?? 'صلاة'),
                            subtitle: Text(data[i]['date'] ?? ''),
                            trailing: Icon(
                              data[i]['completed'] == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: data[i]['completed'] == true ? AppColors.present : AppColors.error,
                            ),
                          ),
                        ),
                  ),

                  // Confessions Tab
                  confessions.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('خطأ: $e')),
                    data: (data) => data.isEmpty 
                      ? const Center(child: Text('لا يوجد سجل اعتراف'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: data.length,
                          itemBuilder: (ctx, i) => ListTile(
                            leading: const Icon(Icons.church_rounded, color: AppColors.primary),
                            title: const Text('سجل اعتراف'),
                            subtitle: Text('تاريخ: ${data[i]['last_confession_date'] ?? '—'}'),
                            trailing: data[i]['has_confessed'] == true 
                              ? const SizedBox(
                                  width: 70,
                                  child: Row(children: [
                                    Icon(Icons.check_circle_rounded, color: AppColors.present, size: 16),
                                    SizedBox(width: 4),
                                    Text('معترف', style: TextStyle(color: AppColors.present, fontSize: 12))
                                  ]),
                                )
                              : const Text('متأخر', style: TextStyle(color: AppColors.error)),
                          ),
                        ),
                  ),

                  // Followups Tab
                  followups.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('خطأ: $e')),
                    data: (data) => data.isEmpty 
                      ? const Center(child: Text('لا يوجد سجل متابعات'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: data.length,
                          itemBuilder: (ctx, i) => ListTile(
                            leading: const Icon(Icons.assignment_ind_rounded, color: AppColors.warning),
                            title: Text(data[i]['type'] ?? 'متابعة'),
                            subtitle: Text(data[i]['date'] ?? ''),
                            trailing: Text(data[i]['status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                  ),

                  // Friday Tab
                  friday.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('خطأ: $e')),
                    data: (data) => data.isEmpty 
                      ? const Center(child: Text('لا يوجد سجل حضور جمعة'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: data.length,
                          itemBuilder: (ctx, i) {
                            final status = data[i]['status'] ?? 'absent';
                            final isPresent = status == 'present';
                            final isLate = status == 'late';
                            final isExcused = status == 'excused';
                            
                            Color statusColor = AppColors.error;
                            String statusText = 'غائب';
                            IconData statusIcon = Icons.cancel_rounded;

                            if (isPresent) {
                              statusColor = AppColors.present;
                              statusText = 'حاضر';
                              statusIcon = Icons.check_circle_rounded;
                            } else if (isLate) {
                              statusColor = AppColors.warning;
                              statusText = 'متأخر';
                              statusIcon = Icons.watch_later_rounded;
                            } else if (isExcused) {
                              statusColor = AppColors.info;
                              statusText = 'مستأذن';
                              statusIcon = Icons.info_rounded;
                            }

                            final dateRaw = data[i]['marked_at'] ?? '';
                            final dateFormatted = dateRaw.toString().split('T').first;

                            return ListTile(
                              leading: Icon(statusIcon, color: statusColor),
                              title: const Text('اجتماع الجمعة'),
                              subtitle: Text(dateFormatted),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
