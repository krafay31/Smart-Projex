// add_sites_page.dart
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import '../data/app_database.dart';
// import '../main.dart';
// import '../utils/responsive_utils.dart';
// import '../services/setups_service.dart';
// import '../helpers/site_helper.dart';

// class AddSitePage extends StatefulWidget {
//   const AddSitePage({super.key});

//   @override
//   State<AddSitePage> createState() => _AddSitePageState();
// }

// class _AddSitePageState extends State<AddSitePage> {
//   late Future<List<Site>> _sitesFuture;
//   Site? _selectedSite;
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSites();
//   }

//   Future<void> _loadSites() async {
//     setState(() => _sitesFuture = SiteHelper.fetchFromServer());
//   }

//   void _selectSite(Site site) {
//     setState(() {
//       _selectedSite = site;
//       _nameController.text = site.name;
//       _isEditing = true;
//     });
//   }

//   void _clearSelection() {
//     setState(() {
//       _selectedSite = null;
//       _nameController.clear();
//       _isEditing = false;
//     });
//   }

//   Future<void> _saveSite() async {
//     if (!_formKey.currentState!.validate()) return;

//     try {
//       final setupsService = SetupsService();
      
//       if (_isEditing && _selectedSite != null) {
//         // Update existing site
//         final success = await setupsService.updateSite(
//           id: _selectedSite!.uuid,
//           name: _nameController.text,
//         );
        
//         if (success) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Site updated successfully')),
//             );
//           }
//         } else {
//           throw Exception('Failed to update site on server');
//         }
//       } else {
//         // Create new site
//         const uuid = Uuid();
//         final siteId = uuid.v4();
        
//         final success = await setupsService.createSite(
//           id: siteId,
//           name: _nameController.text,
//         );
        
//         if (success) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Site added successfully')),
//             );
//           }
//         } else {
//           throw Exception('Failed to create site on server');
//         }
//       }
      
//       _clearSelection();
//       _loadSites();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _deleteSite() async {
//     if (_selectedSite == null) return;

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Site'),
//         content: Text('Are you sure you want to delete "${_selectedSite!.name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     try {
//       final setupsService = SetupsService();
//       final success = await setupsService.deleteSite(_selectedSite!.uuid);
      
//       if (success) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Site deleted successfully')),
//           );
//         }
//         _clearSelection();
//         _loadSites();
//       } else {
//         throw Exception('Failed to delete site');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveBuilder(
//       builder: (context, screenSize) {
//         final isMobile = screenSize == ScreenSize.mobile;
//         final padding = ResponsiveUtils.getResponsivePadding(context);

//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             title: const Text(
//               'Manage Sites',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(1),
//               child: Container(
//                 color: Colors.grey[300],
//                 height: 1,
//               ),
//             ),
//           ),
//           body: _buildDesktopLayout(padding, isMobile),
//         );
//       },
//     );
//   }

//   Widget _buildDesktopLayout(double padding, bool isMobile) {
//     return Padding(
//       padding: EdgeInsets.all(padding),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left Panel - List of sites
//           Expanded(
//             flex: 2,
//             child: Container(
//               padding: EdgeInsets.all(padding),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'All Sites',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const Divider(height: 1),
//                   Expanded(
//                     child: FutureBuilder<List<Site>>(
//                       future: _sitesFuture,
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData) {
//                           return const Center(child: CircularProgressIndicator());
//                         }

//                         final sites = snapshot.data!;
//                         if (sites.isEmpty) {
//                           return const Center(
//                             child: Text(
//                               'No sites found. Click "New Site" to add one.',
//                               style: TextStyle(color: Color(0xFF9CA3AF)),
//                             ),
//                           );
//                         }

//                         return ListView.builder(
//                           itemCount: sites.length,
//                           itemBuilder: (context, index) {
//                             final site = sites[index];
//                             final isSelected = _selectedSite?.uuid == site.uuid;
                            
//                             return Container(
//                               decoration: BoxDecoration(
//                                 color: isSelected ? const Color(0xFFFFE8DD) : Colors.transparent,
//                                 border: Border(
//                                   bottom: BorderSide(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
//                                 ),
//                               ),
//                               child: ListTile(
//                                 title: Text(
//                                   site.name,
//                                   style: TextStyle(
//                                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                                     color: isSelected ? AppColors.textPrimary : const Color(0xFF111827),
//                                   ),
//                                 ),
//                                 trailing: isSelected 
//                                     ? const Icon(Icons.check_circle, AppColors.textPrimary)
//                                     : const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)),
//                                 onTap: () => _selectSite(site),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(width: padding),
          
//           // Right Panel - Form
//           Expanded(
//             flex: 3,
//             child: Container(
//               padding: EdgeInsets.all(padding),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header with buttons
//                     Row(
//                       children: [
//                         Text(
//                           _isEditing ? 'Edit Site' : 'Add New Site',
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const Spacer(),
//                         if (_isEditing) ...[
//                           OutlinedButton.icon(
//                             icon: const Icon(Icons.delete, size: 18),
//                             label: const Text('Delete'),
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.red,
//                               side: const BorderSide(color: Colors.red),
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             ),
//                             onPressed: _deleteSite,
//                           ),
//                           const SizedBox(width: 8),
//                         ],
//                         FilledButton.icon(
//                           icon: const Icon(Icons.add, size: 18),
//                           label: const Text('New Site'),
//                           style: FilledButton.styleFrom(
//                             backgroundColor: AppColors.textPrimary,
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           ),
//                           onPressed: _clearSelection,
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 32),
                    
