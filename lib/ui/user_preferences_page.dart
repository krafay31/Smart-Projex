// user_preferences_page.dart - UPDATED with API integration

import 'package:flutter/material.dart';
import 'package:safety_card_web/utils/app_colors.dart';
import '../data/app_database.dart';
import '../main.dart';
import '../utils/responsive_utils.dart';
import 'home_page.dart';
import '../services/sync_service.dart';
import '../services/user_api_service.dart';
import '../helpers/site_helper.dart';
import '../helpers/location_helper.dart';

class UserPreferencesPage extends StatefulWidget {
  const UserPreferencesPage({super.key});

  @override
  State<UserPreferencesPage> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  
  int? _siteId;
  int? _locationId;
  String _department = 'Services';
  
  late Future<List<Site>> _sitesFuture;
  List<Location> _locations = [];
  bool _loading = false;
  bool _isLoadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _sitesFuture = SiteHelper.fetchFromServer();
    _loadExistingPreferences();
  }

  Future<void> _loadExistingPreferences() async {
    try {
      // 🆕 STEP 1: Try to load preferences from API first
      if (UserSession.userEmail != null) {
        print('📥 Loading preferences from API for: ${UserSession.userEmail}');
        final userData = await UserApiService.fetchUserByEmail(UserSession.userEmail!);
        
        if (userData != null) {
          final currentSite = userData['currentSite']?.toString();
          final currentLocation = userData['currentLocation']?.toString();
          final currentDepartment = userData['currentDepartment']?.toString();
          
          print('   - API currentSite: $currentSite');
          print('   - API currentLocation: $currentLocation');
          print('   - API currentDepartment: $currentDepartment');
          
          if (currentSite != null && currentLocation != null && currentDepartment != null) {
            // Convert site UUID to local site ID
            final sites = await SiteHelper.fetchFromServer();
            final site = sites.firstWhere(
              (s) => s.uuid == currentSite,
              orElse: () => sites.first,
            );
            
            // Load locations for that site
            _locations = await LocationHelper.fetchBySite(site.uuid);
            
            // Convert location UUID to local location ID
            final location = _locations.firstWhere(
              (l) => l.uuid == currentLocation,
              orElse: () => _locations.first,
            );
            
            setState(() {
              _siteId = site.id;
              _locationId = location.id;
              _department = currentDepartment;
            });
            
            // Save to local storage
            await UserSession.savePreferences(currentDepartment, site.id, location.id);
            
            print('✅ Preferences loaded from API: Site=${site.name}, Location=${location.name}, Dept=$currentDepartment');
          }
        }
      }
      
      // STEP 2: If API didn't provide preferences, load from local storage
      if (_siteId == null) {
        await UserSession.loadPreferences();
        
        if (UserSession.userSiteId != null) {
          setState(() {
            _siteId = UserSession.userSiteId;
            _department = UserSession.userDepartment ?? 'Services';
          });
          
          // Need to fetch site UUID to get locations
          final sites = await SiteHelper.fetchFromServer();
          final site = sites.firstWhere((s) => s.id == _siteId, orElse: () => sites.first);
          
          _locations = await LocationHelper.fetchBySite(site.uuid);
          
          if (UserSession.userLocationId != null && 
              _locations.any((l) => l.id == UserSession.userLocationId)) {
            setState(() {
              _locationId = UserSession.userLocationId;
            });
          }
        }
      }
    } catch (e) {
      print('❌ Error loading preferences: $e');
    } finally {
      setState(() {
        _isLoadingPreferences = false;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_siteId == null || _locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Site and Location')),
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      // 🆕 STEP 1: Get site and location UUIDs
      final sites = await SiteHelper.fetchFromServer();
      final site = sites.firstWhere((s) => s.id == _siteId);
      
      final locations = await LocationHelper.fetchFromServer();
      final location = locations.firstWhere((l) => l.id == _locationId);
      
      print('📤 Saving preferences:');
      print('   - Site: ${site.name} (UUID: ${site.uuid})');
      print('   - Location: ${location.name} (UUID: ${location.uuid})');
      print('   - Department: $_department');
      
      // 🆕 STEP 2: Update preferences on server using API userId
      if (UserSession.apiUserId != null) {
        print('📤 Updating preferences on server for user: ${UserSession.apiUserId}');
        
        final userData = await UserApiService.fetchUserByEmail(UserSession.userEmail!);
        if (userData == null) {
          throw Exception('User data not found');
        }

        final success = await UserApiService.updateUserPreferences(
          userId: UserSession.apiUserId!,
          name: UserSession.userName ?? '',
          securityLevel: userData['securityLevel'] ?? 'User', // Use actual security level from API
          loginEmail: UserSession.userEmail ?? '',
          currentSite: site.uuid,
          currentLocation: location.uuid,
          currentDepartment: _department,
        );
        
        if (!success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Warning: Failed to update preferences on server'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('✅ Preferences updated on server');
        }
      } else {
        print('⚠️ No API user ID available, skipping server update');
      }
      
      // STEP 3: Save preferences locally
      await UserSession.savePreferences(_department, _siteId!, _locationId!);
      print('✅ Preferences saved locally');
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to home page immediately
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      print('❌ Error during save: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
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
              child: _isLoadingPreferences
                  ? const CircularProgressIndicator()
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : (isTablet ? 24 : 40),
                        vertical: isMobile ? 16 : (isTablet ? 24 : 32),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : (isTablet ? 500 : 560),
                        ),
                        child: Card(
                          elevation: isMobile ? 1 : (isTablet ? 4 : 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20 : (isTablet ? 32 : 40),
                              vertical: isMobile ? 24 : (isTablet ? 36 : 40),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.all(isMobile ? 10 : (isTablet ? 14 : 14)),
                                      decoration: BoxDecoration(
                                        color: AppColors.textPrimary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.settings,
                                        size: isMobile ? 28 : (isTablet ? 32 : 36),
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 14 : 20),
                                  
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Welcome, ${UserSession.userName ?? "User"}!',
                                          style: TextStyle(
                                            fontSize: isMobile ? 16 : (isTablet ? 20 : 22),
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: isMobile ? 4 : 6),
                                        Text(
                                          'Set your default work location',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: isMobile ? 11 : (isTablet ? 13 : 14),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 20 : (isTablet ? 24 : 28)),
                                  
                                  // Site Selection
                                  Text(
                                    'Site',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isMobile ? 11 : (isTablet ? 13 : 14),
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  FutureBuilder<List<Site>>(
                                    future: _sitesFuture,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(isMobile ? 8 : 12),
                                            child: const CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      
                                      final sites = snapshot.data!;
                                      return DropdownButtonFormField<int>(
                                        decoration: InputDecoration(
                                          hintText: 'Select your site',
                                          hintStyle: TextStyle(
                                            fontSize: isMobile ? 11 : (isTablet ? 13 : 14),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 12 : 14,
                                            vertical: isMobile ? 10 : (isTablet ? 12 : 14),
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontSize: isMobile ? 12 : (isTablet ? 14 : 15),
                                          color: const Color(0xFF111827),
                                        ),
                                        value: _siteId,
                                        items: sites.map((s) {
                                          return DropdownMenuItem<int>(
                                            value: s.id,
                                            child: Text(s.name),
                                          );
                                        }).toList(),
                                        onChanged: (v) async {
                                          if (v != null) {
                                            setState(() {
                                              _siteId = v;
                                              _locationId = null;
                                              _locations = [];
                                            });
                                            
                                            // Fetch locations from server using site UUID
                                            final site = sites.firstWhere((s) => s.id == v);
                                            final newLocations = await LocationHelper.fetchBySite(site.uuid);
                                            
                                            setState(() {
                                              _locations = newLocations;
                                            });
                                          }
                                        },
                                        validator: (v) => v == null ? 'Please select a site' : null,
                                      );
                                    },
                                  ),
                                  SizedBox(height: isMobile ? 12 : (isTablet ? 16 : 18)),
                                  
                                  // Location Selection
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isMobile ? 11 : (isTablet ? 13 : 14),
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    key: ValueKey('location_dropdown_${_siteId}_${_locations.length}'),
                                    decoration: InputDecoration(
                                      hintText: _locations.isEmpty 
                                          ? 'Select a site first' 
                                          : 'Select your location',
                                      hintStyle: TextStyle(
                                        fontSize: isMobile ? 11 : (isTablet ? 13 : 14),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 12 : 14,
                                        vertical: isMobile ? 10 : (isTablet ? 12 : 14),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : (isTablet ? 14 : 15),
                                      color: const Color(0xFF111827),
                                    ),
                                    value: _locationId,
                                    items: _locations.isEmpty 
                                        ? null
                                        : _locations.map((l) {
                                            return DropdownMenuItem<int>(
                                              value: l.id,
                                              child: Text(l.name),
                                            );
                                          }).toList(),
                                    onChanged: _locations.isEmpty 
                                        ? null 
                                        : (v) => setState(() => _locationId = v),
                                    validator: (v) => v == null ? 'Please select a location' : null,
                                  ),
                                  SizedBox(height: isMobile ? 12 : (isTablet ? 16 : 18)),
                                  
                                  // Department
                                  Text(
                                    'Department',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isMobile ? 11 : (isTablet ? 13 : 14),
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    initialValue: _department,
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : (isTablet ? 14 : 15),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your department',
                                      hintStyle: TextStyle(
                                        fontSize: isMobile ? 11 : (isTablet ? 13 : 14),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 12 : 14,
                                        vertical: isMobile ? 10 : (isTablet ? 12 : 14),
                                      ),
                                    ),
                                    onChanged: (v) => _department = v,
                                    validator: (v) => (v == null || v.isEmpty) 
                                        ? 'Please enter your department' 
                                        : null,
                                  ),
                                  SizedBox(height: isMobile ? 20 : (isTablet ? 24 : 28)),
                                  
                                  // Save Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: isMobile ? 42 : (isTablet ? 46 : 48),
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.textPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _loading ? null : _saveAndContinue,
                                      child: _loading
                                          ? SizedBox(
                                              width: isMobile ? 16 : 18,
                                              height: isMobile ? 16 : 18,
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Save & Continue',
                                              style: TextStyle(
                                                fontSize: isMobile ? 13 : (isTablet ? 15 : 16),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 10 : 12),
                                  
                                  // Info text
                                  Center(
                                    child: Text(
                                      'These defaults will be used when creating new safety cards',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: isMobile ? 9 : (isTablet ? 11 : 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
}