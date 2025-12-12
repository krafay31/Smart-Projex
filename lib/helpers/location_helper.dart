import '../data/app_database.dart';
import '../services/setups_service.dart';
import '../main.dart';
import 'site_helper.dart';
import 'package:drift/drift.dart';

/// Helper class to fetch Locations from server and map them to Location objects
class LocationHelper {
  /// Fetch all Locations from server as mapped objects
  static Future<List<Location>> fetchFromServer() async {
    try {
      final setupsService = SetupsService();
      final serverData = await setupsService.fetchAllLocations();
      
      // Fetch local locations
      final localLocations = await db.allLocations();
      
      // Create maps for quick lookup
      final uuidMap = {for (var l in localLocations) l.uuid: l};
      final nameMap = {for (var l in localLocations) l.name.toLowerCase(): l};
      
      // We need Site mapping to resolve safetySiteID (UUID) to local Site ID (int)
      // Ensure Sites are synced first
      final sites = await SiteHelper.fetchFromServer();
      final siteUuidToId = {for (var s in sites) s.uuid: s.id};
      
      final List<Location> resultList = [];
      
      for (var d in serverData) {
        final uuid = d['id']?.toString() ?? '';
        final name = d['name']?.toString() ?? '';
        final safetySiteID = d['safetySiteID']?.toString() ?? '';
        
        // Resolve Site ID
        final siteIntId = siteUuidToId[safetySiteID];
        
        // If site doesn't exist locally (shouldn't happen if we synced sites), skip or use default
        if (siteIntId == null) {
          print('⚠️ Warning: Location $name has unknown site UUID $safetySiteID');
          continue; 
        }
        
        // Check if location already exists by UUID
        final existing = await (db.select(db.locations)
          ..where((l) => l.uuid.equals(uuid))).getSingleOrNull();
        
        int localId;
        if (existing != null) {
          // Update existing location
          await (db.update(db.locations)..where((l) => l.uuid.equals(uuid))).write(
            LocationsCompanion(
              name: Value(name),
              siteId: Value(siteIntId),
            ),
          );
          localId = existing.id;
        } else {
          // Insert new location
          localId = await db.into(db.locations).insert(
            LocationsCompanion(
              name: Value(name),
              siteId: Value(siteIntId),
              uuid: Value(uuid),
            ),
          );
        }
        
        resultList.add(Location(
          id: localId,
          name: name,
          siteId: siteIntId,
          uuid: uuid,
        ));
      }
      
      return resultList;
    } catch (e) {
      print('❌ Error fetching/syncing Locations: $e');
      try {
        return await db.allLocations();
      } catch (e2) {
        return [];
      }
    }
  }
  
  /// Fetch locations for a specific site
  static Future<List<Location>> fetchBySite(String siteUuid) async {
    try {
      // Since we need to ensure local DB is synced for IDs to match,
      // we should call fetchFromServer() which handles the sync.
      // Then we filter the results.
      
      // 1. Ensure all locations are synced
      final allLocations = await fetchFromServer();
      
      // 2. Get the Site ID for the requested UUID
      final sites = await SiteHelper.fetchFromServer();
      final site = sites.firstWhere((s) => s.uuid == siteUuid, orElse: () => sites.first);
      
      // 3. Filter locations for this site
      return allLocations.where((l) => l.siteId == site.id).toList();
      
    } catch (e) {
      print('❌ Error fetching Location objects by site: $e');
      return [];
    }
  }
}
