import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

import '../presentation/widgets/app_shell.dart';

// Screen Imports
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

import '../../features/user/presentation/screens/profile_screen.dart';
import '../../features/user/presentation/screens/foreign_profile_screen.dart';
import '../../features/user/presentation/screens/user_search_screen.dart';

import '../../features/friends/presentation/screens/friend_screen.dart';

import '../../features/challenge/presentation/screens/challenge_screen.dart';
import '../../features/challenge/presentation/screens/challenge_detail_screen.dart';
import '../../features/challenge/presentation/screens/create_challenge_screen.dart';

import '../../features/rewards/presentation/screens/my_store_screen.dart';
import '../../features/rewards/presentation/screens/create_reward_screen.dart';
import '../../features/rewards/presentation/screens/friend_shop_screen.dart';
import '../../features/rewards/presentation/screens/reward_detail_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/boot',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);

      final isBoot = state.uri.path == '/boot';
      final isGoingToLogIn = state.uri.path == '/login';
      final isGoingToRegister = state.uri.path == '/register';

      if (authState.isLoading) {
        return null; 
      }

      final isAuthenticated = authState.valueOrNull != null;

      if (!isAuthenticated && !isGoingToLogIn && !isGoingToRegister) {
        return '/login';
      }

      if (isAuthenticated && (isGoingToLogIn || isGoingToRegister || isBoot)) {
        return '/challenges';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/challenges',
                builder: (context, state) => const ChallengeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-store',
                builder: (context, state) => const MyStoreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/friends',
                builder: (context, state) => const FriendScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/History',
                builder: (context, state) => const Center(child: Text('Todo: History Screen')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ]
      ),
      GoRoute(
        path: '/boot',
        builder: (context, state) => const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator())
        ),
      ),
      GoRoute(
        path: '/foreign-profile/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ForeignProfileScreen(id: id);
        }
      ),
      GoRoute(
        path: '/user-search',
        builder: (context, state) => const UserSearchScreen(),
      ),
      GoRoute(
        path: '/challenges/new',
        builder: (context, state) => const CreateChallengeScreen(),
      ),
      GoRoute(
        path: '/challenges/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChallengeDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/rewards/new',
        builder: (context, state) => const CreateRewardScreen(),
      ),
      GoRoute(
        path: '/rewards/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RewardDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/shop/:giverId',
        builder: (context, state) {
          final giverId = state.pathParameters['giverId']!;
          return FriendShopScreen(giverId: giverId);
        },
      ),
    ],
  );

});