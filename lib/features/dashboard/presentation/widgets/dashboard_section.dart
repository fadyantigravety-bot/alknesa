import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const DashboardSection({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: child,
              )),
        ],
      ),
    );
  }
}
