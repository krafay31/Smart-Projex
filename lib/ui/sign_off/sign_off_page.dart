import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/app_database.dart';
import '../../main.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/app_colors.dart';
import '../../services/sign_off_service.dart';
import '../../services/attachment_storage_service.dart';
import 'create_sign_off_page.dart';
import 'sign_off_settings_page.dart';
import 'signature_modal.dart';

class SignOffPage extends StatefulWidget {
  const SignOffPage({super.key});

  @override
  State<SignOffPage> createState() => _SignOffPageState();
}

class _SignOffPageState extends State<SignOffPage> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _filtersChanged = false;
  
  // Data from SERVER
  List<Map<String, dynamic>> _serverCards = [];
  List<Map<String, dynamic>> _filteredServerCards = [];
  List<Map<String, dynamic>> _serverSites = [];
  List<Map<String, dynamic>> _serverLocations = [];
  List<AppUser> _allUsers = [];
  Map<String, List<Map<String, dynamic>>> _serverSignatures = {};
  
  // Usage counts for filter labels
  Map<String, int> _categoryUsage = {};
  Map<String, int> _sitesUsage = {};
  Map<String, int> _usersUsage = {};
  
  // Filters
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _selectedCategory;
  String? _selectedSiteId;
  String? _selectedLocationId;
  String? _selectedDeliveredBy;
  String? _selectedSignStatus; // "yet_to_sign", "signed", or null for all
  
  // Sorting
  String _sortColumn = 'date';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadDataFromServer();
  }

  Future<void> _loadDataFromServer() async {
    setState(() => _isLoading = true);
    try {
      final service = SignOffService();
      final sites = await service.fetchSites();
      final locations = await service.fetchLocations();
      final cards = await service.fetchSafetyCommunications();
      final allSignatures = await service.fetchSignatures();
      final users = await db.select(db.appUsers).get();
      
      final sigMap = <String, List<Map<String, dynamic>>>{};
      for (var card in cards) {
        final cardId = card['id']?.toString() ?? '';
        sigMap[cardId] = allSignatures.where((s) => s['communicationId'] == cardId).toList();
      }

      if (mounted) {
        setState(() {
          _serverSites = sites;
          _serverLocations = locations;
          _serverCards = cards;
          _allUsers = users;
          _serverSignatures = sigMap;
          _isLoading = false;
        });
        _applyFiltersAndSort();
        
        // Load usage counts asynchronously
        _loadUsageCounts();
      }
    } catch (e) {
      print('Error loading SignOff data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsageCounts() async {
    try {
      final service = SignOffService();
      final categoryUsage = await service.fetchCategoryUsage();
      final sitesUsage = await service.fetchSitesUsage();
      final usersUsage = await service.fetchUserUsage();
      
      if (mounted) {
        setState(() {
          _categoryUsage = categoryUsage;
          _sitesUsage = sitesUsage;
          _usersUsage = usersUsage;
        });
      }
    } catch (e) {
      print('Error loading usage counts: $e');
    }
  }

  void _applyFiltersAndSort() {
    var filtered = List<Map<String, dynamic>>.from(_serverCards);
    
    final currentUser = UserSession.userName ?? '';
    final isAdmin = UserSession.isAdmin;
    
    // Permission-based filtering: Admin sees all, users see own cards + cards where they're attendee
    if (!isAdmin) {
      filtered = filtered.where((card) {
        final cardId = card['id']?.toString() ?? '';
        final deliveredBy = card['deliveredBy']?.toString() ?? '';
        
        // User created/delivered the card
        if (deliveredBy.toLowerCase() == currentUser.toLowerCase()) {
          return true;
        }
        
        // User is an attendee of this card
        final signatures = _serverSignatures[cardId] ?? [];
        final isAttendee = signatures.any((sig) => 
          (sig['teamMember']?.toString() ?? '').toLowerCase() == currentUser.toLowerCase()
        );
        
        return isAttendee;
      }).toList();
    }
    
    if (_dateFrom != null) {
      filtered = filtered.where((c) {
        final d = DateTime.tryParse(c['date']?.toString() ?? '');
        return d != null && !d.isBefore(_dateFrom!);
      }).toList();
    }
    if (_dateTo != null) {
      filtered = filtered.where((c) {
        final d = DateTime.tryParse(c['date']?.toString() ?? '');
        return d != null && !d.isAfter(_dateTo!);
      }).toList();
    }
    if (_selectedCategory != null) {
      filtered = filtered.where((c) => c['category'] == _selectedCategory).toList();
    }
    if (_selectedSiteId != null) {
      filtered = filtered.where((c) => c['siteId'] == _selectedSiteId).toList();
    }
    if (_selectedLocationId != null) {
      filtered = filtered.where((c) => c['location'] == _selectedLocationId).toList();
    }
    if (_selectedDeliveredBy != null) {
      filtered = filtered.where((c) => c['deliveredBy'] == _selectedDeliveredBy).toList();
    }
    
    // Sign Status filter
    if (_selectedSignStatus != null) {
      filtered = filtered.where((card) {
        final cardId = card['id']?.toString() ?? '';
        final signatures = _serverSignatures[cardId] ?? [];
        
        if (_selectedSignStatus == 'yet_to_sign') {
          // Cards where current user has NOT signed yet
          final mySignatures = signatures.where((sig) => 
            (sig['teamMember']?.toString() ?? '').toLowerCase() == currentUser.toLowerCase()
          );
          return mySignatures.isNotEmpty && mySignatures.any((sig) {
            final signature = sig['signature']?.toString() ?? '';
            return signature.isEmpty || signature == 'null';
          });
        } else if (_selectedSignStatus == 'signed') {
          // Cards where current user has signed OR delivered by current user
          final deliveredBy = card['deliveredBy']?.toString() ?? '';
          if (deliveredBy.toLowerCase() == currentUser.toLowerCase()) {
            return true;
          }
          final mySignatures = signatures.where((sig) => 
            (sig['teamMember']?.toString() ?? '').toLowerCase() == currentUser.toLowerCase()
          );
          return mySignatures.isNotEmpty && mySignatures.any((sig) {
            final signature = sig['signature']?.toString() ?? '';
            return signature.isNotEmpty && signature != 'null';
          });
        }
        return true;
      }).toList();
    }
    
    // Sort
    filtered.sort((a, b) {
      // Default sort (Newest to Oldest) if no column selected
      if (_sortColumn == null || _sortColumn!.isEmpty) {
         final ca = DateTime.tryParse(a['creationDateTime']?.toString() ?? '') ?? DateTime(1900);
         final cb = DateTime.tryParse(b['creationDateTime']?.toString() ?? '') ?? DateTime(1900);
         return cb.compareTo(ca); // Descending
      }

      int cmp = 0;
      switch (_sortColumn) {
        case 'date':
          final da = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1900);
          final db = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1900);
          cmp = da.compareTo(db);
          break;
        case 'title':
          cmp = (a['title']?.toString() ?? '').compareTo(b['title']?.toString() ?? '');
          break;
        case 'category':
          cmp = (a['category']?.toString() ?? '').compareTo(b['category']?.toString() ?? '');
          break;
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });
    
    setState(() {
      _filteredServerCards = filtered;
      _filtersChanged = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _selectedCategory = null;
      _selectedSiteId = null;
      _selectedLocationId = null;
      _selectedDeliveredBy = null;
      _selectedSignStatus = null;
      _filtersChanged = false;
    });
    _applyFiltersAndSort();
  }

  void _sortBy(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = column != 'date';
      }
    });
    _applyFiltersAndSort();
  }

  String _getSiteName(String? siteId) {
    if (siteId == null) return '--';
    final site = _serverSites.firstWhere((s) => s['siteId'] == siteId || s['id'] == siteId || s['uuid'] == siteId, orElse: () => {});
    return site['name']?.toString() ?? siteId;
  }

  String _getLocationName(String? locId) {
    if (locId == null || locId.isEmpty) return '--';
    final loc = _serverLocations.firstWhere((l) => l['locationId'] == locId || l['id'] == locId || l['uuid'] == locId, orElse: () => {});
    return loc['name']?.toString() ?? locId;
  }

  String _extractTime(String? dateStr, [String? timeStr]) {
    // First check if we have a separate time field that's valid
    if (timeStr != null && timeStr.isNotEmpty && timeStr != 'null' && timeStr != '--') {
      return timeStr;
    }
    
    // Otherwise extract from date string
    if (dateStr == null || dateStr.isEmpty) return '--';
    
    try {
      // Try parsing with DateTime
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        final formatted = DateFormat('hh:mm a').format(dt.toLocal());
        // Return formatted time (even if 00:00 - let the grid show it)
        return formatted;
      }
      return '--';
    } catch (_) {
      return '--';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yy').format(dt);
    } catch (_) {
      return dateStr ?? '--';
    }
  }

  String _formatDateWithTime(Map<String, dynamic> card) {
    final dateStr = card['date']?.toString();
    final timeStr = card['time']?.toString();
    
    String datePart = '--';
    String timePart = '';
    
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr);
        datePart = DateFormat('dd/MM/yy').format(dt);
        // Extract time from date if contains T
        if (dateStr.contains('T')) {
          final extractedTime = DateFormat.Hm().format(dt);
          if (extractedTime != '00:00') {
            timePart = extractedTime;
          }
        }
      } catch (_) {
        datePart = dateStr;
      }
    }
    
    // Use separate time field if available and valid
    if (timeStr != null && timeStr.isNotEmpty && timeStr != 'null' && timeStr != '00:00') {
      timePart = timeStr;
    }
    
    return timePart.isNotEmpty ? '$datePart $timePart' : datePart;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final isMobile = screenSize == ScreenSize.mobile;
        final isTablet = screenSize == ScreenSize.tablet;
        final padding = ResponsiveUtils.getResponsivePadding(context);

        if (isMobile) {
          return _buildMobileLayout(padding);
        } else if (isTablet) {
          return _buildTabletLayout(padding);
        } else {
          return _buildDesktopLayout(padding);
        }
      },
    );
  }

  // === DESKTOP LAYOUT (Same as HomePage) ===
  Widget _buildDesktopLayout(double padding) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final filterWidth = (totalWidth * 0.18).clamp(220.0, 350.0);
        final statsWidth = (totalWidth * 0.18).clamp(180.0, 320.0);
        final gap = padding * 0.125;
        
        return Padding(
          padding: EdgeInsets.all(gap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LEFT: Filters
              Container(
                width: filterWidth,
                decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(gap),
                  child: _buildFiltersSection(padding),
                ),
              ),
              SizedBox(width: gap),
              // CENTER: Records
              Expanded(
                child: Container(
                  color: const Color(0xFFF3F4F6),
                  padding: EdgeInsets.all(gap),
                  child: _buildRecordsSection(padding),
                ),
              ),
              SizedBox(width: gap),
              // RIGHT: Stats
              Container(
                width: statsWidth,
                constraints: const BoxConstraints(minWidth: 150, maxWidth: 320),
                decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(gap),
                  child: _buildStatsSection(padding),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout(double padding) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            _buildFiltersSection(padding),
            SizedBox(height: padding),
            _buildRecordsSection(padding),
            SizedBox(height: padding),
            _buildStatsSection(padding),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double padding) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildFiltersSection(padding),
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
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
                _buildRecordsSection(padding),
                _buildStatsSection(padding),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === FILTERS SECTION (Same design as HomePage) ===
  Widget _buildFiltersSection(double padding) {
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
          // Header with ICON BUTTONS (like HomePage)
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _filtersChanged ? const Color(0xFF0076D6).withOpacity(0.1) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    _filtersChanged ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: _filtersChanged ? const Color(0xFF0076D6) : const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  onPressed: _filtersChanged ? _applyFiltersAndSort : null,
                  tooltip: _filtersChanged ? 'Apply Filters' : 'No Changes',
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF6B7280), size: 20),
                  onPressed: _clearFilters,
                  tooltip: 'Clear Filters',
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          SizedBox(height: padding),
          
          // Date Range - Icon click popup (like HomePage)
          _buildFilterLabel('Date Range'),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showDateRangeDialog(),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 18, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dateFrom != null || _dateTo != null
                          ? '${_dateFrom != null ? DateFormat('dd/MM/yy').format(_dateFrom!) : 'Start'} - ${_dateTo != null ? DateFormat('dd/MM/yy').format(_dateTo!) : 'End'}'
                          : 'All Dates',
                      style: TextStyle(fontSize: 13, color: _dateFrom != null || _dateTo != null ? const Color(0xFF111827) : const Color(0xFF9CA3AF)),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Category dropdown (with usage counts)
          _buildFilterLabel('Category'),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            value: _selectedCategory,
            hint: 'All Categories',
            items: ['Induction', 'Training', 'Toolbox Talk', 'Procedure', 'Risk Assessment', 'COSHH Assessment', 'Other'],
            itemLabels: {
              for (var cat in ['Induction', 'Training', 'Toolbox Talk', 'Procedure', 'Risk Assessment', 'COSHH Assessment', 'Other'])
                cat: () {
                  final count = _categoryUsage[cat] ?? 0;
                  return count > 0 ? '$cat ($count)' : cat;
                }()
            },
            onChanged: (v) => setState(() { _selectedCategory = v; _filtersChanged = true; }),
          ),
          const SizedBox(height: 16),
          
          // Site dropdown (with usage counts)
          _buildFilterLabel('Site'),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            value: _selectedSiteId,
            hint: 'All Sites',
            items: _serverSites.map((s) => s['siteId']?.toString() ?? s['id']?.toString() ?? '').where((s) => s.isNotEmpty).toSet().toList(),
            itemLabels: {
              for (var s in _serverSites)
                (s['siteId']?.toString() ?? s['id']?.toString() ?? ''): () {
                  final name = s['name']?.toString() ?? '';
                  final count = _sitesUsage[name] ?? 0;
                  return count > 0 ? '$name ($count)' : name;
                }()
            },
            onChanged: (v) => setState(() { _selectedSiteId = v; _selectedLocationId = null; _filtersChanged = true; }),
          ),
          const SizedBox(height: 16),
          
          // Location dropdown
          _buildFilterLabel('Location'),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            value: _selectedLocationId,
            hint: 'All Locations',
            items: _serverLocations
                .where((l) => _selectedSiteId == null || l['siteId'] == _selectedSiteId)
                .map((l) => l['locationId']?.toString() ?? l['id']?.toString() ?? '')
                .where((l) => l.isNotEmpty)
                .toSet()
                .toList(),
            itemLabels: {for (var l in _serverLocations) (l['locationId']?.toString() ?? l['id']?.toString() ?? ''): l['name']?.toString() ?? ''},
            onChanged: _selectedSiteId == null ? null : (v) => setState(() { _selectedLocationId = v; _filtersChanged = true; }),
          ),
          const SizedBox(height: 16),
          
          // Delivered By dropdown (with usage counts)
          _buildFilterLabel('Delivered By'),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            value: _selectedDeliveredBy,
            hint: 'All Users',
            items: _allUsers.map((u) => u.name).toSet().toList(),
            itemLabels: {
              for (var u in _allUsers)
                u.name: () {
                  final count = _usersUsage[u.name] ?? 0;
                  return count > 0 ? '${u.name} ($count)' : u.name;
                }()
            },
            onChanged: (v) => setState(() { _selectedDeliveredBy = v; _filtersChanged = true; }),
          ),
          const SizedBox(height: 16),
          
          // Apply and Clear buttons at bottom (like HomePage)
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _filtersChanged ? _applyFiltersAndSort : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0076D6),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)));
  }

  Widget _buildFilterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    Map<String, String>? itemLabels,
    ValueChanged<String?>? onChanged,
  }) {
    // Deduplicate
    final uniqueItems = items.toSet().toList();
    final effectiveValue = (value != null && uniqueItems.contains(value)) ? value : null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(6),
        color: onChanged == null ? const Color(0xFFF9FAFB) : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          value: effectiveValue,
          style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
          items: [
            DropdownMenuItem<String>(value: null, child: Text(hint)),
            ...uniqueItems.map((item) => DropdownMenuItem(
              value: item,
              child: Text(itemLabels?[item] ?? item, overflow: TextOverflow.ellipsis),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showDateRangeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range, color: Color(0xFF0076D6)),
                  const SizedBox(width: 8),
                  const Text('Date Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDatePickerField('From', _dateFrom, (d) => setState(() { _dateFrom = d; _filtersChanged = true; Navigator.pop(ctx); _showDateRangeDialog(); })),
              const SizedBox(height: 12),
              _buildDatePickerField('To', _dateTo, (d) => setState(() { _dateTo = d; _filtersChanged = true; Navigator.pop(ctx); _showDateRangeDialog(); })),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() { _dateFrom = null; _dateTo = null; _filtersChanged = true; });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear', style: TextStyle(color: Color(0xFF6B7280))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () { Navigator.pop(ctx); _applyFiltersAndSort(); },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0076D6), foregroundColor: Colors.white),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, DateTime? value, ValueChanged<DateTime> onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            const Spacer(),
            Text(
              value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Select',
              style: TextStyle(fontSize: 14, color: value != null ? const Color(0xFF111827) : const Color(0xFF9CA3AF)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  // === RECORDS SECTION ===
  Widget _buildRecordsSection(double padding) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(padding),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0076D6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment, color: Color(0xFF0076D6), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Safety Communications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      Text('${_filteredServerCards.length} records', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateSignOffPage()));
                    _loadDataFromServer();
                  },
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF9FAFB),
            child: Row(
              children: [
                _buildSortableHeader('TITLE', 'title', flex: 4),
                _buildSortableHeader('DATE & TIME', 'date', flex: 3),
                _buildHeader('DELIVERED BY', flex: 3),
                _buildHeader('CATEGORY', flex: 2),
                _buildHeader('SITE', flex: 2),
                _buildHeader('LOCATION', flex: 2),
                _buildHeader('ACTIONS', flex: 3, centered: true),
              ],
            ),
          ),
          
          // Table Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0076D6)))
                : _filteredServerCards.isEmpty
                    ? const Center(child: Text('No records found', style: TextStyle(color: Color(0xFF6B7280))))
                    : ListView.builder(
                        itemCount: _filteredServerCards.length,
                        itemBuilder: (context, index) => _buildRecordRow(_filteredServerCards[index], index),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String label, String column, {int flex = 1}) {
    final isActive = _sortColumn == column;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _sortBy(column),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF0076D6) : const Color(0xFF6B7280))),
            if (isActive) Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: const Color(0xFF0076D6)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String label, {int flex = 1, bool centered = false}) {
    return Expanded(
      flex: flex,
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)), textAlign: centered ? TextAlign.center : TextAlign.left),
    );
  }

  Widget _buildRecordRow(Map<String, dynamic> card, int index) {
    final category = card['category']?.toString() ?? '';
    final catColor = _getCategoryColor(category);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFAFAFA),
        border: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          // Title
          Expanded(flex: 4, child: Text(card['title']?.toString() ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          // Date & Time
          Expanded(
            flex: 3, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDate(card['date']?.toString()),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 2),
                Text(
                  _extractTime(card['creationDateTime']?.toString(), card['time']?.toString()),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            )
          ),
          // Delivered By
          Expanded(flex: 3, child: Text(card['deliveredBy']?.toString() ?? '', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
          // Category
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.category_outlined, size: 20, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Site
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 4),
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
                      _getSiteName(card['siteId']?.toString()),
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
          // Location
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 4),
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
                      _getLocationName(card['location']?.toString()),
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
          // Actions - permission-based
          Expanded(
            flex: 3,
            child: Builder(
              builder: (context) {
                final currentUser = UserSession.userName ?? '';
                final isAdmin = UserSession.isAdmin;
                final deliveredBy = card['deliveredBy']?.toString() ?? '';
                final isCreator = deliveredBy.toLowerCase() == currentUser.toLowerCase();
                final canEditDelete = isAdmin || isCreator;
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionIcon(Icons.visibility_outlined, Colors.purple, () => _showDetailsDialog(card)),
                    const SizedBox(width: 4),
                    if (canEditDelete) ...[
                    _buildActionIcon(Icons.edit_outlined, AppColors.primary, () => _handleAction('edit', card)),
                    const SizedBox(width: 4),
                  ],
                  _buildActionIcon(Icons.draw_outlined, const Color(0xFF16A34A), () => _handleAction('signature', card)),
                  if (canEditDelete) ...[
                    const SizedBox(width: 4),
                    _buildActionIcon(Icons.delete_outline, const Color(0xFFDC2626), () => _handleAction('delete', card)),
                  ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  String _formatDateTimeCombined(Map<String, dynamic> card) {
    // Try to get date and time
    final dateStr = card['date']?.toString();
    final timeStr = card['time']?.toString();
    final creationDateTime = card['creationDateTime']?.toString();
    
    if (dateStr == null || dateStr.isEmpty) return '--';
    
    try {
      // Parse date
      DateTime dt = DateTime.parse(dateStr);
      
      // Try to parse time
      if (timeStr != null && timeStr.isNotEmpty && timeStr != 'null' && timeStr != '00:00') {
        final timeParts = timeStr.split(':');
        if (timeParts.length >= 2) {
          dt = DateTime(dt.year, dt.month, dt.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
        }
      } else if (creationDateTime != null) {
        // Fallback to creationDateTime if time is missing
        try {
          final creationDt = DateTime.parse(creationDateTime).toLocal();
          dt = DateTime(dt.year, dt.month, dt.day, creationDt.hour, creationDt.minute);
        } catch (_) {}
      } else if (dateStr.contains('T')) {
         // If dateStr has time component
      }
      
      return DateFormat('dd/MM/yy hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Color _getCategoryColor(String category) {
    // All categories use the same blue color for consistency
    return const Color(0xFF0076D6);
  }



  void _handleAction(String action, Map<String, dynamic> card) async {
    final cardId = card['id']?.toString() ?? '';
    switch (action) {
      case 'edit':
        final safetyComm = SafetyCommunication(
          localId: 0,
          id: cardId,
          title: card['title']?.toString() ?? '',
          category: card['category']?.toString() ?? '',
          date: card['date']?.toString() ?? '',
          siteId: card['siteId']?.toString() ?? '',
          location: card['location']?.toString() ?? '',
          deliveredBy: card['deliveredBy']?.toString() ?? '',
          department: card['department']?.toString(),
          project: card['project']?.toString(),
          description: card['description']?.toString(),
          induction: card['induction'] == true,
          training: card['training'] == true,
          toolboxTalk: card['toolboxTalk'] == true,
          procedure: card['procedure'] == true,
          riskAssessment: card['riskAssessment'] == true,
          coshhAssessment: card['coshhAssessment'] == true,
          other: card['other'] == true,
          generateReport: card['generateReport'] == true,
          creationDateTime: card['creationDateTime']?.toString(),
          isSynced: true,
          isDeleted: false,
        );
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateSignOffPage(existingCard: safetyComm)));
        _loadDataFromServer();
        break;
      case 'signature':
        final safetyComm = SafetyCommunication(
          localId: 0,
          id: cardId,
          title: card['title']?.toString() ?? '',
          category: card['category']?.toString() ?? '',
          date: card['date']?.toString() ?? '',
          siteId: card['siteId']?.toString() ?? '',
          location: card['location']?.toString() ?? '',
          deliveredBy: card['deliveredBy']?.toString() ?? '',
          induction: false, training: false, toolboxTalk: false, procedure: false, riskAssessment: false, coshhAssessment: false, other: false, generateReport: false, isSynced: true, isDeleted: false,
        );
        showDialog(context: context, builder: (_) => SignatureModal(communication: safetyComm));
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete'),
            content: const Text('Delete this record?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (confirm == true) {
          await SignOffService().deleteSafetyCommunication(cardId);
          _loadDataFromServer();
        }
        break;
    }
  }

  // === STATS SECTION ===
  Widget _buildStatsSection(double padding) {
    final categoryCount = <String, int>{};
    final siteCount = <String, int>{};
    final deliveredByCount = <String, int>{};
    
    for (var card in _filteredServerCards) {
      final cat = card['category']?.toString() ?? 'Other';
      final site = _getSiteName(card['siteId']?.toString());
      final del = card['deliveredBy']?.toString() ?? 'Unknown';
      categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
      siteCount[site] = (siteCount[site] ?? 0) + 1;
      deliveredByCount[del] = (deliveredByCount[del] ?? 0) + 1;
    }

    return Column(
      children: [
        // Total Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.textPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.assignment, color: AppColors.textPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_filteredServerCards.length}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const Text('Total', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12),  // Reduced from full padding
        _buildBarChart('Categories', categoryCount, padding),
        SizedBox(height: 12),  // Reduced from full padding
        _buildBarChart('Sites', siteCount, padding),
        SizedBox(height: 12),  // Reduced from full padding
        _buildBarChart('Delivered By', deliveredByCount, padding),
      ],
    );
  }

  Widget _buildBarChart(String title, Map<String, int> data, double padding) {
    final sortedEntries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sortedEntries.take(5).toList();
    final maxVal = top5.isEmpty ? 1 : top5.first.value;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (top5.isEmpty)
            const Center(child: Text('No data', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)))
          else
            ...top5.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                      Text('${e.value}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / maxVal,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
  void _showDetailsDialog(Map<String, dynamic> card) async {
    // Retrieve attachments from IndexedDB
    final attachmentStorage = AttachmentStorageService();
    final attachments = await attachmentStorage.getAttachments(card['id']?.toString() ?? '');
    
    // Add attachments to card data for display
    final cardWithAttachments = Map<String, dynamic>.from(card);
    if (attachments.isNotEmpty) {
      cardWithAttachments['attachments'] = attachments;
    }
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment, color: Color(0xFF0076D6), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cardWithAttachments['title']?.toString() ?? 'Details',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  _detailItem('Category', cardWithAttachments['category']?.toString()),
                  _detailItem('Date', _formatDate(cardWithAttachments['date']?.toString())),
                  _detailItem('Time', _extractTime(cardWithAttachments['creationDateTime']?.toString(), cardWithAttachments['time']?.toString())),
                  _detailItem('Delivered By', cardWithAttachments['deliveredBy']?.toString()),
                  _detailItem('Site', _getSiteName(cardWithAttachments['siteId']?.toString())),
                  _detailItem('Location', _getLocationName(cardWithAttachments['location']?.toString())),
                  _detailItem('Department', cardWithAttachments['department']?.toString()),
                  _detailItem('Project', cardWithAttachments['project']?.toString()),
                ],
              ),
              if (cardWithAttachments['description'] != null && cardWithAttachments['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Description / Comments', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
                  child: Text(cardWithAttachments['description']?.toString() ?? '', style: const TextStyle(fontSize: 14)),
                ),
              ],
              // Attachments section (if available)
              if (cardWithAttachments['attachments'] != null) ..._buildAttachmentSection(cardWithAttachments['attachments']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String? value) {
    if (value == null || value.isEmpty || value == 'null') return const SizedBox();
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  List<Widget> _buildAttachmentSection(dynamic attachmentsData) {
    print('📎 Attachments field type: ${attachmentsData.runtimeType}');
    print('📎 Attachments value: $attachmentsData');
    
    // Parse attachments - handle both List and JSON string
    List attachmentList = [];
    try {
      if (attachmentsData is List) {
        attachmentList = attachmentsData;
      } else if (attachmentsData is String && attachmentsData.isNotEmpty) {
        // Try to parse JSON string
        final decoded = json.decode(attachmentsData);
        if (decoded is List) {
          attachmentList = decoded;
        }
      }
    } catch (e) {
      print('⚠️ Error parsing attachments: $e');
    }
    
    if (attachmentList.isEmpty) return [];
    
    return [
      const SizedBox(height: 24),
      const Text('Attachments', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: attachmentList.map((file) => InkWell(
          onTap: () => _downloadAttachment(file),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.attach_file, size: 16, color: Color(0xFF0076D6)),
                const SizedBox(width: 6),
                Text(
                  file is Map ? (file['name']?.toString() ?? 'File') : file.toString(), 
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0076D6), decoration: TextDecoration.underline)
                ),
                const SizedBox(width: 4),
                const Icon(Icons.download, size: 14, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        )).toList(),
      ),
    ];
  }
  
  void _downloadAttachment(dynamic file) {
    if (file is! Map) return;
    
    try {
      final fileName = file['name']?.toString() ?? 'download';
      final base64Data = file['data']?.toString();
      
      if (base64Data == null || base64Data.isEmpty) {
        print('⚠️ No data found for attachment');
        return;
      }
      
      // Decode base64 to bytes
      final bytes = base64.decode(base64Data);
      
      // Create blob and download
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      
      print('📎 Downloaded attachment: $fileName');
    } catch (e) {
      print('⚠️ Error downloading attachment: $e');
    }
  }
}
