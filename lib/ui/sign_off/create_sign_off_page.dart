import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:intl/intl.dart';
import '../../data/app_database.dart';
import '../../main.dart';
import '../../utils/responsive_utils.dart';
import '../../services/sign_off_service.dart';
import '../../services/attachment_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class CreateSignOffPage extends StatefulWidget {
  final SafetyCommunication? existingCard;
  
  const CreateSignOffPage({super.key, this.existingCard});

  @override
  State<CreateSignOffPage> createState() => _CreateSignOffPageState();
}

class _CreateSignOffPageState extends State<CreateSignOffPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _currentPanel = 0;
  bool _isSaving = false;

  // Form state
  String? _selectedCategory;
  String _title = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedSiteId;
  String? _selectedLocationId;
  String _deliveredBy = '';
  String? _selectedDepartment;
  String? _project;
  String _comments = '';
  List<AppUser> _selectedAttendees = [];
  
  // File attachments (stored as name:path pairs for future API integration)
  List<Map<String, String>> _attachments = [];

  // Validation error states
  bool _showCategoryError = false;
  bool _showTitleError = false;
  bool _showSiteError = false;
  bool _showDeliveredByError = false;
  bool _showProjectNumberError = false;

  // Data from SERVER
  List<Map<String, dynamic>> _serverSites = [];
  List<Map<String, dynamic>> _serverLocations = [];
  List<AppUser> _allUsers = [];
  String _attendeeSearchQuery = '';
  String _attendeeViewFilter = 'all'; // 'all', 'selected', 'unselected'

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectNumberController = TextEditingController();
  final _commentsController = TextEditingController();
  final _deliveredByController = TextEditingController();
  final _attendeeSearchController = TextEditingController();
  final _departmentController = TextEditingController();

  // Animation
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<String> _categories = [
    'Induction', 'Training', 'Toolbox Talk', 'Procedure', 
    'Risk Assessment', 'COSHH Assessment', 'Other',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Induction': Icons.person_add,
    'Training': Icons.school,
    'Toolbox Talk': Icons.handyman,
    'Procedure': Icons.description,
    'Risk Assessment': Icons.warning,
    'COSHH Assessment': Icons.science,
    'Other': Icons.help_outline,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    
    _loadDataFromServer();
    
    if (widget.existingCard != null) {
      final card = widget.existingCard!;
      _selectedCategory = card.category;
      _title = card.title;
      _titleController.text = card.title;
      // Parse date and extract time
      final parsedDate = DateTime.tryParse(card.date);
      if (parsedDate != null) {
        _selectedDate = parsedDate;
        _selectedTime = TimeOfDay(hour: parsedDate.hour, minute: parsedDate.minute);
      } else {
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
      }
      _selectedSiteId = card.siteId;
      _selectedLocationId = card.location;
      _deliveredBy = card.deliveredBy;
      _deliveredByController.text = card.deliveredBy;
      _selectedDepartment = card.department;
      _departmentController.text = card.department ?? '';
      _project = card.project;
      _projectNumberController.text = card.project ?? '';
      _comments = card.description ?? '';
      _commentsController.text = card.description ?? '';
      // Start at page 2 (Details) when editing - like Think Safety edit form
      _currentPanel = 1;
    } else {
      _deliveredBy = UserSession.userName ?? '';
      _deliveredByController.text = _deliveredBy;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _projectNumberController.dispose();
    _commentsController.dispose();
    _deliveredByController.dispose();
    _attendeeSearchController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromServer() async {
    try {
      final service = SignOffService();
      final sites = await service.fetchSites();
      final locations = await service.fetchLocations();
      final users = await db.select(db.appUsers).get(); // Users still from local
      
      // If editing, load existing attendees/signatures for this card
      List<AppUser> existingAttendees = [];
      if (widget.existingCard != null) {
        final allSignatures = await service.fetchSignatures();
        final cardSignatures = allSignatures.where(
          (s) => s['communicationId'] == widget.existingCard!.id
        ).toList();
        
        // Convert signatures to AppUser list for display
        for (var sig in cardSignatures) {
          final teamMember = sig['teamMember']?.toString() ?? '';
          final matchingUser = users.firstWhere(
            (u) => u.name.toLowerCase() == teamMember.toLowerCase(),
            orElse: () => AppUser(id: -1, name: teamMember, email: '', securityLevel: ''),
          );
          if (matchingUser.name.isNotEmpty) {
            existingAttendees.add(matchingUser);
          }
        }
        print('Loaded ${existingAttendees.length} existing attendees for card ${widget.existingCard!.id}');
      }
      
      if (mounted) {
        setState(() {
          _serverSites = sites;
          _serverLocations = locations;
          // Sort users alphabetically by name
          _allUsers = users..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          if (widget.existingCard != null && existingAttendees.isNotEmpty) {
            _selectedAttendees = existingAttendees;
          }
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  String _getSiteName(String? siteId) {
    if (siteId == null || siteId.isEmpty) return '';
    final site = _serverSites.firstWhere((s) => s['siteId'] == siteId || s['id'] == siteId, orElse: () => {});
    return site['name']?.toString() ?? siteId;
  }

  String _getLocationName(String? locId) {
    if (locId == null || locId.isEmpty) return '';
    final loc = _serverLocations.firstWhere((l) => l['locationId'] == locId || l['id'] == locId, orElse: () => {});
    return loc['name']?.toString() ?? locId;
  }

  bool _validatePanel(int panel) {
    bool isValid = true;
    
    if (panel == 0) {
      if (_selectedCategory == null) {
        setState(() => _showCategoryError = true);
        _showSnackBar('Please select a category');
        isValid = false;
      } else {
        setState(() => _showCategoryError = false);
      }
    }
    
    if (panel == 1) {
      bool titleMissing = _titleController.text.isEmpty;
      bool siteMissing = _selectedSiteId == null;
      bool deliveredByMissing = _deliveredByController.text.isEmpty;
      bool projectNumberMissing = _projectNumberController.text.isEmpty;
      
      setState(() {
        _showTitleError = titleMissing;
        _showSiteError = siteMissing;
        _showDeliveredByError = deliveredByMissing;
        _showProjectNumberError = projectNumberMissing;
      });
      
      if (titleMissing || siteMissing || deliveredByMissing || projectNumberMissing) {
        _showSnackBar('Please fill all required fields');
        isValid = false;
      }
    }
    
    return isValid;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0076D6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _jumpToPanel(int panelIndex) {
    if (panelIndex > _currentPanel) {
      for (int i = 0; i < panelIndex; i++) {
        if (!_validatePanel(i)) return;
      }
    }
    _animationController.reset();
    _animationController.forward();
    setState(() => _currentPanel = panelIndex);
  }

  void _nextPanel() {
    if (!_validatePanel(_currentPanel)) return;
    if (_currentPanel < 2) {
      _animationController.reset();
      _animationController.forward();
      setState(() => _currentPanel++);
    }
  }

  void _previousPanel() {
    if (_currentPanel > 0) {
      _animationController.reset();
      _animationController.forward();
      setState(() => _currentPanel--);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_validatePanel(2)) return;

    setState(() => _isSaving = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      final cardId = widget.existingCard?.id ?? const Uuid().v4();

      final now = DateTime.now().toIso8601String();
      final userEmail = UserSession.userEmail ?? '';
      
      // Determine category booleans based on selection
      final selectedCat = _selectedCategory?.toLowerCase() ?? '';
      
      // Build payload for SERVER with security audit fields
      // NOTE: Attachments are NOT included - they're stored locally in IndexedDB
      final serverData = {
        'id': cardId,
        'title': _titleController.text,
        'category': _selectedCategory,
        'date': '${dateStr}T$timeStr:00', // Include time in date
        'time': timeStr,
        'siteId': _selectedSiteId,
        'location': _selectedLocationId ?? '',
        'deliveredBy': _deliveredByController.text,
        'department': _departmentController.text,
        'project': _projectNumberController.text,
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : _commentsController.text,
        // Category boolean fields - set TRUE for selected category
        'induction': selectedCat == 'induction',
        'training': selectedCat == 'training',
        'toolboxTalk': selectedCat == 'toolbox talk',
        'procedure': selectedCat == 'procedure',
        'riskAssessment': selectedCat == 'risk assessment',
        'coshhAssessment': selectedCat == 'coshh assessment',
        'other': selectedCat == 'other',
        // Security audit fields
        'creationDateTime': widget.existingCard != null && widget.existingCard!.creationDateTime != null 
             ? widget.existingCard!.creationDateTime 
             : now,
        'creationUser': widget.existingCard != null ? widget.existingCard!.deliveredBy : userEmail,
        'creationLocation': '', // Location latlong - can be added if device location is available
        'editDateTime': now,
        'editUser': userEmail,
        'editLocation': '', // Location latlong - can be added if device location is available
      };

      final service = SignOffService();
      bool success;
      
      if (widget.existingCard != null) {
        success = await service.updateSafetyCommunication(widget.existingCard!.id, serverData);
      } else {
        success = await service.createSafetyCommunication(serverData);
      }

      if (mounted) {
        if (success) {
          // Save attendees
          if (_selectedAttendees.isNotEmpty) {
            await _saveAttendees(cardId);
          }
          
          // Save attachments to IndexedDB (local storage)
          if (_attachments.isNotEmpty) {
            final attachmentStorage = AttachmentStorageService();
            await attachmentStorage.saveAttachments(cardId, _attachments);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.existingCard != null ? 'Updated successfully' : 'Created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          _showSnackBar('Failed to save to server. Please try again.');
          setState(() => _isSaving = false);
        }
      }
    } catch (e) {
      print('Error saving: $e');
      if (mounted) {
        _showSnackBar('Error: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveAttendees(String communicationId) async {
    final service = SignOffService();
    int successCount = 0;
    final now = DateTime.now().toUtc().toIso8601String();
    
    for (var user in _selectedAttendees) {
      try {
        final sigId = const Uuid().v4();
        
        // Simplified payload matching the API schema
        final payload = {
          'id': sigId,
          'uuid': sigId,
          'communicationId': communicationId,
          'communicationuuid': communicationId,
          'teamMember': user.name,
          'shift': '',
          'signature': '',
          'creationDateTime': now,
          'creationDate': now,
          'creationUser': UserSession.userName ?? '',
          'editDateTime': now,
          'editDate': now,
          'editUser': UserSession.userName ?? '',
        };
        
        print('📤 Saving attendee ${user.name} with payload: $payload');
        final success = await service.createSignature(payload);
        
        if (success) {
          successCount++;
          print('✅ Attendee ${user.name} saved successfully');
        } else {
          print('❌ Failed to save attendee ${user.name}');
        }
      } catch (e) {
        print('❌ Error adding attendee ${user.name}: $e');
      }
    }
    print('📊 Added $successCount / ${_selectedAttendees.length} attendees');
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.existingCard != null ? 'Edit Communication' : 'New Communication',
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 900),
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 50),
                  child: Opacity(
                    opacity: 1 - _slideAnimation.value * 2,
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProgressIndicator(isMobile),
                            SizedBox(height: isMobile ? 24 : 32),
                            
                            if (_currentPanel == 0) _buildPanel0(isMobile),
                            if (_currentPanel == 1) _buildPanel1(isMobile),
                            if (_currentPanel == 2) _buildPanel2(isMobile),
                            
                            // Navigation Buttons INSIDE the form
                            const SizedBox(height: 32),
                            _buildFormNavigationButtons(isMobile),
                          ],
                        ),
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

  Widget _buildFormNavigationButtons(bool isMobile) {
    return Row(
      children: [
        if (_currentPanel > 0)
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _previousPanel,
            ),
          )
        else
          const Expanded(child: SizedBox()),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: _currentPanel < 2
              ? ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  label: const Text('Next', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _nextPanel,
                )
              : ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check, size: 18, color: Colors.white),
                  label: Text(_isSaving ? 'Saving...' : 'Submit', style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _save,
                ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(bool isMobile) {
    return Column(
      children: [
        // Cancel button above step 1
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Progress steps only (navigation moved to panel headers)
        Row(
          children: [
            _buildProgressStep(0, 'Category', isMobile),
            Expanded(child: _buildProgressLine(0)),
            _buildProgressStep(1, 'Details', isMobile),
            Expanded(child: _buildProgressLine(1)),
            _buildProgressStep(2, 'Attendees', isMobile),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressStep(int index, String label, bool isMobile) {
    final isActive = _currentPanel >= index;
    final isCurrent = _currentPanel == index;

    return InkWell(
      onTap: () => _jumpToPanel(index),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            decoration: BoxDecoration(
              color: isActive ? AppColors.textPrimary : const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
              boxShadow: isCurrent ? [
                BoxShadow(color: AppColors.textPrimary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
              ] : null,
            ),
            child: Center(
              child: isActive && !isCurrent
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: isActive ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: isActive ? AppColors.textPrimary : const Color(0xFF6B7280),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(int index) {
    final isActive = _currentPanel > index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 3,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: isActive ? AppColors.textPrimary : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildPanel0(bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.category, color: AppColors.textPrimary, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text('Choose the type of communication', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            // Navigation buttons in header
            IconButton(
              onPressed: _nextPanel,
              icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
              tooltip: 'Next',
              iconSize: 24,
            ),
          ],
        ),
        SizedBox(height: isMobile ? 20 : 28),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;
            final icon = _categoryIcons[category] ?? Icons.help_outline;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedCategory = category);
                  Future.delayed(const Duration(milliseconds: 200), _nextPanel);
                },
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.textPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB), width: 2),
                    boxShadow: isSelected ? [
                      BoxShadow(color: AppColors.textPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 36, color: isSelected ? Colors.white : const Color(0xFF6B7280)),
                      const SizedBox(height: 10),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF374151)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPanel1(bool isMobile) {
    final filteredLocations = _serverLocations.where((l) => 
        _selectedSiteId == null || l['siteId'] == _selectedSiteId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedCategory != null) _buildSelectedCategoryCard(isMobile),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_note, color: AppColors.textPrimary, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Communication Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text('Fill in the required information', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            // Navigation buttons in header
            IconButton(
              onPressed: _previousPanel,
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              tooltip: 'Back',
              iconSize: 24,
            ),
            IconButton(
              onPressed: _nextPanel,
              icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
              tooltip: 'Next',
              iconSize: 24,
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildTextField('Title *', _titleController, 'Enter communication title', Icons.title, hasError: _showTitleError),
        const SizedBox(height: 20),

        // Description field (under Title)
        _buildTextField('Description', _descriptionController, 'Enter description', Icons.description),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildDatePicker(isMobile)),
            const SizedBox(width: 16),
            Expanded(child: _buildTimePicker(isMobile)),
          ],
        ),
        const SizedBox(height: 20),

        // Project Number field (mandatory, above Site)
        _buildTextField('Project Number *', _projectNumberController, 'Enter project number', Icons.numbers, hasError: _showProjectNumberError),
        const SizedBox(height: 20),

        _buildServerDropdown(
          'Site *',
          Icons.business,
          _selectedSiteId,
          _serverSites,
          (site) => site['siteId']?.toString() ?? site['id']?.toString() ?? '',
          (site) => site['name']?.toString() ?? '',
          (v) {
            setState(() {
              _selectedSiteId = v;
              _selectedLocationId = null;
              _showSiteError = false;
            });
          },
          hasError: _showSiteError,
        ),
        const SizedBox(height: 20),

        _buildServerDropdown(
          'Location',
          Icons.place,
          _selectedLocationId,
          filteredLocations,
          (loc) => loc['locationId']?.toString() ?? loc['id']?.toString() ?? '',
          (loc) => loc['name']?.toString() ?? '',
          _selectedSiteId == null ? null : (v) => setState(() => _selectedLocationId = v),
        ),
        const SizedBox(height: 20),

        // Department field (under Location)
        _buildTextField('Department', _departmentController, 'Enter department', Icons.business_center),
        const SizedBox(height: 20),

        _buildServerDropdown(
          'Delivered By *',
          Icons.person,
          _deliveredBy.isEmpty ? null : _deliveredBy,
          _allUsers.map((u) => {'id': u.name, 'name': u.name}).toList(),
          (u) => u['id']?.toString() ?? '',
          (u) => u['name']?.toString() ?? '',
          (v) {
            setState(() {
              _deliveredBy = v ?? '';
              _deliveredByController.text = v ?? '';
              _showDeliveredByError = false;
            });
          },
          hasError: _showDeliveredByError,
        ),
      ],
    );
  }

  Widget _buildServerDropdown(
    String label,
    IconData icon,
    String? value,
    List<dynamic> items,
    String Function(dynamic) getValue,
    String Function(dynamic) getLabel,
    ValueChanged<String?>? onChanged, {
    bool hasError = false,
  }) {
    // Deduplicate items by value and ensure current value is included
    final seenValues = <String>{};
    final uniqueItems = <dynamic>[];
    for (var item in items) {
      final itemValue = getValue(item);
      if (itemValue.isNotEmpty && !seenValues.contains(itemValue)) {
        seenValues.add(itemValue);
        uniqueItems.add(item);
      }
    }
    
    // If current value is not in the list, clear it
    final effectiveValue = (value != null && seenValues.contains(value)) ? value : null;
    
    return DropdownButtonFormField<String>(
      value: effectiveValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hasError ? Colors.red : null),
        prefixIcon: Icon(icon, color: hasError ? Colors.red : const Color(0xFF0076D6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hasError ? Colors.red : const Color(0xFFE5E7EB), width: hasError ? 2 : 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hasError ? Colors.red : const Color(0xFF0076D6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: hasError ? Colors.red.withOpacity(0.05) : (onChanged == null ? const Color(0xFFF9FAFB) : Colors.white),
      ),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('Select $label')),
        ...uniqueItems.map((item) => DropdownMenuItem(
          value: getValue(item),
          child: Text(getLabel(item)),
        )),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildSelectedCategoryCard(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0076D6).withOpacity(0.1), const Color(0xFF0059A3).withOpacity(0.05)],
        ),
        border: Border.all(color: const Color(0xFF0076D6).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0076D6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_categoryIcons[_selectedCategory], color: const Color(0xFF0076D6), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Category', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                Text(_selectedCategory!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0076D6))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0076D6), size: 20),
            onPressed: () => _jumpToPanel(0),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel2(bool isMobile) {
    // Get all users filtered by search
    final searchFiltered = _allUsers.where((u) =>
        u.name.toLowerCase().contains(_attendeeSearchQuery.toLowerCase())).toList();
    
    // Apply view filter
    List<AppUser> displayUsers;
    if (_attendeeViewFilter == 'selected') {
      displayUsers = searchFiltered.where((u) => 
          _selectedAttendees.any((s) => s.name.toLowerCase() == u.name.toLowerCase())).toList();
    } else if (_attendeeViewFilter == 'unselected') {
      displayUsers = searchFiltered.where((u) => 
          !_selectedAttendees.any((s) => s.name.toLowerCase() == u.name.toLowerCase())).toList();
    } else {
      displayUsers = searchFiltered;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0076D6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.group, color: Color(0xFF0076D6), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text('Add notes and attachments', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            // Navigation buttons in header
            IconButton(
              onPressed: _previousPanel,
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0076D6)),
              tooltip: 'Back',
              iconSize: 24,
            ),
            IconButton(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0076D6)))
                : const Icon(Icons.check, color: Color(0xFF0076D6)),
              tooltip: 'Submit',
              iconSize: 24,
            ),
          ],
        ),
        const SizedBox(height: 24),

        TextFormField(
          controller: _commentsController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Comments',
            prefixIcon: const Icon(Icons.notes, color: Color(0xFF0076D6)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0076D6), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // File Attachments Section (above Attendees)
        Row(
          children: [
            const Text('Attachments', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${_attachments.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showAddAttachmentDialog(),
              icon: const Icon(Icons.attach_file, size: 18),
              label: const Text('Add File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0076D6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_attachments.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _attachments.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: index < _attachments.length - 1 
                        ? const Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0076D6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getFileIcon(file['type'] ?? ''),
                          color: const Color(0xFF0076D6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              file['type'] ?? 'File',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Color(0xFFDC2626)),
                        onPressed: () => setState(() => _attachments.removeAt(index)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 8),
                  Text('No attachments', style: TextStyle(color: Color(0xFF6B7280))),
                  SizedBox(height: 4),
                  Text('Click "Add File" to upload files', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 24),

        // Attendees header with action buttons
        Row(
          children: [
            const Text('Attendees', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              child: Text('${_selectedAttendees.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const Spacer(),
            // Filter buttons
            TextButton.icon(
              icon: const Icon(Icons.select_all, size: 18),
              label: const Text('Select All'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              onPressed: () => setState(() => _selectedAttendees = List.from(_allUsers)),
            ),
            TextButton.icon(
              icon: const Icon(Icons.deselect, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
              onPressed: () => setState(() => _selectedAttendees.clear()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Filter toggle buttons (Show Selected / Show Unselected)
        Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'selected', label: Text('Selected')),
                  ButtonSegment(value: 'unselected', label: Text('Unselected')),
                ],
                selected: {_attendeeViewFilter},
                onSelectionChanged: (v) => setState(() => _attendeeViewFilter = v.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primary,
                  selectedForegroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _attendeeSearchController,
          decoration: InputDecoration(
            hintText: 'Search attendees...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (v) => setState(() => _attendeeSearchQuery = v),
        ),
        const SizedBox(height: 12),

        // User list with toggle selection
        Container(
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: displayUsers.isEmpty
              ? Center(child: Text(
                  _attendeeViewFilter == 'selected' ? 'No selected attendees' :
                  _attendeeViewFilter == 'unselected' ? 'All attendees are selected' :
                  'No users found', 
                  style: const TextStyle(color: Color(0xFF6B7280))))
              : ListView.builder(
                  itemCount: displayUsers.length,
                  itemBuilder: (context, index) {
                    final user = displayUsers[index];
                    final isSelected = _selectedAttendees.any((s) => s.name.toLowerCase() == user.name.toLowerCase());
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedAttendees.removeWhere((s) => s.name.toLowerCase() == user.name.toLowerCase());
                          } else {
                            _selectedAttendees.add(user);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                          border: Border(bottom: BorderSide(color: const Color(0xFFF3F4F6))),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                              child: Text(
                                user.name[0].toUpperCase(), 
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.primary, 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user.name, 
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : const Color(0xFF374151),
                                ),
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.add_circle_outline,
                              color: isSelected ? AppColors.primary : const Color(0xFF9CA3AF),
                              size: 22,
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
  
  IconData _getFileIcon(String type) {
    if (type.toLowerCase().contains('image')) return Icons.image;
    if (type.toLowerCase().contains('pdf')) return Icons.picture_as_pdf;
    if (type.toLowerCase().contains('doc')) return Icons.description;
    return Icons.insert_drive_file;
  }
  
  Future<void> _showAddAttachmentDialog() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
        withData: true, // Required for web to get file bytes
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (final file in result.files) {
            // Store file data as base64 for IndexedDB storage
            String? base64Data;
            if (file.bytes != null) {
              base64Data = base64Encode(file.bytes!);
            }
            
            _attachments.add({
              'name': file.name,
              'type': file.extension ?? 'file',
              'size': '${(file.size / 1024).toStringAsFixed(1)} KB',
              'data': base64Data ?? '',
            });
          }
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, IconData icon, {bool hasError = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: hasError ? Colors.red : AppColors.textPrimary),
        labelStyle: TextStyle(color: hasError ? Colors.red : null),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hasError ? Colors.red : const Color(0xFFE5E7EB), width: hasError ? 2 : 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hasError ? Colors.red : AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: hasError ? Colors.red.withOpacity(0.05) : Colors.white,
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildDatePicker(bool isMobile) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date *',
          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.textPrimary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
      ),
    );
  }

  Widget _buildTimePicker(bool isMobile) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _selectedTime);
        if (time != null) setState(() => _selectedTime = time);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time',
          prefixIcon: const Icon(Icons.access_time, color: AppColors.textPrimary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(_selectedTime.format(context)),
      ),
    );
  }
}
