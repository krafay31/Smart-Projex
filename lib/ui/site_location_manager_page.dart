import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safety_card_web/utils/app_colors.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../main.dart';
import '../utils/responsive_utils.dart';
import '../services/setups_service.dart';
import '../helpers/site_helper.dart';
import '../helpers/location_helper.dart';

class SiteLocationManagerPage extends StatefulWidget {
  const SiteLocationManagerPage({super.key});

  @override
  State<SiteLocationManagerPage> createState() => _SiteLocationManagerPageState();
}

class _SiteLocationManagerPageState extends State<SiteLocationManagerPage> {
  // Data Futures
  late Future<List<Site>> _sitesFuture;
  late Future<List<Location>> _locationsFuture;

  // Selection State
  Site? _selectedSite;
  Location? _selectedLocation;

  // Form State (Location)
  final _locationFormKey = GlobalKey<FormState>();
  final _locationNameController = TextEditingController();
  bool _isLocationEditing = false;
  bool _isSavingLocation = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _sitesFuture = SiteHelper.fetchFromServer();
      // If a site is selected, we might want to fetch only its locations, 
      // but for simplicity and "Show all if no site selected", we can fetch all or filter locally.
      // However, LocationHelper.fetchBySite(uuid) is available.
      // Let's fetch all initially or when no site is selected.
      if (_selectedSite != null) {
        _locationsFuture = LocationHelper.fetchBySite(_selectedSite!.uuid);
      } else {
        _locationsFuture = LocationHelper.fetchFromServer();
      }
    });
  }

  void _onSiteSelected(Site? site) {
    setState(() {
      // Toggle selection if clicking the same site? Or just select.
      // Requirement: "if no location is selected then blank"
      // Requirement: "if no site selected Location Grid to show all Locations"
      
      if (_selectedSite?.id == site?.id) {
         // Deselect if clicking same? Let's allow deselecting by clicking "All Sites" or similar button if we add one,
         // or maybe just clicking the same one toggles it off.
         _selectedSite = null;
      } else {
        _selectedSite = site;
      }
      
      _selectedLocation = null; // Clear location selection when site changes
      _isLocationEditing = false;
      _locationNameController.clear();
      
      _refreshData(); // This will update _locationsFuture based on _selectedSite
    });
  }

  void _onLocationSelected(Location location) {
    setState(() {
      _selectedLocation = location;
      _locationNameController.text = location.name;
      _isLocationEditing = true;
    });
  }

  // --- Site Actions ---

  Future<void> _showSiteDialog({Site? site}) async {
    final isEditing = site != null;
    final nameController = TextEditingController(text: site?.name ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Site' : 'Add New Site'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Site Name',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              Navigator.pop(context); // Close dialog first
              
              final setupsService = SetupsService();
              bool success = false;
              
              try {
                if (isEditing) {
                  success = await setupsService.updateSite(
                    id: site.uuid,
                    name: nameController.text,
                  );
                } else {
                  success = await setupsService.createSite(
                    id: const Uuid().v4(),
                    name: nameController.text,
                  );
                }
                
                if (success) {
                  _refreshData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Site updated' : 'Site added')),
                  );
                } else {
                  throw Exception('Operation failed');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSite(Site site) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Site'),
        content: Text('Delete "${site.name}"? This will affect associated locations.'),
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
        final success = await SetupsService().deleteSite(site.uuid);
        if (success) {
          setState(() {
            if (_selectedSite?.id == site.id) _selectedSite = null;
          });
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Site deleted')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // --- Location Actions ---

  Future<void> _saveLocation() async {
    if (!_locationFormKey.currentState!.validate()) return;
    if (_selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a site first')));
      return;
    }

    setState(() => _isSavingLocation = true);

    try {
      final setupsService = SetupsService();
      bool success = false;

      if (_isLocationEditing && _selectedLocation != null) {
        success = await setupsService.updateLocation(
          id: _selectedLocation!.uuid,
          name: _locationNameController.text,
          safetySiteID: _selectedSite!.uuid,
        );
      } else {
        success = await setupsService.createLocation(
          id: const Uuid().v4(),
          name: _locationNameController.text,
          safetySiteID: _selectedSite!.uuid,
        );
      }

      if (success) {
        _refreshData();
        // Clear location selection after save? Or keep it? 
        // Requirement says "page should auto refresh and show the latest".
        // Let's keep selection if editing, clear if adding? 
        // Actually, clearing selection is safer to show the list update.
        setState(() {
          _selectedLocation = null;
          _isLocationEditing = false;
          _locationNameController.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isLocationEditing ? 'Location updated' : 'Location added')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSavingLocation = false);
    }
  }

  Future<void> _deleteLocation(Location location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Delete "${location.name}"?'),
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
        final success = await SetupsService().deleteLocation(location.uuid);
        if (success) {
          setState(() {
            if (_selectedLocation?.id == location.id) {
              _selectedLocation = null;
              _isLocationEditing = false;
              _locationNameController.clear();
            }
          });
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location deleted')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            title: const Text('Site & Location Manager', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primary),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.grey[300], height: 1),
            ),
          ),
          body: isMobile 
            ? _buildMobileLayout(padding) 
            : _buildDesktopLayout(padding),
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
          // 1. Site Grid (Left)
          Expanded(
            flex: 2,
            child: _buildSitePanel(),
          ),
          SizedBox(width: padding),
          
          // 2. Location Grid (Center)
          Expanded(
            flex: 2,
            child: _buildLocationListPanel(),
          ),
          SizedBox(width: padding),
          
          // 3. Location Edit (Right)
          Expanded(
            flex: 2,
            child: _buildLocationEditPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(double padding) {
    // For mobile, maybe tabs or just stacked?
    // Given the complexity, tabs might be better.
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Sites'),
              Tab(text: 'Locations'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSitePanel(),
                Column(
                  children: [
                    Expanded(child: _buildLocationListPanel()),
                    const Divider(),
                    SizedBox(
                      height: 300,
                      child: _buildLocationEditPanel(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Panels ---

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
                const Text('Sites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                // Edit and Delete buttons at TOP (only when site selected)
                if (_selectedSite != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showSiteDialog(site: _selectedSite),
                    tooltip: 'Edit Site',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSite(_selectedSite!),
                    tooltip: 'Delete Site',
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Site>>(
              future: _sitesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final sites = snapshot.data!;
                if (sites.isEmpty) return const Center(child: Text('No sites'));

                return ListView.builder(
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    final isSelected = _selectedSite?.id == site.id;
                    return ListTile(
                      title: Text(site.name),
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFFFE8DD),
                      selectedColor: AppColors.textPrimary,
                      onTap: () => _onSiteSelected(site),
                      trailing: isSelected ? const Icon(Icons.check_circle, size: 16) : null,
                    );
                  },
                );
              },
            ),
          ),
         // Add Site button at BOTTOM
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Site'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.textPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                Text(
                  _selectedSite != null ? 'Locations in ${_selectedSite!.name}' : 'Locations',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        Icon(Icons.location_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Select a site to view locations',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : FutureBuilder<List<Location>>(
                    future: _locationsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final locations = snapshot.data!;
                      if (locations.isEmpty) return const Center(child: Text('No locations found'));

                      return ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          final isSelected = _selectedLocation?.id == location.id;
                          return ListTile(
                            title: Text(location.name),
                            selected: isSelected,
                            selectedTileColor: const Color(0xFFFFE8DD),
                            selectedColor: AppColors.primary,
                            onTap: () => _onLocationSelected(location),
                            trailing: isSelected ? const Icon(Icons.edit, size: 16) : null,
                          );
                        },
                      );
                    },
                  ),
          ),
          // Add Location button at BOTTOM (only shown if site is selected)
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
                    side: const BorderSide(color: AppColors.textPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Clear form for adding new location
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
            Text(
              _isLocationEditing ? 'Edit Location' : 'Add Location',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_selectedSite == null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.amber[100],
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text('Select a site to add/edit locations')),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Site Selection Dropdown
            FutureBuilder<List<Site>>(
              future: _sitesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final sites = snapshot.data!;
                
                return DropdownButtonFormField<int>(
                  value: _selectedSite?.id,
                  decoration: const InputDecoration(
                    labelText: 'Site *',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: sites.map((site) => DropdownMenuItem(
                    value: site.id,
                    child: Text(site.name),
                  )).toList(),
                  onChanged: (_selectedLocation != null || !_isLocationEditing) 
                    ? (value) {
                        if (value != null) {
                          final selectedSite = sites.firstWhere((s) => s.id == value);
                          setState(() {
                            _selectedSite = selectedSite;
                          });
                        }
                      }
                    : null,
                  validator: (v) => v == null ? 'Please select a site' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                labelText: 'Location Name',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              enabled: _selectedSite != null,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const Spacer(),
            Row(
              children: [
                if (_isLocationEditing)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: _selectedLocation == null ? null : () => _deleteLocation(_selectedLocation!),
                      child: const Text('Delete'),
                    ),
                  ),
                if (_isLocationEditing) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.textPrimary),
                    onPressed: _selectedSite == null || _isSavingLocation ? null : _saveLocation,
                    child: _isSavingLocation 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isLocationEditing ? 'Update' : 'Add'),
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
