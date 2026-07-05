import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/session_notifier.dart';
import '../features/booking/slot_grid_screen.dart';
import '../features/bookings/bookings_screen.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/club/club_screen.dart';
import '../features/profile/profile_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final loggedIn = ref.watch(sessionProvider) != null;
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final goingToLogin = state.matchedLocation == '/login';
      if (!loggedIn) return goingToLogin ? null : '/login';
      if (goingToLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _NavShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const CatalogScreen(),
                routes: [
                  GoRoute(
                    path: 'clubs/:clubId',
                    builder: (_, state) =>
                        ClubScreen(clubId: state.pathParameters['clubId']!),
                    routes: [
                      GoRoute(
                        path: 'courts/:courtId',
                        builder: (_, state) => SlotGridScreen(
                          clubId: state.pathParameters['clubId']!,
                          courtId: state.pathParameters['courtId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (_, __) => const BookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _NavShell extends StatelessWidget {
  const _NavShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.sports_tennis),
            label: l10n.catalogTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event),
            label: l10n.bookingsTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.profileTitle,
          ),
        ],
      ),
    );
  }
}
