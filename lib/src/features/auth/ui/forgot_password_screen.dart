import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/core/widgets/custom_main_button.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // 0: Ingresar email, 1: Verificar OTP, 2: Nueva contraseña
  int _currentStep = 0;
  bool _isLoading = false;

  late final TextEditingController _emailController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);

    for (int i = 0; i < 6; i++) {
      _otpFocusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _otpControllers[i].text.isEmpty &&
            i > 0) {
          _otpFocusNodes[i - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      String pasted = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (pasted.length > 6) pasted = pasted.substring(0, 6);

      for (int i = 0; i < pasted.length; i++) {
        if (index + i < 6) {
          _otpControllers[index + i].text = pasted[i];
        }
      }

      final nextIdx =
          (index + pasted.length < 6) ? index + pasted.length : 5;
      _otpFocusNodes[nextIdx].requestFocus();

      final fullOtp = _otpControllers.map((c) => c.text).join();
      if (fullOtp.length == 6) {
        _handleVerifyOtp();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        final fullOtp = _otpControllers.map((c) => c.text).join();
        if (fullOtp.length == 6) {
          _handleVerifyOtp();
        }
      }
    }
  }

  Future<void> _handleSendCode() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final success = await authProvider.forgotPassword(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Te enviamos un código de 6 dígitos a tu correo electrónico.',
            ),
          ),
        );
      setState(() => _currentStep = 1);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'No pudimos enviar el código. Verifica tu correo e inténtalo de nuevo.',
            ),
          ),
        );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join().trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Ingresa los 6 dígitos del código de verificación.'),
          ),
        );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyRecoveryOtp(
      _emailController.text.trim(),
      otp,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Código verificado. Ahora crea tu nueva contraseña.'),
          ),
        );
      setState(() => _currentStep = 2);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Código inválido o expirado. Verifica e inténtalo nuevamente.',
            ),
          ),
        );
    }
  }

  Future<void> _handleResetPassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              '¡Contraseña actualizada con éxito! Ya puedes iniciar sesión.',
            ),
          ),
        );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'No se pudo actualizar la contraseña. Inténtalo de nuevo.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.secondary),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Recuperar contraseña',
          style: TextStyle(
            color: colors.secondary,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Indicador de Pasos (1 -> 2 -> 3) ─────────────────────────
              _buildStepHeader(colors),
              const SizedBox(height: 28),

              // ─── Tarjeta del Paso Activo ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildCurrentStepContent(colors),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(ColorScheme colors) {
    final steps = [
      (index: 0, label: 'Correo', icon: Icons.mail_outline_rounded),
      (index: 1, label: 'Código OTP', icon: Icons.pin_outlined),
      (index: 2, label: 'Nueva clave', icon: Icons.lock_reset_rounded),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isActive = _currentStep == step.index;
        final isCompleted = _currentStep > step.index;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? colors.primary.withValues(alpha: 0.15)
                    : isCompleted
                        ? colors.tertiary.withValues(alpha: 0.12)
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? colors.primary.withValues(alpha: 0.5)
                      : isCompleted
                          ? colors.tertiary.withValues(alpha: 0.4)
                          : colors.secondary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle_rounded : step.icon,
                    size: 15,
                    color: isActive
                        ? colors.primary
                        : isCompleted
                            ? colors.tertiary
                            : colors.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isCompleted
                          ? colors.tertiary
                          : colors.secondary.withValues(
                              alpha: isActive ? 1.0 : 0.6,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < steps.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: colors.secondary.withValues(alpha: 0.35),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentStepContent(ColorScheme colors) {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep(colors);
      case 1:
        return _buildOtpStep(colors);
      case 2:
        return _buildNewPasswordStep(colors);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmailStep(ColorScheme colors) {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey('step_email'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 34,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '¿Olvidaste tu contraseña?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa el correo asociado a tu cuenta de Recetarium y te enviaremos un código de 6 dígitos para restablecerla.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          CustomIconInput(
            controller: _emailController,
            label: 'Correo electrónico',
            hintText: 'ejemplo@correo.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: colors.primary),
                )
              : CustomMainButton(
                  text: 'Enviar código de recuperación',
                  icon: Icons.send_rounded,
                  onPressed: _handleSendCode,
                ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(ColorScheme colors) {
    return Column(
      key: const ValueKey('step_otp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 34,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Verifica tu código',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'Ingresa el código de 6 dígitos enviado a\n',
              ),
              TextSpan(
                text: _emailController.text.trim(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.secondary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: colors.secondary.withValues(alpha: 0.06),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colors.secondary.withValues(alpha: 0.14),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => _onOtpChanged(value, index),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(color: colors.primary),
              )
            : CustomMainButton(
                text: 'Verificar código',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _handleVerifyOtp,
              ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No recibiste el código?',
              style: TextStyle(
                fontSize: 13.5,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _handleSendCode,
              child: Text(
                'Reenviar código',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep(ColorScheme colors) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        key: const ValueKey('step_password'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.tertiary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 36,
                color: colors.tertiary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Crea tu nueva contraseña',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige una contraseña segura de al menos 6 caracteres para proteger tu cuenta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          CustomIconInput(
            controller: _newPasswordController,
            label: 'Nueva contraseña',
            hintText: 'Mínimo 6 caracteres',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu nueva contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          CustomIconInput(
            controller: _confirmPasswordController,
            label: 'Confirmar nueva contraseña',
            hintText: 'Repite tu nueva contraseña',
            prefixIcon: Icons.lock_person_outlined,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu nueva contraseña';
              }
              if (value != _newPasswordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: colors.primary),
                )
              : CustomMainButton(
                  text: 'Actualizar contraseña',
                  icon: Icons.save_outlined,
                  onPressed: _handleResetPassword,
                ),
        ],
      ),
    );
  }
}
