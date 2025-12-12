// add_krc_page.dart
// ignore_for_file: unused_import, unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_card_web/utils/app_colors.dart';
import 'dart:typed_data';
import '../data/app_database.dart';
import '../main.dart';
import '../utils/responsive_utils.dart';
import '../services/setups_service.dart';


class AddKrcPage extends StatefulWidget {
  const AddKrcPage({super.key});

  @override
  State<AddKrcPage> createState() => _AddKrcPageState();
}

class _AddKrcPageState extends State<AddKrcPage> {
  late Future<List<KeyRiskCondition>> _krcFuture;
  KeyRiskCondition? _selectedKrc;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  bool _isEditing = false;
  
  // Image upload variables
  Uint8List? _uploadedImageBytes;
  String? _uploadedImageName;
  bool _useCustomImage = false;

  // Available icons list
  final List<String> _availableIcons = [
    'slip_trips_falls.png',
    'working_at_height.png',
    'manual_handling.png',
    'stored_energy_pressure.png',
    'stored_energy_electrical.png',
    'stored_energy_falling_objects.png',
    'cutting_knife_safety.png',
    'tools_equipment.png',
    'hazardous_substances.png',
    'mobile_plant.png',
    'lifting_slinging.png',
    'Personal_Protection_Equipment.png',
    'procedures.png',
    'contractor_management.png',
    'Complacency.png',
    'noise.png',
    'working_environment.png',
    'fatigue.png',
    'spillages.png',
    'waste.png',
    'emissions.png',
    'other.png',
  ];
  
  bool _isSaving = false;
  bool _showImageError = false;

  @override
  void initState() {
    super.initState();
    _krcFuture = _fetchKrcs();
  }

