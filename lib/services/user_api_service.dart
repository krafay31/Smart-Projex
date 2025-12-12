// services/user_api_service.dart - COMPLETE IMPLEMENTATION
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserApiService {
  static const String _baseUrl = 'https://clickpad.cloud/api/AppUsers';

  /// 1. Fetch all users from the server
  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      print('📥 Fetching all users from API...');
      
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Fetched ${data.length} users from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
      throw Exception('Network error: $e');
    }
  }

  /// 2. Fetch user by email from the server
  static Future<Map<String, dynamic>?> fetchUserByEmail(String email) async {
    try {
      print('📥 Fetching user by email: $email');
      
      final encodedEmail = Uri.encodeComponent(email);
      final response = await http.get(
        Uri.parse('$_baseUrl/by-email?email=$encodedEmail'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Fetched user data for: ${data['name']}');
        print('   - userId: ${data['userId']}');
        print('   - currentSite: ${data['currentSite']}');
        print('   - currentLocation: ${data['currentLocation']}');
        print('   - currentDepartment: ${data['currentDepartment']}');
        return data;
      } else if (response.statusCode == 404) {
        print('⚠️ User not found: $email');
        return null;
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching user by email: $e');
      throw Exception('Network error: $e');
    }
  }

  /// 3. Update user preferences (site, location, department)
  static Future<bool> updateUserPreferences({
    required String userId,
    required String name,
    required String securityLevel,
    required String loginEmail,
    required String currentSite,
    required String currentLocation,
    required String currentDepartment,
  }) async {
    try {
      print('📤 Updating user preferences for: $userId');
      
      // ✅ FIXED: Include ALL required fields in PUT request
      final requestBody = {
        'userId': userId,
        'name': name,
        'securityLevel': securityLevel,
        'loginEmail': loginEmail,
        'currentSite': currentSite,
        'currentLocation': currentLocation,
        'currentDepartment': currentDepartment,
      };

      print('Request URL: $_baseUrl/$userId');
      print('Request body: ${json.encode(requestBody)}');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 60));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ User preferences updated successfully');
        return true;
      } else {
        print('❌ Failed to update user preferences: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating user preferences: $e');
      return false;
    }
  }
}