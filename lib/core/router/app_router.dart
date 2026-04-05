import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/screens/priest_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/leader_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/servant_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/member_dashboard_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/members/presentation/screens/members_list_screen.dart';
import '../../features/prayers/presentation/screens/prayer_schedule_screen.dart';
import '../../features/friday_attendance/presentation/screens/friday_sessions_screen.dart';
import '../../features/messaging/presentation/screens/conversations_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/followups/presentation/screens/followups_screen.dart';
import '../../features/confessions/presentation/screens/confession_management_screen.dart';
import '../../features/mass_attendance/presentation/screens/mass_attendance_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/messaging/presentation/screens/create_group_chat_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) {
        final role = authState.value!.role;
        switch (role) {
          case 'priest':
            return '/priest';
          case 'service_leader':
            return '/leader';
          case 'servant':
            return '/servant';
          case 'member':
            return '/member';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            conversationId: state.pathParameters['id']!,
            otherName: extra?['name'] ?? 'محادثة',
          );
        },
      ),

      GoRoute(
        path: '/create_group',
        builder: (context, state) => const CreateGroupChatScreen(),
      ),

      // ═══════════════════════════════════════
      // PRIEST Routes
      // ═══════════════════════════════════════
      ShellRoute(
        builder: (context, state, child) => AppShell(role: 'priest', child: child),
        routes: [
          GoRoute(path: '/priest', builder: (_, __) => const PriestDashboardScreen()),
          GoRoute(path: '/priest/members', builder: (_, __) => const MembersListScreen()),
          GoRoute(path: '/priest/confessions', builder: (_, __) => const ConfessionManagementScreen()),
          GoRoute(path: '/priest/prayers', builder: (_, __) => const PrayerScheduleScreen()),
          GoRoute(path: '/priest/friday', builder: (_, __) => const FridaySessionsScreen()),
          GoRoute(path: '/priest/mass', builder: (_, __) => const MassAttendanceScreen()),
          GoRoute(path: '/priest/followups', builder: (_, __) => const FollowupsScreen()),
          GoRoute(path: '/priest/messages', builder: (_, __) => const ConversationsScreen()),
          GoRoute(path: '/priest/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/priest/reports', builder: (_, __) => const ReportsScreen()),
          GoRoute(path: '/priest/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ═══════════════════════════════════════
      // LEADER Routes
      // ═══════════════════════════════════════
      ShellRoute(
        builder: (context, state, child) => AppShell(role: 'service_leader', child: child),
        routes: [
          GoRoute(path: '/leader', builder: (_, __) => const LeaderDashboardScreen()),
          GoRoute(path: '/leader/members', builder: (_, __) => const MembersListScreen()),
          GoRoute(path: '/leader/prayers', builder: (_, __) => const PrayerScheduleScreen()),
          GoRoute(path: '/leader/friday', builder: (_, __) => const FridaySessionsScreen()),
          GoRoute(path: '/leader/followups', builder: (_, __) => const FollowupsScreen()),
          GoRoute(path: '/leader/messages', builder: (_, __) => const ConversationsScreen()),
          GoRoute(path: '/leader/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/leader/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ═══════════════════════════════════════
      // SERVANT Routes
      // ═══════════════════════════════════════
      ShellRoute(
        builder: (context, state, child) => AppShell(role: 'servant', child: child),
        routes: [
          GoRoute(path: '/servant', builder: (_, __) => const ServantDashboardScreen()),
          GoRoute(path: '/servant/members', builder: (_, __) => const MembersListScreen()),
          GoRoute(path: '/servant/friday', builder: (_, __) => const FridaySessionsScreen()),
          GoRoute(path: '/servant/followups', builder: (_, __) => const FollowupsScreen()),
          GoRoute(path: '/servant/messages', builder: (_, __) => const ConversationsScreen()),
          GoRoute(path: '/servant/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/servant/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ═══════════════════════════════════════
      // MEMBER Routes
      // ═══════════════════════════════════════
      ShellRoute(
        builder: (context, state, child) => AppShell(role: 'member', child: child),
        routes: [
          GoRoute(path: '/member', builder: (_, __) => const MemberDashboardScreen()),
          GoRoute(path: '/member/prayers', builder: (_, __) => const PrayerScheduleScreen()),
          GoRoute(path: '/member/friday', builder: (_, __) => const FridaySessionsScreen()),
          GoRoute(path: '/member/mass', builder: (_, __) => const MassAttendanceScreen()),
          GoRoute(path: '/member/messages', builder: (_, __) => const ConversationsScreen()),
          GoRoute(path: '/member/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/member/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
