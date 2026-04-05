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

class _AnimatedBottomNav extends StatefulWidget {
  final String role;
  final String currentPath;

  const _AnimatedBottomNav({required this.role, required this.currentPath});

  @override
  State<_AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<_AnimatedBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  int _previousIndex = 0;

  List<_NavItem> get _items {
    switch (widget.role) {
      case 'priest':
        return [
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'الرئيسية',
            path: '/priest',
          ),
          _NavItem(
            icon: Icons.people_rounded,
            label: 'الأعضاء',
            path: '/priest/members',
          ),
          _NavItem(
            icon: Icons.event_available_rounded,
            label: 'الجمعة',
            path: '/priest/friday',
          ),
          _NavItem(
            icon: Icons.chat_bubble_rounded,
            label: 'الرسائل',
            path: '/priest/messages',
          ),
          _NavItem(
            icon: Icons.analytics_rounded,
            label: 'التقارير',
            path: '/priest/reports',
          ),
        ];
      case 'service_leader':
        return [
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'الرئيسية',
            path: '/leader',
          ),
          _NavItem(
            icon: Icons.people_rounded,
            label: 'الأعضاء',
            path: '/leader/members',
          ),
          _NavItem(
            icon: Icons.event_available_rounded,
            label: 'الجمعة',
            path: '/leader/friday',
          ),
          _NavItem(
            icon: Icons.chat_bubble_rounded,
            label: 'الرسائل',
            path: '/leader/messages',
          ),
          _NavItem(
            icon: Icons.notifications_rounded,
            label: 'الإشعارات',
            path: '/leader/notifications',
          ),
        ];
      case 'servant':
        return [
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'الرئيسية',
            path: '/servant',
          ),
          _NavItem(
            icon: Icons.people_rounded,
            label: 'المخدومين',
            path: '/servant/members',
          ),
          _NavItem(
            icon: Icons.event_available_rounded,
            label: 'الجمعة',
            path: '/servant/friday',
          ),
          _NavItem(
            icon: Icons.follow_the_signs_rounded,
            label: 'المتابعة',
            path: '/servant/followups',
          ),
          _NavItem(
            icon: Icons.chat_bubble_rounded,
            label: 'الرسائل',
            path: '/servant/messages',
          ),
        ];
      case 'member':
        return [
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'الرئيسية',
            path: '/member',
          ),
          _NavItem(
            icon: Icons.mosque_rounded,
            label: 'الصلوات',
            path: '/member/prayers',
          ),
          _NavItem(
            icon: Icons.event_rounded,
            label: 'الجمعة',
            path: '/member/friday',
          ),
          _NavItem(
            icon: Icons.chat_bubble_rounded,
            label: 'الرسائل',
            path: '/member/messages',
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'حسابي',
            path: '/member/profile',
          ),
        ];
      default:
        return [];
    }
  }

  int _getSelectedIndex() {
    final items = _items;

    // Find the longest path match to handle nested routes correctly
    // e.g. /priest/members is matched to /priest/members instead of /priest
    int bestMatchIndex = 0;
    int maxPathLength = -1;

    for (int i = 0; i < items.length; i++) {
      if (widget.currentPath.startsWith(items[i].path) &&
          items[i].path.length > maxPathLength) {
        maxPathLength = items[i].path.length;
        bestMatchIndex = i;
      }
    }

    return bestMatchIndex;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final selectedIndex = _getSelectedIndex();
    _previousIndex = selectedIndex;
    _positionAnimation = Tween<double>(
      begin: selectedIndex.toDouble(),
      end: selectedIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
  }

  @override
  void didUpdateWidget(covariant _AnimatedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      final newIndex = _getSelectedIndex();
      if (newIndex != _previousIndex) {
        _positionAnimation =
            Tween<double>(
              begin: _previousIndex.toDouble(),
              end: newIndex.toDouble(),
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
            );
        _controller.forward(from: 0);
        _previousIndex = newIndex;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final selectedIndex = _getSelectedIndex();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: 90 + bottomPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemWidth = width / items.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Background Bar with Animated Notch
              AnimatedBuilder(
                animation: _positionAnimation,
                builder: (context, child) {
                  final xPos =
                      _positionAnimation.value * itemWidth + (itemWidth / 2);
                  final notchX = isRtl ? width - xPos : xPos;
                  return Positioned(
                    top: 30,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CustomPaint(
                      painter: _NotchedBarPainter(
                        notchX: notchX,
                        color: Colors.white,
                        shadowColor: Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                  );
                },
              ),

              // The Floating Selected Circle (Blank background spotlight)
              AnimatedBuilder(
                animation: _positionAnimation,
                builder: (context, child) {
                  final xPos =
                      _positionAnimation.value * itemWidth + (itemWidth / 2);
                  return Positioned.directional(
                    textDirection: Directionality.of(context),
                    start: xPos - 28, // Center offset (56/2)
                    top: 2, // Centered on y=30
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // The Tab Items (Icons + Text)
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                bottom: bottomPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == selectedIndex;

                    return GestureDetector(
                      onTap: () => context.go(item.path),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: itemWidth,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // Animated Icon that leaps UP into the white circle
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutBack,
                              top: isSelected ? -14 : 8,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                child: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: isSelected ? 28 : 24,
                                ),
                              ),
                            ),

                            // Text below the icon
                            Positioned(
                              bottom: 8,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                style: TextStyle(
                                  fontSize: isSelected ? 12 : 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                child: Text(item.label),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
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

class _NotchedBarPainter extends CustomPainter {
  final double notchX;
  final Color color;
  final Color shadowColor;

  _NotchedBarPainter({
    required this.notchX,
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final host = Rect.fromLTWH(0, 0, size.width, size.height);
    // 72 width/height guest rect gives a 8px clearance curve around the 56px floating circle
    final guest = Rect.fromCenter(
      center: Offset(notchX, 0),
      width: 72,
      height: 72,
    );

    final path = const CircularNotchedRectangle().getOuterPath(host, guest);

    // Custom shadow that spreads evenly (including upwards)
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.save();
    canvas.translate(0, -2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw bar
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) {
    return oldDelegate.notchX != notchX ||
        oldDelegate.color != color ||
        oldDelegate.shadowColor != shadowColor;
  }
}
