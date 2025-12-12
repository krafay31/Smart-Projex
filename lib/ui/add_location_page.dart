// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safety_card_web/utils/app_colors.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../main.dart';
import '../utils/responsive_utils.dart';
import '../services/setups_service.dart';
import '../helpers/location_helper.dart';
import '../helpers/site_helper.dart';

class AddLocationsPage extends StatefulWidget {
  const AddLocationsPage({super.key});

  @override
  State<AddLocationsPage> createState() => _AddLocationsPageState();
}

class _AddLocationsPageState extends State<AddLocationsPage> {
  late Future<List<Location>> _locationsFuture;
  late Future<List<Site>> _sitesFuture;
  Location? _selectedLocation;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedSiteUuid;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _locationsFuture = LocationHelper.fetchFromServer();
      _sitesFuture = SiteHelper.fetchFromServer();
    });
  }

  void _selectLocation(Location location) async {
    final sites = await _sitesFuture;
    final site = sites.firstWhere(
      (s) => s.id == location.siteId,
      orElse: () => sites.first,
    );
    
    setState(() {
      _selectedLocation = location;
      _nameController.text = location.name;
      _selectedSiteUuid = site.uuid;
      _isEditing = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedLocation = null;
      _nameController.clear();
      _selectedSiteUuid = null;
      _isEditing = false;
    });
  }

  Future<void> _saveLocation() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSiteUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a site')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final setupsService = SetupsService();
      
      if (_isEditing && _selectedLocation != null) {
        final success = await setupsService.updateLocation(
          id: _selectedLocation!.uuid,
          name: _nameController.text,
          safetySiteID: _selectedSiteUuid!,
        );
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location updated successfully')),
            );
          }
        } else {
          throw Exception('Failed to update location on server');
        }
      } else {
        const uuid = Uuid();
        final locationId = uuid.v4();
        
        final success = await setupsService.createLocation(
          id: locationId,
          name: _nameController.text,
          safetySiteID: _selectedSiteUuid!,
        );
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location added successfully')),
            );
          }
        } else {
          throw Exception('Failed to create location on server');
        }
      }
      _clearSelection();
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteLocation() async {
    if (_selectedLocation == null || _isSaving) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Location'),
        content: const Text('Are you sure you want to delete this location? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        final setupsService = SetupsService();
        final success = await setupsService.deleteLocation(_selectedLocation!.uuid);
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location deleted successfully')),
            );
          }
          _clearSelection();
          _loadData();
        } else {
          throw Exception('Failed to delete location');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
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
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Manage Locations',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: const Color(0xFFE5E7EB),
                height: 1,
              ),
            ),
          ),
          body: isMobile ? _buildMobileLayout(padding) : _buildDesktopLayout(padding),
        );
      },
    );
  }

  Widget _buildMobileLayout(double padding) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait([_locationsFuture, _sitesFuture]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final locations = snapshot.data![0] as List<Location>;
              final sites = snapshot.data![1] as List<Site>;

              return ListView.builder(
                padding: EdgeInsets.all(padding),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  final site = sites.firstWhere((s) => s.id == location.siteId);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        location.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Site: ${site.name}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _selectLocation(location),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(padding),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: SafeArea(
            child: _buildForm(padding, true),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
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
                        const Text(
                          'All Locations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Location'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                          ),
                          onPressed: _clearSelection,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: Future.wait([_locationsFuture, _sitesFuture]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final locations = snapshot.data![0] as List<Location>;
                        final sites = snapshot.data![1] as List<Site>;
                        
                        if (locations.isEmpty) {
                          return const Center(
                            child: Text(
                              'No locations found. Click "New Location" to add one.',
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            final location = locations[index];
                            final site = sites.firstWhere((s) => s.id == location.siteId);
                            final isSelected = _selectedLocation?.id == location.id;
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFE8DD) : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  location.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? AppColors.textPrimary : const Color(0xFF111827),
                                  ),
                                ),
                                subtitle: Text(
                                  'Site: ${site.name}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? AppColors.textPrimary.withOpacity(0.7) : const Color(0xFF6B7280),
                                  ),
                                ),
                                trailing: isSelected 
                                    ? const Icon(Icons.check_circle, color: AppColors.textPrimary)
                                    : const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)),
                                onTap: () => _selectLocation(location),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: padding),
          
          Expanded(
            flex: 3,
            child: Container(
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
              child: _buildForm(padding, false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(double padding, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.place,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Edit Location' : 'Add New Location',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isEditing ? 'Update location information' : 'Enter location details below',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Site',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Site>>(
            future: _sitesFuture,
            builder: (context, snapshot) {
              final sites = snapshot.data ?? [];
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                hint: const Text('Select a site'),
                initialValue: _selectedSiteUuid,
                items: sites.map((site) {
                  return DropdownMenuItem<String>(
                    value: site.uuid,
                    child: Text(site.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSiteUuid = value;
                  });
                },
                validator: (v) => v == null ? 'Please select a site' : null,
              );
            },
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Location Name',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter location name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Location name is required' : null,
          ),
          
          if (!isMobile) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Color(0xFF6B7280)),
                      SizedBox(width: 8),
                      Text(
                        'Location Information',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow('Created Date', DateFormat('dd/MM/yyyy').format(DateTime.now())),
                  const SizedBox(height: 8),
                  _infoRow('Created By', 'Admin'),
                ],
              ),
            ),
          ],
          
          const Spacer(),
          const SizedBox(height: 24),
          
          Row(
            children: [
              if (_isEditing && !isMobile) ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isSaving ? null : _deleteLocation,
                    child: const Text(
                      'Delete Location',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveLocation,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Location' : 'Add Location',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}