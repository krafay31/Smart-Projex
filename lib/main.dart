// ignore_for_file: unused_import

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_database.dart';
import 'services/sync_service.dart';
import 'ui/login_page.dart';
import 'ui/home_page.dart';
import 'ui/user_preferences_page.dart';
import 'ui/sign_off/sign_off_page.dart';

final db = AppDatabase();
final syncService = SyncService(); // Global sync service instance

class UserSession {
  static int? userId;
  static int? appUserId;
  static String? userName;
  static String? userEmail;
  static bool isAdmin = false;

  // 🆕 NEW: Store API user ID (userId from API response like "talha_abbas")
  static String? apiUserId;
  
  // User preferences
  static String? userDepartment;
  static int? userSiteId;
  static int? userLocationId;
  static List<int> adminUserIds = [];  

  static late SharedPreferences _prefs;

  // Session persistence keys
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyIsAdmin = 'isAdmin';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyApiUserId = 'apiUserId'; // 🆕 NEW
  static const String _keyAppUserId = 'appUserId';

  /// Initialize session from storage on app start
  static Future<bool> initializeSession() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final isLoggedIn = _prefs.getBool(_keyIsLoggedIn) ?? false;
      
      if (isLoggedIn) {
        userId = _prefs.getInt(_keyUserId);
        appUserId = _prefs.getInt(_keyAppUserId);
        userName = _prefs.getString(_keyUserName);
        userEmail = _prefs.getString(_keyUserEmail);
        isAdmin = _prefs.getBool(_keyIsAdmin) ?? false;
        apiUserId = _prefs.getString(_keyApiUserId); // 🆕 NEW
        
        // Also load user preferences
        await loadPreferences();
        
        print('📱 Session restored: $userName (${isAdmin ? "Admin" : "User"})');
        print('🆔 API User ID: $apiUserId');
        print('🆔 App User ID: $appUserId');
        print('🆔 Local User ID: $userId');
        return true;
      }
      
      print('🔒 No saved session found');
      return false;
    } catch (e) {
      print('❌ Error initializing session: $e');
      return false;
    }
  }

  static Future<void> loadPreferences() async {
    if (!_isPrefsInitialized()) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    userEmail = _prefs.getString(_keyUserEmail);
    userName = _prefs.getString(_keyUserName);
    userId = _prefs.getInt(_keyUserId);
    appUserId = _prefs.getInt(_keyAppUserId);
    isAdmin = _prefs.getBool(_keyIsAdmin) ?? false;
    apiUserId = _prefs.getString(_keyApiUserId); // 🆕 NEW
    userSiteId = _prefs.getInt('userSiteId');
    userLocationId = _prefs.getInt('userLocationId');
    userDepartment = _prefs.getString('userDepartment');
    
    print('📱 Loaded user session: $userName');
    print('   - User ID: $userId');
    print('   - AppUser ID: $appUserId');
    print('   - API User ID: $apiUserId'); // 🆕 NEW
    print('   - Admin: $isAdmin');
  }

  static Future<void> savePreferences(
    String department, int siteId, int locationId) async {
    if (!_isPrefsInitialized()) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    userDepartment = department;
    userSiteId = siteId;
    userLocationId = locationId;
    
    await _prefs.setString('userDepartment', department);
    await _prefs.setInt('userSiteId', siteId);
    await _prefs.setInt('userLocationId', locationId);
  }

  /// Save login session (call this after successful login)
  static Future<void> saveLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (userId != null) await prefs.setInt(_keyUserId, userId!);
    if (appUserId != null) await prefs.setInt(_keyAppUserId, appUserId!);
    if (userName != null) await prefs.setString(_keyUserName, userName!);
    if (userEmail != null) await prefs.setString(_keyUserEmail, userEmail!);
    await prefs.setBool(_keyIsAdmin, isAdmin);
    
    // 🆕 NEW: Save API user ID
    if (apiUserId != null) await prefs.setString(_keyApiUserId, apiUserId!);
    
    // Mark as logged in
    await prefs.setBool(_keyIsLoggedIn, true);
    
    print('💾 Session saved to storage');
    print('   - API User ID: $apiUserId');
  }

  /// Clear all session data (call on logout)
  static Future<void> clear() async {
    userEmail = null;
    userName = null;
    userId = null;
    appUserId = null;
    apiUserId = null; // 🆕 NEW
    isAdmin = false;
    userSiteId = null;
    userLocationId = null;
    userDepartment = null;
    
    if (!_isPrefsInitialized()) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    await _prefs.clear();
    print('🚪 Session cleared');
  }

  // Helper method to check if _prefs is initialized
  static bool _isPrefsInitialized() {
    try {
      _prefs.getBool('test');
      return true;
    } catch (e) {
      return false;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sync service
  syncService.initialize();
  
  // Check for existing session
  final hasSession = await UserSession.initializeSession();
  
  runApp(SafetyCardWebApp(hasSession: hasSession));
}

class SafetyCardWebApp extends StatelessWidget {
  final bool hasSession;
  
  const SafetyCardWebApp({super.key, required this.hasSession});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Cards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2D7CF6),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      // Use initialRoute instead of home to work with routes
      initialRoute: _getInitialRoute(),
      routes: {
        '/': (context) => const LoginPage(),
        '/preferences': (context) => const UserPreferencesPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }

  String _getInitialRoute() {
    if (!hasSession) {
      // No session - go to login
      print('🔒 No session found, showing login page');
      return '/';
    }
    
    // Has session - check if preferences are set
    // if (UserSession.userSiteId == null || UserSession.userLocationId == null) {
      print('🔄 Session restored but no preferences, showing preferences page');
      return '/preferences';
    // }
    
    print('✅ Session and preferences restored, showing home page');
    return '/home';
  }
}