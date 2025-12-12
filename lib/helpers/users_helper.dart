import '../data/app_database.dart';
import '../services/setups_service.dart';

/// Helper class to fetch Users from server and map them to UserLite objects
class UsersHelper {
  /// Fetch all App Users from server as mapped UserLite objects
  static Future<List<UserLite>> fetchFromServer() async {
    try {
      final setupsService = SetupsService();
      final data = await setupsService.fetchAllAppUsers();
      
      var idCounter = 1;
      final seenNames = <String>{};
      
      return data.where((d) {
        final name = d['name']?.toString() ?? '';
        // Filter out duplicates by name
        if (seenNames.contains(name)) return false;
        seenNames.add(name);
        return name.isNotEmpty;
      }).map((d) {
        final name = d['name']?.toString() ?? '';
        final intId = idCounter++;
        
        return UserLite(
          id: intId,
          name: name,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching User objects from server: $e');
      return [];
    }
  }
}
