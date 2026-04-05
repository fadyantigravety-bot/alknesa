import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QuickMarkAttendanceScreen extends StatefulWidget {
  final String sessionId;
  final List<Map<String, dynamic>> members;

  const QuickMarkAttendanceScreen({super.key, required this.sessionId, required this.members});

  @override
  State<QuickMarkAttendanceScreen> createState() => _QuickMarkAttendanceScreenState();
}

class _QuickMarkAttendanceScreenState extends State<QuickMarkAttendanceScreen> {
  final Map<String, String> _statuses = {};

  @override
  void initState() {
    super.initState();
    for (final m in widget.members) {
      _statuses[m['id']] = m['current_status'] ?? 'absent';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present': return AppColors.present;
      case 'absent': return AppColors.absent;
      case 'excused': return AppColors.excused;
      case 'late': return AppColors.late;
      default: return AppColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الحضور'),
        actions: [
          TextButton.icon(
            onPressed: () { /* TODO: submit bulk */ },
            icon: const Icon(Icons.save_rounded),
            label: const Text('حفظ'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CountBadge(label: 'حاضر', count: _statuses.values.where((s) => s == 'present').length, color: AppColors.present),
                _CountBadge(label: 'غائب', count: _statuses.values.where((s) => s == 'absent').length, color: AppColors.absent),
                _CountBadge(label: 'معتذر', count: _statuses.values.where((s) => s == 'excused').length, color: AppColors.excused),
              ],
            ),
          ),
          // Members list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.members.length,
              itemBuilder: (context, index) {
                final member = widget.members[index];
                final id = member['id'] as String;
                final status = _statuses[id] ?? 'absent';

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor(status).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _statusColor(status).withOpacity(0.15),
                        child: Text(
                          (member['name'] as String? ?? 'م').characters.first,
                          style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(member['name'] ?? '', style: Theme.of(context).textTheme.titleSmall),
                      ),
                      // Status toggle buttons
                      _ToggleButton(label: 'حضر', isActive: status == 'present', color: AppColors.present,
                        onTap: () => setState(() => _statuses[id] = 'present')),
                      const SizedBox(width: 4),
                      _ToggleButton(label: 'غاب', isActive: status == 'absent', color: AppColors.absent,
                        onTap: () => setState(() => _statuses[id] = 'absent')),
                      const SizedBox(width: 4),
                      _ToggleButton(label: 'عذر', isActive: status == 'excused', color: AppColors.excused,
                        onTap: () => setState(() => _statuses[id] = 'excused')),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;
  const _ToggleButton({required this.label, required this.isActive, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(
          color: isActive ? Colors.white : color, fontSize: 11, fontWeight: FontWeight.w600,
        )),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountBadge({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}
