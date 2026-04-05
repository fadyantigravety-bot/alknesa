import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

final membersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.users, queryParameters: {'role': 'member'});
  return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
});

class MembersListScreen extends ConsumerStatefulWidget {
  const MembersListScreen({super.key});

  @override
  ConsumerState<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends ConsumerState<MembersListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الأعضاء')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'بحث بالاسم...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: members.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (data) {
                final filtered = data.where((m) {
                  final name = '${m['first_name']} ${m['last_name']}'.toLowerCase();
                  return _search.isEmpty || name.contains(_search.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text('لا يوجد أعضاء', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          child: Text(
                            (m['first_name'] as String? ?? 'م').characters.first,
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(m['full_name'] ?? '${m['first_name']} ${m['last_name']}', style: Theme.of(context).textTheme.titleSmall),
                        subtitle: Text(m['phone'] ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.textHint),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(radius: 30, backgroundColor: AppColors.primary.withOpacity(0.12), child: Text((m['first_name'] as String? ?? 'م').characters.first, style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold))),
                                  const SizedBox(height: 12),
                                  Text(m['full_name'] ?? '${m['first_name']} ${m['last_name']}', style: Theme.of(context).textTheme.titleLarge),
                                  Text(m['phone'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: 24),
                                  ListTile(
                                    leading: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                                    title: const Text('إرسال رسالة'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم فتح المحادثة قريباً')));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.call_rounded, color: AppColors.present),
                                    title: const Text('اتصال مباشر'),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
