import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconInput extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final dynamic prefixIcon; // Puede ser IconData o String (ruta SVG)
  final VoidCallback? onCleared;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final bool isPassword;

  const CustomIconInput({
    super.key,
    required this.controller,
    this.label,
    this.hintText = 'Buscar...',
    this.prefixIcon,
    this.onCleared,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
  });

  @override
  State<CustomIconInput> createState() => _CustomIconInputState();
}

class _CustomIconInputState extends State<CustomIconInput> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: colors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: widget.controller,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            onChanged: (val) {
              if (widget.onChanged != null) widget.onChanged!(val);
              setState(() {}); // Para actualizar el icono de limpiar
            },
            validator: widget.validator,
            obscureText: _obscureText,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.45)),
              prefixIcon: _buildPrefixIcon(colors.secondary),
              suffixIcon: _buildSuffixIcon(colors),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.error, width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.error, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildPrefixIcon(Color color) {
    if (widget.prefixIcon == null) return null;

    if (widget.prefixIcon is IconData) {
      return Icon(widget.prefixIcon as IconData, color: color, size: 22);
    } else if (widget.prefixIcon is String) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          widget.prefixIcon as String,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: 20,
          height: 20,
        ),
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon(ColorScheme colors) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF9E9E9E),
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.controller.text.isNotEmpty && widget.onCleared != null) {
      return IconButton(
        icon: const Icon(Icons.clear_rounded, size: 20),
        onPressed: () {
          widget.controller.clear();
          widget.onCleared!();
          setState(() {});
        },
      );
    }

    return null;
  }
}
