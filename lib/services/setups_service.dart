import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SetupsService {
  static const String _krcBaseUrl = 'https://clickpad.cloud/api/RiskCondition';
  static const String _sitesBaseUrl = 'https://clickpad.cloud/api/safety-sites';
  static const String _locationsBaseUrl = 'https://clickpad.cloud/api/safety-locations';
  static const String _appUsersBaseUrl = 'https://clickpad.cloud/api/AppUsers';
  static const Duration _timeout = Duration(seconds: 30);

  // ==================== KRC Methods ====================
  
  /// Fetch all Key Risk Conditions from server
  Future<List<Map<String, dynamic>>> fetchAllKRCs() async {
    try {
      print('📥 Fetching all KRCs from API...');
      
      final response = await http.get(
        Uri.parse(_krcBaseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        //print('📥 API Response Body: ${response.body}');
        final List<dynamic> data = json.decode(response.body);
        //print('✅ Fetched ${data.length} KRCs from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch KRCs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching KRCs: $e');
      rethrow;
    }
  }

  /// Create a new Key Risk Condition
  Future<bool> createKRC({
    required String id,
    required String name,
    String? imageUrl,
    String? url,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      print('📤 Creating new KRC: $name');
      
      var request = http.MultipartRequest('POST', Uri.parse(_krcBaseUrl));
      
      request.fields['Id'] = id;
      request.fields['Name'] = name;
      if (url != null) request.fields['Url'] = url;
      
      if (imageBytes != null && imageName != null) {
        final isPng = imageName.toLowerCase().endsWith('.png');
        final contentType = isPng ? MediaType('image', 'png') : MediaType('image', 'jpeg');
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'Image',
            imageBytes,
            filename: imageName,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Successfully created KRC: $name');
        return true;
      } else {
        print('❌ Failed to create KRC: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error creating KRC: $e');
      return false;
    }
  }

  /// Update an existing Key Risk Condition
  Future<bool> updateKRC({
    required String id,
    required String name,
    String? imageUrl,
    String? url,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      print('📤 Updating KRC: $name (ID: $id)');
      
      var request = http.MultipartRequest('PUT', Uri.parse('$_krcBaseUrl/$id'));
      
      request.fields['Id'] = id;
      request.fields['Name'] = name;
      if (url != null) request.fields['Url'] = url;
      
      if (imageBytes != null && imageName != null) {
        final isPng = imageName.toLowerCase().endsWith('.png');
        final contentType = isPng ? MediaType('image', 'png') : MediaType('image', 'jpeg');
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'Image',
            imageBytes,
            filename: imageName,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully updated KRC: $name');
        return true;
      } else {
        print('❌ Failed to update KRC: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating KRC: $e');
      return false;
    }
  }

  /// Delete a Key Risk Condition
  Future<bool> deleteKRC(String id) async {
    try {
      print('🗑️ Deleting KRC with ID: $id');
      
      final response = await http.delete(
        Uri.parse('$_krcBaseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully deleted KRC');
        return true;
      } else {
        print('❌ Failed to delete KRC: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting KRC: $e');
      return false;
    }
  }

  // ==================== Sites Methods ====================
  
  /// Fetch all Sites from server
  Future<List<Map<String, dynamic>>> fetchAllSites() async {
    try {
      print('📥 Fetching all sites from API...');
      
      final response = await http.get(
        Uri.parse(_sitesBaseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Fetched ${data.length} sites from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch sites: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching sites: $e');
      rethrow;
    }
  }

  /// Create a new Site
  Future<bool> createSite({
    required String id,
    required String name,
  }) async {
    try {
      print('📤 Creating new site: $name');
      
      final response = await http.post(
        Uri.parse(_sitesBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id, 'name': name}),
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Successfully created site: $name');
        return true;
      } else {
        print('❌ Failed to create site: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error creating site: $e');
      return false;
    }
  }

  /// Update an existing Site
  Future<bool> updateSite({
    required String id,
    required String name,
  }) async {
    try {
      print('📤 Updating site: $name (ID: $id)');
      
      final response = await http.put(
        Uri.parse('$_sitesBaseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id, 'name': name}),
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully updated site: $name');
        return true;
      } else {
        print('❌ Failed to update site: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating site: $e');
      return false;
    }
  }

  /// Delete a Site
  Future<bool> deleteSite(String id) async {
    try {
      print('🗑️ Deleting site with ID: $id');
      
      final response = await http.delete(
        Uri.parse('$_sitesBaseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully deleted site');
        return true;
      } else {
        print('❌ Failed to delete site: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting site: $e');
      return false;
    }
  }

  // ==================== Locations Methods ====================
  
  /// Fetch all Locations from server
  Future<List<Map<String, dynamic>>> fetchAllLocations() async {
    try {
      print('📥 Fetching all locations from API...');
      
      final response = await http.get(
        Uri.parse(_locationsBaseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Fetched ${data.length} locations from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch locations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching locations: $e');
      rethrow;
    }
  }

  /// Fetch locations by site ID
  Future<List<Map<String, dynamic>>> fetchLocationsBySite(String siteId) async {
    try {
      print('📥 Fetching locations for site: $siteId');
      
      final response = await http.get(
        Uri.parse('$_locationsBaseUrl/safety-site/$siteId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Fetched ${data.length} locations for site $siteId');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch locations for site: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching locations by site: $e');
      rethrow;
    }
  }

  /// Create a new Location
  Future<bool> createLocation({
    required String id,
    required String name,
    required String safetySiteID,
  }) async {
    try {
      print('📤 Creating new location: $name');
      
      final response = await http.post(
        Uri.parse(_locationsBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'id': id,
          'name': name,
          'safetySiteID': safetySiteID,
        }),
      ).timeout(_timeout);
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Successfully created location: $name');
        return true;
      } else {
        print('❌ Failed to create location: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error creating location: $e');
      return false;
    }
  }

  /// Update an existing Location
  Future<bool> updateLocation({
    required String id,
    required String name,
    required String safetySiteID,
  }) async {
    try {
      print('📤 Updating location: $name (ID: $id)');
      
      final response = await http.put(
        Uri.parse('$_locationsBaseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'name': name,
          'safetySiteID': safetySiteID,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully updated location: $name');
        return true;
      } else {
        print('❌ Failed to update location: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating location: $e');
      return false;
    }
  }

  /// Delete a Location
  Future<bool> deleteLocation(String id) async {
    try {
      print('🗑️ Deleting location with ID: $id');
      
      final response = await http.delete(
        Uri.parse('$_locationsBaseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully deleted location');
        return true;
      } else {
        print('❌ Failed to delete location: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting location: $e');
      return false;
    }
  }

  // ==================== AppUsers Methods ====================
  
  /// Fetch all App Users from server
  Future<List<Map<String, dynamic>>> fetchAllAppUsers() async {
    try {
      print('📥 Fetching all app users from API...');
      
      final response = await http.get(
        Uri.parse(_appUsersBaseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Fetched ${data.length} app users from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch app users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching app users: $e');
      rethrow;
    }
  }
}
