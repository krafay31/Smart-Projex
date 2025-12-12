// ignore_for_file: unnecessary_import, unused_import

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:safety_card_web/utils/app_colors.dart';
import '../services/sync_service.dart';
import '../data/app_database.dart';
import '../main.dart';
import '../utils/responsive_utils.dart';
import '../services/sync_service.dart';
import 'package:uuid/uuid.dart';
import '../helpers/krc_helper.dart';
import '../helpers/site_helper.dart';
import '../helpers/location_helper.dart';
import '../helpers/users_helper.dart';
import '../utils/status_helper.dart';

class CreateSafetyCardPage extends StatefulWidget {
  const CreateSafetyCardPage({super.key});

  @override
  State<CreateSafetyCardPage> createState() => _CreateSafetyCardPageState();
}

class _CreateSafetyCardPageState extends State<CreateSafetyCardPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentPanel = 0;
  bool _safetyStatusError = false;
  bool _isSaving = false; // Add this flag to prevent double submission

  int? _raisedById;
  late Future<List<AppUser>> _appUsersF;

  // form state
  int? _siteId;
  int? _locationId;
  int? _krcId;
  String _department = 'Services';
  String? _safetyStatus; // Changed to nullable
  String _observation = '';
  String _actionTaken = '';
  int? _personResponsibleId;
  List<Uint8List> _imageBytesList = [];
  bool _isAnonymous = false; // New state for anonymous submission
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  late Future<List<Site>> _sitesF;
  late Future<List<KeyRiskCondition>> _krcF;
  // ignore: unused_field
  late Future<List<UserLite>> _usersF;
  List<Location> _locations = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
    
    _loadPreferences();
    
    _sitesF = SiteHelper.fetchFromServer();
    _krcF = KrcHelper.fetchFromServer();
    _usersF = UsersHelper.fetchFromServer();
    _appUsersF = db.select(db.appUsers).get();
    _raisedById = UserSession.userId; // Pre-select current user
  }

  Future<void> _loadPreferences() async {
    await UserSession.loadPreferences();
    if (UserSession.userSiteId != null) {
      _siteId = UserSession.userSiteId;
      _locationId = UserSession.userLocationId;
      _department = UserSession.userDepartment ?? 'Services';
      
      if (_siteId != null) {
        // Find the site UUID from the helper results to fetch locations
        final sites = await _sitesF;
        final site = sites.firstWhere((s) => s.id == _siteId, orElse: () => sites.first);
        _locations = await LocationHelper.fetchBySite(site.uuid);
      }
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _imageBytesList.add(bytes));
    }
  }

  Future<KeyRiskCondition?> _getSelectedKrc() async {
    if (_krcId == null) return null;
    final krcList = await _krcF;
    return krcList.firstWhere((k) => k.id == _krcId, orElse: () => krcList.first);
  }

  void _removeImage(int index) {
    setState(() => _imageBytesList.removeAt(index));
  }

  bool _validatePanel0() {
    if (_krcId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Key Risk Condition')),
      );
      return false;
    }
    return true;
  }

  bool _validatePanel1() {
    if (_krcId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Key Risk Condition first')),
      );
      return false;
    }
    if (_siteId == null || _locationId == null || _department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
  }

  bool _validatePanel2() {
    if (_safetyStatus == null) {
      setState(() => _safetyStatusError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Safe or Unsafe status')),
      );
      return false;
    }
    setState(() => _safetyStatusError = false);
    return true;
  }

  void _jumpToPanel(int panelIndex) {
    if (panelIndex == _currentPanel) return;
    
    // If trying to go forward, validate current panels up to the target
    if (panelIndex > _currentPanel) {
      if (_currentPanel == 0 && !_validatePanel0()) return;
      if (_currentPanel == 1 && !_validatePanel1()) return;
      // If jumping from 0 to 2, need to validate 1 as well? 
      // Ideally we validate everything up to the target.
      // For simplicity, let's just allow sequential or backward navigation via clicks if validated.
      
      // Better approach: Check if we CAN go to that panel.
      if (panelIndex == 1 && !_validatePanel0()) return;
      if (panelIndex == 2) {
        if (!_validatePanel0()) return;
        if (!_validatePanel1()) return;
      }
    }
    
    setState(() => _currentPanel = panelIndex);
  }

  void _nextPanel() {
    if (_currentPanel == 0 && !_validatePanel0()) return;
    if (_currentPanel == 1 && !_validatePanel1()) return;
    
    if (_currentPanel < 2) {
      setState(() => _currentPanel++);
    }
  }

  void _previousPanel() {
    if (_currentPanel > 0) {
      setState(() => _currentPanel--);
    }
  }

  Future<void> _save() async {
    // Prevent double submission
    if (_isSaving) return;
    
    if (!_formKey.currentState!.validate()) return;
    if (!_validatePanel2()) return;
    
    setState(() => _isSaving = true);
    
    try {
      _formKey.currentState!.save();
      
      if (_siteId != null && _locationId != null) {
        await UserSession.savePreferences(_department, _siteId!, _locationId!);
      }
      
      Uint8List? primaryImage;
      String? imageListJson;
      
      if (_imageBytesList.isNotEmpty) {
        final base64List = _imageBytesList.map((bytes) {
          return base64Encode(bytes);
        }).toList();
        imageListJson = base64List.join('|||');
        primaryImage = null;
      }

      // Use actual raisedById (not anonymous user)
      int raisedByIdToUse = _raisedById ?? UserSession.userId ?? 1;
      
      print('💾 Creating card with raisedById: $raisedByIdToUse (adminModified: $_isAnonymous)');

      final int? finalPersonResponsibleId = UserSession.isAdmin 
        ? _personResponsibleId 
        : null;

      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr = DateFormat('HH:mm:ss').format(DateTime(
        now.year, 
        now.month, 
        now.day, 
        _selectedTime.hour, 
        _selectedTime.minute,
        now.second,
      ));

      // ✅ Set adminModified based on checkbox
      final card = SafetyCardsCompanion.insert(
        uuid: const Uuid().v4(), 
        keyRiskConditionId: _krcId!,
        date: dateStr,
        time: timeStr,
        raisedById: raisedByIdToUse, // ✅ Use actual user ID
        department: _department,
        siteId: _siteId!,
        locationId: _locationId!,
        safetyStatus: _safetyStatus!,
        observation: _observation,
        actionTaken: _actionTaken,
        personResponsibleId: Value(finalPersonResponsibleId),
        imageData: Value(primaryImage),
        imageListBase64: Value(imageListJson),
        status: const Value('Open'),
        adminModified: Value(_isAnonymous ? true : null), // ✅ Set based on checkbox
      );

      await syncService.createCard(card); // ✅ No isAnonymous parameter
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safety card created successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error saving card: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final isMobile = screenSize == ScreenSize.mobile;
        final padding = ResponsiveUtils.getResponsivePadding(context);
        
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isMobile ? 'New Safety Record' : 'Health and Safety Management Panel',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface,
                ),
              ),
            ),
            actions: [
              if (!isMobile)
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: Colors.grey[300],
                height: 1,
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 1000,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Card(
                  elevation: isMobile ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    side: isMobile ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMobile) ...[
                            Row(
                              children: [
                                const Text(
                                  'Create New Safety Record',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  icon: const Icon(Icons.close),
                                  label: const Text(''),
                                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ] else ...[
                            const Text(
                              'Create New Safety Record',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Progress indicator
                          _buildProgressIndicator(isMobile),
                          SizedBox(height: isMobile ? 24 : 32),
                          
                          // Panel content
                          if (_currentPanel == 0) _buildPanel0(isMobile),
                          if (_currentPanel == 1) _buildPanel1(isMobile),
                          if (_currentPanel == 2) _buildPanel2(isMobile),
                          
                          SizedBox(height: isMobile ? 24 : 32),
                          
                          // Navigation buttons
                          _buildNavigationButtons(isMobile),
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
    );
  }

  Widget _buildProgressIndicator(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              _buildProgressStep(0, 'Key Risk', isMobile),
              Expanded(child: _buildProgressLine(0)),
              _buildProgressStep(1, 'Location', isMobile),
              Expanded(child: _buildProgressLine(1)),
              _buildProgressStep(2, 'Details', isMobile),
            ],
          ),
        ],
      );
    }
    
    return Row(
      children: [
        _buildProgressStep(0, 'Key Risk', isMobile),
        Expanded(child: _buildProgressLine(0)),
        _buildProgressStep(1, 'Location', isMobile),
        Expanded(child: _buildProgressLine(1)),
        _buildProgressStep(2, 'Details', isMobile),
      ],
    );
  }

  Widget _buildProgressStep(int index, String label, bool isMobile) {
    final isActive = _currentPanel >= index;
    return InkWell(
      onTap: () => _jumpToPanel(index),
      borderRadius: BorderRadius.circular(8),
      child: Column(
      children: [
        Container(
          width: isMobile ? 32 : 40,
          height: isMobile ? 32 : 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.textPrimary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: isActive ? AppColors.textPrimary : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildProgressLine(int index) {
    final isActive = _currentPanel > index;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: isActive ? AppColors.primary : Colors.grey[300],
    );
  }

  Widget _buildPanel0(bool isMobile) {
    return FutureBuilder<List<KeyRiskCondition>>(
      future: _krcF,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final krcList = snapshot.data!;
        final crossAxisCount = ResponsiveUtils.getGridCrossAxisCount(context);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Key Risk Condition',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(
                        'Choose the key risk condition that applies to this observation',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentPanel == 0 && _krcId != null) ...[
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: AppColors.primary,
                    iconSize: isMobile ? 24 : 28,
                    tooltip: 'Next',
                    onPressed: _nextPanel,
                  ),
                ],
              ],
            ),
            SizedBox(height: isMobile ? 16 : 24),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isMobile ? 8 : 16,
                mainAxisSpacing: isMobile ? 8 : 16,
                childAspectRatio: 0.85,
              ),
              itemCount: krcList.length,
              itemBuilder: (context, index) {
                final krc = krcList[index];
                final isSelected = _krcId == krc.id;
                
                return InkWell(
                  onTap: () {
                    setState(() => _krcId = krc.id);
                    // Auto-navigate to Location page
                    _jumpToPanel(1);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.textPrimary
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                      color: isSelected 
                          ? AppColors.textPrimary.withOpacity(0.05)
                          : AppColors.surface,
                    ),
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: krc.icon.startsWith('http')
                              ? Image.network(
                                  krc.icon,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image,
                                          size: isMobile ? 24 : 40, color: Colors.grey),
                                )
                              : Image.asset(
                                  'assets/icons/${krc.icon}',
                                  fit: BoxFit.contain, // Ensure aspect ratio is maintained
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image_not_supported,
                                          size: isMobile ? 24 : 40, color: Colors.grey),
                                ),
                        ),
                        SizedBox(height: isMobile ? 4 : 8),
                        Text(
                          krc.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected 
                                ? AppColors.textPrimary
                                : const Color(0xFF374151),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPanel1(bool isMobile) {
    return FutureBuilder<List<Site>>(
      future: _sitesF,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final sites = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Details',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(
                        'Provide location and reporter information',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentPanel == 1 && _siteId != 0 && _locationId != 0) ...[
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: AppColors.primary,
                    iconSize: isMobile ? 24 : 28,
                    tooltip: 'Next',
                    onPressed: _nextPanel,
                  ),
                ],
              ],
            ),
            SizedBox(height: isMobile ? 16 : 24),
            
            // Add Selected KRC Display Card
            FutureBuilder<KeyRiskCondition?>(
              future: _getSelectedKrc(),
              builder: (context, krcSnapshot) {
                final krc = krcSnapshot.data;
                return InkWell(
                  onTap: () => setState(() => _currentPanel = 0),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBorder,
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        if (krc != null)
                          Container(
                            width: isMobile ? 50 : 60,
                            height: isMobile ? 50 : 60,
                            alignment: Alignment.center,
                            child: krc.icon.startsWith('http')
                                ? Image.network(
                                    krc.icon,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.broken_image,
                                            size: isMobile ? 40 : 50, color: Colors.grey),
                                  )
                                : Image.asset(
                                    'assets/icons/${krc.icon}',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.image_not_supported,
                                            size: isMobile ? 40 : 50, color: Colors.grey),
                                  ),
                          )
                        else
                          Icon(
                            Icons.warning_amber_rounded,
                            size: isMobile ? 40 : 50,
                            color: AppColors.yellow,
                          ),
                        SizedBox(width: isMobile ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Risk Condition',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 13,
                                  color: AppColors.surface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                krc?.name ?? 'Not Selected',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: isMobile ? 20 : 24,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isMobile ? 16 : 24),
            _dropdown<int>(
              'Site *',
              _siteId,
              sites
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ))
                  .toList(),
              (v) async {
                setState(() => _siteId = v);
                if (v != null) {
                  // Find the site UUID from the helper results to fetch locations
                  final sites = await _sitesF;
                  final site = sites.firstWhere((s) => s.id == v, orElse: () => sites.first);
                  _locations = await LocationHelper.fetchBySite(site.uuid);
                  
                  setState(() => _locationId = null);
                  if (_locationId != null) {
                    await UserSession.savePreferences(_department, v, _locationId!);
                  }
                }
              },
            ),
            SizedBox(height: isMobile ? 16 : 20),
            
            _dropdown<int>(
              'Location *',
              _locationId,
              _locations
                  .map((l) => DropdownMenuItem(
                        value: l.id,
                        child: Text(l.name),
                      ))
                  .toList(),
              (v) async {
                setState(() => _locationId = v);
                if (v != null && _siteId != null) {
                  await UserSession.savePreferences(_department, _siteId!, v);
                }
              },
            ),
            SizedBox(height: isMobile ? 16 : 20),
            
            _text(
              'Department *',
              (v) {
                _department = v ?? 'Services';
                if (_siteId != null && _locationId != null) {
                  UserSession.savePreferences(_department, _siteId!, _locationId!);
                }
              },
              initial: _department,
              onChanged: (v) async {
                _department = v;
                if (_siteId != null && _locationId != null) {
                  await UserSession.savePreferences(v, _siteId!, _locationId!);
                }
              },
            ),
            SizedBox(height: isMobile ? 16 : 20),

            // Anonymous Checkbox + Raised By Section with padding
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ PRETTIER: Modern card-style checkbox
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isAnonymous = !_isAnonymous;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isAnonymous 
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.white,
                        border: Border.all(
                          color: _isAnonymous 
                              ? AppColors.primary
                              : const Color(0xFFE5E7EB),
                          width: _isAnonymous ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _isAnonymous 
                                  ? AppColors.primary
                                  : Colors.white,
                              border: Border.all(
                                color: _isAnonymous 
                                    ? AppColors.primary
                                    : const Color(0xFFD1D5DB),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: _isAnonymous
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Submit as Anonymous',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _isAnonymous 
                                        ? AppColors.primary
                                        : const Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your identity will be hidden from the report',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isAnonymous 
                                        ? AppColors.primaryDark
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isAnonymous ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: _isAnonymous 
                                ? AppColors.primary
                                : const Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // ✅ UPDATED: Only show Raised By when NOT anonymous
                  if (!_isAnonymous) ...[
                    const SizedBox(height: 16),
                    FutureBuilder<List<AppUser>>(
                      future: _appUsersF,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final appUsers = snapshot.data!;
                        
                        // For non-admin users, show raised by name in a disabled text field
                        if (!UserSession.isAdmin) {
                          return FutureBuilder<List<UserLite>>(
                            future: _usersF,
                            builder: (context, usersSnapshot) {
                              if (!usersSnapshot.hasData) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final users = usersSnapshot.data!;
                              final raisedByUser = users.firstWhere(
                                (u) => u.id == _raisedById,
                                orElse: () => users.first,
                              );
                              
                              return TextFormField(
                                initialValue: raisedByUser.name,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Raised By *',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                              );
                            },
                          );
                        }
                        
                        // For admin users, show dropdown
                        return FutureBuilder<List<UserLite>>(
                          future: _usersF,
                          builder: (context, usersSnapshot) {
                            if (!usersSnapshot.hasData) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final users = usersSnapshot.data!;
                            
                            return _dropdown<int>(
                              'Raised By *',
                              _raisedById,
                              appUsers
                                  .map((appUser) {
                                    final matchingUser = users.firstWhere(
                                      (u) => u.name == appUser.name,
                                      orElse: () => users.first,
                                    );
                                    return DropdownMenuItem(
                                      value: matchingUser.id,
                                      child: Text(appUser.name),
                                    );
                                  })
                                  .toList(),
                              (v) => setState(() => _raisedById = v!),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),


            SizedBox(height: isMobile ? 16 : 24),
            
            const Divider(),
            SizedBox(height: isMobile ? 16 : 24),
            
            // Date and Time fields
            isMobile
                ? Column(
                    children: [
                      _buildDateTimePicker(true),
                      const SizedBox(height: 16),
                      _buildDateTimePicker(false),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildDateTimePicker(true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDateTimePicker(false)),
                    ],
                  ),
          ],
        );
      },
    );
  }



  Widget _buildDateTimePicker(bool isDate) {
    return InkWell(
      onTap: () async {
        if (isDate) {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            setState(() => _selectedDate = date);
          }
        } else {
          final time = await showTimePicker(
            context: context,
            initialTime: _selectedTime,
          );
          if (time != null) {
            setState(() => _selectedTime = time);
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isDate ? 'Date *' : 'Time *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(isDate ? Icons.calendar_today : Icons.access_time),
        ),
        child: Text(
          isDate
              ? DateFormat('yyyy-MM-dd').format(_selectedDate)
              : _selectedTime.format(context),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPanel2(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observation Details',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          'Provide details about the observation and actions taken',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        
        _textArea(
          'Observation *',
          (v) => _observation = v ?? '',
          hint: 'Describe what you observed in detail...',
        ),
        SizedBox(height: isMobile ? 16 : 20),
        
        _textArea(
          'Action Taken *',
          (v) => _actionTaken = v ?? '',
          hint: 'What immediate action was taken?',
        ),
        SizedBox(height: isMobile ? 16 : 20),

        // Safety Status Buttons
        Text(
          'Safety Status *',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSafetyStatusButton(
                'Safe',
                'Safe Observation',
                const Color(0xFF16A34A),
                const Color(0xFFDCFCE7),
                isMobile,
                _safetyStatusError,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSafetyStatusButton(
                'Unsafe',
                'Unsafe Condition',
                const Color(0xFFDC2626),
                const Color(0xFFFEE2E2),
                isMobile,
                _safetyStatusError,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 16 : 20),
        
        // Image Upload Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Attach Photos (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate, size: 18),
                    label: Text(isMobile ? 'Add' : 'Add Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_imageBytesList.isEmpty)
                Text(
                  'No photos added',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                Wrap(
                  spacing: isMobile ? 8 : 12,
                  runSpacing: isMobile ? 8 : 12,
                  children: List.generate(_imageBytesList.length, (index) {
                    final size = isMobile ? 80.0 : 120.0;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _imageBytesList[index],
                            height: size,
                            width: size,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyStatusButton(
    String label,
    String value,
    Color textColor,
    Color bgColor,
    bool isMobile,
    bool showError,
  ) {
    final isSelected = _safetyStatus == value;
    
    return InkWell(
      onTap: () => setState(() {
        _safetyStatus = value;
        _safetyStatusError = false;
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 16,
          horizontal: isMobile ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.white,
          border: Border.all(
            color: showError && !isSelected
                ? Colors.red
                : isSelected
                    ? textColor
                    : Colors.grey[300]!,
            width: showError && !isSelected ? 2 : isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? textColor : Colors.grey[600],
              fontSize: isMobile ? 14 : 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          if (_currentPanel < 2)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                ),
                onPressed: _isSaving ? null : _nextPanel,
                label: const Text('Next'),
                icon: const Icon(Icons.arrow_forward),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                ),
                onPressed: _isSaving ? null : _save,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Safety Card'),
              ),
            ),
          if (_currentPanel > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: _isSaving ? null : _previousPanel,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          ],
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPanel > 0)
          TextButton.icon(
            onPressed: _isSaving ? null : _previousPanel,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          )
        else
          const SizedBox(),
        
        if (_currentPanel < 2)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
            onPressed: _isSaving ? null : _nextPanel,
            label: const Text('Next'),
            icon: const Icon(Icons.arrow_forward),
          )
        else
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
            onPressed: _isSaving ? null : _save,
            icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save Record'),
          ),
      ],
    );
  }

  Widget _text(
    String label,
    FormFieldSetter<String?> onSaved, {
    String? initial,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'This field is required' : null,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }

  Widget _textArea(
    String label,
    FormFieldSetter<String?> onSaved, {
    String? hint,
  }) {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
      ),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'This field is required' : null,
      onSaved: onSaved,
    );
  }

  Widget _dropdown<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
  ) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: (v) =>
          label.contains('*') && v == null ? 'This field is required' : null,
    );
  }
}