//                     // Name field
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         labelText: 'Site Name',
//                         hintText: 'Enter site name',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         filled: true,
//                         fillColor: const Color(0xFFF9FAFB),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a site name';
//                         }
//                         return null;
//                       },
//                     ),
                    
//                     const Spacer(),
                    
//                     // Save button
//                     SizedBox(
//                       width: double.infinity,
//                       child: FilledButton(
//                         onPressed: _saveSite,
//                         style: FilledButton.styleFrom(
//                           backgroundColor: AppColors.textPrimary,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           _isEditing ? 'Update Site' : 'Add Site',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }
// }

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

class AddSitesPage extends StatefulWidget {
  const AddSitesPage({super.key});

  @override
  State<AddSitesPage> createState() => _AddSitesPageState();
}

class _AddSitesPageState extends State<AddSitesPage> {
  late Future<List<Site>> _sitesFuture;
  Site? _selectedSite;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  void _loadSites() {
    setState(() {
      _sitesFuture = SiteHelper.fetchFromServer();
    });
  }

  void _selectSite(Site site) {
    setState(() {
      _selectedSite = site;
      _nameController.text = site.name;
      _isEditing = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedSite = null;
      _nameController.clear();
      _isEditing = false;
    });
  }

  Future<void> _saveSite() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final setupsService = SetupsService();
      
      if (_isEditing && _selectedSite != null) {
        final success = await setupsService.updateSite(
          id: _selectedSite!.uuid,
          name: _nameController.text,
        );
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Site updated successfully')),
            );
          }
        } else {
          throw Exception('Failed to update site on server');
        }
      } else {
        const uuid = Uuid();
        final siteId = uuid.v4();
        
        final success = await setupsService.createSite(
          id: siteId,
          name: _nameController.text,
        );
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Site added successfully')),
            );
          }
        } else {
          throw Exception('Failed to create site on server');
        }
      }
      _clearSelection();
      _loadSites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteSite() async {
    if (_selectedSite == null) return;

    // Check for dependent locations
    List<Location> dependentLocations = [];
    bool isLoading = true;
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      dependentLocations = await LocationHelper.fetchBySite(_selectedSite!.uuid);
    } catch (e) {
      print('Error checking dependent locations: $e');
    } finally {
      if (mounted) Navigator.pop(context); // Dismiss loading
    }

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Site'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this site?'),
            if (dependentLocations.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'WARNING: The following locations are attached to this site and will be affected (randomly allocated or orphaned):',
                style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: dependentLocations.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text('• ${dependentLocations[index].name}', style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('This action cannot be undone.'),
          ],
        ),
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
        final success = await setupsService.deleteSite(_selectedSite!.uuid);
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Site deleted successfully')),
            );
          }
          _clearSelection();
          _loadSites();
        } else {
          throw Exception('Failed to delete site');
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
              'Manage Sites',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w600,
                color: AppColors.surface,
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.primary),
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
          child: FutureBuilder<List<Site>>(
            future: _sitesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final sites = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(padding),
                itemCount: sites.length,
                itemBuilder: (context, index) {
                  final site = sites[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        site.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Created: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _selectSite(site),
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
          // Left side - Sites list
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
                          'All Sites',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Site'),
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
                    child: FutureBuilder<List<Site>>(
                      future: _sitesFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final sites = snapshot.data!;
                        if (sites.isEmpty) {
                          return const Center(
                            child: Text(
                              'No sites found. Click "New Site" to add one.',
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: sites.length,
                          itemBuilder: (context, index) {
                            final site = sites[index];
                            final isSelected = _selectedSite?.id == site.id;
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFE8DD) : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  site.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : const Color(0xFF111827),
                                  ),
                                ),
                                trailing: isSelected 
                                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                                    : const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)),
                                onTap: () => _selectSite(site),
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
          
          // Right side - Site details/form
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
                  Icons.location_city,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Edit Site' : 'Add New Site',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isEditing ? 'Update site information' : 'Enter site details below',
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
            'Site Name',
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
              hintText: 'Enter site name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Site name is required' : null,
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
                        'Site Information',
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
                    onPressed: _deleteSite,
                    child: const Text(
                      'Delete Site',
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
                  onPressed: _saveSite,
                  child: Text(
                    _isEditing ? 'Update Site' : 'Add Site',
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