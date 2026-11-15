import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/l10n/app_localizations.dart';
import 'package:recetarium/src/core/widgets/custom_back_app_bar.dart';
import 'package:recetarium/src/features/auth/data/auth_provider.dart';
import 'package:recetarium/src/features/user_profile/models/user_model.dart';
import 'package:recetarium/src/features/user_profile/ui/widgets/profile_modals.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  static const Color _bgPage = Color(0xFFF8F9FA);
  static const Color _dangerColor = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().refreshUserProfile();
    });
  }

  String _fullName(UserResModel user) {
    final full = '${user.username} ${user.lastname}'.trim();
    if (full.isNotEmpty) return full;
    if (user.email.isNotEmpty) return user.email.split('@').first;
    return 'Usuario';
  }

  String _locationSummary(UserResModel user) {
    final parts = [
      user.city.trim(),
      user.country.trim(),
    ].where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Sin ubicación';
  }

  String _phoneSummary(UserResModel user) {
    final phone = user.phone.trim();
    return phone.isNotEmpty ? phone : 'Sin teléfono';
  }

  bool _hasBankAccount(UserResModel user) {
    final bank = user.bankAccount;
    if (bank == null) return false;
    final bankName = (bank['bankName'] ?? '').toString().trim();
    final accNum = (bank['accountNumber'] ?? '').toString().trim();
    return bankName.isNotEmpty && accNum.isNotEmpty;
  }

  String _bankAccountSubtitle(UserResModel user) {
    if (!_hasBankAccount(user)) {
      return 'Recibir pagos y transferencias';
    }
    final bank = user.bankAccount!;
    final bankName = (bank['bankName'] ?? '').toString().trim();
    final accountType = (bank['accountType'] ?? 'Ahorros').toString().trim();
    final rawNumber = (bank['accountNumber'] ?? '').toString().trim();
    final last4 = rawNumber.length >= 4
        ? rawNumber.substring(rawNumber.length - 4)
        : rawNumber;
    return '$bankName • $accountType ****$last4';
  }

  String _billingSubtitle(UserResModel user) {
    final billing = user.billingInfo;
    if (billing == null) {
      return 'Identificación fiscal, régimen y dirección';
    }
    final docType = (billing['documentType'] ?? '').toString().trim();
    final docNum = (billing['documentNumber'] ?? '').toString().trim();
    final regime = (billing['taxRegime'] ?? '').toString().trim();
    if (docNum.isEmpty) {
      return 'Identificación fiscal, régimen y dirección';
    }
    final prefix = docType.isNotEmpty ? '$docType $docNum' : docNum;
    return regime.isNotEmpty ? '$prefix • $regime' : prefix;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return Scaffold(
        backgroundColor: _bgPage,
        body: SafeArea(
          child: Center(child: Text(l10n.noUserInfo)),
        ),
      );
    }

    final bankActive = _hasBankAccount(user);

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: CustomBackAppBar(
        backgroundColor: _bgPage,
        title: l10n.myProfile,
        onBack: () => context.pop(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => showPersonalDataSheet(context, authProvider, user),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(context, authProvider, user, l10n),
                  const SizedBox(height: 24),
                  _buildSectionTitle(colors, 'CUENTA Y SEGURIDAD'),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    colors: colors,
                    children: [
                      _buildProfileItem(
                        colors: colors,
                        icon: Icons.person_outline_rounded,
                        iconBg: colors.secondary.withValues(alpha: 0.1),
                        iconColor: colors.secondary,
                        title: 'Datos personales',
                        subtitle: 'Nombre, teléfono y ubicación',
                        onTap: () => showPersonalDataSheet(
                          context,
                          authProvider,
                          user,
                        ),
                      ),
                      _buildDivider(colors),
                      _buildProfileItem(
                        colors: colors,
                        icon: Icons.lock_outline_rounded,
                        iconBg: colors.primary.withValues(alpha: 0.14),
                        iconColor: colors.primary,
                        title: 'Cambiar contraseña',
                        subtitle: 'Actualizar clave con código OTP',
                        onTap: () => context.push(
                          '/forgot_password',
                          extra: user.email,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(colors, 'PAGOS Y FACTURACIÓN'),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    colors: colors,
                    children: [
                      _buildProfileItem(
                        colors: colors,
                        icon: Icons.account_balance_rounded,
                        iconBg: const Color(0xFFDCFCE7),
                        iconColor: const Color(0xFF15803D),
                        title: 'Cuenta bancaria',
                        subtitle: _bankAccountSubtitle(user),
                        badgeText: bankActive ? 'Activa' : null,
                        onTap: () => showBankAccountSheet(
                          context,
                          authProvider,
                          user,
                        ),
                      ),
                      _buildDivider(colors),
                      _buildProfileItem(
                        colors: colors,
                        icon: Icons.receipt_long_rounded,
                        iconBg: colors.primary.withValues(alpha: 0.14),
                        iconColor: colors.secondary,
                        title: 'Datos de facturación',
                        subtitle: _billingSubtitle(user),
                        onTap: () => showBillingInfoSheet(
                          context,
                          authProvider,
                          user,
                        ),
                      ),
                    ],
                  ),
                  if (user.role == 'super_admin') ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(colors, 'ADMINISTRACIÓN'),
                    const SizedBox(height: 10),
                    _buildAdminCard(context, colors),
                  ],
                  const SizedBox(height: 28),
                  Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          _confirmLogout(context, colors, authProvider),
                      style: TextButton.styleFrom(
                        foregroundColor: _dangerColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: _dangerColor,
                      ),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _dangerColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    AuthProvider authProvider,
    UserResModel user,
    AppLocalizations l10n,
  ) {
    final colors = Theme.of(context).colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.62);
    final roleLabel = user.role == 'super_admin'
        ? 'Super Administrador'
        : user.role == 'admin'
            ? 'Chef Creador'
            : l10n.chefAmateur;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.secondary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showPersonalDataSheet(context, authProvider, user),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.45),
                      width: 2.2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: colors.primary.withValues(alpha: 0.14),
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: user.photoUrl.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: colors.secondary,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _fullName(user),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 15,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      roleLabel,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (user.role == 'super_admin')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 13,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'SUPER ADMIN',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 15,
                color: muted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _locationSummary(user),
                    style: TextStyle(
                      fontSize: 13,
                      color: muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '•',
                style: TextStyle(color: muted, fontSize: 13),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _phoneSummary(user),
                    style: TextStyle(
                      fontSize: 13,
                      color: muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ColorScheme colors, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          color: colors.secondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ColorScheme colors,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.secondary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(ColorScheme colors) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: colors.secondary.withValues(alpha: 0.08),
    );
  }

  Widget _buildProfileItem({
    required ColorScheme colors,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: colors.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.secondary.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, ColorScheme colors) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/super_admin'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.secondary.withValues(alpha: 0.2),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shield_outlined,
                color: colors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panel de administración',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gestión global de la plataforma',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    ColorScheme colors,
    AuthProvider authProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _dangerColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: _dangerColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¿Cerrar sesión?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Tendrás que volver a ingresar con tu correo y código de verificación.',
          style: TextStyle(
            fontSize: 14,
            color: colors.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: colors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      authProvider.logout();
      context.go('/login');
    }
  }
}
