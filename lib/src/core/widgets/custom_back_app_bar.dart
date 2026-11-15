import 'package:flutter/material.dart';

/// AppBar estándar para pantallas secundarias con botón de retroceso.
class CustomBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final bool centerTitle;

  const CustomBackAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.onBack,
    this.backgroundColor,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveBg = backgroundColor ?? const Color(0xFFF8F9FA);

    return AppBar(
      backgroundColor: effectiveBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: IconButton(
        tooltip: 'Volver',
        icon: Icon(Icons.arrow_back_rounded, color: colors.secondary),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.secondary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : null),
      actions: actions,
    );
  }
}
