import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:uuid/uuid.dart';
import '../../main.dart';
import '../../utils/responsive_utils.dart';
import '../../services/sign_off_service.dart';

class SignOffSettingsPage extends StatefulWidget {
  const SignOffSettingsPage({super.key});

  @override
  State<SignOffSettingsPage> createState() => _SignOffSettingsPageState();
}

class _SignOffSettingsPageState extends State<SignOffSettingsPage> {
  // Data from SERVER
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = false;

  // Selection State
  Map<String, dynamic>? _selectedSite;
  Map<String, dynamic>? _selectedLocation;

  // Form State
  final _locationFormKey = GlobalKey<FormState>();
  final _locationNameController = TextEditingController();
  bool _isLocationEditing = false;
  bool _isSaving = false;
  
  // Enum values for location fields
  String? _selectedFieldType; // Tower, OSS, Other
  String? _selectedTaskLocation; // OSS, 2 off, 1 off
  
  static const List<String> _fieldTypeOptions = ['Tower', 'OSS', 'Other'];
  static const List<String> _taskLocationOptions = ['OSS', '2 off', '1 off'];

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
      List<Map<String, dynamic>> locations;
      if (_selectedSite != null) {
        final allLocs = await service.fetchLocations();
        final siteId = _selectedSite!['siteId'] ?? _selectedSite!['id'];
        locations = allLocs.where((l) => l['siteId'] == siteId).toList();
      } else {
        locations = await service.fetchLocations();
      }
      
