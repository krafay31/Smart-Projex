// helpers/analytics_helper.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

/// Helper class for fetching analytics data from the API
class AnalyticsHelper {
  static const String _baseUrl = 'https://clickpad.cloud/api/analytics';

  /// Fetch site usage statistics
  static Future<Map<String, int>> fetchSiteUsage() async {
    try {
      final email = Uri.encodeComponent(UserSession.userEmail ?? '');
      final isAdmin = UserSession.isAdmin;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/safety-sites-usage/$email?isAdmin=$isAdmin'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, int> usageMap = {};
        
        for (var item in data) {
          final siteId = item['siteId']?.toString();
          final count = item['count'] as int? ?? 0;
          if (siteId != null) {
            usageMap[siteId] = count;
          }
        }
        
        return usageMap;
      }
      return {};
    } catch (e) {
      print('Error fetching site usage: $e');
      return {};
    }
  }

  /// Fetch location usage statistics for a specific site
  static Future<Map<String, int>> fetchLocationUsage(String siteUuid) async {
    try {
      final email = Uri.encodeComponent(UserSession.userEmail ?? '');
      final isAdmin = UserSession.isAdmin;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/safety-locations-usage/$siteUuid/$email?isAdmin=$isAdmin'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, int> usageMap = {};
        
        for (var item in data) {
          final locationId = item['locationId']?.toString();
          final count = item['count'] as int? ?? 0;
          if (locationId != null) {
            usageMap[locationId] = count;
          }
        }
        
        return usageMap;
      }
      return {};
    } catch (e) {
      print('Error fetching location usage: $e');
      return {};
    }
  }

  /// Fetch KRC usage statistics
  static Future<Map<String, int>> fetchKrcUsage() async {
    try {
      final email = Uri.encodeComponent(UserSession.userEmail ?? '');
      final isAdmin = UserSession.isAdmin;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/krc-usage/$email?isAdmin=$isAdmin'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, int> usageMap = {};
        
        for (var item in data) {
          final krcId = item['krcId']?.toString();
          final count = item['count'] as int? ?? 0;
          if (krcId != null) {
            usageMap[krcId] = count;
          }
        }
        
        return usageMap;
      }
      return {};
    } catch (e) {
      print('Error fetching KRC usage: $e');
      return {};
    }
  }

  /// Fetch user usage statistics
  static Future<Map<String, int>> fetchUserUsage() async {
    try {
      final email = Uri.encodeComponent(UserSession.userEmail ?? '');
      final isAdmin = UserSession.isAdmin;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/safety-user-usage/$email?isAdmin=$isAdmin'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, int> usageMap = {};
        
        for (var item in data) {
          final userEmail = item['userEmail']?.toString();
          final count = item['count'] as int? ?? 0;
          if (userEmail != null) {
            usageMap[userEmail] = count;
          }
        }
        
        return usageMap;
      }
      return {};
    } catch (e) {
      print('Error fetching user usage: $e');
      return {};
    }
  }
}