import '../data/app_database.dart';
import '../services/setups_service.dart';
import '../main.dart';
import 'package:drift/drift.dart';

/// Helper class to fetch KRCs from server and map them to KeyRiskCondition objects
class KrcHelper {
  /// Fetch all Key Risk Conditions from server as mapped objects
  static Future<List<KeyRiskCondition>> fetchFromServer() async {
    try {
      final setupsService = SetupsService();
      final serverKrcs = await setupsService.fetchAllKRCs();
      
      // Fetch all local KRCs to check for existing records
      final localKrcs = await db.select(db.keyRiskConditions).get();
      
      // Create maps for quick lookup
      final hexIdMap = {for (var k in localKrcs) k.hexId: k};
      final nameMap = {for (var k in localKrcs) k.name.toLowerCase(): k};
      
      final List<KeyRiskCondition> resultList = [];
      
      for (var data in serverKrcs) {
        final hexId = data['id']?.toString() ?? '';
        final name = data['name']?.toString() ?? '';
        
        // Determine icon URL
        String icon = 'other.png';
        if (data['url'] != null && data['url'].toString().startsWith('http')) {
          icon = data['url'].toString();
        } else if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
          String imgUrl = data['imageUrl'].toString();
          if (imgUrl.contains('Risk_Conditions_Images')) {
             icon = 'https://clickpad.cloud/media/$imgUrl';
          } else {
             icon = imgUrl;
          }
        }
        
        // 1. Try to find by HexID
        KeyRiskCondition? existing = hexIdMap[hexId];
        
        // 2. If not found, try to find by Name (Legacy data linking)
        if (existing == null) {
          existing = nameMap[name.toLowerCase()];
        }
        
        int localId;
        
        if (existing != null) {
          // UPDATE existing record
          localId = existing.id;
          await (db.update(db.keyRiskConditions)..where((k) => k.id.equals(localId))).write(
            KeyRiskConditionsCompanion(
              name: Value(name),
              icon: Value(icon),
              hexId: Value(hexId),
            ),
          );
        } else {
          // INSERT new record
          localId = await db.into(db.keyRiskConditions).insert(
            KeyRiskConditionsCompanion(
              name: Value(name),
              icon: Value(icon),
              hexId: Value(hexId),
            ),
          );
        }
        
        resultList.add(KeyRiskCondition(
          id: localId,
          name: name,
          icon: icon,
          hexId: hexId,
        ));
      }
      
      return resultList;
    } catch (e) {
      print('❌ Error fetching/syncing KRCs: $e');
      // Fallback to local data if server fails
      try {
        return await db.select(db.keyRiskConditions).get();
      } catch (e2) {
        return [];
      }
    }
  }
}
