import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/app_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/listing_list_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/add_edit_listing_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/my_listings_viewings_screen.dart';
import 'screens/user_profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // Login screen - outside shell (no bottom navigation bar)
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),

    // Stateful shell route holding top-level branches with persistent tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Search & Listings (/listings)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/listings',
              builder: (context, state) => const ListingListScreen(),
              routes: [
                // Add new listing sub-route (/listings/new)
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const AddEditListingScreen(),
                ),
                // Details sub-route (/listings/:id)
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ListingDetailScreen(id: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 2: Favorites (/favorites)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),

        // Branch 3: Activity / My Listings & Viewings (/activity)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/activity',
              builder: (context, state) => const MyListingsAndViewingsScreen(),
            ),
          ],
        ),

        // Branch 4: Profile (/profile)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const UserProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
