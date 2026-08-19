import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';


// Screen Imports
import '../../features/auth/presentation/screens/login_screen.dart';

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
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);

      final isGoingToLogIn = state.uri.path == '/login';

      if (authState.isLoading) {
        return null; 
      }

      final isAuthenticated = authState.valueOrNull != null;

      if (!isAuthenticated && !isGoingToLogIn) {
        return '/login';
      }

      if (isAuthenticated && isGoingToLogIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Panjang Umur')),
          body: const Center(child: Text('Home Screen Placeholder')),
        ),
      ),
    ],
  );

});