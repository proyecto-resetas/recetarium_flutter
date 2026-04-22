import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/core/widgets/custom_main_button.dart';
import 'package:resetas/l10n/app_localizations.dart';
import 'package:resetas/src/features/auth/models/login_request_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white light grey
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Logo in a circle with soft pink border
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/images/recetariumBorderLive.png', // Logo actual del proyecto
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 30),
              Text(
                l10n.welcome,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B2332), // Dark blue/black
                ),
              ),
              Text(
                l10n.loginToContinue,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280), // Grayish blue
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomIconInput(
                      controller: emailController,
                      label: l10n.email,
                      hintText: l10n.emailHint,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomIconInput(
                      controller: passwordController,
                      label: l10n.password,
                      hintText: l10n.passwordHint,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Acción olvidaste contraseña
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.forgotPassword,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomMainButton(
                      text: l10n.login,
                      icon: Icons.login, // Icono de puerta con flecha
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          LoginRequestModel loginRequestModel = LoginRequestModel(
                            email: emailController.text,
                            password: passwordController.text,
                          );

                          final success = await authProvider.login(loginRequestModel);
                          if (success) {
                            context.push('/otp_verification',
                                extra: emailController.text);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.loginFailed)),
                              );
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: Colors.grey.shade300, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            l10n.or,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                        context.push('/register');
                        },
                        child: RichText(
                          text: TextSpan(
                            text: '${l10n.noAccount} ',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: l10n.registerNow,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
