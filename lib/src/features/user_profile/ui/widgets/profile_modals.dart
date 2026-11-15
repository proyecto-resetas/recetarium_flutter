import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recetarium/src/core/utils/input_sanitizers.dart';
import 'package:recetarium/src/core/widgets/custom_icon_input.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/core/widgets/custom_select_field.dart';
import 'package:recetarium/src/features/auth/data/auth_provider.dart';
import 'package:recetarium/src/features/user_profile/models/user_model.dart';

/// Abre el modal para editar foto, nombre, teléfono y ubicación del usuario.
Future<void> showPersonalDataSheet(
  BuildContext context,
  AuthProvider authProvider,
  UserResModel user,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PersonalDataSheetBody(
      parentContext: context,
      authProvider: authProvider,
      user: user,
    ),
  );
}

/// Abre el modal para configurar la cuenta bancaria del usuario.
Future<void> showBankAccountSheet(
  BuildContext context,
  AuthProvider authProvider,
  UserResModel user,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BankAccountSheetBody(
      parentContext: context,
      authProvider: authProvider,
      user: user,
    ),
  );
}

/// Abre el modal para configurar los datos fiscales y de facturación.
Future<void> showBillingInfoSheet(
  BuildContext context,
  AuthProvider authProvider,
  UserResModel user,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BillingInfoSheetBody(
      parentContext: context,
      authProvider: authProvider,
      user: user,
    ),
  );
}

String _displayFullName(UserResModel user) {
  final full = '${user.username} ${user.lastname}'.trim();
  if (full.isNotEmpty) return full;
  if (user.email.isNotEmpty) return user.email.split('@').first;
  return 'Usuario';
}

void _showFeedbackSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required bool isSuccess,
}) {
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          isSuccess ? const Color(0xFF16A34A) : const Color(0xFFE53935),
    ),
  );
}

