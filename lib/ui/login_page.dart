// login_page.dart - UPDATED with API authentication

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:safety_card_web/utils/app_colors.dart';
import '../data/app_database.dart';
import '../main.dart';
import 'user_preferences_page.dart';
import '../utils/responsive_utils.dart';
import '../services/user_api_service.dart';
import '../services/sync_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 🆕 STEP 1: Fetch all users from API and sync to database
      print('📥 Fetching all users from API...');
      final allUsers = await UserApiService.fetchAllUsers();
      await db.syncUsersFromApi(allUsers);
      print('✅ Users synced to database');

      // 🆕 STEP 2: Fetch specific user by email
      print('📥 Fetching user by email: ${_emailController.text}');
      final userData = await UserApiService.fetchUserByEmail(_emailController.text);
      
      if (userData == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email address')),
        );
        setState(() => _loading = false);
        return;
      }

      // 🆕 STEP 3: Find user in local database
      final user = await db.findAppUserByEmail(_emailController.text);
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found in database')),
        );
        setState(() => _loading = false);
        return;
      }

      // 🆕 STEP 4: Set user session with API data
      UserSession.userId = user.id;
      UserSession.appUserId = user.id;
      UserSession.userName = userData['name'];
      UserSession.userEmail = userData['loginEmail'];
      UserSession.isAdmin = userData['securityLevel'] == 'Admin';
      UserSession.apiUserId = userData['userId']; // Store API userId (e.g., "talha_abbas")
      
      print('✅ User logged in: ${userData['name']} (${userData['securityLevel']})');
      print('   - API User ID: ${userData['userId']}');
      print('   - Local User ID: ${UserSession.userId}');

      // 🆕 STEP 5: Check if user has preferences set in API response
      final currentSite = userData['currentSite']?.toString();
      final currentLocation = userData['currentLocation']?.toString();
      final currentDepartment = userData['currentDepartment']?.toString();

      if (currentSite != null && currentLocation != null && currentDepartment != null) {
        // Convert site UUID to local site ID
        final sites = await db.allSites();
        final site = sites.firstWhere(
          (s) => s.uuid == currentSite,
          orElse: () => sites.first,
        );
        
        // Convert location UUID to local location ID
        final locations = await db.allLocations();
        final location = locations.firstWhere(
          (l) => l.uuid == currentLocation,
          orElse: () => locations.first,
        );
        
        // Save preferences locally
        await UserSession.savePreferences(currentDepartment, site.id, location.id);
        print('✅ Preferences loaded from API: Site=${site.name}, Location=${location.name}, Dept=$currentDepartment');
      }

      // Save the login session
      await UserSession.saveLoginSession();
      
      if (!mounted) return;
      
      // 🆕 STEP 6: Run initial sync if preferences exist
      if (UserSession.userSiteId != null && UserSession.userLocationId != null) {
        print('Preferences found, loading first page...');
        
        try {
          // Sync sites and locations first
          await syncService.syncSitesAndLocations();
          print('Sites and locations synced');
          
          // ðŸ†• Use filtered API with proper date range
          print('Loading first page of safety cards (50 cards)...');
          final emptyDateTime = DateTime.fromMillisecondsSinceEpoch(0);
          final now = DateTime.now();
          
          final result = await syncService.fetchFilteredCards(
            pageNumber: 1,
            pageSize: 50,
            dateFrom: emptyDateTime,
            dateTo: now,
          );
          print('✅ Initial page loaded: ${result.cards.length} cards');
          
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.cards.length} records loaded. More will load as you navigate.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } catch (e) {
          print('⚠️ Initial load failed: $e');
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Load failed: $e\nYou can load more from the home page.'),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.orange,
            ),
          );
        }
        
        if (!mounted) return;
        print('✅ Going to home page');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        print('📄 No preferences found, redirecting to preferences page');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserPreferencesPage()),
        );
      }
      
    } catch (e) {
      print('❌ Login error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          final isMobile = screenSize == ScreenSize.mobile;
          final isTablet = screenSize == ScreenSize.tablet;
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2D7CF6).withOpacity(0.1),
                  AppColors.textPrimary.withOpacity(0.1),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : (isTablet ? 40 : 60),
                  vertical: isMobile ? 24 : 40,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : (isTablet ? 500 : 480),
                  ),
                  child: Card(
                    elevation: isMobile ? 2 : (isTablet ? 6 : 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : (isTablet ? 40 : 48),
                        vertical: isMobile ? 32 : (isTablet ? 44 : 48),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo/Icon
                          Container(
                            padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 18 : 20)),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.security,
                              size: isMobile ? 32 : (isTablet ? 40 : 48),
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: isMobile ? 16 : (isTablet ? 20 : 24)),
                          
                          // Title
                          Text(
                            'Smart Projex',
                            style: TextStyle(
                              fontSize: isMobile ? 20 : (isTablet ? 24 : 28),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Safety Management System',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : (isTablet ? 17 : 20),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2D7CF6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isMobile ? 6 : 8),
                          Text(
                            'Sign in to continue',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isMobile ? 13 : (isTablet ? 14 : 15),
                            ),
                          ),
                          SizedBox(height: isMobile ? 24 : (isTablet ? 32 : 40)),
                          
                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !_loading,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 15,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                    ),
                                    hintText: 'Enter your email',
                                    hintStyle: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      size: isMobile ? 20 : 22,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: isMobile ? 14 : 16,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!v.contains('@') || !v.contains('.')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                
                                if (_error != null) ...[
                                  SizedBox(height: isMobile ? 12 : 16),
                                  Container(
                                    padding: EdgeInsets.all(isMobile ? 10 : 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red[700],
                                          size: isMobile ? 18 : 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _error!,
                                            style: TextStyle(
                                              color: Colors.red[700],
                                              fontSize: isMobile ? 13 : 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                SizedBox(height: isMobile ? 20 : (isTablet ? 22 : 24)),
                                
                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: isMobile ? 46 : (isTablet ? 48 : 50),
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.textPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _loading ? null : _login,
                                    child: _loading
                                        ? SizedBox(
                                            width: isMobile ? 18 : 20,
                                            height: isMobile ? 18 : 20,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: isMobile ? 15 : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isMobile ? 20 : (isTablet ? 22 : 24)),
                          
                          // Footer
                          Text(
                            'Powered by Smart Projex',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: isMobile ? 11 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}