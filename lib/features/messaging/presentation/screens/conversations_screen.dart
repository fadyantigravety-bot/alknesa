import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/messaging_repository.dart';
import 'package:go_router/go_router.dart';

final messagingRepoProvider = Provider((ref) => MessagingRepository(ref.watch(dioProvider)));
final conversationsProvider = FutureProvider((ref) => ref.watch(messagingRepoProvider).getConversations());

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convos = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم إضافة نموذج محادثة جديدة قريباً')));
        },
        child: const Icon(Icons.edit_rounded),
      ),
      body: convos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('لا توجد محادثات', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = data[index];
              final lastMsg = c['last_message'] as Map<String, dynamic>?;
              final other = c['other_participant'] as Map<String, dynamic>?;
              final unread = c['unread_count'] ?? 0;
              final name = c['type'] == 'announcement' ? (c['title'] ?? 'إعلان') : (other?['full_name'] ?? 'محادثة');

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: c['type'] == 'announcement' ? AppColors.accent.withOpacity(0.15) : AppColors.primary.withOpacity(0.12),
                  child: Icon(
                    c['type'] == 'announcement' ? Icons.campaign_rounded : Icons.person_rounded,
                    color: c['type'] == 'announcement' ? AppColors.accent : AppColors.primary,
                  ),
                ),
                title: Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                )),
                subtitle: Text(
                  lastMsg?['content'] ?? '',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastMsg?['created_at'] != null)
                      Text(_formatTime(lastMsg!['created_at']), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textHint)),
                    if (unread > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                        child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  context.push('/chat/${c['id']}', extra: {'name': name});
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
