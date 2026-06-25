import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../local/database_helper.dart';
import '../models/lead_model.dart';
import '../models/stats_model.dart';
import '../remote/github_remote_data_source.dart';

class SyncRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<GithubRemoteDataSource> _getRemoteDataSource() async {
    final prefs = await SharedPreferences.getInstance();
    final owner = prefs.getString(AppConstants.keyGithubUsername) ?? "";
    final repo = prefs.getString(AppConstants.keyGithubRepo) ?? "";
    final branch = prefs.getString(AppConstants.keyGithubBranch) ?? AppConstants.defaultBranch;

    return GithubRemoteDataSource(
      owner: owner,
      repo: repo,
      branch: branch,
    );
  }

  /// Test connection to repository
  Future<bool> testConnection() async {
    final source = await _getRemoteDataSource();
    if (source.owner.isEmpty || source.repo.isEmpty) return false;
    return await source.testConnection();
  }

  /// Perform bidirectional sync:
  /// 1. Push pending local actions to remote user_actions.json
  /// 2. Fetch remote leads.json and overwrite/merge locally
  /// 3. Fetch remote stats.json and cache it
  Future<SyncResult> syncWithGithub() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final owner = prefs.getString(AppConstants.keyGithubUsername) ?? "";
      final repo = prefs.getString(AppConstants.keyGithubRepo) ?? "";
      
      if (owner.isEmpty || repo.isEmpty) {
        return SyncResult(success: false, message: "GitHub settings are incomplete.");
      }

      final source = await _getRemoteDataSource();
      final isConnected = await source.testConnection();
      if (!isConnected) {
        return SyncResult(success: false, message: "Failed to connect to GitHub repository.");
      }

      // --- STEP 1: PUSH LOCAL ACTIONS ---
      final pendingActions = await _dbHelper.getPendingActions();
      if (pendingActions.isNotEmpty) {
        final actionsPath = prefs.getString(AppConstants.keyActionsPath) ?? AppConstants.defaultActionsPath;
        
        // Fetch current remote user_actions.json
        final fileResponse = await source.fetchFile(actionsPath);
        
        List<dynamic> remoteActions = [];
        if (fileResponse.exists && fileResponse.content.isNotEmpty) {
          try {
            remoteActions = jsonDecode(fileResponse.content);
          } catch (_) {
            remoteActions = [];
          }
        }
        
        // Append local actions
        final localActionList = pendingActions.map((map) {
          return {
            "lead_id": map["lead_id"],
            "action": map["action"],
            "value": map["value"],
            "timestamp": map["timestamp"]
          };
        }).toList();
        
        remoteActions.addAll(localActionList);
        final updatedContent = jsonEncode(remoteActions);
        
        // Push back to GitHub
        await source.updateFile(
          path: actionsPath,
          content: updatedContent,
          sha: fileResponse.sha,
          commitMessage: "Push mobile user actions",
        );
        
        // Clear local actions database table
        final actionIds = pendingActions.map((map) => map["id"] as int).toList();
        await _dbHelper.deleteActions(actionIds);
      }

      // --- STEP 2: FETCH REMOTE LEADS ---
      final leadsPath = prefs.getString(AppConstants.keyLeadsPath) ?? AppConstants.defaultLeadsPath;
      final leadsResponse = await source.fetchFile(leadsPath);
      
      int leadsCount = 0;
      if (leadsResponse.exists && leadsResponse.content.isNotEmpty) {
        final List<dynamic> leadsList = jsonDecode(leadsResponse.content);
        final List<Map<String, dynamic>> dbLeads = [];
        
        for (var item in leadsList) {
          final lead = LeadModel.fromJson(item);
          dbLeads.add(lead.toDbMap());
        }
        
        await _dbHelper.replaceAllLeads(dbLeads);
        leadsCount = dbLeads.length;
      }

      // --- STEP 3: FETCH REMOTE STATS ---
      try {
        final statsResponse = await source.fetchFile("data/stats.json");
        if (statsResponse.exists && statsResponse.content.isNotEmpty) {
          await _dbHelper.cacheStats(statsResponse.content);
        }
      } catch (e) {
        // Log error silently, statistics are secondary to leads data
      }

      return SyncResult(
        success: true, 
        message: "Sync completed. Downloaded $leadsCount leads.",
        leadsCount: leadsCount
      );
    } catch (e) {
      return SyncResult(success: false, message: "Sync failed: ${e.toString()}");
    }
  }

  /// Get cached stats
  Future<StatsModel> getStats() async {
    final cached = await _dbHelper.getCachedStats();
    if (cached != null && cached.isNotEmpty) {
      try {
        return StatsModel.fromJson(jsonDecode(cached));
      } catch (_) {
        return StatsModel.empty();
      }
    }
    return StatsModel.empty();
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int leadsCount;

  SyncResult({
    required this.success,
    required this.message,
    this.leadsCount = 0,
  });
}
