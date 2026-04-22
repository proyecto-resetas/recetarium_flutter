import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSelectField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String hintText;
  final dynamic prefixIcon; // Puede ser IconData o String (ruta SVG)
  final String? Function(T?)? validator;

  const CustomSelectField({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.hintText = 'Seleccionar...',
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9E9E9E)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
            filled: true,
            fillColor: colors.secondary.withValues(alpha: 0.1),
            prefixIcon: _buildPrefixIcon(colors.secondary),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.error, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildPrefixIcon(Color color) {
    if (prefixIcon == null) return null;

    if (prefixIcon is IconData) {
      return Icon(prefixIcon as IconData, color: color, size: 22);
    } else if (prefixIcon is String) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          prefixIcon as String,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: 20,
          height: 20,
        ),
      );
    }
    return null;
  }
}
