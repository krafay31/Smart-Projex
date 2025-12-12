import '../data/app_database.dart';
import '../services/setups_service.dart';
import '../main.dart';
import 'package:drift/drift.dart';

/// Helper class to fetch Sites from server and map them to Site objects
class SiteHelper {
  /// Fetch all Sites from server as mapped objects
  static Future<List<Site>> fetchFromServer() async {
    try {
      final setupsService = SetupsService();
      final serverData = await setupsService.fetchAllSites();
      
      // Fetch local sites to check for existing records
      final localSites = await db.allSites();
      
      // Create maps for quick lookup
      final uuidMap = {for (var s in localSites) s.uuid: s};
      final nameMap = {for (var s in localSites) s.name.toLowerCase(): s};
      
      final List<Site> resultList = [];
      
      for (var d in serverData) {
        final uuid = d['id']?.toString() ?? '';
        final name = d['name']?.toString() ?? '';
        
        // 1. Try to find by UUID
        Site? existing = uuidMap[uuid];
        
        // 2. If not found, try to find by Name (Legacy data linking)
        if (existing == null) {
          existing = nameMap[name.toLowerCase()];
        }
        
        int localId;
        
        if (existing != null) {
          // UPDATE existing record
          localId = existing.id;
          await (db.update(db.sites)..where((s) => s.id.equals(localId))).write(
            SitesCompanion(
              name: Value(name),
              uuid: Value(uuid),
            ),
          );
        } else {
          // INSERT new record
          localId = await db.into(db.sites).insert(
            SitesCompanion(
              name: Value(name),
              uuid: Value(uuid),
            ),
          );
        }
        
        resultList.add(Site(
          id: localId,
          name: name,
          uuid: uuid,
        ));
      }
       
      return resultList;
    } catch (e) {
      print('❌ Error fetching/syncing Sites: $e');
      // Fallback to local data
      try {
        return await db.allSites();
      } catch (e2) {
        return [];
      }
    }
  }
}
