import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart'; // For UserSession
import '../data/app_database.dart'; // For data classes if needed

class SignOffService {
  static const String _baseUrl = 'https://clickpad.cloud/api';
  static const String _cloudUrl = 'https://clickpad.cloud';

  // Singleton
  static final SignOffService _instance = SignOffService._internal();
  factory SignOffService() => _instance;
  SignOffService._internal();

  // Headers helper
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'accept': '*/*',
  };

  // ===========================================================================
  // SITES (SignOff specific)
  // ===========================================================================

  Future<List<Map<String, dynamic>>> fetchSites() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/sites'), headers: _headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch sites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sites: $e');
      rethrow;
    }
  }

  Future<bool> createSite(Map<String, dynamic> siteData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sites'),
        headers: _headers,
        body: json.encode(siteData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating site: $e');
      return false;
    }
  }

  Future<bool> updateSite(String id, Map<String, dynamic> siteData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sites/$id'),
        headers: _headers,
        body: json.encode(siteData),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating site: $e');
      return false;
    }
  }

  Future<bool> deleteSite(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/sites/$id'), headers: _headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting site: $e');
      return false;
    }
  }

  // ===========================================================================
  // LOCATIONS (SignOff specific)
  // ===========================================================================

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/locations'), headers: _headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching locations: $e');
      rethrow;
    }
  }

  Future<bool> createLocation(Map<String, dynamic> locationData) async {
    try {
      print('📤 Creating location: ${json.encode(locationData)}');
      final response = await http.post(
        Uri.parse('$_baseUrl/locations'),
        headers: _headers,
        body: json.encode(locationData),
      );
      print('📥 Location create response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Location create failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error creating location: $e');
      return false;
    }
  }

  Future<bool> updateLocation(String id, Map<String, dynamic> locationData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/locations/$id'),
        headers: _headers,
        body: json.encode(locationData),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }

  Future<bool> deleteLocation(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/locations/$id'), headers: _headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting location: $e');
      return false;
    }
  }

  // ===========================================================================
  // SAFETY COMMUNICATIONS (SignOff Cards)
  // ===========================================================================

  Future<List<Map<String, dynamic>>> fetchSafetyCommunications() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/safety-communications'), headers: _headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch communications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching communications: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> fetchSafetyCommunicationById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/safety-communications/$id'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching communication by id $id: $e');
      return null;
    }
  }

  Future<bool> createSafetyCommunication(Map<String, dynamic> data) async {
    try {
      print('📤 Creating SafetyCommunication: ${json.encode(data)}');
      print('   Time field value: ${data['time']}');
      print('   Date field value: ${data['date']}');
      final response = await http.post(
        Uri.parse('$_baseUrl/safety-communications'),
        headers: _headers,
        body: json.encode(data),
      );
      print('📥 Response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating communication: $e');
      return false;
    }
  }

  Future<bool> updateSafetyCommunication(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/safety-communications/$id'),
        headers: _headers,
        body: json.encode(data),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating communication: $e');
      return false;
    }
  }

  Future<bool> deleteSafetyCommunication(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/safety-communications/$id'), headers: _headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting communication: $e');
      return false;
    }
  }

  // ===========================================================================
  // SIGNATURES
  // ===========================================================================

  Future<List<Map<String, dynamic>>> fetchSignatures() async {
    try {
      // NOTE: API seems to fetch all, we might need to filter locally or check if API supports filtering
      final response = await http.get(Uri.parse('$_baseUrl/safety-comm-signatures'), headers: _headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching signatures: $e');
      return [];
    }
  }
  
  // Fetch signatures specific to a communication
  // Since API for filtering isn't explicit in "GET /api/safety-comm-signatures", 
  // we assume we fetch all and filter client side OR user instructed "only show those were communicationId = id"
  Future<List<Map<String, dynamic>>> fetchSignaturesForComm(String communicationId) async {
    final all = await fetchSignatures();
    return all.where((s) => s['communicationId'] == communicationId).toList();
  }

  Future<bool> createSignature(Map<String, dynamic> data) async {
    try {
      print('📤 Creating signature: ${json.encode(data)}');
      final response = await http.post(
        Uri.parse('$_baseUrl/safety-comm-signatures'),
        headers: _headers,
        body: json.encode(data),
      );
      print('📥 Signature create response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error creating signature: $e');
      return false;
    }
  }

  Future<bool> updateSignature(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/safety-comm-signatures/$id'),
        headers: _headers,
        body: json.encode(data),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating signature: $e');
      return false;
    }
  }

  Future<bool> deleteSignature(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/safety-comm-signatures/$id'), headers: _headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting signature: $e');
      return false;
    }
  }

  // ===========================================================================
  // ANALYTICS / USAGE - Returns list of {id, name, count, percentage}
  // ===========================================================================
  
  /// Fetch sites usage: [{siteId, siteName, count, percentage}]
  Future<List<Map<String, dynamic>>> fetchSitesUsageList() async {
    final email = UserSession.userEmail ?? '';
    if (email.isEmpty) return [];
    
    try {
      // https://clickpad.cloud/sites-usage/{email}?isAdmin=true
      final url = '$_cloudUrl/sites-usage/${Uri.encodeComponent(email)}?isAdmin=${UserSession.isAdmin}';
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      print('Error fetching sites usage: $e');
      return [];
    }
  }
  
  /// Fetch locations usage for a site: [{locationId, locationName, count, percentage}]
  Future<List<Map<String, dynamic>>> fetchLocationsUsageList(String siteId) async {
    final email = UserSession.userEmail ?? '';
    if (email.isEmpty || siteId.isEmpty) return [];
    
    try {
      // https://clickpad.cloud/locations-usage/{siteId}/{email}?isAdmin=true
      final url = '$_cloudUrl/locations-usage/$siteId/${Uri.encodeComponent(email)}?isAdmin=${UserSession.isAdmin}';
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      print('Error fetching locations usage: $e');
      return [];
    }
  }

  /// Fetch user usage: [{user, count, percentage}]
  Future<List<Map<String, dynamic>>> fetchUserUsageList() async {
    final email = UserSession.userEmail ?? '';
    if (email.isEmpty) return [];
    
    try {
      // https://clickpad.cloud/user-usage/{email}?isAdmin=true
      final url = '$_cloudUrl/user-usage/${Uri.encodeComponent(email)}?isAdmin=${UserSession.isAdmin}';
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      print('Error fetching user usage: $e');
      return [];
    }
  }

  // Category usage - API returns [{name, count, percentage}]
  Future<List<Map<String, dynamic>>> fetchCategoryUsageList() async {
    final email = UserSession.userEmail ?? '';
    if (email.isEmpty) return [];
    
    try {
      final url = '$_cloudUrl/category-usage/${Uri.encodeComponent(email)}?isAdmin=${UserSession.isAdmin}';
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      print('Error fetching category usage: $e');
      return [];
    }
  }

  // Legacy methods for backwards compatibility
  Future<Map<String, int>> fetchCategoryUsage() async {
    final list = await fetchCategoryUsageList();
    // Convert to map: name -> count
    return {for (var e in list) (e['name']?.toString() ?? ''): (e['count'] as int? ?? 0)};
  }

  Future<Map<String, int>> fetchSitesUsage() async {
    final list = await fetchSitesUsageList();
    // Convert to map: siteName -> count
    return {for (var e in list) (e['siteName'] ?? e['siteId']?.toString() ?? ''): (e['count'] as int? ?? 0)};
  }

  Future<Map<String, int>> fetchLocationsUsage(String siteId) async {
    final list = await fetchLocationsUsageList(siteId);
    // Convert to map: locationName -> count
    return {for (var e in list) (e['locationName'] ?? e['locationId']?.toString() ?? ''): (e['count'] as int? ?? 0)};
  }

  Future<Map<String, int>> fetchUserUsage() async {
    final list = await fetchUserUsageList();
    // Convert to map: user -> count
    return {for (var e in list) (e['user']?.toString() ?? ''): (e['count'] as int? ?? 0)};
  }
  
  Future<Map<String, int>> _fetchUsageMap(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      print('Error fetching usage stats from $url: $e');
      return {};
    }
  }
}
