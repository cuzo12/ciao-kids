import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

/// Email/password sign-in screen.
///
/// Reads [AuthController] via `provider`: it watches [AuthController.busy] to
/// drive the button spinner and [AuthController.errorMessage] to surface
/// failures in a snackbar. On success, navigation is handled centrally by the
/// router's auth redirect — this screen never pushes `/home` itself.
class LoginScreen extends StatefulWidget {
  /// Creates the [LoginScreen].
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final AuthController auth = context.read<AuthController>();
    final bool ok = await auth.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!ok && mounted) {
      _showError(auth.errorMessage);
    }
  }

  Future<void> _guest() async {
    final AuthController auth = context.read<AuthController>();
    final bool ok = await auth.continueAsGuest();
    if (!ok && mounted) _showError(auth.errorMessage);
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Something went wrong.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when busy/error change.
    final bool busy = context.watch<AuthController>().busy;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      const AppLogo(size: 96),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Ciao! 👋',
                        textAlign: TextAlign.center,
                        style: text.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Sign in to keep learning Italian.',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: 'Email',
                        controller: _email,
                        hintText: 'parent@email.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        enabled: !busy,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Password',
                        controller: _password,
                        hintText: '••••••',
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        onSubmitted: (_) => _submit(),
                        enabled: !busy,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: 'Sign In',
                        icon: Icons.login,
                        isLoading: busy,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: busy ? null : _guest,
                        child: const Text('Continue as guest'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('New here?', style: text.bodyMedium),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => context.goNamed(Routes.signupName),
                            child: const Text('Create an account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
