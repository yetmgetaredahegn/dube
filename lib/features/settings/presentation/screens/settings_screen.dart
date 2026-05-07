import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dube/core/theme/app_theme.dart';
import 'package:dube/features/auth/providers/auth_notifier.dart';
import 'package:dube/shared/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: DubeSpacing.screenPadding,
        children: [
          // ── Profile card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DubeTheme.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: DubeTheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Shop Owner',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Shop Owner',
                        style: DubeText.bodyMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Menu items ────────────────────────────────────────
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Dube',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Dube',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Dube Team',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Credit management system for local shops and mini-markets.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
            subtitle: 'Your data is isolated to your account',
            onTap: () {},
          ),
          const SizedBox(height: 32),

          // ── Sign out ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content:
                        const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authNotifierProvider.notifier).signOut();
                }
              },
              icon: const Icon(Icons.logout, color: DubeTheme.danger),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: DubeTheme.danger),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: DubeTheme.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: DubeTheme.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: DubeText.bodyMuted),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCED4DA)),
          ],
        ),
      ),
    );
  }
}
