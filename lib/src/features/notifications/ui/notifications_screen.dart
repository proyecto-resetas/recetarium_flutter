import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';
import 'package:resetas/src/features/notifications/data/notifications_provider.dart';
import 'package:resetas/src/features/notifications/models/notification_model.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _brandOrange = Color(0xFFF26625);
  static const Color _bgWarm = Color(0xFFFAF8F5);
  static const Color _unreadCardBg = Color(0xFFFFF6F0);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textMuted = Color(0xFF757575);

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
    final provider = context.watch<NotificationsProvider>();
    final filtered = _filterNotifications(provider.notifications);
    final todayList = filtered.where((n) => _isToday(n.createdAt)).toList();
    final olderList = filtered.where((n) => !_isToday(n.createdAt)).toList();

    return Scaffold(
      backgroundColor: _bgWarm,
      appBar: AppBar(
        backgroundColor: _bgWarm,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textDark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          // Botón para probar notificación WebSocket + Push en vivo
          IconButton(
            tooltip: 'Enviar notificación de prueba en vivo',
            onPressed: () async {
              await provider.sendTestNotification();
            },
            icon: const Icon(
              Icons.bolt_rounded,
              color: _brandOrange,
              size: 22,
            ),
          ),
          if (provider.unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: provider.markAllAsRead,
                icon: const Icon(
                  Icons.done_all_rounded,
                  size: 18,
                  color: _textDark,
                ),
                label: const Text(
                  'Leer todas',
                  style: TextStyle(
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: _brandOrange,
        onRefresh: provider.fetchNotifications,
        child: CustomScrollView(
          slivers: [
            // ─── Cabecera: Logo + "Notificaciones" + Badge "X nuevas" ───────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECE2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/icon/recetariumLogoxxl-03.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.notifications_rounded,
                              color: _brandOrange,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Notificaciones',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (provider.unreadCount > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _brandOrange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${provider.unreadCount} ${provider.unreadCount == 1 ? 'nueva' : 'nuevas'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Filtros rápidos horizontales ─────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            id: 'all',
                            label: 'Todas',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            id: 'unread',
                            label: 'No leídas (${provider.unreadCount})',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            id: 'purchases',
                            label: 'Compras',
                            icon: Icons.shopping_bag_outlined,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            id: 'gifts',
                            label: 'Regalos',
                            icon: Icons.card_giftcard_rounded,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            id: 'favorites',
                            label: 'Favoritos',
                            icon: Icons.favorite_border_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Estado de WebSocket en tiempo real y Push ────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          todayList.isNotEmpty ? 'HOY' : 'ACTIVIDAD',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: provider.isSocketConnected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.amber.shade700,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              provider.isSocketConnected
                                  ? 'Conectado en tiempo real'
                                  : 'Sincronizando WebSocket…',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: provider.isSocketConnected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Lista o Estado Vacío ───────────────────────────────────────
            if (provider.isLoading && provider.notifications.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: _brandOrange),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyNotificationsState(provider),
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
                        provider,
                        todayList[index],
                      ),
                      childCount: todayList.length,
                    ),
                  ),
                ),

              // Sección ANTERIORES / AYER
              if (olderList.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    child: const Text(
                      'ANTERIORES',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: 0.6,
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
    );
  }

  Widget _buildFilterChip({
    required String id,
    required String label,
    IconData? icon,
  }) {
    final selected = _selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _brandOrange : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? _brandOrange : const Color(0xFFD8D4CE),
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
    NotificationsProvider provider,
    NotificationModel item,
  ) {
    final badgeConfig = _getBadgeConfig(item.type);
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
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(20),
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
            color: item.read ? Colors.white : _unreadCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.read
                  ? Colors.black.withValues(alpha: 0.04)
                  : _brandOrange.withValues(alpha: 0.2),
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
                          color: badgeConfig.bgColor.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badgeConfig.icon,
                          color: badgeConfig.bgColor,
                          size: 26,
                        ),
                      ),

                    // Punto naranja de no leído (arriba izquierda)
                    if (!item.read)
                      Positioned(
                        top: -3,
                        left: -3,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: _brandOrange,
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
                        fontSize: 15.5,
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
                        color: Color(0xFF3E3E3E),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
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
                              color: _brandOrange,
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
                                    fontWeight: FontWeight.w800,
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

  ({IconData icon, Color bgColor}) _getBadgeConfig(String type) {
    switch (type) {
      case 'recipe_sold':
        return (
          icon: Icons.monetization_on_rounded,
          bgColor: const Color(0xFFF28C25),
        );
      case 'recipe_gift':
        return (
          icon: Icons.card_giftcard_rounded,
          bgColor: const Color(0xFFF26625),
        );
      case 'purchase_confirmed':
        return (
          icon: Icons.check_rounded,
          bgColor: const Color(0xFF2E7D32),
        );
      case 'recipe_favorited':
        return (
          icon: Icons.favorite_border_rounded,
          bgColor: const Color(0xFFE53935),
        );
      default:
        return (
          icon: Icons.notifications_rounded,
          bgColor: _brandOrange,
        );
    }
  }

  Widget _buildEmptyNotificationsState(NotificationsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: _brandOrange,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aún no tienes notificaciones',
              style: TextStyle(
                fontSize: 19,
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
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () async {
                await provider.sendTestNotification();
              },
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text(
                'Probar notificación en tiempo real',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
