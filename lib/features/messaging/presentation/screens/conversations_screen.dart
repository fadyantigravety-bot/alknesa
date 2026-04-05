import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/websocket_service.dart';
import '../../data/repositories/messaging_repository.dart';
import 'package:go_router/go_router.dart';

final messagingRepoProvider = Provider((ref) => MessagingRepository(ref.watch(dioProvider)));
final conversationsProvider = FutureProvider((ref) => ref.watch(messagingRepoProvider).getConversations());

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    // Connect to global notifications if not already connected
    ref.read(webSocketServiceProvider).connectNotifications();
    
    // Listen for incoming messages to refresh the list automatically
    ref.read(webSocketServiceProvider).notificationStream.listen((data) {
      if (data['type'] == 'notification' && data['notification'] != null) {
        final notif = data['notification'];
        if (notif['notification_type'] == 'message') {
          // Real-time update for conversation list
          ref.invalidate(conversationsProvider);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final convos = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          context.push('/create_group').then((_) => ref.invalidate(conversationsProvider));
        },
        child: const Icon(Icons.group_add_rounded),
      ),
      body: convos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (unfilteredData) {
          // Filter out empty conversations (where last_message is null) unless it's a freshly created group
          final data = unfilteredData.where((c) {
            final hasMessage = c['last_message'] != null;
            final isGroup = c['type'] == 'announcement' || c['type'] == 'group';
            return hasMessage || isGroup; // always show groups, only show private chats if they have messages
          }).toList();

          if (data.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(conversationsProvider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Center(child: Text('لا توجد محادثات', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary))),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(conversationsProvider),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = data[index];
                final lastMsg = c['last_message'] as Map<String, dynamic>?;
                final other = c['other_participant'] as Map<String, dynamic>?;
                final unread = c['unread_count'] ?? 0;
                final isGroup = c['type'] == 'announcement' || c['type'] == 'group';
                final name = isGroup ? (c['title'] ?? 'إعلان') : (other?['full_name'] ?? 'محادثة');

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: isGroup ? AppColors.accent.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.12),
                    child: Icon(
                      isGroup ? Icons.groups_rounded : Icons.person_rounded,
                      color: isGroup ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  title: Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                  )),
                  subtitle: Text(
                    lastMsg?['content'] ?? (isGroup ? 'اضغط لبدء المحادثة...' : ''),
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
                    context.push('/chat/${c['id']}', extra: {'name': name}).then((_) {
                      ref.invalidate(conversationsProvider);
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

