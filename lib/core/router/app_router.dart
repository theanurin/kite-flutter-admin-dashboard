import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider, Ref;
import 'package:go_router/go_router.dart' show GoRoute, GoRouter, ShellRoute;

import '../../features/apps/calendar_screen.dart' show CalendarScreen;
import '../../features/apps/chat_screen.dart' show ChatScreen;
import '../../features/apps/inbox_screen.dart' show InboxScreen;
import '../../features/apps/kanban_screen.dart' show KanbanScreen;
import '../../features/auth/auth_screens.dart' show ForgotPasswordScreen, LockScreen, OtpScreen, SignInScreen, SignUpScreen;
import '../../features/components/components_screen.dart' show ComponentsScreen;
import '../../features/dashboard/dashboard_screen.dart' show DashboardScreen;
import '../../features/dashboard/project_dashboard_screen.dart' show ProjectDashboardScreen;
import '../../features/forms/forms_screen.dart' show FormsScreen;
import '../../features/forms/wizard_screen.dart' show WizardScreen;
import '../../features/resources/resource_detail_screen.dart' show ResourceDetailScreen;
import '../../features/resources/resource_form_screen.dart' show ResourceFormScreen;
import '../../features/resources/resource_list_screen.dart' show ResourceListScreen;
import '../../features/system/error_screen.dart' show NotFoundScreen, ServerErrorScreen;
import '../../features/system/profile_screen.dart' show ProfileScreen;
import '../../features/system/settings_screen.dart' show SettingsScreen;
import '../../shared/layout/app_shell.dart' show AppShell;
import '../auth/session.dart' show sessionProvider;
import 'routes.dart' show R;

/// Bridges Riverpod state into go_router's `refreshListenable`, so signing in
/// or out re-evaluates the guard immediately rather than on the next
/// navigation.
class _SessionRefresh extends ChangeNotifier {
  _SessionRefresh(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: R.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(sessionProvider) != null;
      final onAuth = R.isAuthRoute(state.matchedLocation);
      if (!signedIn && !onAuth) return R.signIn;
      if (signedIn && onAuth) return R.dashboard;
      return null;
    },
    errorBuilder: (context, state) => NotFoundScreen(location: state.uri.path),
    routes: [
      GoRoute(path: R.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: R.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: R.forgot, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: R.otp, builder: (_, _) => const OtpScreen()),
      GoRoute(path: R.lock, builder: (_, _) => const LockScreen()),

      // Everything below renders inside the persistent shell: the sidebar and
      // top bar survive navigation instead of rebuilding on every route.
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: R.dashboard,
            builder: (_, _) => const DashboardScreen(),
          ),
          // One list / new / detail / edit set per resource. `new` is declared
          // before `:id` so it is matched as a literal rather than an id.
          for (final resource in const ['orders', 'customers', 'products'])
            GoRoute(
              path: '/$resource',
              builder: (_, _) => ResourceListScreen(resource: resource),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, _) => ResourceFormScreen(resource: resource),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => ResourceDetailScreen(
                    resource: resource,
                    id: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => ResourceFormScreen(
                        resource: resource,
                        id: state.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          GoRoute(path: R.inbox, builder: (_, _) => const InboxScreen()),
          GoRoute(path: R.kanban, builder: (_, _) => const KanbanScreen()),
          GoRoute(path: R.calendar, builder: (_, _) => const CalendarScreen()),
          GoRoute(path: R.chat, builder: (_, _) => const ChatScreen()),
          GoRoute(
            path: R.components,
            builder: (_, _) => const ComponentsScreen(),
          ),
          GoRoute(path: R.forms, builder: (_, _) => const FormsScreen()),
          GoRoute(path: R.wizard, builder: (_, _) => const WizardScreen()),
          GoRoute(
            path: R.projects,
            builder: (_, _) => const ProjectDashboardScreen(),
          ),
          GoRoute(path: R.settings, builder: (_, _) => const SettingsScreen()),
          GoRoute(path: R.profile, builder: (_, _) => const ProfileScreen()),
          GoRoute(
            path: R.serverError,
            builder: (_, _) => const ServerErrorScreen(),
          ),
        ],
      ),
    ],
  );
});
