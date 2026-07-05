import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';
import '../bookings/bookings_notifier.dart';
import 'settings_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showStubNote(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.profileStubNotAvailable)),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditNameSheet(initial: current),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(sessionProvider.notifier).logIn(name);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final colors = context.appColors;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            0,
            AppSpacing.l,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.deleteAccountConfirmTitle,
                style: sheetContext.appTextStyles.title,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                l10n.deleteAccountConfirmMessage,
                style: sheetContext.appTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.l),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.danger,
                  foregroundColor: colors.onPrimary,
                ),
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: Text(l10n.deleteAccountConfirm),
              ),
              const SizedBox(height: AppSpacing.s),
              AppTonalButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: Text(l10n.deleteAccountKeep),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) {
      await ref.read(bookingsProvider.notifier).clearAll();
      // Dropping the session triggers the router redirect to /login.
      await ref.read(sessionProvider.notifier).logOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final userName = ref.watch(sessionProvider) ?? '';
    final isDark = switch (settings.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    final localeCode = settings.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    userName.isEmpty ? '?' : userName.characters.first,
                    style: context.appTextStyles.price,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: context.appTextStyles.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        _pseudoEmail(userName),
                        style: context.appTextStyles.bodySecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            _SettingRow(
              label: l10n.profileEditProfile,
              onTap: () => _editName(context, ref, userName),
              child: const _Chevron(),
            ),
            const SizedBox(height: AppSpacing.s),
            _SettingRow(
              label: l10n.profilePayments,
              onTap: () => _showStubNote(context),
              child: const _Chevron(),
            ),
            const SizedBox(height: AppSpacing.s),
            _SettingRow(
              label: l10n.profileNotifications,
              child: Switch(
                value: settings.notifications,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleNotifications(v),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            _SettingRow(
              label: l10n.profileDarkTheme,
              child: Switch(
                value: isDark,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleDark(v),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            _SettingRow(
              label: l10n.profileLanguage,
              child: _LanguageSwitch(
                selected: localeCode,
                onChanged: (code) =>
                    ref.read(settingsProvider.notifier).setLocale(code),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            _SettingRow(
              label: l10n.profileHelp,
              onTap: () => _showStubNote(context),
              child: const _Chevron(),
            ),
            const SizedBox(height: AppSpacing.l),
            AppTonalButton(
              onPressed: () => ref.read(sessionProvider.notifier).logOut(),
              child: Text(l10n.profileLogout),
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: colors.danger),
              onPressed: () => _deleteAccount(context, ref),
              child: Text(l10n.profileDeleteAccount),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fake by design, like the rest of the data: there is no real account, so
/// the "email" is derived from the entered name.
String _pseudoEmail(String name) {
  final slug = name
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .join('.');
  return slug.isEmpty ? 'player@courtly.app' : '$slug@courtly.app';
}

/// Bordered card row from the design: label left, control right.
class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.child, this.onTap});

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.m),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: context.appTextStyles.body),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Icon(
        Icons.chevron_right,
        size: 20,
        color: context.appColors.textSecondary,
      ),
    );
  }
}

/// EN | RU segmented control from the design.
class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in const ['en', 'ru'])
            Material(
              color: selected == code ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.s - 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.s - 2),
                onTap: () => onChanged(code),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs + AppSpacing.xs / 2,
                  ),
                  child: Text(
                    code.toUpperCase(),
                    style: context.appTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected == code
                          ? colors.onPrimary
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({required this.initial});

  final String initial;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      // Keeps the sheet above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            0,
            AppSpacing.l,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.editProfileTitle,
                style: context.appTextStyles.title,
              ),
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(hintText: l10n.loginNameHint),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: AppSpacing.m),
              FilledButton(
                onPressed: _save,
                child: Text(l10n.editProfileSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