class _ProfileSheetFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final List<Widget> children;

  const _ProfileSheetFrame({
    required this.title,
    required this.subtitle,
    required this.onClose,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colors.secondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.secondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// MODAL 1: DATOS PERSONALES
// ===========================================================================
class _PersonalDataSheetBody extends StatefulWidget {
  final BuildContext parentContext;
  final AuthProvider authProvider;
  final UserResModel user;

  const _PersonalDataSheetBody({
    required this.parentContext,
    required this.authProvider,
    required this.user,
  });

  @override
  State<_PersonalDataSheetBody> createState() => _PersonalDataSheetBodyState();
}

class _PersonalDataSheetBodyState extends State<_PersonalDataSheetBody> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _lastnameCtrl;
  late final TextEditingController _countryCodeCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _countryCtrl;

  XFile? _pickedPhoto;
  Uint8List? _pickedPhotoBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _lastnameCtrl = TextEditingController(text: widget.user.lastname);

    String initialCode = '+57';
    String initialPhone = widget.user.phone.trim();
    if (initialPhone.startsWith('+')) {
      final parts = initialPhone.split(' ');
      if (parts.length > 1) {
        initialCode = parts.first;
        initialPhone = parts.sublist(1).join(' ');
      }
    }

    _countryCodeCtrl = TextEditingController(text: initialCode);
    _phoneCtrl = TextEditingController(text: initialPhone);
    _cityCtrl = TextEditingController(text: widget.user.city);
    _countryCtrl = TextEditingController(
      text: widget.user.country.isNotEmpty ? widget.user.country : 'Colombia',
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _lastnameCtrl.dispose();
    _countryCodeCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedPhoto = file;
        _pickedPhotoBytes = bytes;
      });
    }
  }

  Future<void> _saveChanges() async {
    final messenger = ScaffoldMessenger.of(widget.parentContext);
    if (_usernameCtrl.text.trim().isEmpty) {
      _showFeedbackSnackBar(
        messenger,
        message: 'El nombre es obligatorio',
        isSuccess: false,
      );
      return;
    }
    setState(() => _isSaving = true);

    final payload = <String, dynamic>{
      'username': _usernameCtrl.text.trim(),
      'lastname': _lastnameCtrl.text.trim(),
      'phone': {
        'countryCode': _countryCodeCtrl.text.trim().isNotEmpty
            ? _countryCodeCtrl.text.trim()
            : '+57',
        'phoneNumber': _phoneCtrl.text.trim(),
      },
      'city': _cityCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
    };

    final ok = await widget.authProvider.updateProfile(
      payload,
      newPhoto: _pickedPhoto,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.of(context).pop();
      _showFeedbackSnackBar(
        messenger,
        message: 'Datos personales actualizados',
        isSuccess: true,
      );
    } else {
      _showFeedbackSnackBar(
        messenger,
        message: 'No se pudieron guardar los cambios',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _ProfileSheetFrame(
      title: 'Datos personales',
      subtitle: 'Actualiza tu foto, nombre, teléfono y ubicación',
      onClose: () => Navigator.of(context).pop(),
      children: [
        Center(
          child: GestureDetector(
            onTap: _isSaving ? null : _pickProfileImage,
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: colors.primary.withValues(alpha: 0.14),
                      backgroundImage: _pickedPhotoBytes != null
                          ? MemoryImage(_pickedPhotoBytes!)
                          : (widget.user.photoUrl.isNotEmpty
                              ? NetworkImage(widget.user.photoUrl)
                                  as ImageProvider
                              : null),
                      child: (_pickedPhotoBytes == null &&
                              widget.user.photoUrl.isEmpty)
                          ? Icon(
                              Icons.person_rounded,
                              size: 42,
                              color: colors.secondary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: CustomIconInput(
                controller: _usernameCtrl,
                label: 'Nombre',
                hintText: 'Ej: Mateo',
                prefixIcon: Icons.person_outline_rounded,
                maxLength: 50,
                inputFormatters: InputSanitizers.safeText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomIconInput(
                controller: _lastnameCtrl,
                label: 'Apellido',
                hintText: 'Ej: Restrepo',
                prefixIcon: Icons.badge_outlined,
                maxLength: 50,
                inputFormatters: InputSanitizers.safeText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 96,
              child: CustomIconInput(
                controller: _countryCodeCtrl,
                label: 'Indicativo',
                hintText: '+57',
                keyboardType: TextInputType.phone,
                maxLength: 5,
                inputFormatters: InputSanitizers.phoneCode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomIconInput(
                controller: _phoneCtrl,
                label: 'Teléfono móvil',
                hintText: '3001234567',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.number,
                maxLength: 15,
                inputFormatters: InputSanitizers.digitsOnly,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: CustomIconInput(
                controller: _cityCtrl,
                label: 'Ciudad',
                hintText: 'Ej: Medellín',
                prefixIcon: Icons.location_city_rounded,
                maxLength: 60,
                inputFormatters: InputSanitizers.safeText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomIconInput(
                controller: _countryCtrl,
                label: 'País',
                hintText: 'Ej: Colombia',
                prefixIcon: Icons.public_rounded,
                maxLength: 60,
                inputFormatters: InputSanitizers.safeText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        CustomMainButton(
          text: 'Guardar cambios',
          icon: Icons.check_rounded,
          height: 52,
          isLoading: _isSaving,
          onPressed: _saveChanges,
        ),
      ],
    );
  }
}

// ===========================================================================
// MODAL 2: CUENTA BANCARIA
// ===========================================================================
class _BankAccountSheetBody extends StatefulWidget {
  final BuildContext parentContext;
  final AuthProvider authProvider;
  final UserResModel user;

  const _BankAccountSheetBody({
    required this.parentContext,
    required this.authProvider,
    required this.user,
  });

  @override
  State<_BankAccountSheetBody> createState() => _BankAccountSheetBodyState();
}

class _BankAccountSheetBodyState extends State<_BankAccountSheetBody> {
  static const List<String> _popularBanks = [
    'Bancolombia',
    'Davivienda',
    'Nequi',
    'Daviplata',
    'Banco de Bogotá',
    'BBVA',
    'Nu',
    'Lulo Bank',
  ];

  static const List<String> _accountTypes = [
    'Ahorros',
    'Corriente',
    'Depósito electrónico',
  ];

  static const List<String> _documentTypes = [
    'CC',
    'CE',
    'NIT',
    'Pasaporte',
    'TI',
  ];

  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _accountNumberCtrl;
  late final TextEditingController _holderNameCtrl;
  late final TextEditingController _documentNumberCtrl;
  late String _accountType;
  late String _documentType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.user.bankAccount ?? <String, dynamic>{};
    _bankNameCtrl = TextEditingController(
      text: (existing['bankName'] ?? '').toString(),
    );
    _accountNumberCtrl = TextEditingController(
      text: (existing['accountNumber'] ?? '').toString(),
    );
    _holderNameCtrl = TextEditingController(
      text: (existing['holderName'] ?? _displayFullName(widget.user)).toString(),
    );
    _documentNumberCtrl = TextEditingController(
      text: (existing['documentNumber'] ?? '').toString(),
    );

    final rawAccType = (existing['accountType'] ?? 'Ahorros').toString();
    _accountType =
        _accountTypes.contains(rawAccType) ? rawAccType : 'Ahorros';

    final rawDocType = (existing['documentType'] ?? 'CC').toString();
    _documentType =
        _documentTypes.contains(rawDocType) ? rawDocType : 'CC';
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _holderNameCtrl.dispose();
    _documentNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBank() async {
    final messenger = ScaffoldMessenger.of(widget.parentContext);
    if (_bankNameCtrl.text.trim().isEmpty ||
        _accountNumberCtrl.text.trim().isEmpty ||
        _holderNameCtrl.text.trim().isEmpty) {
      _showFeedbackSnackBar(
        messenger,
        message: 'Completa el banco, número de cuenta y titular',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isSaving = true);

    final ok = await widget.authProvider.updateProfile({
      'bankAccount': {
        'bankName': _bankNameCtrl.text.trim(),
        'accountType': _accountType,
        'accountNumber': _accountNumberCtrl.text.trim(),
        'holderName': _holderNameCtrl.text.trim(),
        'documentType': _documentType,
        'documentNumber': _documentNumberCtrl.text.trim(),
      },
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.of(context).pop();
      _showFeedbackSnackBar(
        messenger,
        message: 'Cuenta bancaria guardada correctamente',
        isSuccess: true,
      );
    } else {
      _showFeedbackSnackBar(
        messenger,
        message: 'Error al guardar la cuenta bancaria',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _ProfileSheetFrame(
      title: 'Cuenta bancaria',
      subtitle: 'Configura dónde recibirás tus pagos y transferencias',
      onClose: () => Navigator.of(context).pop(),
      children: [
        Text(
          'Selección rápida de entidad',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularBanks.map((bank) {
            final selected =
                _bankNameCtrl.text.trim().toLowerCase() == bank.toLowerCase();
            return ChoiceChip(
              label: Text(bank),
              selected: selected,
              selectedColor: colors.primary.withValues(alpha: 0.15),
              backgroundColor: Colors.white,
              checkmarkColor: colors.primary,
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: colors.secondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.5)
                      : colors.secondary.withValues(alpha: 0.14),
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _bankNameCtrl.text = bank;
                  if (bank == 'Nequi' || bank == 'Daviplata') {
                    _accountType = 'Depósito electrónico';
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        CustomIconInput(
          controller: _bankNameCtrl,
          label: 'Banco o entidad financiera',
          hintText: 'Ej: Bancolombia, Davivienda, Nequi...',
          prefixIcon: Icons.account_balance_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        CustomSelectField<String>(
          label: 'Tipo de cuenta',
          value: _accountType,
          prefixIcon: Icons.credit_card_rounded,
          items: _accountTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _accountType = val);
            }
          },
        ),
        const SizedBox(height: 14),
        CustomIconInput(
          controller: _accountNumberCtrl,
          label: 'Número de cuenta o celular',
          hintText: 'Ej: 01234567890',
          prefixIcon: Icons.numbers_rounded,
          keyboardType: TextInputType.number,
          maxLength: 24,
          inputFormatters: InputSanitizers.digitsOnly,
        ),
        const SizedBox(height: 14),
        CustomIconInput(
          controller: _holderNameCtrl,
          label: 'Nombre completo del titular',
          hintText: 'Como aparece en el banco',
          prefixIcon: Icons.person_outline_rounded,
          maxLength: 80,
          inputFormatters: InputSanitizers.safeText,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 118,
              child: CustomSelectField<String>(
                label: 'Documento',
                value: _documentType,
                items: _documentTypes
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _documentType = val);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomIconInput(
                controller: _documentNumberCtrl,
                label: 'Número de identificación',
                hintText: 'Ej: 1020304050',
                keyboardType: TextInputType.number,
                maxLength: 20,
                inputFormatters: InputSanitizers.digitsOnly,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        CustomMainButton(
          text: 'Guardar cuenta bancaria',
          icon: Icons.check_rounded,
          height: 52,
          isLoading: _isSaving,
          onPressed: _saveBank,
        ),
      ],
    );
  }
}

// ===========================================================================
// MODAL 3: DATOS DE FACTURACIÓN
// ===========================================================================
class _BillingInfoSheetBody extends StatefulWidget {
  final BuildContext parentContext;
  final AuthProvider authProvider;
  final UserResModel user;

  const _BillingInfoSheetBody({
    required this.parentContext,
    required this.authProvider,
    required this.user,
  });

  @override
  State<_BillingInfoSheetBody> createState() => _BillingInfoSheetBodyState();
}

class _BillingInfoSheetBodyState extends State<_BillingInfoSheetBody> {
  static const List<String> _personTypes = [
    'Persona Natural',
    'Persona Jurídica',
  ];

  static const List<String> _documentTypes = [
    'CC',
    'NIT',
    'CE',
    'Pasaporte',
    'RUT / ID Fiscal',
  ];

  static const List<String> _taxRegimes = [
    'No responsable de IVA',
    'Responsable de IVA',
    'Régimen Simple (RST)',
    'Gran Contribuyente',
  ];

  late String _personType;
  late String _documentType;
  late String _taxRegime;

  late final TextEditingController _docNumberCtrl;
  late final TextEditingController _businessNameCtrl;
  late final TextEditingController _invoiceEmailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _countryCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.user.billingInfo ?? <String, dynamic>{};

    final rawPerson = (existing['personType'] ?? 'Persona Natural').toString();
    _personType =
        _personTypes.contains(rawPerson) ? rawPerson : 'Persona Natural';

    final rawDoc = (existing['documentType'] ?? 'CC').toString();
    _documentType = _documentTypes.contains(rawDoc) ? rawDoc : 'CC';

    final rawRegime =
        (existing['taxRegime'] ?? 'No responsable de IVA').toString();
    _taxRegime =
        _taxRegimes.contains(rawRegime) ? rawRegime : 'No responsable de IVA';

    _docNumberCtrl = TextEditingController(
      text: (existing['documentNumber'] ?? '').toString(),
    );
    _businessNameCtrl = TextEditingController(
      text: (existing['businessName'] ?? _displayFullName(widget.user))
          .toString(),
    );
    _invoiceEmailCtrl = TextEditingController(
      text: (existing['invoiceEmail'] ?? widget.user.email).toString(),
    );
    _addressCtrl = TextEditingController(
      text: (existing['fiscalAddress'] ?? '').toString(),
    );
    _cityCtrl = TextEditingController(
      text: (existing['city'] ?? widget.user.city).toString(),
    );
    _countryCtrl = TextEditingController(
      text: (existing['country'] ??
              (widget.user.country.isNotEmpty
                  ? widget.user.country
                  : 'Colombia'))
          .toString(),
    );
  }

  @override
  void dispose() {
    _docNumberCtrl.dispose();
    _businessNameCtrl.dispose();
    _invoiceEmailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBilling() async {
    final messenger = ScaffoldMessenger.of(widget.parentContext);
    if (_docNumberCtrl.text.trim().isEmpty ||
        _businessNameCtrl.text.trim().isEmpty) {
      _showFeedbackSnackBar(
        messenger,
        message: 'Completa la identificación fiscal y razón social / nombre',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isSaving = true);

    final ok = await widget.authProvider.updateProfile({
      'billingInfo': {
        'personType': _personType,
        'documentType': _documentType,
        'documentNumber': _docNumberCtrl.text.trim(),
        'taxRegime': _taxRegime,
        'businessName': _businessNameCtrl.text.trim(),
        'fiscalAddress': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'invoiceEmail': _invoiceEmailCtrl.text.trim(),
      },
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.of(context).pop();
      _showFeedbackSnackBar(
        messenger,
        message: 'Datos de facturación actualizados',
        isSuccess: true,
      );
    } else {
      _showFeedbackSnackBar(
        messenger,
        message: 'Error al guardar los datos de facturación',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileSheetFrame(
      title: 'Datos de facturación',
      subtitle: 'Información fiscal y tributaria para emisión de facturas',
      onClose: () => Navigator.of(context).pop(),
      children: [
        CustomSelectField<String>(
          label: 'Tipo de contribuyente / persona',
          value: _personType,
          prefixIcon: Icons.person_search_rounded,
          items: _personTypes
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _personType = val;
                if (val == 'Persona Jurídica') {
                  _documentType = 'NIT';
                }
              });
            }
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 135,
              child: CustomSelectField<String>(
                label: 'Tipo ID',
                value: _documentType,
                items: _documentTypes
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(d, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _documentType = val);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomIconInput(
                controller: _docNumberCtrl,
                label: 'Número de documento / NIT',
                hintText: 'Ej: 900123456-1',
                keyboardType: TextInputType.number,
                maxLength: 20,
                inputFormatters: InputSanitizers.documentOrNit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomSelectField<String>(
          label: 'Régimen tributario',
          value: _taxRegime,
          prefixIcon: Icons.receipt_long_rounded,
          items: _taxRegimes
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _taxRegime = val);
            }
          },
        ),
        const SizedBox(height: 14),
        CustomIconInput(
          controller: _businessNameCtrl,
          label: _personType == 'Persona Jurídica'
              ? 'Razón social'
              : 'Nombre completo para facturación',
          hintText: 'Nombre o empresa',
          prefixIcon: Icons.business_rounded,
        ),
        const SizedBox(height: 14),
        CustomIconInput(
          controller: _invoiceEmailCtrl,
          label: 'Correo de recepción de facturas',
          hintText: 'facturacion@ejemplo.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        CustomIconInput(
          controller: _addressCtrl,
          label: 'Dirección fiscal',
          hintText: 'Ej: Calle 10 # 43A - 25',
          prefixIcon: Icons.home_work_outlined,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: CustomIconInput(
                controller: _cityCtrl,
                label: 'Ciudad / Municipio',
                hintText: 'Ej: Bogotá',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomIconInput(
                controller: _countryCtrl,
                label: 'País',
                hintText: 'Ej: Colombia',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        CustomMainButton(
          text: 'Guardar facturación',
          icon: Icons.check_rounded,
          height: 52,
          isLoading: _isSaving,
          onPressed: _saveBilling,
        ),
      ],
    );
  }
}
