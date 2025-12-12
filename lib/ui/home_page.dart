// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:safety_card_web/utils/app_colors.dart';
import '../data/app_database.dart';
import '../main.dart';
import '../helpers/krc_helper.dart';
import '../helpers/site_helper.dart';
import '../helpers/location_helper.dart';
import '../helpers/users_helper.dart';
import '../utils/responsive_utils.dart';
import 'edit_safety_card_page.dart';
import 'create_safety_card_page.dart';
import 'user_preferences_page.dart';
import 'site_location_manager_page.dart';
import 'add_krc_page.dart';
import '../services/sync_service.dart';
import '../widgets/sync_status_widget.dart';
import 'dart:async';
import '../services/image_service.dart';
import '../helpers/analytics_helper.dart';
import '../utils/status_helper.dart';
import 'sign_off/sign_off_page.dart';
import 'sign_off/sign_off_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // 🆕 Filter state
  DateTime? _dateFrom;
  DateTime? _dateTo;
  int? _selectedKrc;
  int? _selectedSite;
  int? _selectedLocation;
  int? _selectedUser;
  String? _selectedStatus;
  String? _selectedSafetyStatus;
  bool _showFilters = false;
  bool _filtersChanged = false;
  
  // Pagination state
  int _currentPage = 1;
  int _pageSize = 50;
  int _totalCount = 0;
  int _totalPages = 0;
  bool _isLoadingPage = false;

  // 🆕 Dashboard data state
  DashboardResult? _dashboardData;

  // ✅ Module Navigation
  String _currentModule = 'ThinkSafety'; // 'ThinkSafety' or 'SignOff'
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  late Future<List<SafetyCard>> _cardsFuture = Future.value([]);
  late Future<List<KeyRiskCondition>> _krcFuture;
  late Future<List<Site>> _sitesFuture;
  late Future<List<Location>> _locationsFuture;
  late Future<List<UserLite>> _usersFuture;

  Map<String, int> _siteUsageCounts = {};
  Map<String, int> _locationUsageCounts = {};
  Map<String, int> _krcUsageCounts = {};
  Map<String, int> _userUsageCounts = {};

  // Loading states for usage data
  bool _isLoadingSiteUsage = false;
  bool _isLoadingLocationUsage = false;
  bool _isLoadingKrcUsage = false;
  bool _isLoadingUserUsage = false;
  
  StreamSubscription<SyncStatus>? _syncSubscription;

  String? _sortColumn;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _krcFuture = KrcHelper.fetchFromServer();
    _sitesFuture = SiteHelper.fetchFromServer();
    _locationsFuture = LocationHelper.fetchFromServer();
    _usersFuture = UsersHelper.fetchFromServer();
    
    // 🆕 Default to sorting by date descending (newest first)
    _sortColumn = 'date';
    _sortAscending = false;
    
    // 🆕 Load initial dashboard data
    _applyFiltersAndFetch();
    
    WidgetsBinding.instance.addObserver(this);
    
    _syncSubscription = syncService.syncStatus.listen((status) {
      if (status == SyncStatus.synced && mounted) {
        _refreshFilterData();
        _applyFiltersAndFetch();
      }
    });

    _loadUsageStatistics();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshFilterData();
    }
  }

  void _refreshFilterData() {
    if (!mounted) return;
    setState(() {
      _krcFuture = KrcHelper.fetchFromServer();
      _sitesFuture = SiteHelper.fetchFromServer();
      _locationsFuture = LocationHelper.fetchFromServer();
      _usersFuture = UsersHelper.fetchFromServer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _syncSubscription?.cancel();
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    _applyFiltersAndFetch();
  }

  // Usage Statistics methods remain the same...
  Future<void> _loadUsageStatistics() async {
    await Future.wait([
      _loadSiteUsage(),
      _loadKrcUsage(),
      _loadUserUsage(),
    ]);
  }

  Future<void> _loadSiteUsage() async {
    if (!mounted) return;
    setState(() => _isLoadingSiteUsage = true);
    
    try {
      final usage = await AnalyticsHelper.fetchSiteUsage();
      if (mounted) {
        setState(() {
          _siteUsageCounts = usage;
          _isLoadingSiteUsage = false;
        });
      }
    } catch (e) {
      print('Error loading site usage: $e');
      if (mounted) {
        setState(() => _isLoadingSiteUsage = false);
      }
    }
  }

  Future<void> _loadLocationUsage(String siteUuid) async {
    if (!mounted) return;
    setState(() => _isLoadingLocationUsage = true);
    
    try {
      final usage = await AnalyticsHelper.fetchLocationUsage(siteUuid);
      if (mounted) {
        setState(() {
          _locationUsageCounts = usage;
          _isLoadingLocationUsage = false;
        });
      }
    } catch (e) {
      print('Error loading location usage: $e');
      if (mounted) {
        setState(() => _isLoadingLocationUsage = false);
      }
    }
  }

  Future<void> _loadKrcUsage() async {
    if (!mounted) return;
    setState(() => _isLoadingKrcUsage = true);
    
    try {
      final usage = await AnalyticsHelper.fetchKrcUsage();
      if (mounted) {
        setState(() {
          _krcUsageCounts = usage;
          _isLoadingKrcUsage = false;
        });
      }
    } catch (e) {
      print('Error loading KRC usage: $e');
      if (mounted) {
        setState(() => _isLoadingKrcUsage = false);
      }
    }
  }

  Future<void> _loadUserUsage() async {
    if (!mounted) return;
    setState(() => _isLoadingUserUsage = true);
    
    try {
      final usage = await AnalyticsHelper.fetchUserUsage();
      if (mounted) {
        setState(() {
          _userUsageCounts = usage;
          _isLoadingUserUsage = false;
        });
      }
    } catch (e) {
      print('Error loading user usage: $e');
      if (mounted) {
        setState(() => _isLoadingUserUsage = false);
      }
    }
  }


Future<void> _applyFiltersAndFetch() async {
  if (!mounted) return;
  
  setState(() {
    _isLoadingPage = true;
  });

  try {
    // Convert filter values to API format
    String? krcHexId;
    if (_selectedKrc != null) {
      final krcs = await _krcFuture;
      final krc = krcs.firstWhere((k) => k.id == _selectedKrc);
      krcHexId = krc.hexId;
    }
    
    String? siteUuid;
    if (_selectedSite != null) {
      final sites = await _sitesFuture;
      final site = sites.firstWhere((s) => s.id == _selectedSite);
      siteUuid = site.uuid;
    }
    
    String? locationUuid;
    if (_selectedLocation != null) {
      final locations = await _locationsFuture;
      final location = locations.firstWhere((l) => l.id == _selectedLocation);
      locationUuid = location.uuid;
    }
    
    String? raisedByName;
    if (_selectedUser != null) {
      final users = await _usersFuture;
      final user = users.firstWhere((u) => u.id == _selectedUser);
      raisedByName = user.name;
    }
    
    // Normalize safety status
    String? normalizedSafetyStatus = _selectedSafetyStatus;
    if (_selectedSafetyStatus != null) {
      normalizedSafetyStatus = _selectedSafetyStatus == 'Safe' ? 'Safe' : 'Unsafe';
    }
    
    final emptyDateTime = DateTime.fromMillisecondsSinceEpoch(0);
    final now = DateTime.now();
    final dateFrom = _dateFrom ?? emptyDateTime;
    final dateTo = _dateTo ?? now;
    
    print('🔍 Applying filters:');
    print('   - Date From: $dateFrom');
    print('   - Date To: $dateTo');
    print('   - KRC: $krcHexId');
    print('   - Site: $siteUuid');
    print('   - Location: $locationUuid');
    print('   - Raised By: $raisedByName');
    print('   - Status: $_selectedStatus');
    print('   - Safety Status: $normalizedSafetyStatus');
    
    // 🆕 Fetch dashboard data (cards + analytics)
    final result = await syncService.fetchDashboard(
      pageNumber: _currentPage,
      pageSize: _pageSize,
      dateFrom: dateFrom,
      dateTo: dateTo,
      keyRiskConditionHexId: krcHexId,
      siteUuid: siteUuid,
      locationUuid: locationUuid,
      raisedByName: raisedByName,
      cardStatus: _selectedStatus == 'Open' ? 'Open' : _selectedStatus,
      safetyStatus: normalizedSafetyStatus,
    );
    
    // Apply client-side sorting
    final sortedCards = _applySorting(result.cards);
    
    if (mounted) {
      setState(() {
        _dashboardData = result; // Store full dashboard data
        _cardsFuture = Future.value(sortedCards);
        _totalCount = result.totalCount;
        _totalPages = result.totalPages;
        _isLoadingPage = false;
      });
      
      print('✅ Loaded ${sortedCards.length} cards (page $_currentPage of $_totalPages)');
    }
  } catch (e) {
    print('❌ Error applying filters: $e');
    if (mounted) {
      setState(() {
        _isLoadingPage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cards: $e')),
      );
    }
  }
}


List<SafetyCard> _applySorting(List<SafetyCard> cards) {
  if (_sortColumn == null || cards.isEmpty) return cards;
  
  final sortedCards = List<SafetyCard>.from(cards);
  
  sortedCards.sort((a, b) {
    int comparison = 0;
    
    switch (_sortColumn) {
      case 'raisedBy':
        comparison = a.raisedById.compareTo(b.raisedById);
        break;
        
      case 'date':
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        final dateComparison = dateB.compareTo(dateA);
        if (dateComparison == 0) {
          comparison = b.time.compareTo(a.time);
        } else {
          comparison = dateComparison;
        }
        break;
        
      case 'safetyStatus':
        final statusA = a.safetyStatus.toLowerCase().contains('unsafe') ? 1 : 0;
        final statusB = b.safetyStatus.toLowerCase().contains('unsafe') ? 1 : 0;
        comparison = statusA.compareTo(statusB);
        break;
        
      case 'status':
        final statusOrder = {'Open': 0, 'Submitted': 1, 'Closed': 2};
        final orderA = statusOrder[a.status] ?? 99;
        final orderB = statusOrder[b.status] ?? 99;
        comparison = orderA.compareTo(orderB);
        break;
        
      default:
        comparison = 0;
    }
    
    if (_sortColumn != 'date') {
      return _sortAscending ? comparison : -comparison;
    } else {
      return _sortAscending ? -comparison : comparison;
    }
  });
  
  return sortedCards;
}



void _sortBy(String column) {
  setState(() {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      _sortAscending = (column == 'date') ? false : true; 
    }
  });
  
  _cardsFuture.then((cards) {
    final sortedCards = _applySorting(cards);
    setState(() {
      _cardsFuture = Future.value(sortedCards);
    });
  });
}

void _changePage(int newPage) {
  if (newPage < 1 || newPage > _totalPages || newPage == _currentPage) return;
  
  setState(() {
    _currentPage = newPage;
  });
  
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  
  _applyFiltersAndFetch();
}

/// Clear all filters
void _clearFilters() {
  setState(() {
    _dateFrom = null;
    _dateTo = null;
    _selectedKrc = null;
    _selectedSite = null;
    _selectedLocation = null;
    _selectedUser = null;
    _selectedStatus = null;
    _selectedSafetyStatus = null;
    _currentPage = 1;
    _filtersChanged = false; // Reset changed flag
  });
  
  _applyFiltersAndFetch();
}

void _filterByKrc(String krcHexId) async {
  final krcs = await _krcFuture;
  final krc = krcs.firstWhere((k) => k.hexId == krcHexId, orElse: () => krcs.first);
  
  setState(() {
    _selectedKrc = krc.id;
    _currentPage = 1;
    _filtersChanged = true;
  });
  
  // Auto-apply filter when clicking chart
  _applyFilters();
}

void _filterByStatus(String status) {
  setState(() {
    _selectedStatus = status;
    _currentPage = 1;
    _filtersChanged = true;
  });
  
  // Auto-apply filter when clicking chart
  _applyFilters();
}

void _filterBySafetyStatus(String safetyStatus) {
  setState(() {
    _selectedSafetyStatus = safetyStatus;
    _currentPage = 1;
    _filtersChanged = true;
  });
  
  // Auto-apply filter when clicking chart
  _applyFilters();
}

Future<void> _closeCard(SafetyCard card) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Close Card'),
      content: const Text('Are you sure you want to close this safety card? Once closed, it cannot be edited.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Close Card'),
        ),
      ],
    ),
  );
  if (ok == true) {
    await syncService.closeCard(card.id);
    _reload();
  }
}

  void _applyFilters() {
    if (!_filtersChanged) return;
    
    setState(() {
      _filtersChanged = false;
    });
    
    _applyFiltersAndFetch();
  }

  Future<void> _submitCard(SafetyCard card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Card'),
        content: const Text('Are you sure you want to submit this safety card? You won\'t be able to edit it after submission.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit Card'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await syncService.submitCard(card.id);
      _reload();
    }
  }


  Widget _buildPaginationControls(bool isMobile) {
    if (_totalPages <= 1 && _totalCount == 0) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1 && !_isLoadingPage
                ? () => _changePage(_currentPage - 1)
                : null,
            tooltip: 'Previous page',
          ),
          
          const SizedBox(width: 8),
          
          // Page display
          if (!isMobile && _totalPages > 0) ...[
            // Show page 1
            _buildPageButton(1, isMobile),
            
            // Show ... if current page is far from start
            if (_currentPage > 3) ...[
              const SizedBox(width: 4),
              const Text('...', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            
            // Show pages around current
            for (int i = _currentPage - 1; i <= _currentPage + 1; i++)
              if (i > 1 && i < _totalPages) _buildPageButton(i, isMobile),
            
            // Show ... if current page is far from end
            if (_currentPage < _totalPages - 2) ...[
              const SizedBox(width: 4),
              const Text('...', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            
            // Show last page
            if (_totalPages > 1) _buildPageButton(_totalPages, isMobile),
          ] else ...[
            // Mobile view or loading
            if (_isLoadingPage)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                _totalPages > 0 
                  ? 'Page $_currentPage of $_totalPages'
                  : 'Page $_currentPage',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
          
          const SizedBox(width: 8),
          
          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: (_totalPages == 0 || _currentPage < _totalPages) && !_isLoadingPage
                ? () => _changePage(_currentPage + 1)
                : null,
            tooltip: 'Next page',
          ),
          
          if (!isMobile && _totalCount > 0) ...[
            const SizedBox(width: 16),
            Text(
              'Total: $_totalCount records',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageButton(int pageNumber, bool isMobile) {
    final isCurrentPage = pageNumber == _currentPage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: isCurrentPage || _isLoadingPage ? null : () => _changePage(pageNumber),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isCurrentPage ? AppColors.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isCurrentPage ? AppColors.textPrimary : Colors.grey[300]!,
            ),
          ),
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.normal,
              color: isCurrentPage ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final isMobile = screenSize == ScreenSize.mobile;
        final isTablet = screenSize == ScreenSize.tablet;
        final padding = ResponsiveUtils.getResponsivePadding(context);
        
        return Scaffold(
          key: _scaffoldKey, // ✅ ADD THIS
          backgroundColor: const Color(0xFFF3F4F6),
          // ✅ ADD DRAWER
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D7CF6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Smart Projex',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (UserSession.userName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${UserSession.userName}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.security, color: Color(0xFF2D7CF6)),
                  title: const Text('Think Safety'),
                  selected: _currentModule == 'ThinkSafety',
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                  onTap: () {
                    setState(() => _currentModule = 'ThinkSafety');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_turned_in, color: AppColors.primary),
                  title: const Text('SignOff'),
                  selected: _currentModule == 'SignOff',
                  selectedTileColor: Colors.orange.withOpacity(0.1),
                  onTap: () {
                    setState(() => _currentModule = 'SignOff');
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await UserSession.clear();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              _buildHeader(context, isMobile, padding),
              Expanded(
                // ✅ ADD MODULE SWITCHER HERE
                child: _currentModule == 'SignOff' 
                  ? const SignOffPage()
                  : (isMobile 
                      ? _buildMobileLayout(padding)
                      : isTablet
                          ? _buildTabletLayout(padding)
                          : _buildDesktopLayout(padding)),
              ),
            ],
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.textPrimary,
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateSafetyCardPage(),
                      ),
                    );
                    _reload();
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Record',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, double padding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 12 : 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 28, color: Color(0xFF374151)),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            tooltip: 'Menu',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentModule == 'SignOff' 
                      ? (isMobile ? 'Sign Offs' : 'Sign Off Management Data')
                      : (isMobile ? 'Smart Projex' : 'Smart Projex Safety App'),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!isMobile && UserSession.userName != null)
                  Text(
                    '${UserSession.userName}${UserSession.isAdmin ? ' (Admin)' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
          if (isMobile)
            IconButton(
              icon: Icon(_showFilters ? Icons.close : Icons.filter_list),
              tooltip: 'Filters',
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          SyncStatusWidget(
            onSyncComplete: () {
              print('🔄 SyncStatusWidget callback triggered, reloading...');
              _reload();
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              if (_currentModule == 'ThinkSafety') ...[
                const PopupMenuItem(
                  value: 'preferences',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 20, color: Color(0xFF6B7280)),
                      SizedBox(width: 12),
                      Text('User Preferences'),
                    ],
                  ),
                ),
                if (UserSession.isAdmin) // ✅ Only show to admin users
                  const PopupMenuItem(
                    value: 'add_krc',
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, size: 20, color: Color(0xFF6B7280)),
                        SizedBox(width: 12),
                        Text('Add Key Risk'),
                      ],
                    ),
                  ),
                if (UserSession.isAdmin) // ✅ Only show to admin users
                  const PopupMenuItem(
                    value: 'manage_sites_locations',
                    child: Row(
                      children: [
                        Icon(Icons.manage_accounts, size: 20, color: Color(0xFF6B7280)),
                        SizedBox(width: 12),
                        Text('Manage Site & Location'),
                      ],
                    ),
                  ),
              ],
              if (UserSession.isAdmin && _currentModule == 'SignOff') // ✅ SignOff Admin
                const PopupMenuItem(
                  value: 'sign_off_settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_applications, size: 20, color: Color(0xFF6B7280)),
                      SizedBox(width: 12),
                      Text('SignOff Settings'),
                    ],
                  ),
                ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'preferences':
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserPreferencesPage(),
                    ),
                  );
                  break;
                case 'add_krc':
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddKrcPage(),
                    ),
                  );
                  break;
                case 'manage_sites_locations':
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SiteLocationManagerPage(),
                    ),
                  );
                  break;
                case 'sign_off_settings':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignOffSettingsPage()),
                  );
                  break;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await UserSession.clear();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
    );
  }

  // Mobile Layout - Single column with tabs
  Widget _buildMobileLayout(double padding) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          if (_showFilters) _buildFiltersSection(padding, true),
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: Color(0xFF6B7280),
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Records', icon: Icon(Icons.list)),
                Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRecordsSection(padding, true),
                _buildStatsSection(padding, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tablet Layout - Stacked sections
  Widget _buildTabletLayout(double padding) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            _buildFiltersSection(padding, false),
            SizedBox(height: padding),
            _buildRecordsSection(padding, false),
            SizedBox(height: padding),
            _buildStatsSection(padding, false),
          ],
        ),
      ),
    );
  }

  // Desktop Layout - Responsive three-column layout with flex
  Widget _buildDesktopLayout(double padding) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final filterWidth = (totalWidth * 0.18).clamp(220.0, 350.0);
        final statsWidth = (totalWidth * 0.18).clamp(110.0, 320.0);
        final gap = padding * 0.125;
        
        return Padding(
          padding: EdgeInsets.all(gap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: filterWidth,
                decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(gap),
                  child: _buildFiltersSection(padding, false),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Container(
                  color: const Color(0xFFF3F4F6),
                  padding: EdgeInsets.all(gap),
                  child: _buildRecordsSection(padding, false),
                ),
              ),
              SizedBox(width: gap),
              Container(
                width: statsWidth,
                constraints: const BoxConstraints(
                  minWidth: 70,
                  maxWidth: 320,
                ),
                decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(gap),
                  child: _buildStatsSection(padding, false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }




// Replace the _buildFiltersSection method in your home_page.dart with this updated version

Widget _buildFiltersSection(double padding, bool isMobile) {
  return Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon buttons
        Row(
          children: [
            const Expanded(
              child: Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            // Apply Filters Icon Button
            Container(
              decoration: BoxDecoration(
                color: _filtersChanged 
                    ? AppColors.textPrimary.withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  _filtersChanged ? Icons.filter_alt : Icons.filter_alt_outlined,
                  color: _filtersChanged 
                      ? AppColors.primary 
                      : const Color(0xFF9CA3AF),
                  size: 20,
                ),
                onPressed: _filtersChanged ? _applyFilters : null,
                tooltip: _filtersChanged ? 'Apply Filters' : 'No Changes',
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(width: 8),
            // Clear Filters Icon Button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
                onPressed: () {
                  if (isMobile) setState(() => _showFilters = false);
                  _clearFilters();
                },
                tooltip: 'Clear Filters',
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
        SizedBox(height: padding),
        
        // Date From
        _buildFilterLabel('Date From'),
        const SizedBox(height: 8),
        _buildDateField(_dateFrom, (date) {
          setState(() {
            _dateFrom = date;
            _currentPage = 1;
            _filtersChanged = true;
          });
        }),
        const SizedBox(height: 16),
        
        // Date To
        _buildFilterLabel('Date To'),
        const SizedBox(height: 8),
        _buildDateField(_dateTo, (date) {
          setState(() {
            _dateTo = date;
            _currentPage = 1;
            _filtersChanged = true;
          });
        }),
        const SizedBox(height: 16),
        
        // Key Risk Conditions dropdown WITH COUNTS - SORTED BY COUNT
        _buildFilterLabel('Key Risk Conditions'),
        const SizedBox(height: 8),
        FutureBuilder<List<KeyRiskCondition>>(
          future: _krcFuture,
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            
            // ✅ Sort by count (highest first), then alphabetically for items with same count
            final sortedItems = List<KeyRiskCondition>.from(items)
              ..sort((a, b) {
                final countA = _krcUsageCounts[a.hexId] ?? 0;
                final countB = _krcUsageCounts[b.hexId] ?? 0;
                
                // First compare by count (descending)
                if (countB != countA) {
                  return countB.compareTo(countA);
                }
                // If counts are equal, sort alphabetically
                return a.name.compareTo(b.name);
              });
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('All Risks', style: TextStyle(fontSize: 13)),
                  value: _selectedKrc,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
                  onTap: () {
                    setState(() {
                      _krcFuture = KrcHelper.fetchFromServer();
                    });
                  },
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Risks'),
                    ),
                    ...sortedItems.map((krc) {
                      final count = _krcUsageCounts[krc.hexId] ?? 0;
                      return DropdownMenuItem<int>(
                        value: krc.id,
                        child: Row(
                          children: [
                            krc.icon.startsWith('http')
                              ? Image.network(
                                  krc.icon,
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                )
                              : Image.asset(
                                  'assets/icons/${krc.icon}',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                                ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                krc.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.surface,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _selectedKrc = v;
                      _currentPage = 1;
                      _filtersChanged = true;
                    });
                  },
                ),
              ),
            );
          },
        ),
        
        // Admin-only filters
        if (UserSession.isAdmin) ...[
          const SizedBox(height: 16),
          
          // Site dropdown WITH COUNTS - SORTED BY COUNT
          _buildFilterLabel('Site'),
          const SizedBox(height: 8),
          FutureBuilder<List<Site>>(
            future: _sitesFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              
              final sortedItems = List<Site>.from(items)
                ..sort((a, b) {
                  final countA = _siteUsageCounts[a.uuid] ?? 0;
                  final countB = _siteUsageCounts[b.uuid] ?? 0;
                  
                  if (countB != countA) {
                    return countB.compareTo(countA);
                  }
                  return a.name.compareTo(b.name);
                });
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: const Text('All Sites', style: TextStyle(fontSize: 13)),
                    value: _selectedSite,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
                    onTap: () {
                      setState(() {
                        _sitesFuture = SiteHelper.fetchFromServer();
                      });
                    },
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('All Sites'),
                      ),
                      ...sortedItems.map((s) {
                        final count = _siteUsageCounts[s.uuid] ?? 0;
                        return DropdownMenuItem<int>(
                          value: s.id,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) async {
                      setState(() {
                        _selectedSite = v;
                        _selectedLocation = null;
                        _currentPage = 1;
                        _filtersChanged = true;
                        if (v != null) {
                          final site = items.firstWhere((s) => s.id == v);
                          _locationsFuture = LocationHelper.fetchBySite(site.uuid);
                          _loadLocationUsage(site.uuid);
                        } else {
                          _locationsFuture = LocationHelper.fetchFromServer();
                          _locationUsageCounts = {};
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Location dropdown WITH COUNTS - SORTED BY COUNT
          _buildFilterLabel('Location'),
          const SizedBox(height: 8),
          FutureBuilder<List<Location>>(
            future: _locationsFuture,
            builder: (context, snapshot) {
              final items = (_selectedSite == null) ? <Location>[] : (snapshot.data ?? []);
              
              final sortedItems = List<Location>.from(items)
                ..sort((a, b) {
                  final countA = _locationUsageCounts[a.uuid] ?? 0;
                  final countB = _locationUsageCounts[b.uuid] ?? 0;
                  
                  if (countB != countA) {
                    return countB.compareTo(countA);
                  }
                  return a.name.compareTo(b.name);
                });
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(6),
                  color: _selectedSite == null ? Colors.grey[100] : Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: Text(
                      _selectedSite == null ? 'Select a site first' : 'All Locations',
                      style: TextStyle(
                        fontSize: 13,
                        color: _selectedSite == null ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                      ),
                    ),
                    value: _selectedLocation,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('All Locations'),
                      ),
                      ...sortedItems.map((l) {
                        final count = _locationUsageCounts[l.uuid] ?? 0;
                        return DropdownMenuItem<int>(
                          value: l.id,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: _selectedSite == null ? null : (v) {
                      setState(() {
                        _selectedLocation = v;
                        _currentPage = 1;
                        _filtersChanged = true;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Raised By dropdown - SORTED BY COUNT
          _buildFilterLabel('Raised By'),
          const SizedBox(height: 8),
          FutureBuilder<List<UserLite>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              
              final sortedItems = List<UserLite>.from(items)
                ..sort((a, b) {
                  final countA = _userUsageCounts[a.name] ?? 0;
                  final countB = _userUsageCounts[b.name] ?? 0;
                  
                  if (countB != countA) {
                    return countB.compareTo(countA);
                  }
                  return a.name.compareTo(b.name);
                });
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: const Text('All Users', style: TextStyle(fontSize: 13)),
                    value: _selectedUser,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('All Users'),
                      ),
                      ...sortedItems.map((u) {
                        final count = _userUsageCounts[u.name] ?? 0;
                        return DropdownMenuItem<int>(
                          value: u.id,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  u.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8B5CF6),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedUser = v;
                        _currentPage = 1;
                        _filtersChanged = true;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Card Status dropdown
        _buildFilterLabel('Card Status'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('All Status', style: TextStyle(fontSize: 13)),
              value: _selectedStatus,
              style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
              items: const [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Status'),
                ),
                DropdownMenuItem(value: 'Open', child: Text('Private')),
                DropdownMenuItem(value: 'Submitted', child: Text('Open')),
                DropdownMenuItem(value: 'Closed', child: Text('Closed')),
              ],
              onChanged: (v) {
                setState(() {
                  _selectedStatus = v;
                  _currentPage = 1;
                  _filtersChanged = true;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Safety Status dropdown
        _buildFilterLabel('Safety Status'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('All Safety Status', style: TextStyle(fontSize: 13)),
              value: _selectedSafetyStatus,
              style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
              items: const [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Safety Status'),
                ),
                DropdownMenuItem(value: 'Safe', child: Text('Safe')),
                DropdownMenuItem(value: 'Unsafe', child: Text('Unsafe')),
              ],
              onChanged: (v) {
                setState(() {
                  _selectedSafetyStatus = v;
                  _currentPage = 1;
                  _filtersChanged = true;
                });
              },
            ),
          ),
        ),
        SizedBox(height: padding),
        
        // Bottom buttons (kept for reference/redundancy)
        Column(
          children: [
            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _filtersChanged 
                      ? AppColors.textPrimary
                      : const Color(0xFFE5E7EB),
                  foregroundColor: _filtersChanged 
                      ? Colors.white 
                      : const Color(0xFF9CA3AF),
                  elevation: _filtersChanged ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  disabledForegroundColor: const Color(0xFF9CA3AF),
                ),
                onPressed: _filtersChanged ? _applyFilters : null,
                icon: Icon(
                  _filtersChanged ? Icons.filter_alt : Icons.filter_alt_outlined,
                  size: 20,
                ),
                label: Text(
                  _filtersChanged ? 'Apply Filters' : 'No Changes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Clear Filters Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (isMobile) setState(() => _showFilters = false);
                  _clearFilters();
                },
                icon: const Icon(Icons.clear, size: 20),
                label: const Text(
                  'Clear Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

  Widget _buildRecordsSection(double padding, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isMobile ? 'Records' : 'Health & Safety Records',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (!isMobile)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Add New Record',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateSafetyCardPage(),
                        ),
                      );
                      _reload();
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          Expanded(
            child: FutureBuilder<List<SafetyCard>>(
              future: _cardsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final cards = snapshot.data!;
                
                if (cards.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No safety cards found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: _RecordsTable(
                            cards: cards,
                            onClose: _closeCard,
                            onSubmit: _submitCard,
                            onReload: _reload,
                            isMobile: isMobile,
                            currentSortColumn: _sortColumn,
                            sortAscending: _sortAscending,
                            onSort: _sortBy,
                          ),
                        ),
                      ),
                    ),
                    
                    _buildPaginationControls(isMobile),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(double padding, bool isMobile) {
    if (_dashboardData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return FutureBuilder<List<KeyRiskCondition>>(
      future: db.allKrc(),
      builder: (context, krcSnapshot) {
        if (!krcSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final krcList = krcSnapshot.data!;
        
        return _StatsPanel(
          dashboardData: _dashboardData!,
          krcList: krcList,
          isMobile: isMobile,
        );
      },
    );
  }

  Widget _buildFilterLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildDateField(DateTime? value, Function(DateTime?) onChanged) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onChanged(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'mm/dd/yyyy'
                    : DateFormat('MM/dd/yyyy').format(value),
                style: TextStyle(
                  color: value == null ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
    String hint,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          value: value,
          style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
          items: [
            DropdownMenuItem<T>(value: null, child: Text(hint)),
            ...items,
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Simplified _RecordsTable without sorting since server handles it
class _RecordsTable extends StatelessWidget {
  final List<SafetyCard> cards;
  final void Function(SafetyCard) onClose;
  final void Function(SafetyCard) onSubmit;
  final VoidCallback onReload;
  final bool isMobile;
  final String? currentSortColumn;
  final bool sortAscending;
  final void Function(String) onSort;

  const _RecordsTable({
    required this.cards,
    required this.onClose,
    required this.onSubmit,
    required this.onReload,
    required this.isMobile,
    this.currentSortColumn,
    required this.sortAscending,
    required this.onSort,
  });
  
  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFF6B7280),
    letterSpacing: 0.5,
  );

  String _formatTime(String time24) {
    try {
      String cleanTime = time24.trim();
      if (cleanTime.toUpperCase().contains('AM') || cleanTime.toUpperCase().contains('PM')) {
         return cleanTime.replaceAll(RegExp(r'\s+([AP]M)\s*[AP]M', caseSensitive: false), ' \$1').trim();
      }
      final parts = cleanTime.split(':');
      if (parts.length < 2) return cleanTime;
      
      int hour = int.parse(parts[0]);
      final minute = parts[1].replaceAll(RegExp(r'[^0-9]'), '').padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileList(context);
    }
    
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        KrcHelper.fetchFromServer(), 
        UsersHelper.fetchFromServer(),
        SiteHelper.fetchFromServer(),
        LocationHelper.fetchFromServer(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        final krcList = snapshot.data![0] as List<KeyRiskCondition>;
        final usersList = snapshot.data![1] as List<UserLite>;
        final sitesList = snapshot.data![2] as List<Site>;
        final locationsList = snapshot.data![3] as List<Location>;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 1300;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // User header - Sortable
                      SizedBox(
                        width: isCompact ? 140 : 160,
                        child: _SortableHeader(
                          label: 'USER',
                          sortColumn: 'raisedBy',
                          currentSortColumn: currentSortColumn,
                          sortAscending: sortAscending,
                          onSort: onSort,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: isCompact ? 100 : 120,
                        child: _SortableHeader(
                          label: 'DATE',
                          sortColumn: 'date',
                          currentSortColumn: currentSortColumn,
                          sortAscending: sortAscending,
                          onSort: onSort,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        flex: 2,
                        child: Text('KEY RISK', style: _headerStyle),
                      ),
                      const SizedBox(width: 16),
                      

                      const Expanded(
                        flex: 1,
                        child: Text('LOCATION', style: _headerStyle),
                      ),
                      const SizedBox(width: 16),

                      SizedBox(
                        width: isCompact ? 80 : 90,
                        child: _SortableHeader(
                          label: 'STATUS',
                          sortColumn: 'safetyStatus',
                          currentSortColumn: currentSortColumn,
                          sortAscending: sortAscending,
                          onSort: onSort,
                        ),
                      ),
                      const SizedBox(width: 12),

                      SizedBox(
                        width: isCompact ? 90 : 100,
                        child: _SortableHeader(
                          label: 'REPORTED',
                          sortColumn: 'status',
                          currentSortColumn: currentSortColumn,
                          sortAscending: sortAscending,
                          onSort: onSort,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 160, 
                        child: Text('ACTIONS', style: _headerStyle),
                      ),
                    ],
                  ),
                ),
                
                // Data Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: cards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final user = usersList.firstWhere((u) => u.id == card.raisedById, orElse: () => usersList.first);
                    final krc = krcList.firstWhere((k) => k.id == card.keyRiskConditionId, orElse: () => krcList.first);
                    final site = sitesList.firstWhere((s) => s.id == card.siteId, orElse: () => sitesList.first);
                    final location = locationsList.firstWhere((l) => l.id == card.locationId, orElse: () => locationsList.first);
                    
                    // ✅ NEW: Determine display name based on adminModified
                    final displayName = card.adminModified == true ? 'Anonymous' : user.name;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // User - ✅ UPDATED: Show "Anonymous" if adminModified is true
                          SizedBox(
                            width: isCompact ? 120 : 140,
                            child: Text(
                              displayName, // ✅ Show "Anonymous" or actual user name
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Date
                          SizedBox(
                            width: isCompact ? 90 : 110,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(DateTime.parse(card.date)),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTime(card.time),
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Key Risk
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                krc.icon.startsWith('http')
                                    ? Image.network(
                                        krc.icon,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.contain,
                                        errorBuilder: (ctx, err, _) => const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                                      )
                                    : Image.asset(
                                        'assets/icons/${krc.icon}',
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.contain,
                                        errorBuilder: (ctx, err, _) => const Icon(Icons.warning, size: 32, color: Colors.grey),
                                      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    krc.name,
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Site
                          Expanded(
                            flex: 1,
                            child: Tooltip(
                              message: site.name,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.business, size: 14, color: Color(0xFF9CA3AF)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        site.name,
                                        style: const TextStyle(
                                          fontSize: 12, 
                                          fontWeight: FontWeight.w600, 
                                          color: Color(0xFF4B5563)
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Location
                          Expanded(
                            flex: 1,
                            child: Tooltip(
                              message: location.name,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFFE4C2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.place_outlined, size: 14, color: Color(0xFFFF8A4C)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        location.name,
                                        style: const TextStyle(
                                          fontSize: 12, 
                                          fontWeight: FontWeight.w600, 
                                          color: Color(0xFF9A3412)
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Status
                          SizedBox(
                            width: isCompact ? 80 : 90,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: card.safetyStatus.toLowerCase().contains('unsafe')
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                card.safetyStatus.toLowerCase().contains('unsafe') ? 'Unsafe' : 'Safe',
                                style: TextStyle(
                                  color: card.safetyStatus.toLowerCase().contains('unsafe')
                                      ? const Color(0xFF991B1B)
                                      : const Color(0xFF166534),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Reported Status
                          SizedBox(
                            width: isCompact ? 90 : 100,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: card.status == 'Open'
                                    ? const Color(0xFFFED7AA)
                                    : card.status == 'Submitted'
                                        ? const Color(0xFFDCEEFB)
                                        : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                StatusHelper.toDisplayLabel(card.status),
                                style: TextStyle(
                                  color: card.status == 'Open'
                                      ? const Color(0xFF9A3412)
                                      : card.status == 'Submitted'
                                          ? const Color(0xFF1E40AF)
                                          : const Color(0xFF374151),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis, 
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Actions
                          SizedBox(
                            width: 160,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, color: Color(0xFF2563EB), size: 20),
                                  onPressed: () => _showCardDetails(context, card),
                                  tooltip: 'View Details',
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                ),
                                
                                if ((card.status == 'Open' && card.raisedById == UserSession.userId) || 
                                    (UserSession.isAdmin && card.status != 'Closed'))
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EditSafetyCardPage(card: card),
                                        ),
                                      );
                                      onReload();
                                    },
                                    tooltip: 'Edit',
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  ),

                                if (!UserSession.isAdmin && card.status == 'Open')
                                  IconButton(
                                    icon: const Icon(Icons.send_outlined, color: AppColors.primary, size: 20),
                                    onPressed: () => onSubmit(card),
                                    tooltip: 'Submit Card',
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  ),
                                if (UserSession.isAdmin && (card.status == 'Open' || card.status == 'Submitted'))
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 20),
                                    onPressed: () => onClose(card),
                                    tooltip: 'Close Card',
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  ),
                                if ((card.status == 'Open' && (UserSession.isAdmin || card.raisedById == UserSession.userId)) || ((card.status == 'Submitted' && UserSession.isAdmin)))
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 20),
                                    onPressed: () => _deleteCard(context, card),
                                    tooltip: 'Delete',
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMobileList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([KrcHelper.fetchFromServer(), UsersHelper.fetchFromServer(), SiteHelper.fetchFromServer(), LocationHelper.fetchFromServer()]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        final krcList = snapshot.data![0] as List<KeyRiskCondition>;
        final usersList = snapshot.data![1] as List<UserLite>;
        final sitesList = snapshot.data![2] as List<Site>;
        final locationsList = snapshot.data![3] as List<Location>;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            final user = usersList.firstWhere((u) => u.id == card.raisedById, orElse: () => usersList.first);
            final krc = krcList.firstWhere((k) => k.id == card.keyRiskConditionId, orElse: () => krcList.first);
            final site = sitesList.firstWhere((s) => s.id == card.siteId, orElse: () => sitesList.first);
            final location = locationsList.firstWhere((l) => l.id == card.locationId, orElse: () => locationsList.first);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _showCardDetails(context, card),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(DateTime.parse(card.date)),
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                                    ),
                                    Text(
                                      _formatTime(card.time),
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: card.safetyStatus.toLowerCase().contains('unsafe') ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  card.safetyStatus.toLowerCase().contains('unsafe') ? 'Unsafe' : 'Safe',
                                  style: TextStyle(color: card.safetyStatus.toLowerCase().contains('unsafe') ? const Color(0xFF991B1B) : const Color(0xFF166534), fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              krc.icon.startsWith('http')
                                  ? Image.network(krc.icon, width: 40, height: 40, fit: BoxFit.contain, errorBuilder: (ctx, err, _) => const Icon(Icons.broken_image, size: 40, color: Colors.grey))
                                  : Image.asset('assets/icons/${krc.icon}', width: 40, height: 40, fit: BoxFit.contain, errorBuilder: (ctx, err, _) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(krc.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE5E7EB))),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            const Icon(Icons.business, size: 10, color: Color(0xFF9CA3AF)),
                                            const SizedBox(width: 4),
                                            Text(site.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                                          ]),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFFE4C2))),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            const Icon(Icons.place_outlined, size: 10, color: Color(0xFFFF8A4C)),
                                            const SizedBox(width: 4),
                                            Text(location.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9A3412))),
                                          ]),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('View'),
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB), side: const BorderSide(color: Color(0xFF2563EB)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          onPressed: () => _showCardDetails(context, card),
                        ),
                        const SizedBox(width: 8),
                        if ((card.status == 'Open' && card.raisedById == UserSession.userId) || (UserSession.isAdmin && card.status != 'Closed'))
                          OutlinedButton.icon(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            onPressed: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditSafetyCardPage(card: card))); onReload(); },
                          ),
                        if (!UserSession.isAdmin && card.status == 'Open') ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(icon: const Icon(Icons.delete_outline, size: 18), label: const Text('Delete'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626), side: const BorderSide(color: Color(0xFFDC2626)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), onPressed: () => _deleteCard(context, card)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCardDetails(BuildContext context, SafetyCard card) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
          child: FutureBuilder<List<dynamic>>(
            // ✅ MODIFIED: Fetch card from server + all related data
            future: Future.wait([
              syncService.fetchCardByUuid(card.uuid), // Fetch fresh card from server
              SiteHelper.fetchFromServer(), 
              LocationHelper.fetchFromServer(), 
              KrcHelper.fetchFromServer(), 
              UsersHelper.fetchFromServer(),
              ImageService.getImageUrls(card.uuid),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              // ✅ Use fresh card from server if available, fallback to local
              final freshCard = (snapshot.data![0] as SafetyCard?) ?? card;
              final sitesList = snapshot.data![1] as List<Site>;
              final locationsList = snapshot.data![2] as List<Location>;
              final krcList = snapshot.data![3] as List<KeyRiskCondition>;
              final usersList = snapshot.data![4] as List<UserLite>;
              final imageUrls = snapshot.data![5] as List<String>;
              
              final site = sitesList.firstWhere((s) => s.id == freshCard.siteId, orElse: () => sitesList.first);
              final location = locationsList.firstWhere((l) => l.id == freshCard.locationId, orElse: () => locationsList.first);
              final krc = krcList.firstWhere((k) => k.id == freshCard.keyRiskConditionId, orElse: () => krcList.first);
              final user = usersList.firstWhere((u) => u.id == freshCard.raisedById, orElse: () => usersList.first);
              
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Icon(Icons.description_outlined, color: AppColors.textPrimary, size: 24)
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Safety Card Details',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF111827))
                          )
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(ctx);
                            onReload();
                          }
                        ),
                      ]
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoGrid([
                            _buildInfoCard('Date', freshCard.date, Icons.calendar_today),
                            _buildInfoCard('Time', _formatTime(freshCard.time), Icons.access_time),
                            _buildInfoCard('Raised By', card.adminModified == true ? 'Anonymous' : user.name, Icons.person_outline),
                            _buildInfoCard('Department', freshCard.department, Icons.business),
                          ]),
                          const SizedBox(height: 16),
                          _buildInfoGrid([
                            _buildInfoCard('Site', site.name, Icons.business),
                            _buildInfoCard('Location', location.name, Icons.place),
                          ]),
                          const SizedBox(height: 16),
                          _buildTextSection('Observation', freshCard.observation),
                          const SizedBox(height: 16),
                          _buildTextSection('Action Taken', freshCard.actionTaken),
                          
  //                         if (imageUrls.isNotEmpty) ...[
  //                           const SizedBox(height: 16),
  //                           const Text(
  //                             'Images',
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.w600,
  //                               fontSize: 14,
  //                               color: Color(0xFF111827)
  //                             )
  //                           ),
  //                           const SizedBox(height: 8),
  //                           Wrap(
  //                             spacing: 8,
  //                             runSpacing: 8,
  //                             children: imageUrls.map((url) => GestureDetector(
  //                               onTap: () {
  //                                 showDialog(
  //                                   context: context,
  //                                   builder: (dialogCtx) => Dialog(
  //                                     backgroundColor: Colors.black,
  //                                     child: Stack(
  //                                       children: [
  //                                         Center(
  //                                           child: InteractiveViewer(
  //                                             child: Image.network(
  //                                               url,
  //                                               fit: BoxFit.contain,
  //                                               loadingBuilder: (context, child, loadingProgress) {
  //                                                 if (loadingProgress == null) return child;
  //                                                 return Center(
  //                                                   child: CircularProgressIndicator(
  //                                                     value: loadingProgress.expectedTotalBytes != null
  //                                                         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
  //                                                         : null,
  //                                                   ),
  //                                                 );
  //                                               },
  //                                               errorBuilder: (context, error, stackTrace) {
  //                                                 return Container(
  //                                                   color: Colors.grey[300],
  //                                                   child: const Center(
  //                                                     child: Icon(Icons.broken_image, size: 64),
  //                                                   ),
  //                                                 );
  //                                               },
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Positioned(
  //                                           top: 10,
  //                                           right: 10,
  //                                           child: IconButton(
  //                                             icon: const Icon(Icons.close, color: Colors.white, size: 30),
  //                                             onPressed: () => Navigator.pop(dialogCtx),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 );
  //                               },
  //                               child: ClipRRect(
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 child: Image.network(
  //                                   url,
  //                                   width: 150,
  //                                   height: 150,
  //                                   fit: BoxFit.cover,
  //                                   loadingBuilder: (context, child, loadingProgress) {
  //                                     if (loadingProgress == null) return child;
  //                                     return Container(
  //                                       width: 150,
  //                                       height: 150,
  //                                       color: Colors.grey[200],
  //                                       child: Center(
  //                                         child: CircularProgressIndicator(
  //                                           value: loadingProgress.expectedTotalBytes != null
  //                                               ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
  //                                               : null,
  //                                         ),
  //                                       ),
  //                                     );
  //                                   },
  //                                   errorBuilder: (context, error, stackTrace) {
  //                                     print('❌ Error loading image: $error');
  //                                     return Container(
  //                                       width: 150,
  //                                       height: 150,
  //                                       color: Colors.grey[300],
  //                                       child: const Column(
  //                                         mainAxisAlignment: MainAxisAlignment.center,
  //                                         children: [
  //                                           Icon(Icons.broken_image, size: 40, color: Colors.grey),
  //                                           SizedBox(height: 8),
  //                                           Text('Failed to load', style: TextStyle(fontSize: 10)),
  //                                         ],
  //                                       ),
  //                                     );
  //                                   },
  //                                 ),
  //                               ),
  //                             )).toList(),
  //                           ),
  //                         ],
  //                       ]
  //                     )
  //                   )
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
   if (imageUrls.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Images',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF111827)
                              )
                            ),
                            const SizedBox(height: 8),
                            // ✅ Display fresh image URLs
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: imageUrls.map((url) => GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogCtx) => Dialog(
                                      backgroundColor: Colors.black,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: InteractiveViewer(
                                              child: Image.network(
                                                url,
                                                fit: BoxFit.contain,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(Icons.broken_image, size: 64),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: IconButton(
                                              icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                              onPressed: () => Navigator.pop(dialogCtx),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    // ✅ Add cache busting to force fresh load
                                    cacheWidth: null,
                                    cacheHeight: null,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 150,
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('❌ Error loading image: $error');
                                      return Container(
                                        width: 150,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text('Failed to load', style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )).toList(),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.image_not_supported, color: Colors.grey[400], size: 32),
                                  const SizedBox(width: 12),
                                  Text(
                                    'No images attached',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ]
                      )
                    )
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  Widget _buildInfoGrid(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      return GridView.count(crossAxisCount: constraints.maxWidth > 500 ? 2 : 1, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, children: children);
    });
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children: [Icon(icon, size: 20, color: const Color(0xFF6B7280)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)), overflow: TextOverflow.ellipsis)]))]));
  }

  Widget _buildTextSection(String label, String value) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF111827))), const SizedBox(height: 8), Text(value.isEmpty ? 'No information' : value, style: TextStyle(fontSize: 14, color: value.isEmpty ? const Color(0xFF9CA3AF) : const Color(0xFF374151)))]));
  }

  Future<void> _deleteCard(BuildContext context, SafetyCard card) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Card'), content: const Text('Permanently delete?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
    if (ok == true) { await syncService.deleteCard(card.id); onReload(); }
  }
}

// Stats Panel - Simplified version without complex charts
class _StatsPanel extends StatelessWidget {
  final DashboardResult dashboardData;
  final List<KeyRiskCondition> krcList;
  final bool isMobile;

  const _StatsPanel({
    required this.dashboardData,
    required this.krcList,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final headerHeight = 120;
        final availableHeight = screenHeight - headerHeight - 32;
        
        return SizedBox(
          height: availableHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Total Cards Counter
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        UserSession.isAdmin ? 'TOTAL CARDS' : 'MY TOTAL CARDS',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${dashboardData.safetyCardCount}',
                        style: TextStyle(
                          fontSize: isMobile ? 48 : 52,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),

                // Top 10 KRC Chart
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top 10 Key Risk Conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _KrcBarChart(
                          topKrcData: dashboardData.topKeyRiskConditions,
                          krcList: krcList,
                          onKrcTap: (hexId) {
                            // Access parent widget's filter method
                            final homePageState = context.findAncestorStateOfType<_HomePageState>();
                            homePageState?._filterByKrc(hexId);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),

                // Records Per Week Chart
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Records Per Week (Last 7 Weeks)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: _RecordsPerWeekChart(
                          weeklyData: dashboardData.recordsPerWeek,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),
                
                // Safe/Unsafe Ratio Chart
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Safe / Unsafe Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _SafetyStatusPieChart(
                          safeUnsafe: dashboardData.safeUnsafe,
                          onStatusTap: (status) {
                            final homePageState = context.findAncestorStateOfType<_HomePageState>();
                            homePageState?._filterBySafetyStatus(status);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),
                
                // Card Status Distribution (Admin only)
                if (UserSession.isAdmin)
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card Status Distribution',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _CardStatusPieChart(
                          statusDistribution: dashboardData.cardStatusDistribution,
                          onStatusTap: (status) {
                            final homePageState = context.findAncestorStateOfType<_HomePageState>();
                            homePageState?._filterByStatus(status);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



class _SafetyStatusPieChart extends StatelessWidget {
  final Map<String, dynamic> safeUnsafe;
  final Function(String)? onStatusTap;
  
  const _SafetyStatusPieChart({
    required this.safeUnsafe,
    this.onStatusTap,
  });
  
  @override
  Widget build(BuildContext context) {
    if (safeUnsafe.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Color(0xFF9CA3AF))));
    }
    
    final safeCount = safeUnsafe['safeCount'] ?? 0;
    final unsafeCount = safeUnsafe['unsafeCount'] ?? 0;
    final safePercentage = (safeUnsafe['safePercentage'] ?? 0.0).toStringAsFixed(1);
    final unsafePercentage = (safeUnsafe['unsafePercentage'] ?? 0.0).toStringAsFixed(1);

    if (safeCount == 0 && unsafeCount == 0) {
      return const Center(child: Text('No data available', style: TextStyle(color: Color(0xFF9CA3AF))));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            if (event is FlTapUpEvent && 
                pieTouchResponse != null && 
                pieTouchResponse.touchedSection != null &&
                onStatusTap != null) {
              final index = pieTouchResponse.touchedSection!.touchedSectionIndex;
              final status = index == 0 ? 'Safe' : 'Unsafe';
              onStatusTap!(status);
            }
          },
        ),
        sections: [
          PieChartSectionData(
            value: safeCount.toDouble(),
            title: '$safeCount\n($safePercentage%)',
            color: const Color(0xFF16A34A),
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          PieChartSectionData(
            value: unsafeCount.toDouble(),
            title: '$unsafeCount\n($unsafePercentage%)',
            color: const Color(0xFFDC2626),
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _CardStatusPieChart extends StatelessWidget {
  final Map<String, dynamic> statusDistribution;
  final Function(String)? onStatusTap;
  
  const _CardStatusPieChart({
    required this.statusDistribution,
    this.onStatusTap,
  });
  
  @override
  Widget build(BuildContext context) {
    if (statusDistribution.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Color(0xFF9CA3AF))));
    }
    
    final openCount = statusDistribution['openCount'] ?? 0;
    final closedCount = statusDistribution['closedCount'] ?? 0;
    final submittedCount = statusDistribution['submittedCount'] ?? 0;
    final openPercentage = (statusDistribution['openPercentage'] ?? 0.0).toStringAsFixed(1);
    final closedPercentage = (statusDistribution['closedPercentage'] ?? 0.0).toStringAsFixed(1);
    final submittedPercentage = (statusDistribution['submittedPercentage'] ?? 0.0).toStringAsFixed(1);

    final total = openCount + closedCount + submittedCount;
    if (total == 0) {
      return const Center(child: Text('No data available', style: TextStyle(color: Color(0xFF9CA3AF))));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            if (event is FlTapUpEvent && 
                pieTouchResponse != null && 
                pieTouchResponse.touchedSection != null &&
                onStatusTap != null) {
              final index = pieTouchResponse.touchedSection!.touchedSectionIndex;
              final status = index == 0 ? 'Open' : (index == 1 ? 'Submitted' : 'Closed');
              onStatusTap!(status);
            }
          },
        ),
        sections: [
          PieChartSectionData(
            value: openCount.toDouble(),
            title: '$openCount\n($openPercentage%)',
            color: AppColors.textPrimary,
            radius: 55,
            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          PieChartSectionData(
            value: submittedCount.toDouble(),
            title: '$submittedCount\n($submittedPercentage%)',
            color: const Color(0xFF3B82F6),
            radius: 55,
            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          PieChartSectionData(
            value: closedCount.toDouble(),
            title: '$closedCount\n($closedPercentage%)',
            color: const Color(0xFF6B7280),
            radius: 55,
            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}






class _KrcBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> topKrcData;
  final List<KeyRiskCondition> krcList;
  final Function(String)? onKrcTap; // Add callback

  const _KrcBarChart({
    required this.topKrcData,
    required this.krcList,
    this.onKrcTap, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    if (topKrcData.isEmpty) {
      return const Center(
        child: Text('No data available', style: TextStyle(color: Color(0xFF9CA3AF))),
      );
    }

    final chartData = <Map<String, dynamic>>[];
    for (var item in topKrcData) {
      final hexId = item['krc'] as String;
      final count = item['occurrenceCount'] as int;
      
      try {
        // Try to find the matching KRC
        final krc = krcList.firstWhere(
          (k) => k.hexId.toUpperCase() == hexId.toUpperCase(),
        );
        
        // If found, add it to the data
        chartData.add({
          'krc': krc,
          'count': count,
        });
      } catch (e) {
        // If the ID is not found in krcList, we simply SKIP it.
        // This prevents "Slip Trip and Fall" from appearing as a default for unknown IDs.
        debugPrint('Warning: KRC with ID $hexId not found in krcList. Skipping.');
      }
    }

    final maxCount = chartData.first['count'] as int;
    final yMax = (maxCount * 1.2).ceilToDouble();

    final colors = List.generate(
      chartData.length,
      (index) => Color.lerp(
        AppColors.textPrimary,
        AppColors.primary,
        index / chartData.length,
      )!,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: yMax,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            // Handle tap events
            if (event is FlTapUpEvent && 
                barTouchResponse != null && 
                barTouchResponse.spot != null &&
                onKrcTap != null) {
              final index = barTouchResponse.spot!.touchedBarGroupIndex;
              if (index >= 0 && index < chartData.length) {
                final krc = chartData[index]['krc'] as KeyRiskCondition;
                onKrcTap!(krc.hexId);
              }
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF1F2937),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final krc = chartData[groupIndex]['krc'] as KeyRiskCondition;
              final count = chartData[groupIndex]['count'] as int;
              return BarTooltipItem(
                '${krc.name}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '$count records\n',
                    style: const TextStyle(
                      color: Color(0xFFFFB084),
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                  const TextSpan(
                    text: 'Tap to filter',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= chartData.length) return const SizedBox();
                final krc = chartData[value.toInt()]['krc'] as KeyRiskCondition;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      krc.name,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              },
              reservedSize: 80,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (yMax / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text('0', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w500));
                }
                if (value >= yMax) return const SizedBox();
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w500));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (yMax / 5).ceilToDouble(),
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Color(0xFFE5E7EB), strokeWidth: 1, dashArray: [5, 5]);
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
            left: BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
          ),
        ),
        barGroups: List.generate(chartData.length, (index) {
          final count = chartData[index]['count'] as int;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                gradient: LinearGradient(
                  colors: [colors[index], colors[index].withOpacity(0.7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(show: true, toY: yMax, color: const Color(0xFFF3F4F6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}



class _KrcSiteHeatmapChart extends StatefulWidget {
  final List<SafetyCard> cards;
  final List<KeyRiskCondition> krcList;

  const _KrcSiteHeatmapChart({required this.cards, required this.krcList});

  @override
  State<_KrcSiteHeatmapChart> createState() => _KrcSiteHeatmapChartState();
}

class _KrcSiteHeatmapChartState extends State<_KrcSiteHeatmapChart> {
  String _viewMode = 'bar'; // 'top', 'heatmap', 'bar'
  int _topCount = 10;
  String? _selectedSite;
  String? _selectedKrc;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Site>>(
      future: SiteHelper.fetchFromServer(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No data available', style: TextStyle(color: Color(0xFF9CA3AF))),
          );
        }

        final sites = snapshot.data!;
        
        // Create a map of KRC-Site combinations
        final Map<String, int> heatmapData = {};
        for (var card in widget.cards) {
          final key = '${card.keyRiskConditionId}-${card.siteId}';
          heatmapData[key] = (heatmapData[key] ?? 0) + 1;
        }

        if (heatmapData.isEmpty) {
          return const Center(
            child: Text('No data available', style: TextStyle(color: Color(0xFF9CA3AF))),
          );
        }

        return Column(
          children: [
            // View mode selector
            _buildViewModeSelector(),
            const SizedBox(height: 16),
            
            // Render based on selected view mode
            Expanded(
              child: _viewMode == 'top'
                  ? _buildTopCombinationsView(heatmapData, sites)
                  : _viewMode == 'bar'
                      ? _buildBarChartView(heatmapData, sites)
                      : _buildCompactHeatmapView(heatmapData, sites),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewModeSelector() {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              //_buildViewModeChip('Top Combinations', 'top', Icons.bar_chart),
              _buildViewModeChip('Bar Chart', 'bar', Icons.stacked_bar_chart),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeChip(String label, String mode, IconData icon) {
    final isSelected = _viewMode == mode;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) setState(() => _viewMode = mode);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isSelected ? Colors.white : const Color(0xFF374151),
      ),
      side: BorderSide(
        color: isSelected ? AppColors.textPrimary : const Color(0xFFD1D5DB),
      ),
    );
  }

  Widget _buildTopCombinationsView(Map<String, int> heatmapData, List<Site> sites) {
    // Get top combinations
    final sortedEntries = heatmapData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topEntries = sortedEntries.take(_topCount).toList();
    
    return Column(
      children: [
        // Top count selector
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Text(
                'Show top: ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              ...([10, 15].map((count) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$count'),
                  selected: _topCount == count,
                  onSelected: (selected) {
                    if (selected) setState(() => _topCount = count);
                  },
                  selectedColor: AppColors.textPrimary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _topCount == count ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ))),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: topEntries.length,
            itemBuilder: (context, index) {
              final entry = topEntries[index];
              final parts = entry.key.split('-');
              final krcId = int.parse(parts[0]);
              final siteId = int.parse(parts[1]);
              
              final krc = widget.krcList.firstWhere((k) => k.id == krcId);
              final site = sites.firstWhere((s) => s.id == siteId);
              final count = entry.value;
              final maxCount = topEntries.first.value;
              final percentage = (count / maxCount * 100);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                const Color(0xFFFFE8DD),
                                AppColors.textPrimary,
                                index / topEntries.length,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: index < 3 ? Colors.white : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/${krc.icon}',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.warning, size: 20, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        krc.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  site.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'records',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(
                              const Color(0xFFFFB084),
                              AppColors.textPrimary,
                              percentage / 100,
                            )!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildBarChartView(Map<String, int> heatmapData, List<Site> sites) {
    // Group by site or KRC based on selection
    return Column(
      children: [
        // Filter selector
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Filter by Site', style: TextStyle(fontSize: 13)),
                      value: _selectedSite,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('All Sites')),
                        ...sites.map((s) => DropdownMenuItem(
                          value: s.id.toString(),
                          child: Text(s.name),
                        )),
                      ],
                      onChanged: (v) => setState(() => _selectedSite = v),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Filter by KRC', style: TextStyle(fontSize: 13)),
                      value: _selectedKrc,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('All KRCs')),
                        ...widget.krcList.map((k) => DropdownMenuItem(
                          value: k.id.toString(),
                          child: Text(k.name, overflow: TextOverflow.ellipsis),
                        )),
                      ],
                      onChanged: (v) => setState(() => _selectedKrc = v),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: _buildFilteredBarChart(heatmapData, sites),
        ),
      ],
    );
  }

  Widget _buildFilteredBarChart(Map<String, int> heatmapData, List<Site> sites) {
    // Aggregate data based on filters
    final Map<String, Map<String, dynamic>> aggregatedData = {};
    
    for (var entry in heatmapData.entries) {
      final parts = entry.key.split('-');
      final krcId = int.parse(parts[0]);
      final siteId = int.parse(parts[1]);
      
      if (_selectedSite != null && siteId.toString() != _selectedSite) continue;
      if (_selectedKrc != null && krcId.toString() != _selectedKrc) continue;
      
      final krc = widget.krcList.firstWhere((k) => k.id == krcId);
      final site = sites.firstWhere((s) => s.id == siteId);
      
      final key = _selectedSite != null ? krc.name : site.name;
      final iconOrSite = _selectedSite != null ? krc.icon : site.name;
      
      if (!aggregatedData.containsKey(key)) {
        aggregatedData[key] = {'count': 0, 'icon': iconOrSite};
      }
      aggregatedData[key]!['count'] = (aggregatedData[key]!['count'] as int) + entry.value;
    }
    
    if (aggregatedData.isEmpty) {
      return const Center(child: Text('No data for selected filters'));
    }
    
    final sortedData = aggregatedData.entries.toList()
      ..sort((a, b) => (b.value['count'] as int).compareTo(a.value['count'] as int));
    
    final maxCount = (sortedData.first.value['count'] as int).toDouble();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedData.length,
      itemBuilder: (context, index) {
        final entry = sortedData[index];
        final name = entry.key;
        final count = entry.value['count'] as int;
        final percentage = (count / maxCount);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_selectedSite != null)
                    Image.asset(
                      'assets/icons/${entry.value['icon']}',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.warning, size: 20, color: Colors.grey),
                    ),
                  if (_selectedSite != null) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.textPrimary,
                            Color.lerp(AppColors.textPrimary, const Color(0xFFFFB084), 0.5)!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactHeatmapView(Map<String, int> heatmapData, List<Site> sites) {
    final maxValue = heatmapData.values.fold<int>(0, (max, val) => val > max ? val : max);
    
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legend
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Text(
                      'Intensity: ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    ...List.generate(5, (i) {
                      final intensity = (i + 1) / 5;
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            const Color(0xFFFFE8DD),
                            AppColors.textPrimary,
                            intensity,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      'Max: $maxValue',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              
              // Header row
              Row(
                children: [
                  const SizedBox(width: 100),
                  ...widget.krcList.map((krc) => SizedBox(
                    width: 50,
                    child: Tooltip(
                      message: krc.name,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: krc.icon.startsWith('http')
                                  ? Image.network(
                                      krc.icon,
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                    )
                                  : Image.asset(
                                          'assets/icons/${krc.icon}',
                                          width: 24,
                                          height: 24,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                                        ),
                      ),
                    ),
                  )),
                ],
              ),
              
              // Data rows
              ...sites.map((site) => Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        site.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  ...widget.krcList.map((krc) {
                    final key = '${krc.id}-${site.id}';
                    final count = heatmapData[key] ?? 0;
                    final intensity = maxValue > 0 ? count / maxValue : 0.0;
                    
                    return Tooltip(
                      message: '${krc.name}\n${site.name}\n$count records',
                      child: Container(
                        width: 50,
                        height: 32,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: count == 0
                              ? const Color(0xFFF3F4F6)
                              : Color.lerp(
                                  const Color(0xFFFFE8DD),
                                  AppColors.textPrimary,
                                  intensity,
                                ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            count > 0 ? count.toString() : '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: intensity > 0.5
                                  ? Colors.white
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// Updated Records Per Week Chart
class _RecordsPerWeekChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  
  const _RecordsPerWeekChart({required this.weeklyData});
  
  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Color(0xFF9CA3AF))));
    }
    
    final spots = weeklyData.map((item) {
      final week = item['week'] as int;
      final count = item['safetyCardCount'] as int;
      return FlSpot((week - 1).toDouble(), count.toDouble());
    }).toList();

    final maxY = spots.isEmpty ? 10.0 : spots.map((s) => s.y).fold<double>(0.0, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: (maxY * 1.2).ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.textPrimary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.textPrimary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.textPrimary.withOpacity(0.3),
                  AppColors.textPrimary.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final weekIndex = value.toInt();
                if (weekIndex < 0 || weekIndex >= weeklyData.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'W${weekIndex + 1}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) return const SizedBox();
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Color(0xFFE5E7EB), strokeWidth: 1, dashArray: [5, 5]);
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
            left: BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF1F2937),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final weekIndex = spot.x.toInt();
                return LineTooltipItem(
                  'Week ${weekIndex + 1}\n${spot.y.toInt()} records',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}



class _SortableHeader extends StatelessWidget {
  final String label;
  final String sortColumn;
  final String? currentSortColumn;
  final bool sortAscending;
  final void Function(String) onSort;

  const _SortableHeader({
    required this.label,
    required this.sortColumn,
    required this.currentSortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentSortColumn == sortColumn;
    
    return InkWell(
      onTap: () => onSort(sortColumn),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.textPrimary : const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isActive
                ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 14,
            color: isActive ? AppColors.textPrimary : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }
}