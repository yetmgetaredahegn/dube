import 'package:flutter/material.dart';
import 'package:dube/core/theme/app_theme.dart';

/// Bottom navigation scaffold that wraps Dashboard, Customers, Reports, Settings.
class BottomNavShell extends StatefulWidget {
  final int currentIndex;
  final Widget child;
  final void Function(int index) onTabChanged;

  const BottomNavShell({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.onTabChanged,
  });

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onTabChanged,
              elevation: 0,
              backgroundColor: Colors.transparent,
              selectedItemColor: DubeTheme.primary,
              unselectedItemColor: const Color(0xFFADB5BD),
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people_rounded),
                  label: 'Customers',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart_rounded),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
