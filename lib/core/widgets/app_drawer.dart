// lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairos/core/router/app_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mevcut route'u al
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        children: [
          // === DRAWER HEADER ===
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                SizedBox(height: 8),
                Text(
                  'Hoş Geldiniz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Antrenman Uygulaması',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // === MENÜ ÖĞELERİ ===
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // === GENEL ===
                _buildSectionTitle(context, 'GENEL'),

                // Ana Sayfa
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home,
                  title: 'Ana Sayfa',
                  route: Routes.home,
                  currentLocation: currentLocation,
                  onTap: () => _navigate(context, Routes.home),
                ),

                const Divider(),

                // === HESAP ===
                _buildSectionTitle(context, 'HESAP'),

                const Divider(),

                // === DİĞER ===
                _buildSectionTitle(context, 'DİĞER'),
              ],
            ),
          ),

          // === ALT KISIM ===
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Versiyon 1.0.0',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                IconButton(
                  onPressed: () {
                    // Drawer'ı kapat
                    Navigator.pop(context);
                    // Ana sayfaya git
                    context.go(Routes.home);
                  },
                  icon: const Icon(Icons.home, color: Colors.blue),
                  tooltip: 'Ana Sayfa',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required String currentLocation,
    required VoidCallback onTap,
    String? badge,
  }) {
    // Aktif route'u kontrol et
    final isActive =
        currentLocation == route ||
        (route != '/' && currentLocation.startsWith(route));

    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blue : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.blue : null,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : (isActive
                ? Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : null),
      onTap: onTap,
    );
  }

  void _navigate(BuildContext context, String route) {
    // Drawer'ı kapat
    Navigator.pop(context);
    // GoRouter ile navigasyon
    context.go(route);
  }
}
