import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/user_profile/models/user.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/core/widgets/custom_text_field.dart';
import 'package:resetas/src/core/widgets/custom_main_button.dart';
import 'package:resetas/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedRole = 'user';
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => context.pop(),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuAgXsgbsrTsjbx0SOYL6Ofl6_HkIzB1Sa9L9KTkMTTa8uxqQwdtgMJkJcf5Ux5wupKZLaIBOWjOd4bUOt1T-FFU3elPsG1DMl12Ooi9ANQZhmPkOb8s9sh2uWr4LFC9lM2tjsPtqJrMvH6q-lFkQqkIDgpWqhoQKj0oP7uXQjVB5Y-snZ32aXU5baVhKBOHzax13aD1L53bw3WD2cd9SVYfz9xVBowfzup65u44GilhLtPkOjEOb70C_JDGc1dzCR6xUKPfeppEccs"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFFF8F9FA).withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    l10n.registerTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B2332),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.registerSubtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: firstNameController,
                          label: l10n.fullName,
                          hintText: 'Ej. Juan',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: lastNameController,
                          label: l10n.lastName,
                          hintText: 'Ej. Pérez',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterLastName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: emailController,
                          label: l10n.email,
                          hintText: 'tu@email.com',
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
                        CustomTextField(
                          controller: passwordController,
                          label: l10n.password,
                          hintText: '........',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterPassword;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: confirmPasswordController,
                          label: l10n.confirmPassword,
                          hintText: '........',
                          prefixIcon: Icons.shield_outlined,
                          isPassword: true,
                          validator: (value) {
                            if (value != passwordController.text) {
                              return l10n.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Role Selection Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.whoDoYouWantToBe,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0)),
                                ),
                              ),
                              items: ['user', 'chef'].map((String role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Terms checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              activeColor: colorScheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                l10n.acceptTerms,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        CustomMainButton(
                          text: l10n.registerButton,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (!_acceptTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.mustAcceptTerms)),
                                );
                                return;
                              }
                              User credentials = User(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                userName: firstNameController.text,
                                lastName: lastNameController.text,
                                countryCode: '+57',
                                phoneNumber:
                                    '3001234567', // Ejemplo para probar
                                country: 'Colombia',
                                city: 'Bogotá',
                                role: _selectedRole!,
                              );

                              bool success =
                                  await authProvider.register(credentials);

                              if (success) {
                                if (mounted) {
                                  if (authProvider.user?.role == 'admin') {
                                    Navigator.pushReplacementNamed(
                                        context, '/admin_home');
                                  } else {
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  }
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(l10n.registrationFailed)),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                l10n.alreadyHaveAccount,
                                style: const TextStyle(
                                    color: Color(0xFF6B7280), fontSize: 15),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                },
                                child: Text(
                                  l10n.loginHere,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
