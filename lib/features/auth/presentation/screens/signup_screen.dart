import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

/// Account creation screen.
///
/// Collects the child's name, age (5–15), and the parent's email/password, then
/// delegates to [AuthController.signUp]. Like the login screen, success
/// navigation is handled by the router's auth redirect.
class SignupScreen extends StatefulWidget {
  /// Creates the [SignupScreen].
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final AuthController auth = context.read<AuthController>();
    final bool ok = await auth.signUp(
      displayName: _name.text,
      email: _email.text,
      password: _password.text,
      childAge: int.parse(_age.text.trim()),
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not sign up.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool busy = context.watch<AuthController>().busy;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: busy ? null : () => context.goNamed(Routes.loginName),
        ),
      ),
      extendBodyBehindAppBar: true,
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
                      Text(
                        'Create your account',
                        textAlign: TextAlign.center,
                        style: text.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'A grown-up sets this up. It takes a minute!',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: "Child's name",
                        controller: _name,
                        hintText: 'Sofia',
                        icon: Icons.face_outlined,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: Validators.name,
                        enabled: !busy,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Age',
                        controller: _age,
                        hintText: '5 to 15',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: Validators.childAge,
                        enabled: !busy,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Parent email',
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
                        hintText: 'At least 6 characters',
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        onSubmitted: (_) => _submit(),
                        enabled: !busy,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: 'Create Account',
                        icon: Icons.celebration_outlined,
                        isLoading: busy,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Already have one?', style: text.bodyMedium),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => context.goNamed(Routes.loginName),
                            child: const Text('Sign in'),
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
