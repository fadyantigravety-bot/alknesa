import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PrayerAlertScreen extends StatelessWidget {
  final String prayerName;
  final String scheduledTime;
  final VoidCallback onPrayNow;
  final VoidCallback onSnooze;

  const PrayerAlertScreen({
    super.key,
    required this.prayerName,
    required this.scheduledTime,
    required this.onPrayNow,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF1B5E7B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Animated ring
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.mosque_rounded, size: 48, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'حان وقت الصلاة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(
                prayerName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                scheduledTime,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.accentLight),
              ),
              const Spacer(flex: 2),
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    // Snooze
                    Expanded(
                      child: GestureDetector(
                        onTap: onSnooze,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.snooze_rounded, color: AppColors.snoozed, size: 28),
                              const SizedBox(height: 6),
                              Text('تأجيل', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Pray now
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: onPrayNow,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 28),
                              const SizedBox(height: 6),
                              Text('أصلي الآن', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
