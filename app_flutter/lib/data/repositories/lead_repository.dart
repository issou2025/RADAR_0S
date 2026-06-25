import '../local/database_helper.dart';
import '../models/lead_model.dart';

class LeadRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<LeadModel>> getAllLeads() async {
    final maps = await _dbHelper.getAllLeads();
    return maps.map((map) => LeadModel.fromDbMap(map)).toList();
  }

  Future<LeadModel?> getLeadById(String id) async {
    final map = await _dbHelper.getLead(id);
    if (map != null) return LeadModel.fromDbMap(map);
    return null;
  }

  Future<void> updateLeadStatus(String id, String status) async {
    // 1. Update SQLite local lead status
    await _dbHelper.updateLeadStatus(id, status);
    
    // 2. Queue action for remote synchronization
    await _dbHelper.insertAction(id, "change_status", status);
  }

  Future<void> updateLeadNotes(String id, String notes) async {
    // 1. Update SQLite local notes
    await _dbHelper.updateLeadNotes(id, notes);
    
    // 2. Queue action for remote synchronization
    await _dbHelper.insertAction(id, "update_notes", notes);
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final status = isFavorite ? "favorite" : "new";
    await _dbHelper.updateLeadStatus(id, status);
    await _dbHelper.insertAction(id, "toggle_favorite", isFavorite ? "true" : "false");
  }

  Future<void> clearAllData() async {
    await _dbHelper.clearAllData();
  }
}
