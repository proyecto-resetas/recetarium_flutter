import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/core/widgets/custom_back_app_bar.dart';
import 'package:recetarium/src/core/widgets/image_card.dart';
import 'package:recetarium/src/features/notifications/data/notifications_provider.dart';
import 'package:recetarium/src/features/notifications/models/notification_model.dart';
import 'package:recetarium/src/features/recipes/data/recipes_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _bgPage = Color(0xFFF8F9FA);
  static const Color _textDark = Color(0xFF1A1D1E);
  static const Color _textMuted = Color(0xFF6B7280);

  String _selectedFilter = 'all'; // all, unread, purchases, gifts, favorites

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications();
    });
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> all) {
    switch (_selectedFilter) {
      case 'unread':
        return all.where((n) => !n.read).toList();
      case 'purchases':
        return all
            .where(
              (n) =>
                  n.type == 'recipe_sold' || n.type == 'purchase_confirmed',
            )
            .toList();
      case 'gifts':
        return all.where((n) => n.type == 'recipe_gift').toList();
      case 'favorites':
        return all.where((n) => n.type == 'recipe_favorited').toList();
      default:
        return all;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24 && _isToday(date)) {
      return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
    }
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    if (diff.inDays == 1) return 'Ayer, $hour:$min';
    return '${date.day}/${date.month}/${date.year}, $hour:$min';
  }

  void _openRecipeFromNotification(
    BuildContext context,
    NotificationModel notification,
  ) {
    context.read<NotificationsProvider>().markAsRead(notification.id);

    if (notification.recipeId == null || notification.recipeId!.isEmpty) {
      return;
    }

    final recipesProvider = context.read<ViewRecipesProvider>();
    final match = recipesProvider.recipeList
        .where((r) => r.id == notification.recipeId)
        .toList();

    if (match.isNotEmpty) {
      context.push('/recipes_details', extra: match.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Receta "${notification.recipeName ?? ''}" disponible en tu biblioteca.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<NotificationsProvider>();
    final filtered = _filterNotifications(provider.notifications);
    final todayList = filtered.where((n) => _isToday(n.createdAt)).toList();
    final olderList = filtered.where((n) => !_isToday(n.createdAt)).toList();

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: CustomBackAppBar(
        backgroundColor: _bgPage,
        title: 'Notificaciones',
        actions: [
          if (provider.unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton.icon(
                onPressed: provider.markAllAsRead,
                icon: Icon(
                  Icons.done_all_rounded,
                  size: 18,
                  color: colors.secondary,
                ),
                label: Text(
                  'Leer todas',
                  style: TextStyle(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.secondary,
          onRefresh: provider.fetchNotifications,
          child: CustomScrollView(
            slivers: [
              // ─── Banner resumen + estado en tiempo real ──────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: colors.secondary.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.unreadCount > 0
                                        ? '${provider.unreadCount} ${provider.unreadCount == 1 ? 'notificación nueva' : 'notificaciones nuevas'}'
                                        : 'Todo al día',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: provider.isSocketConnected
                                              ? const Color(0xFF69F0AE)
                                              : colors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        provider.isSocketConnected
                                            ? 'Conectado en tiempo real'
                                            : 'Sincronizando…',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (provider.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${provider.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ─── Filtros rápidos horizontales ───────────────────────
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              colors: colors,
                              id: 'all',
                              label: 'Todas',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              colors: colors,
                              id: 'unread',
                              label: 'No leídas (${provider.unreadCount})',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              colors: colors,
                              id: 'purchases',
                              label: 'Compras',
                              icon: Icons.shopping_bag_outlined,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              colors: colors,
                              id: 'gifts',
                              label: 'Regalos',
                              icon: Icons.card_giftcard_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              colors: colors,
                              id: 'favorites',
                              label: 'Favoritos',
                              icon: Icons.favorite_border_rounded,
                            ),
                          ],
                        ),
                      ),
                      if (filtered.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          todayList.isNotEmpty ? 'HOY' : 'ACTIVIDAD',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colors.secondary,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ─── Lista o Estado Vacío ───────────────────────────────────────
              if (provider.isLoading && provider.notifications.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: colors.secondary),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyNotificationsState(colors),
                )
              else ...[
                // Sección HOY
                if (todayList.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildNotificationCard(
                          context,
                          colors,
                          provider,
                          todayList[index],
                        ),
                        childCount: todayList.length,
                      ),
                    ),
                  ),

                // Sección ANTERIORES
                if (olderList.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                      child: Text(
                        'ANTERIORES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.secondary,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildNotificationCard(
                          context,
                          colors,
                          provider,
                          olderList[index],
                        ),
                        childCount: olderList.length,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required ColorScheme colors,
    required String id,
    required String label,
    IconData? icon,
  }) {
    final selected = _selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? colors.secondary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : _textDark,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    ColorScheme colors,
    NotificationsProvider provider,
    NotificationModel item,
  ) {
    final badgeConfig = _getBadgeConfig(item.type, colors);
    final hasImage =
        item.recipeImage != null && item.recipeImage!.trim().isNotEmpty;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (_) => provider.deleteNotification(item.id),
      child: GestureDetector(
        onTap: () => _openRecipeFromNotification(context, item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.read
                ? Colors.white
                : Color.alphaBlend(
                    colors.primary.withValues(alpha: 0.06),
                    Colors.white,
                  ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.read
                  ? Colors.black.withValues(alpha: 0.05)
                  : colors.primary.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Miniatura o ícono con badge superpuesto
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (hasImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 58,
                          height: 58,
                          child: MyImage(item.recipeImage!),
                        ),
                      )
                    else
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: badgeConfig.bgColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badgeConfig.icon,
                          color: badgeConfig.bgColor,
                          size: 26,
                        ),
                      ),

                    // Punto de no leído (arriba izquierda)
                    if (!item.read)
                      Positioned(
                        top: -3,
                        left: -3,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),

                    // Badge circular semántico (arriba derecha de la imagen)
                    if (hasImage)
                      Positioned(
                        top: -4,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: badgeConfig.bgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            badgeConfig.icon,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Contenido de texto y acciones
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.type == 'recipe_gift' ||
                            item.type == 'purchase_confirmed')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ir a la receta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Text(
                          _formatRelativeTime(item.createdAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({IconData icon, Color bgColor}) _getBadgeConfig(
    String type,
    ColorScheme colors,
  ) {
    switch (type) {
      case 'recipe_sold':
        return (
          icon: Icons.monetization_on_rounded,
          bgColor: colors.primary,
        );
      case 'recipe_gift':
        return (
          icon: Icons.card_giftcard_rounded,
          bgColor: colors.primary,
        );
      case 'purchase_confirmed':
        return (
          icon: Icons.check_rounded,
          bgColor: colors.tertiary,
        );
      case 'recipe_favorited':
        return (
          icon: Icons.favorite_border_rounded,
          bgColor: colors.error,
        );
      default:
        return (
          icon: Icons.notifications_rounded,
          bgColor: colors.secondary,
        );
    }
  }

  Widget _buildEmptyNotificationsState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 42,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aún no tienes notificaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí aparecerán en tiempo real tus compras, regalos de recetas recibidos y cuando otros usuarios guarden tus recetas en favoritos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: _textMuted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
