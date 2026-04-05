import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final String role;
  final Widget child;

  const AppShell({super.key, required this.role, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _AnimatedBottomNav(
        role: role,
        currentPath: GoRouterState.of(context).matchedLocation,
      ),
    );
  }
}

class _AnimatedBottomNav extends StatelessWidget {
  final String role;
  final String currentPath;

  const _AnimatedBottomNav({required this.role, required this.currentPath});

  List<_NavItem> get _items {
    switch (role) {
      case 'priest':
        return [
          _NavItem(icon: Icons.dashboard_rounded, label: 'الرئيسية', path: '/priest'),
          _NavItem(icon: Icons.people_rounded, label: 'الأعضاء', path: '/priest/members'),
          _NavItem(icon: Icons.event_available_rounded, label: 'الجمعة', path: '/priest/friday'),
          _NavItem(icon: Icons.chat_bubble_rounded, label: 'الرسائل', path: '/priest/messages'),
          _NavItem(icon: Icons.analytics_rounded, label: 'التقارير', path: '/priest/reports'),
        ];
      case 'service_leader':
        return [
          _NavItem(icon: Icons.dashboard_rounded, label: 'الرئيسية', path: '/leader'),
          _NavItem(icon: Icons.people_rounded, label: 'الأعضاء', path: '/leader/members'),
          _NavItem(icon: Icons.event_available_rounded, label: 'الجمعة', path: '/leader/friday'),
          _NavItem(icon: Icons.chat_bubble_rounded, label: 'الرسائل', path: '/leader/messages'),
          _NavItem(icon: Icons.notifications_rounded, label: 'الإشعارات', path: '/leader/notifications'),
        ];
      case 'servant':
        return [
          _NavItem(icon: Icons.dashboard_rounded, label: 'الرئيسية', path: '/servant'),
          _NavItem(icon: Icons.people_rounded, label: 'المخدومين', path: '/servant/members'),
          _NavItem(icon: Icons.event_available_rounded, label: 'الجمعة', path: '/servant/friday'),
          _NavItem(icon: Icons.follow_the_signs_rounded, label: 'المتابعة', path: '/servant/followups'),
          _NavItem(icon: Icons.chat_bubble_rounded, label: 'الرسائل', path: '/servant/messages'),
        ];
      case 'member':
        return [
          _NavItem(icon: Icons.dashboard_rounded, label: 'الرئيسية', path: '/member'),
          _NavItem(icon: Icons.mosque_rounded, label: 'الصلوات', path: '/member/prayers'),
          _NavItem(icon: Icons.event_rounded, label: 'الجمعة', path: '/member/friday'),
          _NavItem(icon: Icons.chat_bubble_rounded, label: 'الرسائل', path: '/member/messages'),
          _NavItem(icon: Icons.person_rounded, label: 'حسابي', path: '/member/profile'),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final currentIndex = items.indexWhere((item) => currentPath.startsWith(item.path));
    final selectedIndex = currentIndex == -1 ? 0 : currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == selectedIndex;

              return GestureDetector(
                onTap: () => context.go(item.path),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          item.icon,
                          size: isSelected ? 26 : 22,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: isSelected ? 11 : 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  _NavItem({required this.icon, required this.label, required this.path});
}
