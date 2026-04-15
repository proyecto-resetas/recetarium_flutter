import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:resetas/src/features/user_profile/ui/widgets/stat_card.dart';
import 'package:resetas/src/features/user_profile/ui/widgets/menu_tile.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noUserInfo)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2332)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.myProfile,
          style: const TextStyle(
            color: Color(0xFF1B2332),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: user.photoUrl.isNotEmpty
                          ? NetworkImage(user.photoUrl)
                          : null,
                      child: user.photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${user.username} ${user.lastname}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2332),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.chefAmateur,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: user.myRecipe.length.toString(),
                      label: l10n.recipes,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      value: '128',
                      label: l10n.following,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2332),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MenuTile(
                    icon: Icons.person_outline,
                    title: l10n.editProfile,
                    onTap: () {},
                  ),
                  MenuTile(
                    icon: Icons.notifications_none_outlined,
                    title: l10n.notifications,
                    onTap: () {},
                  ),
                  MenuTile(
                    icon: Icons.favorite_border_outlined,
                    title: l10n.myFavorites,
                    onTap: () {},
                  ),
                  MenuTile(
                    icon: Icons.logout_outlined,
                    title: l10n.logout,
                    isLogout: true,
                    onTap: () {
                      authProvider.logout();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