      if (mounted) {
        setState(() {
          _sites = sites;
          _locations = locations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data from server: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSiteSelected(Map<String, dynamic>? site) {
    setState(() {
      if (_selectedSite != null && _selectedSite!['id'] == site?['id']) {
        _selectedSite = null;
      } else {
        _selectedSite = site;
      }
      _selectedLocation = null;
      _isLocationEditing = false;
      _locationNameController.clear();
    });
    _loadDataFromServer();
  }

  void _onLocationSelected(Map<String, dynamic> location) {
    setState(() {
      _selectedLocation = location;
      _locationNameController.text = location['name']?.toString() ?? '';
      _selectedFieldType = location['field']?.toString();
      _selectedTaskLocation = location['taskLocation']?.toString();
      _isLocationEditing = true;
    });
  }

  // --- Site Actions ---
  Future<void> _showSiteDialog({Map<String, dynamic>? site}) async {
    final isEditing = site != null;
    final nameController = TextEditingController(text: site?['name']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isEditing ? Icons.edit : Icons.add_business, color: AppColors.textPrimary),
            const SizedBox(width: 12),
            Text(isEditing ? 'Edit Site' : 'Add New Site'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Site Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.textPrimary),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              
              try {
                final service = SignOffService();
                if (isEditing) {
                  final siteId = site['siteId'] ?? site['id'];
                  await service.updateSite(siteId, {'siteId': siteId, 'name': nameController.text, 'siteDpr': false});
                } else {
                  final siteId = const Uuid().v4();
                  await service.createSite({'siteId': siteId, 'name': nameController.text, 'siteDpr': false});
                }
                _loadDataFromServer();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Site updated' : 'Site added'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSite(Map<String, dynamic> site) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Site'),
          ],
        ),
        content: Text('Delete "${site['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final siteId = site['siteId'] ?? site['id'];
        await SignOffService().deleteSite(siteId);
        if (_selectedSite != null && _selectedSite!['id'] == site['id']) _selectedSite = null;
        _loadDataFromServer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Site deleted'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // --- Location Actions ---
  Future<void> _saveLocation() async {
    if (!_locationFormKey.currentState!.validate()) return;
    if (_selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a site first')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = SignOffService();
      final siteId = _selectedSite!['siteId'] ?? _selectedSite!['id'] ?? _selectedSite!['uuid'];
      final now = DateTime.now().toIso8601String();
      
      if (_isLocationEditing && _selectedLocation != null) {
        final locId = _selectedLocation!['locationId'] ?? _selectedLocation!['id'] ?? _selectedLocation!['uuid'];
        await service.updateLocation(locId, {
          'locationId': locId,
          'name': _locationNameController.text,
          'latLong': '',
          'siteId': siteId.toString(),
          'field': _selectedFieldType ?? 'Other',
          'taskLocation': _selectedTaskLocation ?? 'OSS',
          'creationDateTime': _selectedLocation!['creationDateTime'] ?? now,
          'creationDate': _selectedLocation!['creationDate'] ?? now,
          'creationUser': UserSession.userName ?? '',
          'creationLocation': '',
          'editCount': (_selectedLocation!['editCount'] ?? 0) + 1,
          'editDateTime': now,
          'editDate': now,
          'editUser': UserSession.userName ?? '',
          'editLocation': '',
        });
      } else {
        final locId = const Uuid().v4();
        await service.createLocation({
          'locationId': locId,
          'name': _locationNameController.text,
          'latLong': '',
          'siteId': siteId.toString(),
          'field': _selectedFieldType ?? 'Other',
          'taskLocation': _selectedTaskLocation ?? 'OSS',
          'creationDateTime': now,
          'creationDate': now,
          'creationUser': UserSession.userName ?? '',
          'creationLocation': '',
          'editCount': 0,
          'editDateTime': now,
          'editDate': now,
          'editUser': UserSession.userName ?? '',
          'editLocation': '',
        });
      }
      
      _loadDataFromServer();
      setState(() {
        _selectedLocation = null;
        _isLocationEditing = false;
        _locationNameController.clear();
        _selectedFieldType = null;
        _selectedTaskLocation = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isLocationEditing ? 'Location updated' : 'Location added'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteLocation(Map<String, dynamic> location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Location'),
          ],
        ),
        content: Text('Delete "${location['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final locId = location['locationId'] ?? location['id'];
        await SignOffService().deleteLocation(locId);
        if (_selectedLocation != null && _selectedLocation!['id'] == location['id']) {
          _selectedLocation = null;
          _isLocationEditing = false;
          _locationNameController.clear();
        }
        _loadDataFromServer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location deleted'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
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
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            title: const Text('SignOff Settings', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primary),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.grey[300], height: 1),
            ),
          ),
          body: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.textPrimary))
              : isMobile ? _buildMobileLayout(padding) : _buildDesktopLayout(padding),
        );
      },
    );
  }

  Widget _buildDesktopLayout(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildSitePanel()),
          SizedBox(width: padding),
          Expanded(flex: 2, child: _buildLocationListPanel()),
          SizedBox(width: padding),
          Expanded(flex: 2, child: _buildLocationEditPanel()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(double padding) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Sites', icon: Icon(Icons.business)),
                Tab(text: 'Locations', icon: Icon(Icons.place)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSitePanel(),
                Column(
                  children: [
                    Expanded(child: _buildLocationListPanel()),
                    const Divider(height: 1),
                    SizedBox(height: 280, child: _buildLocationEditPanel()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSitePanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.business, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(child: Text('Sites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                if (_selectedSite != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () => _showSiteDialog(site: _selectedSite),
                    tooltip: 'Edit Site',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteSite(_selectedSite!),
                    tooltip: 'Delete Site',
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _sites.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_center, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No sites yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _sites.length,
                    itemBuilder: (context, index) {
                      final site = _sites[index];
                      final isSelected = _selectedSite != null && _selectedSite!['id'] == site['id'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? AppColors.primary : Colors.grey[200],
                          child: Icon(Icons.business, color: isSelected ? Colors.white : Colors.grey[600], size: 20),
                        ),
                        title: Text(site['name']?.toString() ?? '', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        selectedTileColor: const Color(0xFFFFE8DD),
                        selectedColor: AppColors.textPrimary,
                        onTap: () => _onSiteSelected(site),
                        trailing: isSelected ? const Icon(Icons.check_circle, size: 20, color: AppColors.primary) : null,
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Site'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showSiteDialog(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationListPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.place, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedSite != null ? 'Locations in ${_selectedSite!['name']}' : 'Locations',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedSite == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Select a site to view locations', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : _locations.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No locations yet', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _locations.length,
                        itemBuilder: (context, index) {
                          final location = _locations[index];
                          final isSelected = _selectedLocation != null && _selectedLocation!['id'] == location['id'];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? AppColors.textPrimary : Colors.grey[200],
                              child: Icon(Icons.place, color: isSelected ? Colors.white : Colors.grey[600], size: 20),
                            ),
                            title: Text(location['name']?.toString() ?? '', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            selected: isSelected,
                            selectedTileColor: const Color(0xFFFFE8DD),
                            selectedColor: AppColors.textPrimary,
                            onTap: () => _onLocationSelected(location),
                            trailing: isSelected ? const Icon(Icons.edit, size: 18, color: AppColors.textPrimary) : null,
                          );
                        },
                      ),
          ),
          if (_selectedSite != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedLocation = null;
                      _isLocationEditing = false;
                      _locationNameController.clear();
                    });
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationEditPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Form(
        key: _locationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_isLocationEditing ? Icons.edit : Icons.add_location, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  _isLocationEditing ? 'Edit Location' : 'Add Location',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_selectedSite == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(child: Text('Select a site first to add/edit locations')),
                  ],
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4ED),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textPrimary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business, size: 20, color: AppColors.textPrimary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selected Site', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                          Text(_selectedSite!['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationNameController,
              decoration: InputDecoration(
                labelText: 'Location Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: _selectedSite == null ? Colors.grey[100] : Colors.white,
                prefixIcon: const Icon(Icons.place),
              ),
              enabled: _selectedSite != null,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            
            const SizedBox(height: 16),
            // Location Type (field enum)
            DropdownButtonFormField<String>(
              value: _selectedFieldType != null && _fieldTypeOptions.contains(_selectedFieldType) 
                  ? _selectedFieldType 
                  : null,
              decoration: InputDecoration(
                labelText: 'Location Type *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: _selectedSite == null ? Colors.grey[100] : Colors.white,
                prefixIcon: const Icon(Icons.category),
              ),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Select Type')),
                ..._fieldTypeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))),
              ],
              onChanged: _selectedSite == null ? null : (v) => setState(() => _selectedFieldType = v),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            
            const SizedBox(height: 16),
            // Task Location enum
            DropdownButtonFormField<String>(
              value: _selectedTaskLocation != null && _taskLocationOptions.contains(_selectedTaskLocation) 
                  ? _selectedTaskLocation 
                  : null,
              decoration: InputDecoration(
                labelText: 'Task Location *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: _selectedSite == null ? Colors.grey[100] : Colors.white,
                prefixIcon: const Icon(Icons.work_outline),
              ),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Select Task Location')),
                ..._taskLocationOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))),
              ],
              onChanged: _selectedSite == null ? null : (v) => setState(() => _selectedTaskLocation = v),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            
            const Spacer(),
            Row(
              children: [
                if (_isLocationEditing)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _selectedLocation == null ? null : () => _deleteLocation(_selectedLocation!),
                    ),
                  ),
                if (_isLocationEditing) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Icon(_isLocationEditing ? Icons.save : Icons.add, size: 18),
                    label: Text(_isSaving ? 'Saving...' : (_isLocationEditing ? 'Update' : 'Add')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _selectedSite == null || _isSaving ? null : _saveLocation,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
