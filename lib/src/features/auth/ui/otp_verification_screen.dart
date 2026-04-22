import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/custom_main_button.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/l10n/app_localizations.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Configurar el escucha de teclas directamente en el FocusNode para evitar conflictos
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[i].text.isEmpty &&
            i > 0) {
          _focusNodes[i - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      // Manejar el pegado (paste) de un código completo
      String pastedCode = value.trim();
      // Eliminar cualquier carácter que no sea un dígito
      pastedCode = pastedCode.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (pastedCode.length > 6) pastedCode = pastedCode.substring(0, 6);

      for (int i = 0; i < pastedCode.length; i++) {
        if (index + i < 6) {
          _controllers[index + i].text = pastedCode[i];
        }
      }

      // Mover el foco al último campo llenado o al final
      int nextFocusIndex = (index + pastedCode.length < 6)
          ? index + pastedCode.length
          : 5;
      _focusNodes[nextFocusIndex].requestFocus();

      // Si se pegaron 6 dígitos o se completó el total, intentar verificar automáticamente
      final fullOtp = _controllers.map((c) => c.text).join();
      if (fullOtp.length == 6) {
        _verifyOtp();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Si es el último dígito y se completaron los 6, verificar
        final fullOtp = _controllers.map((c) => c.text).join();
        if (fullOtp.length == 6) {
          _verifyOtp();
        }
      }
    }
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterSixDigits)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(widget.email, otp);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountVerifiedSuccess)),
        );

        if (authProvider.user?.role == 'admin') {
          context.go('/admin_home');
        } else {
          context.go('/home');
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidCode)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.verificationTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Icono de sobre con check
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 50,
                        color: colorScheme.primary,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                l10n.verifyAccount,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: l10n.verifyOtpSubtitle),
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // OTP Fields con Flexible para evitar overflow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6, // Permitir más para manejar el pegado
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.primary,
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
              const SizedBox(height: 50),
              // Button
              _isLoading
                  ? CircularProgressIndicator(color: colorScheme.primary)
                  : CustomMainButton(
                      text: l10n.verifyCodeButton,
                      onPressed: _verifyOtp,
                      color: colorScheme.primary,
                    ),
              const SizedBox(height: 30),
              // Resend text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.didNotReceiveCode,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthProvider>().resendOtp(widget.email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.codeResent)),
                      );
                    },
                    child: Text(
                      l10n.resendCode,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
