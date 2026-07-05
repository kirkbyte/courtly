import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.loginNameEmpty);
      return;
    }
    // Router redirect navigates away once the session appears.
    await ref.read(sessionProvider.notifier).logIn(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Container(
            height: 280,
            width: double.infinity,
            color: colors.surfaceAlt,
            alignment: Alignment.center,
            child: const SafeArea(bottom: false, child: _CourtIllustration()),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.s),
                  Text(l10n.loginTitle, style: context.appTextStyles.headline),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    l10n.loginSubtitle,
                    style: context.appTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.loginNameHint,
                      errorText: _error,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.loginButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Court line-drawing from the login mockup: outer lines, net, service lines.
class _CourtIllustration extends StatelessWidget {
  const _CourtIllustration();

  @override
  Widget build(BuildContext context) {
    final primary = context.appColors.primary;
    return SizedBox(
      width: 220,
      height: 140,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 109,
            child: Container(width: 2, color: primary),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 28,
            child: Container(height: 2, color: primary),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Container(height: 2, color: primary),
          ),
        ],
      ),
    );
  }
}
