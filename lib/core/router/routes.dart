import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Route paths in one place so the router, the sidebar and every `context.go`
/// call agree. Typed constants rather than string literals scattered around.
abstract final class R {
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgot = '/forgot-password';
  static const otp = '/verify';
  static const lock = '/lock';

  static const dashboard = '/';
  static const projects = '/projects';
  static const serverError = '/500';
  static const orders = '/orders';
  static const customers = '/customers';
  static const products = '/products';
  static const inbox = '/inbox';
  static const kanban = '/board';
  static const calendar = '/calendar';
  static const chat = '/chat';
  static const components = '/components';
  static const forms = '/forms';
  static const wizard = '/wizard';
  static const settings = '/settings';
  static const profile = '/profile';

  static bool isAuthRoute(String location) =>
      location.startsWith(signIn) ||
      location.startsWith(signUp) ||
      location.startsWith(forgot) ||
      location.startsWith(otp) ||
      location.startsWith(lock);
}

@immutable
class NavItem {
  const NavItem(this.labelOf, this.path, this.icon, {this.inSidebar = true});

  final String Function(L l) labelOf; 
  final String path;
  final IconData icon;

  /// Whether the sidebar lists this item.
  ///
  /// Profile is reachable from the account menu, where people look for it, and
  /// listing it again under "Build" both mis-grouped it and pushed the last
  /// real nav row under the promo card. It stays here so the command palette
  /// and the page-title lookup still resolve it.
  final bool inSidebar;
}

/// The sidebar on desktop, the bottom bar on mobile — same source, so the two
/// can never drift apart.
///
/// Grouped rather than flat: eleven undifferentiated rows is a list to read,
/// four labelled groups is a structure to scan.
@immutable
class NavGroup {
  const NavGroup(this.labelOf, this.items);
  final String Function(L l) labelOf; 
  final List<NavItem> items;
}

final kNavGroups = <NavGroup>[
  NavGroup((l) => l.navOverview, [
    NavItem((l) => l.navDashboard, R.dashboard, Icons.dashboard_outlined),
    NavItem((l) => l.navProjects, R.projects, Icons.track_changes_outlined),
  ]),
  NavGroup((l) => l.navManage, [
    NavItem((l) => l.navOrders, R.orders, Icons.receipt_long_outlined),
    NavItem((l) => l.navCustomers, R.customers, Icons.people_outline),
    NavItem((l) => l.navProducts, R.products, Icons.inventory_2_outlined),
  ]),
  NavGroup((l) => l.navApps, [
    NavItem((l) => l.navInbox, R.inbox, Icons.mail_outline),
    NavItem((l) => l.navBoard, R.kanban, Icons.view_kanban_outlined),
    NavItem((l) => l.navCalendar, R.calendar, Icons.calendar_today_outlined),
    NavItem((l) => l.navChat, R.chat, Icons.chat_bubble_outline),
  ]),
  NavGroup((l) => l.navBuild, [
    NavItem((l) => l.navComponents, R.components, Icons.widgets_outlined),
    NavItem((l) => l.navForms, R.forms, Icons.edit_note_outlined),
    NavItem((l) => l.navWizard, R.wizard, Icons.linear_scale_outlined),
    NavItem((l) => l.navSettings, R.settings, Icons.settings_outlined),
    NavItem((l) => l.navProfile, R.profile, Icons.person_outline, inSidebar: false),
  ]),
];

/// Flattened, for the mobile bottom bar and for resolving the page title.
final kNav = [for (final g in kNavGroups) ...g.items];