  Future<List<KeyRiskCondition>> _fetchKrcs() async {
    try {
      final setupsService = SetupsService();
      final serverKrcs = await setupsService.fetchAllKRCs();
      
      // Map server data to KeyRiskCondition objects directly
      // We use a temporary ID (hash of hexId) for the 'id' field since it's required by the class
      // but we'll primarily use 'hexId' for operations.
      return serverKrcs.map((data) {
        final hexId = data['id']?.toString() ?? '';
        final name = data['name']?.toString() ?? '';
        
        // Logic to determine the correct icon URL
        String icon = 'other.png';
        if (data['url'] != null && data['url'].toString().startsWith('http')) {
          icon = data['url'].toString();
        } else if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
          String imgUrl = data['imageUrl'].toString();
          if (imgUrl.contains('Risk_Conditions_Images')) {
             // Ensure we have the correct prefix
             icon = 'https://clickpad.cloud/media/$imgUrl';
          } else {
             icon = imgUrl;
          }
        }
        
        // Generate a stable int ID from hexId for UI selection logic
        final intId = hexId.hashCode;
        
        return KeyRiskCondition(
          id: intId,
          name: name,
          icon: icon,
          hexId: hexId,
        );
      }).toList();
    } catch (e) {
      print('Error fetching KRCs from server: $e');
      // Fallback to empty list or local DB if offline? 
      // User requested "complete from server database", so we return empty or error.
      return [];
    }
  }

  void _selectKrc(KeyRiskCondition krc) {
    setState(() {
      _selectedKrc = krc;
      _nameController.text = krc.name;
      _iconController.text = krc.icon;
      _isEditing = true;
      _useCustomImage = false;
      _uploadedImageBytes = null;
      _uploadedImageName = null;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedKrc = null;
      _nameController.clear();
      _iconController.clear();
      _isEditing = false;
      _useCustomImage = false;
      _uploadedImageBytes = null;
      _uploadedImageName = null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _uploadedImageBytes = bytes;
          _uploadedImageName = image.name;
          _useCustomImage = true;
          _iconController.text = 'custom_${DateTime.now().millisecondsSinceEpoch}.png';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveKrc() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    // Validate icon for new KRCs only
    if (!_isEditing && _uploadedImageBytes == null) {
      setState(() => _showImageError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an icon image')),
      );
      return;
    }
    setState(() => _showImageError = false);

    setState(() => _isSaving = true);

    try {
      final setupsService = SetupsService();
      
      if (_isEditing && _selectedKrc != null) {
        // Update existing KRC on server
        final iconPath = _uploadedImageBytes != null 
            ? 'custom_${DateTime.now().millisecondsSinceEpoch}.png' 
            : _selectedKrc!.icon;
        
        final success = await setupsService.updateKRC(
          id: _selectedKrc!.hexId,
          name: _nameController.text,
          imageUrl: iconPath,
          url: '',
          imageBytes: _uploadedImageBytes,
          imageName: _uploadedImageName ?? 'icon.png',
        );
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Key Risk Condition updated successfully')),
            );
          }
        } else {
          throw Exception('Failed to update KRC on server');
        }
      } else {
        // Create new KRC on server
        final iconPath = 'custom_${DateTime.now().millisecondsSinceEpoch}.png';
        final newId = DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase();
        
        final success = await setupsService.createKRC(
          id: newId,
          name: _nameController.text,
          imageUrl: iconPath,
          url: '',
          imageBytes: _uploadedImageBytes,
          imageName: _uploadedImageName ?? 'icon.png',
        );
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Key Risk Condition added successfully')),
            );
          }
        } else {
          throw Exception('Failed to create KRC on server');
        }
      }
      
      _clearSelection();
      setState(() {
        _krcFuture = _fetchKrcs();
      });
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

  Future<void> _deleteKrc() async {
    if (_selectedKrc == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Key Risk Condition'),
        content: const Text('Are you sure you want to delete this key risk condition? This action cannot be undone.'),
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
      try {
        final setupsService = SetupsService();
        
        // Delete from server first
        final success = await setupsService.deleteKRC(_selectedKrc!.hexId);
        
        if (success) {
          // Delete from local DB
          await db.deleteKrc(_selectedKrc!.id);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Key Risk Condition deleted successfully')),
            );
          }
          _clearSelection();
          setState(() {
            _krcFuture = _fetchKrcs();
          });
        } else {
          throw Exception('Failed to delete KRC from server');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
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
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Manage Key Risk Conditions',
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
          child: FutureBuilder<List<KeyRiskCondition>>(
            future: _krcFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final krcs = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(padding),
                itemCount: krcs.length,
                itemBuilder: (context, index) {
                  final krc = krcs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/icons/${krc.icon}',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.warning, size: 40, color: Colors.grey),
                      ),
                      title: Text(
                        krc.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _selectKrc(krc),
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
                          'All Key Risk Conditions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        if (_selectedKrc != null) ...[
                          OutlinedButton.icon(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFDC2626)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: _deleteKrc,
                          ),
                          const SizedBox(width: 8),
                        ],
                        FilledButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New KRC'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: _clearSelection,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<List<KeyRiskCondition>>(
                      future: _krcFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final krcs = snapshot.data!;
                        if (krcs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No key risk conditions found. Click "New KRC" to add one.',
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: krcs.length,
                          itemBuilder: (context, index) {
                            final krc = krcs[index];
                            final isSelected = _selectedKrc?.id == krc.id;
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFE8DD) : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                                ),
                              ),
                              child: ListTile(
                                leading: krc.icon.startsWith('http')
                                    ? Image.network(
                                        krc.icon,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                      )
                                    : Image.asset(
                                        'assets/icons/${krc.icon}',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.warning, size: 40, color: Colors.grey),
                                      ),
                                title: Text(
                                  krc.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? AppColors.textPrimary : const Color(0xFF111827),
                                  ),
                                ),
                                trailing: isSelected 
                                    ? const Icon(Icons.check_circle, color: AppColors.textPrimary)
                                    : const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)),
                                onTap: () => _selectKrc(krc),
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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.textPrimary.withOpacity(0.1),
                  AppColors.textPrimary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textPrimary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Edit Key Risk Condition' : 'Add New Key Risk Condition',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isEditing ? 'Update the KRC details below' : 'Fill in the details to create a new KRC',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Name Field Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.label_outline,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Risk Condition Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Working at Height, Manual Handling',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.textPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 14),
                  validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Image Selection Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showImageError ? Colors.red : const Color(0xFFE5E7EB),
                width: _showImageError ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Icon Image',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Current icon preview (if editing)
                if (_isEditing && _selectedKrc != null && _uploadedImageBytes == null) ...[
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Current Icon',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: _selectedKrc!.icon.startsWith('http')
                              ? Image.network(
                                  _selectedKrc!.icon,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                )
                              : Image.asset(
                                  'assets/icons/${_selectedKrc!.icon}',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.warning, size: 80, color: Colors.grey),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
                
                // Upload new icon section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _uploadedImageBytes != null 
                          ? AppColors.textPrimary
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF9FAFB),
                  ),
                  child: Column(
                    children: [
                      if (_uploadedImageBytes != null) ...[
                        Text(
                          'New Icon Preview',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Image.memory(
                            _uploadedImageBytes!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _uploadedImageName ?? 'Uploaded Image',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isEditing ? 'Upload new icon to replace current' : 'Upload icon image',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.upload_file, size: 20),
                          label: Text(_uploadedImageBytes != null ? 'Change Image' : 'Upload Image'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recommended: PNG or JPG, max 2MB',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Save Button
          Row(
            children: [
              if (_isEditing) ...[
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
                    onPressed: _isSaving ? null : _deleteKrc,
                    child: const Text(
                      'Delete KRC',
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
                  onPressed: _isSaving ? null : _saveKrc,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isEditing ? Icons.save : Icons.add, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _isEditing ? 'Update KRC' : 'Add KRC',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    _iconController.dispose();
    super.dispose();
  }
}