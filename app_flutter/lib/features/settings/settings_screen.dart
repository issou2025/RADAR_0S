import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/lead_repository.dart';
import 'github_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearCache(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Vider le Cache Local ?"),
        content: const Text(
          "Cette action supprimera toutes les opportunités stockées localement sur le téléphone. Vos données distantes sur GitHub ne seront pas affectées."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Vider", style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = LeadRepository();
      await repo.clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cache SQLite vidé avec succès !"),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: ListView(
        children: [
          // Section GitHub Configuration
          _buildSectionHeader("Connexion & Synchronisation"),
          _buildSettingsTile(
            context,
            "Configuration GitHub",
            "Modifier le dépôt, l'utilisateur et le Token PAT d'accès sécurisé.",
            Icons.cloud_sync_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GithubSettingsScreen()),
              );
            },
          ),
          
          // Section Cache Operations
          _buildSectionHeader("Données Locales"),
          _buildSettingsTile(
            context,
            "Vider le Cache Local",
            "Effacer la base de données SQLite sur le téléphone.",
            Icons.delete_sweep_outlined,
            () => _clearCache(context),
            textColor: AppTheme.danger,
          ),

          // Section About
          _buildSectionHeader("À propos"),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Version 1.0.0 (MVP)",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Client Radar OS est une solution privée et sans serveur. Vos clés API et données commerciales restent stockées dans votre dépôt GitHub privé et sur votre appareil mobile en local.",
                      style: TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
