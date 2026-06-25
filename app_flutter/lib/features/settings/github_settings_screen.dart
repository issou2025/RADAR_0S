import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/security/encryption_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/sync_repository.dart';

class GithubSettingsScreen extends StatefulWidget {
  const GithubSettingsScreen({super.key});

  @override
  State<GithubSettingsScreen> createState() => _GithubSettingsScreenState();
}

class _GithubSettingsScreenState extends State<GithubSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _syncRepo = SyncRepository();

  final _usernameController = TextEditingController();
  final _repoController = TextEditingController();
  final _branchController = TextEditingController();
  final _tokenController = TextEditingController();
  final _leadsController = TextEditingController();
  final _actionsController = TextEditingController();
  final _pagesUrlController = TextEditingController();

  bool _obscureToken = true;
  bool _isLoading = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = await EncryptionHelper.getGithubToken() ?? "";

    setState(() {
      _usernameController.text = prefs.getString(AppConstants.keyGithubUsername) ?? "";
      _repoController.text = prefs.getString(AppConstants.keyGithubRepo) ?? "client-radar-os-private";
      _branchController.text = prefs.getString(AppConstants.keyGithubBranch) ?? AppConstants.defaultBranch;
      _tokenController.text = token;
      _leadsController.text = prefs.getString(AppConstants.keyLeadsPath) ?? AppConstants.defaultLeadsPath;
      _actionsController.text = prefs.getString(AppConstants.keyActionsPath) ?? AppConstants.defaultActionsPath;
      _pagesUrlController.text = prefs.getString(AppConstants.keyGithubPagesBaseUrl) ?? "";
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(AppConstants.keyGithubUsername, _usernameController.text.trim());
    await prefs.setString(AppConstants.keyGithubRepo, _repoController.text.trim());
    await prefs.setString(AppConstants.keyGithubBranch, _branchController.text.trim());
    await prefs.setString(AppConstants.keyLeadsPath, _leadsController.text.trim());
    await prefs.setString(AppConstants.keyActionsPath, _actionsController.text.trim());
    
    // Auto-generate pages base URL if empty
    var pagesUrl = _pagesUrlController.text.trim();
    if (pagesUrl.isEmpty && _usernameController.text.isNotEmpty) {
      pagesUrl = "https://${_usernameController.text.trim()}.github.io/${_repoController.text.trim()}";
    }
    await prefs.setString(AppConstants.keyGithubPagesBaseUrl, pagesUrl);
    
    await EncryptionHelper.saveGithubToken(_tokenController.text.trim());

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Paramètres GitHub enregistrés avec succès !"),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isTesting = true);
    
    // Temporary save to test datasource
    final prefs = await SharedPreferences.getInstance();
    final oldUser = prefs.getString(AppConstants.keyGithubUsername);
    final oldRepo = prefs.getString(AppConstants.keyGithubRepo);
    final oldBranch = prefs.getString(AppConstants.keyGithubBranch);
    final oldToken = await EncryptionHelper.getGithubToken();
    
    await prefs.setString(AppConstants.keyGithubUsername, _usernameController.text.trim());
    await prefs.setString(AppConstants.keyGithubRepo, _repoController.text.trim());
    await prefs.setString(AppConstants.keyGithubBranch, _branchController.text.trim());
    await EncryptionHelper.saveGithubToken(_tokenController.text.trim());

    final success = await _syncRepo.testConnection();

    // Revert settings
    if (oldUser != null) await prefs.setString(AppConstants.keyGithubUsername, oldUser);
    if (oldRepo != null) await prefs.setString(AppConstants.keyGithubRepo, oldRepo);
    if (oldBranch != null) await prefs.setString(AppConstants.keyGithubBranch, oldBranch);
    if (oldToken != null) {
      await EncryptionHelper.saveGithubToken(oldToken);
    } else {
      await EncryptionHelper.deleteGithubToken();
    }

    setState(() => _isTesting = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(success ? "Connexion Réussie" : "Échec de Connexion"),
          content: Text(
            success 
              ? "L'application a réussi à communiquer avec votre dépôt privé GitHub !" 
              : "Impossible d'accéder au dépôt. Veuillez vérifier vos identifiants, le nom du dépôt et la validité de votre Token PAT."
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres GitHub"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Configuration du dépôt distant",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ces informations permettent de synchroniser l'application avec vos données de prospection privées.",
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    
                    // Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Utilisateur GitHub",
                        hintText: "Ex: jean-dupont",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Nom d'utilisateur requis" : null,
                    ),
                    const SizedBox(height: 16),

                    // Repo Name
                    TextFormField(
                      controller: _repoController,
                      decoration: const InputDecoration(
                        labelText: "Nom du Dépôt",
                        hintText: "Ex: client-radar-os-private",
                        prefixIcon: Icon(Icons.folder_open_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Nom du dépôt requis" : null,
                    ),
                    const SizedBox(height: 16),

                    // Branch
                    TextFormField(
                      controller: _branchController,
                      decoration: const InputDecoration(
                        labelText: "Branche",
                        hintText: "Ex: main",
                        prefixIcon: Icon(Icons.insights_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Branche requise" : null,
                    ),
                    const SizedBox(height: 16),

                    // Secure Token PAT
                    TextFormField(
                      controller: _tokenController,
                      obscureText: _obscureToken,
                      decoration: InputDecoration(
                        labelText: "Token d'accès personnel (PAT)",
                        hintText: "ghp_xxxxxxxxxxxx",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureToken ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscureToken = !_obscureToken),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Token d'accès requis" : null,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Paramètres avancés",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                    ),
                    const SizedBox(height: 12),

                    // Leads File Path
                    TextFormField(
                      controller: _leadsController,
                      decoration: const InputDecoration(
                        labelText: "Chemin leads.json",
                        hintText: "data/leads.json",
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User Actions File Path
                    TextFormField(
                      controller: _actionsController,
                      decoration: const InputDecoration(
                        labelText: "Chemin user_actions.json",
                        hintText: "data/user_actions.json",
                        prefixIcon: Icon(Icons.swap_horiz_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pages URL
                    TextFormField(
                      controller: _pagesUrlController,
                      decoration: const InputDecoration(
                        labelText: "URL de base GitHub Pages (optionnel)",
                        hintText: "https://username.github.io/repo",
                        prefixIcon: Icon(Icons.language_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isTesting ? null : _testConnection,
                            child: _isTesting 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text("Tester connexion"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveSettings,
                            child: const Text("Enregistrer"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
