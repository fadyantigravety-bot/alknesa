import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/repositories/messaging_repository.dart';

final membersListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.users, queryParameters: {'role': 'member'});
  return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
});

class CreateGroupChatScreen extends ConsumerStatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  ConsumerState<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends ConsumerState<CreateGroupChatScreen> {
  final _titleController = TextEditingController();
  final Set<String> _selectedMemberIds = {};
  bool _isCreating = false;

  void _createGroup() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال اسم الجروب')));
      return;
    }
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تحديد عضو واحد على الأقل')));
      return;
    }

    setState(() => _isCreating = true);
    try {
      final repo = MessagingRepository(ref.read(dioProvider));
      final title = _titleController.text.trim();
      
      final conv = await repo.createConversation(
        'announcement',
        _selectedMemberIds.toList(),
        title: title,
      );
      
      final convId = conv['id'].toString();
      
      if (context.mounted) {
        // Go back to previous screen (Conversations list)
        context.pop();
        // Then push the chat screen with the new group
        context.push('/chat/$convId', extra: {'name': title});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    } finally {
      if (context.mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء جروب جديد'),
        actions: [
          if (_isCreating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
            )
          else
            TextButton(
              onPressed: _createGroup,
              child: const Text('إنشاء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'اسم الجروب',
                hintText: 'مثال: تنبيهات خدمة إعداد خدام',
                prefixIcon: const Icon(Icons.group_rounded),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text('اختيار الأعضاء', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_selectedMemberIds.length} محدد', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (members) {
                if (members.isEmpty) {
                  return const Center(child: Text('لا يوجد أعضاء متوفرين'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final m = members[index];
                    final memberId = m['id'].toString();
                    final isSelected = _selectedMemberIds.contains(memberId);
                    
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 1),
                      ),
                      child: CheckboxListTile(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedMemberIds.add(memberId);
                            } else {
                              _selectedMemberIds.remove(memberId);
                            }
                          });
                        },
                        title: Text(m['full_name'] ?? '${m['first_name']} ${m['last_name']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(m['phone'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        secondary: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          child: Text(
                            (m['first_name'] as String? ?? 'م').characters.first,
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
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
