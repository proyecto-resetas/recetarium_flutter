import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/core/widgets/image_card.dart';
import 'package:resetas/src/features/admin/data/super_admin_provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/my_recipes_created_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/ui/widgets/recipe_filters_bar.dart';

class SuperAdminPanelScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onBackToExplore;

  const SuperAdminPanelScreen({
    super.key,
    this.embedded = false,
    this.onBackToExplore,
  });

  @override
  State<SuperAdminPanelScreen> createState() => _SuperAdminPanelScreenState();
}

class _SuperAdminPanelScreenState extends State<SuperAdminPanelScreen> {
  // 0: Resumen General, 1: Recetas, 2: Usuarios, 3: Permisos, 4: Ventas y Regalos
  int _activeSection = 0;

  final TextEditingController _recipeSearchCtrl = TextEditingController();
  final TextEditingController _userSearchCtrl = TextEditingController();

  String _recipeSearch = '';
  String? _selectedRecipeCategory;
  String _userSearch = '';
  String? _selectedUserRoleFilter; // null: Todos, 'user', 'admin', 'super_admin'
  String _salesFilter = 'all'; // 'all', 'direct', 'gift'

  static const List<String> _availablePermissionsCatalog = [
    'recipes:read',
    'recipes:read:own',
    'recipes:create',
    'recipes:create:own',
    'recipes:update',
    'recipes:update:own',
    'recipes:delete',
    'recipes:delete:own',
    'recipes:*',
    'steps:read',
    'steps:create',
    'steps:update',
    'steps:delete',
    'steps:*',
    'users:read',
    'users:create',
    'users:update',
    'users:delete',
    'users:*',
    'roles:read',
    'roles:update',
    'roles:delete',
    'roles:*',
    'profile:read',
    'profile:update',
    'profile:*',
    '*',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SuperAdminProvider>().loadAllDashboardData();
    });
  }

  @override
  void dispose() {
    _recipeSearchCtrl.dispose();
    _userSearchCtrl.dispose();
    super.dispose();
  }

  String _formatCurrency(num value) {
    if (value <= 0) return '\$0';
    final intVal = value.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intVal.length; i++) {
      if (i > 0 && (intVal.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intVal[i]);
    }
    return '\$${buffer.toString()}';
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Chef (admin)';
      default:
        return 'Usuario';
    }
  }

  Color _roleAccentColor(String role, ColorScheme colors) {
    switch (role) {
      case 'super_admin':
        return colors.tertiary;
      case 'admin':
        return colors.primary;
      default:
        return colors.secondary;
    }
  }

  List<RecipesModel> _filteredRecipes(List<RecipesModel> all) {
    return RecipeFilterCatalog.applyFilters(
      source: all,
      searchQuery: _recipeSearch,
      category: _selectedRecipeCategory,
    );
  }

  List<Map<String, dynamic>> _filteredUsers(List<Map<String, dynamic>> all) {
    final q = _userSearch.trim().toLowerCase();
    return all.where((u) {
      final role = (u['role'] ?? 'user').toString();
      if (_selectedUserRoleFilter != null && role != _selectedUserRoleFilter) {
        return false;
      }
      if (q.isNotEmpty) {
        final name =
            '${u['username'] ?? ''} ${u['lastname'] ?? ''}'.toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q) || role.contains(q);
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _filteredTransactions(
    List<Map<String, dynamic>> all,
  ) {
    if (_salesFilter == 'direct') {
      return all.where((t) => t['isGift'] != true).toList();
    }
    if (_salesFilter == 'gift') {
      return all.where((t) => t['isGift'] == true).toList();
    }
    return all;
  }

  Future<void> _confirmDeleteRecipe(
    BuildContext context,
    RecipesModel recipe,
  ) async {
    final colors = Theme.of(context).colorScheme;
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
                color: const Color(0xFFE53935).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFE53935),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Eliminar receta',
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
          '¿Estás seguro de eliminar permanentemente "${recipe.nameRecipe}"?\n\nEsta acción borrará la receta, sus pasos y sus referencias en la plataforma.',
          style: TextStyle(
            fontSize: 14,
            color: colors.onSurface.withValues(alpha: 0.75),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: colors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sí, eliminar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final recipeId = recipe.id ?? '';
    final ok = await context
        .read<SuperAdminProvider>()
        .deleteRecipeAsSuperAdmin(recipeId);
    if (!context.mounted) return;

    if (ok) {
      final authUser = context.read<AuthProvider>().user;
      context.read<ViewRecipesProvider>().getRecipeFilter(
            null,
            null,
            null,
            null,
          );
      context.read<RecipeMyCreatedProvider>().getMyRecipesCreated(authUser);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Receta "${recipe.nameRecipe}" eliminada.'),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('No se pudo eliminar la receta. Verifica permisos.'),
          ),
        );
    }
  }

  Future<void> _openEditRecipeModal(
    BuildContext context,
    RecipesModel recipe,
  ) async {
    final colors = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController(text: recipe.nameRecipe);
    final priceCtrl = TextEditingController(text: recipe.price.toString());
    final descCtrl = TextEditingController(text: recipe.descriptionRecipe);
    String selectedCat = recipe.category.isNotEmpty
        ? recipe.category
        : 'Plato principal';
    String selectedLvl =
        recipe.level.isNotEmpty ? recipe.level : 'Basico';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
                    Text(
                      'Editar Receta (Super Admin)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomIconInput(
                      controller: nameCtrl,
                      label: 'Nombre de la receta',
                      hintText: 'Ej: Pasta Carbonara',
                      prefixIcon: Icons.restaurant_menu_rounded,
                    ),
                    const SizedBox(height: 14),
                    CustomIconInput(
                      controller: priceCtrl,
                      label: 'Precio (\$)',
                      hintText: '15000',
                      prefixIcon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Categoría',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RecipeFilterCatalog.categories
                          .where((c) => c['value'] != null)
                          .map((c) {
                        final val = c['value'] as String;
                        final sel = selectedCat.toLowerCase() ==
                            val.toLowerCase();
                        return ChoiceChip(
                          label: Text(
                            c['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.secondary,
                            ),
                          ),
                          selected: sel,
                          selectedColor: colors.primary.withValues(alpha: 0.18),
                          backgroundColor:
                              colors.secondary.withValues(alpha: 0.05),
                          onSelected: (_) =>
                              setModalState(() => selectedCat = val),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Nivel de dificultad',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: RecipeFilterCatalog.levels.map((lvl) {
                        final sel =
                            selectedLvl.toLowerCase() == lvl.toLowerCase();
                        return ChoiceChip(
                          label: Text(
                            lvl,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.secondary,
                            ),
                          ),
                          selected: sel,
                          selectedColor: colors.primary.withValues(alpha: 0.18),
                          backgroundColor:
                              colors.secondary.withValues(alpha: 0.05),
                          onSelected: (_) =>
                              setModalState(() => selectedLvl = lvl),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    CustomIconInput(
                      controller: descCtrl,
                      label: 'Descripción',
                      hintText: 'Descripción de la receta…',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final ok = await context
                              .read<SuperAdminProvider>()
                              .updateRecipeAsSuperAdmin(
                            recipe.id ?? '',
                            {
                              'nameRecipe': nameCtrl.text.trim(),
                              'price':
                                  int.tryParse(priceCtrl.text.trim()) ??
                                      recipe.price,
                              'category': selectedCat,
                              'level': selectedLvl,
                              'description': descCtrl.text.trim(),
                            },
                          );
                          if (!sheetCtx.mounted) return;
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  ok
                                      ? 'Receta actualizada exitosamente.'
                                      : 'No se pudo actualizar la receta.',
                                ),
                              ),
                            );
                        },
                        child: const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openEditRolePermissionsModal(
    BuildContext context,
    Map<String, dynamic> role,
  ) async {
    final colors = Theme.of(context).colorScheme;
    final roleId = (role['_id'] ?? role['id'] ?? '').toString();
    final roleName = (role['name'] ?? '').toString();
    final displayCtrl = TextEditingController(
      text: (role['displayName'] ?? roleName).toString(),
    );
    final Set<String> activePerms = {
      ...((role['permissions'] as List?)?.map((e) => e.toString()) ?? []),
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 16),
                      Text(
                        'Permisos del Rol: $roleName',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.secondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomIconInput(
                        controller: displayCtrl,
                        label: 'Nombre visible',
                        hintText: 'Ej: Chef (Creador)',
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selecciona los permisos activos (${activePerms.length}):',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colors.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availablePermissionsCatalog.map((perm) {
                          final selected = activePerms.contains(perm);
                          return FilterChip(
                            label: Text(
                              perm,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: colors.secondary,
                              ),
                            ),
                            selected: selected,
                            selectedColor:
                                colors.primary.withValues(alpha: 0.18),
                            checkmarkColor: colors.primary,
                            backgroundColor:
                                colors.secondary.withValues(alpha: 0.05),
                            side: BorderSide(
                              color: selected
                                  ? colors.primary.withValues(alpha: 0.5)
                                  : colors.secondary.withValues(alpha: 0.12),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  activePerms.add(perm);
                                } else {
                                  activePerms.remove(perm);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            await context
                                .read<SuperAdminProvider>()
                                .updateRolePermissions(
                                  roleId,
                                  activePerms.toList(),
                                  displayName: displayCtrl.text.trim(),
                                );
                            if (!sheetCtx.mounted) return;
                            Navigator.pop(sheetCtx);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Permisos del rol "$roleName" actualizados.',
                                  ),
                                ),
                              );
                          },
                          child: const Text(
                            'Guardar permisos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final adminProvider = context.watch<SuperAdminProvider>();
    final authProvider = context.watch<AuthProvider>();

    // Verificación estricta de rol super_admin
    if (authProvider.user?.role != 'super_admin') {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.gpp_maybe_rounded,
                  size: 56,
                  color: colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Acceso restringido a Super Administradores',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: colors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Este panel solo está disponible para cuentas con el rol super_admin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        final Widget bodyContent = isDesktop
            ? _buildDesktopLayout(context, colors, adminProvider, authProvider)
            : _buildMobileLayout(context, colors, adminProvider);

        if (widget.embedded) {
          return ColoredBox(
            color: const Color(0xFFF8F9FA),
            child: bodyContent,
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: const Color(0xFFF8F9FA),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: colors.secondary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    'Panel Super Admin',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: colors.secondary,
                    ),
                  ),
                  centerTitle: true,
                ),
          body: SafeArea(child: bodyContent),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. LAYOUT WEB / ESCRITORIO (>= 900px) CON SIDEBAR + 4 KPIs + SPLIT PANEL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDesktopLayout(
    BuildContext context,
    ColorScheme colors,
    SuperAdminProvider adminProvider,
    AuthProvider authProvider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Sidebar Lateral Izquierdo (260px) ─────────────────────────────
        Container(
          width: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: colors.secondary.withValues(alpha: 0.08),
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del Sidebar con Escudo Super Admin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          color: colors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Super Admin',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'ROOT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: colors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSidebarItem(
                colors: colors,
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Resumen General',
              ),
              const SizedBox(height: 6),
              _buildSidebarItem(
                colors: colors,
                index: 1,
                icon: Icons.restaurant_menu_rounded,
                activeIcon: Icons.restaurant_menu_rounded,
                label: 'Gestión de Recetas',
                badge: '${adminProvider.totalRecipes}',
              ),
              const SizedBox(height: 6),
              _buildSidebarItem(
                colors: colors,
                index: 2,
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_alt_rounded,
                label: 'Usuarios y Roles',
                badge: '${adminProvider.totalUsers}',
              ),
              const SizedBox(height: 6),
              _buildSidebarItem(
                colors: colors,
                index: 3,
                icon: Icons.lock_outline_rounded,
                activeIcon: Icons.lock_person_rounded,
                label: 'Permisos Dinámicos',
              ),
              const SizedBox(height: 6),
              _buildSidebarItem(
                colors: colors,
                index: 4,
                icon: Icons.card_giftcard_rounded,
                activeIcon: Icons.card_giftcard_rounded,
                label: 'Historial de Ventas',
                badge: '${adminProvider.totalSalesCount}',
              ),

              const Spacer(),

              if (widget.onBackToExplore != null || !widget.embedded)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.secondary,
                      side: BorderSide(
                        color: colors.secondary.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (widget.onBackToExplore != null) {
                        widget.onBackToExplore!();
                      } else {
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 17),
                    label: const Text(
                      'Volver a Explorar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Tarjeta del Super Admin activo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.secondary.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colors.primary.withValues(alpha: 0.18),
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: 18,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.user?.username ?? 'Super Admin',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: colors.secondary,
                            ),
                          ),
                          Text(
                            'Super Administrador',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ─── Área Principal Derecha ────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: colors.primary,
            onRefresh: adminProvider.loadAllDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera Superior Web
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panel de Super Administración',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: colors.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Control global de usuarios, recetas, roles, permisos y transacciones de Recetarium',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Actualizar métricas',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              colors.secondary.withValues(alpha: 0.08),
                        ),
                        onPressed: adminProvider.loadAllDashboardData,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Fila de 4 KPIs en Paralelo
                  _buildDesktopKpiRow(colors, adminProvider),
                  const SizedBox(height: 24),

                  // Contenido según sección seleccionada en Sidebar
                  if (_activeSection == 0)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildRecipesManagementCard(
                            context,
                            colors,
                            adminProvider,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildUsersManagementCard(
                                context,
                                colors,
                                adminProvider,
                                compact: true,
                              ),
                              const SizedBox(height: 20),
                              _buildTransactionsCard(
                                context,
                                colors,
                                adminProvider,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else if (_activeSection == 1)
                    _buildRecipesManagementCard(
                      context,
                      colors,
                      adminProvider,
                    )
                  else if (_activeSection == 2)
                    _buildUsersManagementCard(
                      context,
                      colors,
                      adminProvider,
                    )
                  else if (_activeSection == 3)
                    _buildRolesPermissionsCard(
                      context,
                      colors,
                      adminProvider,
                    )
                  else if (_activeSection == 4)
                    _buildTransactionsCard(
                      context,
                      colors,
                      adminProvider,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem({
    required ColorScheme colors,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    String? badge,
  }) {
    final isSelected = _activeSection == index;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _activeSection = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 19,
              color: isSelected
                  ? colors.primary
                  : colors.secondary.withValues(alpha: 0.65),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: colors.secondary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colors.secondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopKpiRow(
    ColorScheme colors,
    SuperAdminProvider adminProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            colors: colors,
            title: 'Usuarios Totales',
            value: '${adminProvider.totalUsers}',
            subtitle:
                '${adminProvider.totalChefs} Chefs • ${adminProvider.totalRegularUsers} Usuarios',
            icon: Icons.people_alt_rounded,
            accentColor: colors.secondary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildKpiCard(
            colors: colors,
            title: 'Recetas Publicadas',
            value: '${adminProvider.totalRecipes}',
            subtitle: 'Catálogo global activo',
            icon: Icons.menu_book_rounded,
            accentColor: colors.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildKpiCard(
            colors: colors,
            title: 'Ventas Completadas',
            value: '${adminProvider.totalSalesCount} compras',
            subtitle: '${adminProvider.totalGiftsCount} enviadas como regalo',
            icon: Icons.shopping_bag_rounded,
            accentColor: colors.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildKpiCard(
            colors: colors,
            title: 'Ingresos Globales',
            value: _formatCurrency(adminProvider.totalRevenue),
            subtitle: 'Recaudación acumulada',
            icon: Icons.trending_up_rounded,
            accentColor: colors.tertiary,
            tintedBackground: true,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. LAYOUT MOBILE (< 900px) CON PESTAÑAS CENTRADAS Y GRID 2×2
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMobileLayout(
    BuildContext context,
    ColorScheme colors,
    SuperAdminProvider adminProvider,
  ) {
    final tabs = [
      (index: 0, label: 'Resumen', icon: Icons.dashboard_rounded),
      (
        index: 1,
        label: 'Recetas (${adminProvider.totalRecipes})',
        icon: Icons.restaurant_menu_rounded,
      ),
      (
        index: 2,
        label: 'Usuarios (${adminProvider.totalUsers})',
        icon: Icons.people_alt_rounded,
      ),
      (index: 3, label: 'Permisos', icon: Icons.lock_person_rounded),
      (
        index: 4,
        label: 'Ventas (${adminProvider.totalSalesCount})',
        icon: Icons.card_giftcard_rounded,
      ),
    ];

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: adminProvider.loadAllDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Mobile con badge SUPER ADMIN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel Super Admin',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colors.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Control total de Recetarium',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 14,
                        color: colors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SUPER ADMIN',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Píldoras de Navegación Centradas
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(tabs.length, (i) {
                    final t = tabs[i];
                    final sel = _activeSection == t.index;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: i == tabs.length - 1 ? 0 : 8,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeSection = t.index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? colors.primary.withValues(alpha: 0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: sel
                                  ? colors.primary.withValues(alpha: 0.45)
                                  : colors.secondary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                t.icon,
                                size: 15,
                                color: sel
                                    ? colors.primary
                                    : colors.secondary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: sel
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: colors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_activeSection == 0) ...[
              // Grid 2×2 de KPIs en Mobile
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      colors: colors,
                      title: 'Usuarios Totales',
                      value: '${adminProvider.totalUsers}',
                      subtitle:
                          '${adminProvider.totalChefs} Chefs • ${adminProvider.totalRegularUsers} Usuarios',
                      icon: Icons.people_alt_rounded,
                      accentColor: colors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      colors: colors,
                      title: 'Recetas Publicadas',
                      value: '${adminProvider.totalRecipes}',
                      subtitle: 'Catálogo global',
                      icon: Icons.menu_book_rounded,
                      accentColor: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      colors: colors,
                      title: 'Ventas Totales',
                      value: '${adminProvider.totalSalesCount} compras',
                      subtitle: '${adminProvider.totalGiftsCount} regalos',
                      icon: Icons.shopping_bag_rounded,
                      accentColor: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      colors: colors,
                      title: 'Ingresos Globales',
                      value: _formatCurrency(adminProvider.totalRevenue),
                      subtitle: 'Recaudado',
                      icon: Icons.trending_up_rounded,
                      accentColor: colors.tertiary,
                      tintedBackground: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildRecipesManagementCard(context, colors, adminProvider),
            ] else if (_activeSection == 1)
              _buildRecipesManagementCard(context, colors, adminProvider)
            else if (_activeSection == 2)
              _buildUsersManagementCard(context, colors, adminProvider)
            else if (_activeSection == 3)
              _buildRolesPermissionsCard(context, colors, adminProvider)
            else if (_activeSection == 4)
              _buildTransactionsCard(context, colors, adminProvider),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. COMPONENTES COMPARTIDOS (KPIs, Recetas, Usuarios, Roles y Ventas)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildKpiCard({
    required ColorScheme colors,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    bool tintedBackground = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tintedBackground
            ? accentColor.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tintedBackground
              ? accentColor.withValues(alpha: 0.25)
              : colors.secondary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.secondary.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: tintedBackground ? accentColor : colors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesManagementCard(
    BuildContext context,
    ColorScheme colors,
    SuperAdminProvider adminProvider,
  ) {
    final recipes = _filteredRecipes(adminProvider.recipes);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestión de Recetas Publicadas',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${recipes.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          CustomIconInput(
            controller: _recipeSearchCtrl,
            hintText: 'Buscar receta por nombre, categoría o chef…',
            prefixIcon: Icons.search_rounded,
            onCleared: () {
              _recipeSearchCtrl.clear();
              setState(() => _recipeSearch = '');
            },
            onChanged: (v) => setState(() => _recipeSearch = v),
          ),
          const SizedBox(height: 10),

          // Píldoras de Categorías centradas
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: RecipeFilterCatalog.categories.map((cat) {
                  final val = cat['value'] as String?;
                  final sel = _selectedRecipeCategory == val;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(
                        () => _selectedRecipeCategory =
                            sel && val != null ? null : val,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? colors.primary.withValues(alpha: 0.15)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: sel
                                ? colors.primary.withValues(alpha: 0.45)
                                : colors.secondary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.w800 : FontWeight.w600,
                            color: colors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          if (adminProvider.isLoading && recipes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: CircularProgressIndicator(color: colors.primary),
              ),
            )
          else if (recipes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No se encontraron recetas con ese filtro.',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              separatorBuilder: (_, __) => Divider(
                color: colors.secondary.withValues(alpha: 0.08),
                height: 18,
              ),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          context.push('/recipes_details', extra: recipe),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: MyImage(recipe.imageUrl),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.nameRecipe,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: colors.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${recipe.creatorDisplayName} • ${recipe.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(recipe.price),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón Editar
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _openEditRecipeModal(context, recipe),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: colors.secondary.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: colors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Editar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: colors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón Eliminar (Exclusivo Super Admin)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _confirmDeleteRecipe(context, recipe),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 15,
                              color: Color(0xFFE53935),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUsersManagementCard(
    BuildContext context,
    ColorScheme colors,
    SuperAdminProvider adminProvider, {
    bool compact = false,
  }) {
    final users = _filteredUsers(adminProvider.users);
    final displayedUsers = compact ? users.take(5).toList() : users;

    final roleFilters = [
      (label: 'Todos', value: null),
      (label: 'Usuarios', value: 'user'),
      (label: 'Chefs', value: 'admin'),
      (label: 'Super Admin', value: 'super_admin'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Usuarios y Asignación de Roles',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
              if (compact)
                TextButton(
                  onPressed: () => setState(() => _activeSection = 2),
                  child: Text(
                    'Ver todos (${users.length})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          CustomIconInput(
            controller: _userSearchCtrl,
            hintText: 'Buscar usuario por nombre, correo o rol…',
            prefixIcon: Icons.search_rounded,
            onCleared: () {
              _userSearchCtrl.clear();
              setState(() => _userSearch = '');
            },
            onChanged: (v) => setState(() => _userSearch = v),
          ),
          const SizedBox(height: 10),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: roleFilters.map((rf) {
                  final sel = _selectedUserRoleFilter == rf.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedUserRoleFilter = rf.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? colors.primary.withValues(alpha: 0.15)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: sel
                                ? colors.primary.withValues(alpha: 0.45)
                                : colors.secondary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          rf.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.w800 : FontWeight.w600,
                            color: colors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (displayedUsers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No hay usuarios para mostrar.',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedUsers.length,
              separatorBuilder: (_, __) => Divider(
                color: colors.secondary.withValues(alpha: 0.08),
                height: 16,
              ),
              itemBuilder: (context, index) {
                final u = displayedUsers[index];
                final userId = (u['_id'] ?? u['id'] ?? '').toString();
                final username =
                    '${u['username'] ?? 'Usuario'} ${u['lastname'] ?? ''}'
                        .trim();
                final email = (u['email'] ?? '').toString();
                final role = (u['role'] ?? 'user').toString();
                final roleColor = _roleAccentColor(role, colors);

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: roleColor.withValues(alpha: 0.14),
                      child: Text(
                        username.isNotEmpty
                            ? username[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colors.secondary,
                            ),
                          ),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Selector desplegable de Rol
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: roleColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ['user', 'admin', 'super_admin'].contains(role)
                              ? role
                              : 'user',
                          isDense: true,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colors.secondary,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('Usuario'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Chef (admin)'),
                            ),
                            DropdownMenuItem(
                              value: 'super_admin',
                              child: Text('Super Admin'),
                            ),
                          ],
                          onChanged: (newRole) async {
                            if (newRole == null || newRole == role) return;
                            final ok = await adminProvider.changeUserRole(
                              userId,
                              newRole,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    ok
                                        ? 'Rol de $username actualizado a ${_roleLabel(newRole)}.'
                                        : 'No se pudo cambiar el rol.',
                                  ),
                                ),
                              );
                          },
                        ),
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'Eliminar usuario',
                        onPressed: () async {
                          final ok = await adminProvider.removeUser(userId);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  ok
                                      ? 'Usuario $username eliminado.'
                                      : 'No se pudo eliminar el usuario.',
                                ),
                              ),
                            );
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          if (compact) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.secondary,
                  backgroundColor: colors.secondary.withValues(alpha: 0.05),
                  side: BorderSide(
                    color: colors.secondary.withValues(alpha: 0.15),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => setState(() => _activeSection = 3),
                icon: const Icon(Icons.lock_person_outlined, size: 17),
                label: const Text(
                  'Gestionar Permisos (recipes:*, users:*)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRolesPermissionsCard(
    BuildContext context,
    ColorScheme colors,
    SuperAdminProvider adminProvider,
  ) {
    final roles = adminProvider.roles;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Roles y Permisos Dinámicos',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Configura qué acciones puede ejecutar cada rol en el backend en tiempo real.',
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: roles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final role = roles[index];
              final name = (role['name'] ?? '').toString();
              final displayName = (role['displayName'] ?? name).toString();
              final description = (role['description'] ?? '').toString();
              final perms = (role['permissions'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colors.secondary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$displayName ($name)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.secondary,
                              ),
                            ),
                            if (description.isNotEmpty)
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                          ],
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () =>
                              _openEditRolePermissionsModal(context, role),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 14,
                                  color: colors.secondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Editar permisos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: colors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: perms.map((p) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.secondary.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Text(
                            p,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colors.secondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard(
    BuildContext context,
    ColorScheme colors,
    SuperAdminProvider adminProvider, {
    bool compact = false,
  }) {
    final allTx = adminProvider.transactions;
    final filteredTx = _filteredTransactions(allTx);
    final displayed = compact ? filteredTx.take(4).toList() : filteredTx;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                compact
                    ? 'Últimas Ventas y Regalos'
                    : 'Historial Global de Ventas y Regalos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
              if (compact)
                TextButton(
                  onPressed: () => setState(() => _activeSection = 4),
                  child: Text(
                    'Ver historial',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${adminProvider.totalSalesCount} transacciones completadas • ${adminProvider.totalGiftsCount} enviadas como regalo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSalesFilterPill(colors, 'all', 'Todas'),
                  const SizedBox(width: 8),
                  _buildSalesFilterPill(colors, 'direct', 'Compras directas'),
                  const SizedBox(width: 8),
                  _buildSalesFilterPill(colors, 'gift', '🎁 Regalos'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (displayed.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Aún no se registran transacciones.',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayed.length,
              separatorBuilder: (_, __) => Divider(
                color: colors.secondary.withValues(alpha: 0.08),
                height: 16,
              ),
              itemBuilder: (context, index) {
                final tx = displayed[index];
                final isGift = tx['isGift'] == true;
                final recipeName = (tx['recipeName'] ?? 'Receta').toString();
                final recipeImage = (tx['recipeImage'] ?? '').toString();
                final buyer = (tx['buyerUsername'] ?? 'usuario').toString();
                final chef = (tx['chefName'] ?? 'Chef').toString();
                final recipientEmail = tx['recipientEmail']?.toString();
                final amount = (tx['amount'] as num?) ?? 0;

                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: MyImage(recipeImage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colors.secondary,
                            ),
                          ),
                          Text(
                            '@$buyer • $chef',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isGift
                                  ? colors.primary.withValues(alpha: 0.14)
                                  : colors.tertiary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isGift
                                  ? '🎁 Regalo para ${recipientEmail ?? 'usuario'}'
                                  : '✓ Compra directa',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isGift
                                    ? colors.secondary
                                    : colors.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrency(amount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSalesFilterPill(
    ColorScheme colors,
    String key,
    String label,
  ) {
    final sel = _salesFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _salesFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel
              ? colors.primary.withValues(alpha: 0.15)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: sel
                ? colors.primary.withValues(alpha: 0.45)
                : colors.secondary.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
            color: colors.secondary,
          ),
        ),
      ),
    );
  }
}
