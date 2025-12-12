// ignore_for_file: unused_import, avoid_print

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
import '../helpers/krc_helper.dart';
import '../helpers/site_helper.dart';
import '../helpers/location_helper.dart';
import '../helpers/users_helper.dart';
import '../utils/responsive_utils.dart';
import '../services/sync_service.dart';
import 'package:crypto/crypto.dart';
import '../utils/status_helper.dart';

import 'package:http/http.dart' as http;
import '../services/image_service.dart';

class EditSafetyCardPage extends StatefulWidget {
  final SafetyCard card;
  
  const EditSafetyCardPage({super.key, required this.card});

  @override
  State<EditSafetyCardPage> createState() => _EditSafetyCardPageState();
}

class _EditSafetyCardPageState extends State<EditSafetyCardPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentPanel = 1;
  bool _safetyStatusError = false;

  // form state
  late int _siteId;
  late int _locationId;
  late int _krcId;
  late String _department;
  late String _safetyStatus;
  late String _observation;
  late String _actionTaken;
  late String _cardStatus;
  late int _raisedById;
  late int? _personResponsibleId;
  bool _isAnonymous = false; // Track anonymous submission
  List<Uint8List> _imageBytesList = [];
  List<Uint8List> _newImageBytesList = [];
  // ✅ NEW: Better tracking with both ID and URL
  List<Map<String, String>> _existingImageDetails = []; // [{id: '123', url: 'http://...'}]
  List<String> _deletedImageIds = []; // Track IDs to delete
  bool _imagesChanged = false;
  
  
  // Date and time fields
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _originalTime;

  late Future<List<Site>> _sitesF;
  late Future<List<KeyRiskCondition>> _krcF;
  late Future<List<AppUser>> _appUsersF;

  // ignore: unused_field
  late Future<List<UserLite>> _usersF;
  List<Location> _locations = [];



@override
void initState() {
  super.initState();
  
  // ✅ FIXED: Initialize with local data first (synchronous) so form can render
  _initializeWithLocalCard();
  
  // ✅ Then fetch fresh server data and update (asynchronous)
  _initializeWithServerData();
  
  _currentPanel = 1;
  
  _sitesF = SiteHelper.fetchFromServer();
  _krcF = KrcHelper.fetchFromServer();
  _usersF = UsersHelper.fetchFromServer();
}

// ✅ NEW: Initialize form with fresh server data
Future<void> _initializeWithServerData() async {
  try {
    print('📥 Fetching fresh card data from server: ${widget.card.uuid}');
    
    // Fetch fresh card from server
    final freshCard = await syncService.fetchCardByUuid(widget.card.uuid);
    
    // Use fresh card if available, otherwise use widget.card
    final cardToUse = freshCard ?? widget.card;
    
    if (mounted) {
      setState(() {
        // Initialize with fresh server data
        _siteId = cardToUse.siteId;
        _locationId = cardToUse.locationId;
        _krcId = cardToUse.keyRiskConditionId;
        _department = cardToUse.department;
        
        // ✅ FIX: Normalize safety status to match button values
        String storedStatus = cardToUse.safetyStatus.toLowerCase().trim();
        _safetyStatus = switch (storedStatus) {
          'unsafe' || _ when storedStatus.contains('unsafe') => 'Unsafe Condition',
          'safe' || _ when storedStatus.contains('safe') => 'Safe Observation',
          _ => 'Safe Observation',
        };
        print('🔍 Edit init: Stored status="$storedStatus" → Mapped to "$_safetyStatus"');
        
        // ✅ IMPORTANT: Load latest observation and action taken from server
        _observation = cardToUse.observation;
        _actionTaken = cardToUse.actionTaken;
        _cardStatus = cardToUse.status;
        _raisedById = cardToUse.raisedById;
        _personResponsibleId = cardToUse.personResponsibleId;
        
        // Check if this was an anonymous submission
        _isAnonymous = (cardToUse.filePath == 'Anonymous');
        print('🔍 Anonymous check: filePath="${cardToUse.filePath}" → _isAnonymous=$_isAnonymous');
        
        // Parse date and time
        _selectedDate = DateTime.parse(cardToUse.date);
        _originalTime = cardToUse.time;
        final initTimeParts = _originalTime.split(':');
        final hour = int.parse(initTimeParts[0]);
        final minute = int.parse(initTimeParts.length > 1 ? initTimeParts[1] : '0');
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      });
      
      // Load locations after site is set
      await _loadLocations();
      
      // Load existing images from API
      await _loadExistingImages();
      
      _appUsersF = db.select(db.appUsers).get();
      
      print('✅ Form initialized with fresh server data');
    }
  } catch (e) {
    print('❌ Error fetching fresh card data: $e');
    // Fall back to local card data on error
    _initializeWithLocalCard();
  }
}

// ✅ NEW: Fallback to initialize with local card data
void _initializeWithLocalCard() {
  _siteId = widget.card.siteId;
  _locationId = widget.card.locationId;
  _krcId = widget.card.keyRiskConditionId;
  _department = widget.card.department;
  
  String storedStatus = widget.card.safetyStatus.toLowerCase().trim();
  _safetyStatus = switch (storedStatus) {
    'unsafe' || _ when storedStatus.contains('unsafe') => 'Unsafe Condition',
    'safe' || _ when storedStatus.contains('safe') => 'Safe Observation',
    _ => 'Safe Observation',
  };
  
  _observation = widget.card.observation;
  _actionTaken = widget.card.actionTaken;
  _cardStatus = widget.card.status;
  _raisedById = widget.card.raisedById;
  _personResponsibleId = widget.card.personResponsibleId;
  
  // ✅ Set isAnonymous based on adminModified field only
  _isAnonymous = (widget.card.adminModified == true);
  
  _selectedDate = DateTime.parse(widget.card.date);
  _originalTime = widget.card.time;
  final initTimeParts = _originalTime.split(':');
  final hour = int.parse(initTimeParts[0]);
  final minute = int.parse(initTimeParts.length > 1 ? initTimeParts[1] : '0');
  _selectedTime = TimeOfDay(hour: hour, minute: minute);
  
  _loadLocations();
  _appUsersF = db.select(db.appUsers).get();
}

// ✅ NEW: Load existing images from API
// Future<void> _loadExistingImages() async {
//   try {
//     print('📥 Loading existing images for card: ${widget.card.uuid}');
    
//     // First, try to load from local imageListBase64
//     if (widget.card.imageListBase64 != null && widget.card.imageListBase64!.isNotEmpty) {
//       print('📦 Found images in imageListBase64');
//       final imageStrings = widget.card.imageListBase64!.split('|||');
      
//       for (var imgStr in imageStrings) {
//         if (imgStr.isNotEmpty) {
//           try {
//             final bytes = base64Decode(imgStr);
//             setState(() {
//               _imageBytesList.add(bytes);
//             });
//           } catch (e) {
//             print('⚠️ Failed to decode base64 image: $e');
//           }
//         }
//       }
      
//       print('✅ Loaded ${_imageBytesList.length} images from imageListBase64');
//       return;
//     }
    
// //     // Fallback: If no local images, try loading from API
// //     print('🔍 No local images found, checking API...');
// //     final imageUrls = await ImageService.getImageUrls(widget.card.uuid);
    
// //     if (imageUrls.isNotEmpty) {
// //       print('📷 Found ${imageUrls.length} images on server');
      
// //       // Download each image and convert to bytes
// //       for (final url in imageUrls) {
// //         try {
// //           final response = await http.get(Uri.parse(url));
// //           if (response.statusCode == 200) {
// //             setState(() {
// //               _imageBytesList.add(response.bodyBytes);
// //             });
// //             print('✅ Loaded image from: $url');
// //           }
// //         } catch (e) {
// //           print('⚠️ Failed to load image from $url: $e');
// //         }
// //       }
      
// //       print('✅ Loaded ${_imageBytesList.length} images from API');
// //     } else {
// //       print('ℹ️ No existing images found');
// //     }
// //   } catch (e) {
// //     print('❌ Error loading existing images: $e');
// //   }
// // }
// // ✅ NEW: Always fetch URLs from API for deletion tracking
//       print('🔍 Fetching image URLs from API...');
//       final imageUrls = await ImageService.getImageUrls(widget.card.uuid);
      
//       if (imageUrls.isNotEmpty) {
//         print('📷 Found ${imageUrls.length} images on server');
//         setState(() {
//           _existingImageUrls = imageUrls;
//         });
        
//         // If we didn't have local images, download them
//         if (_imageBytesList.isEmpty) {
//           for (final url in imageUrls) {
//             try {
//               final response = await http.get(Uri.parse(url));
//               if (response.statusCode == 200) {
//                 setState(() {
//                   _imageBytesList.add(response.bodyBytes);
//                 });
//                 print('✅ Loaded image from: $url');
//               }
//             } catch (e) {
//               print('⚠️ Failed to load image from $url: $e');
//             }
//           }
          
//           print('✅ Loaded ${_imageBytesList.length} images from API');
//         }
//       } else {
//         print('ℹ️ No existing images found');
//       }
//     } catch (e) {
//       print('❌ Error loading existing images: $e');
//     }
//  }
// // ✅ FINAL: Load existing images with both ID and URL
//   Future<void> _loadExistingImages() async {
//     try {
//       print('📥 Loading existing images for card: ${widget.card.uuid}');
      
//       // First, try to load from local imageListBase64
//       if (widget.card.imageListBase64 != null && widget.card.imageListBase64!.isNotEmpty) {
//         print('📦 Found images in imageListBase64');
//         final imageStrings = widget.card.imageListBase64!.split('|||');
        
//         for (var imgStr in imageStrings) {
//           if (imgStr.isNotEmpty) {
//             try {
//               final bytes = base64Decode(imgStr);
//               setState(() {
//                 _imageBytesList.add(bytes);
//               });
//             } catch (e) {
//               print('⚠️ Failed to decode base64 image: $e');
//             }
//           }
//         }
        
//         print('✅ Loaded ${_imageBytesList.length} images from imageListBase64');
//       }
      
//       // ✅ NEW: Always fetch image details (ID + URL) from API
//       print('🔍 Fetching image details from API...');
//       final imageDetails = await ImageService.getImageDetails(widget.card.uuid);
      
//       if (imageDetails.isNotEmpty) {
//         print('📷 Found ${imageDetails.length} images on server');
//         setState(() {
//           _existingImageDetails = imageDetails;
//         });
        
//         // If we didn't have local images, download them
//         if (_imageBytesList.isEmpty) {
//           for (final detail in imageDetails) {
//             final url = detail['url']!;
//             try {
//               final response = await http.get(Uri.parse(url));
//               if (response.statusCode == 200) {
//                 setState(() {
//                   _imageBytesList.add(response.bodyBytes);
//                 });
//                 print('✅ Loaded image from: $url');
//               }
//             } catch (e) {
//               print('⚠️ Failed to load image from $url: $e');
//             }
//           }
          
//           print('✅ Loaded ${_imageBytesList.length} images from API');
//         }
//       } else {
//         print('ℹ️ No existing images found');
//       }
//     } catch (e) {
//       print('❌ Error loading existing images: $e');
//     }
//   }
// ✅ FIXED: Load only from server, ignore local imageListBase64 to prevent duplicates
Future<void> _loadExistingImages() async {
  try {
    print('📥 Loading existing images for card: ${widget.card.uuid}');
    
    // Clear existing lists
    _imageBytesList.clear();
    _existingImageDetails.clear();
    
    // ✅ ONLY fetch from server - ignore local imageListBase64
    print('🔍 Fetching image details from API...');
    final imageDetails = await ImageService.getImageDetails(widget.card.uuid);
    
    if (imageDetails.isNotEmpty) {
      print('📷 Found ${imageDetails.length} images on server');
      setState(() {
        _existingImageDetails = imageDetails;
      });
      
      // Download each server image
      for (final detail in imageDetails) {
        final url = detail['url']!;
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            setState(() {
              _imageBytesList.add(response.bodyBytes);
            });
            print('✅ Loaded image from: $url');
          }
        } catch (e) {
          print('⚠️ Failed to load image from $url: $e');
        }
      }
      
      print('✅ Loaded ${_imageBytesList.length} images from API');
    } else {
      print('ℹ️ No existing images found on server');
    }
    
    // ✅ DO NOT merge local images - this was causing duplicates
    
  } catch (e) {
    print('❌ Error loading existing images: $e');
  }
}
  Future<void> _loadLocations() async {
    print('Loading locations for site: $_siteId');
    
    // Find the site UUID from the helper results to fetch locations
    final sites = await _sitesF;
    final site = sites.firstWhere((s) => s.id == _siteId, orElse: () => sites.first);
    
    _locations = await LocationHelper.fetchBySite(site.uuid);
    print('Loaded ${_locations.length} locations');
    
    if (_locations.isEmpty) {
      print('⚠️ WARNING: No locations found for site $_siteId');
    } else {
      // Verify that _locationId exists in loaded locations
      final locationExists = _locations.any((l) => l.id == _locationId);
      if (!locationExists) {
        print('⚠️ WARNING: Location ID $_locationId not found in loaded locations');
        print('Available locations: ${_locations.map((l) => '${l.id}: ${l.name}').join(', ')}');
      }
    }
    
    if (mounted) setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytesList.add(bytes);
        _newImageBytesList.add(bytes);
        _imagesChanged = true;
      });
    }
  }

  Future<KeyRiskCondition?> _getSelectedKrc() async {
    final krcList = await _krcF;
    return krcList.firstWhere((k) => k.id == _krcId, orElse: () => krcList.first);
  }

  // void _removeImage(int index) {
  //   setState(() {
  //     final removedImage = _imageBytesList[index];
  //     _imageBytesList.removeAt(index);
      
  //     // ✅ NEW: If it was a new image, remove from new list too
  //     _newImageBytesList.remove(removedImage);
      
  //     _imagesChanged = true;
  //   });
  // }
// ✅ FINAL: Track deletion with proper ID
  // void _removeImage(int index) {
  //   setState(() {
  //     final removedImage = _imageBytesList[index];
  //     _imageBytesList.removeAt(index);
      
  //     // If this was a new image, remove from new list
  //     _newImageBytesList.remove(removedImage);
      
  //     // ✅ NEW: If this was an existing image, mark ID for deletion
  //     if (index < _existingImageDetails.length) {
  //       final imageId = _existingImageDetails[index]['id']!;
  //       _deletedImageIds.add(imageId);
  //       print('🗑️ Marked image for deletion: ID=$imageId');
  //     }
      
  //     _imagesChanged = true;
  //   });
  // }
  void _removeImage(int index) {
    setState(() {
      // If this was a server image, track for deletion
      if (index < _existingImageDetails.length) {
        final id = _existingImageDetails[index]['id']!;
        _deletedImageIds.add(id);
      }
      _imageBytesList.removeAt(index);
      _imagesChanged = true;
    });
  }
  bool _validatePanel0() {
    if (_krcId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Key Risk Condition')),
      );
      return false;
    }
    return true;
  }

  bool _validatePanel1() {
    if (_krcId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Key Risk Condition first')),
      );
      return false;
    }
    if (_siteId == 0 || _locationId == 0 || _department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
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

  bool _validatePanel2() {
    if (_safetyStatus.isEmpty) {
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
      
      if (panelIndex == 1 && !_validatePanel0()) return;
      if (panelIndex == 2) {
        if (!_validatePanel0()) return;
        if (!_validatePanel1()) return;
      }
    }
    
    setState(() => _currentPanel = panelIndex);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validatePanel2()) return;
    _formKey.currentState!.save();

    print('=== SAVING CARD ===');
    print('Card ID: ${widget.card.id}');
    print('Card UUID: ${widget.card.uuid}');
    print('Anonymous: $_isAnonymous');
    
    if (_deletedImageIds.isNotEmpty) {
      print('🗑️ Deleting ${_deletedImageIds.length} images from server...');
      
      for (final imageId in _deletedImageIds) {
        try {
          print('🗑️ Deleting image ID: $imageId');
          final deleted = await ImageService.deleteImage(imageId);
          
          if (deleted) {
            print('✅ Successfully deleted image: $imageId');
          } else {
            print('⚠️ Failed to delete image: $imageId');
          }
        } catch (e) {
          print('❌ Error deleting image: $e');
        }
      }
    }

    String? imageListJson = null;
    Uint8List? primaryImage = null;

    final timeParts = _originalTime.split(':');
    final originalHour = int.parse(timeParts[0]);
    final originalMinute = int.parse(timeParts.length > 1 ? timeParts[1] : '0');
    String timeStr;
    if (_selectedTime.hour == originalHour && _selectedTime.minute == originalMinute) {
      timeStr = _originalTime;
    } else {
      timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
    }

    String normalizedSafetyStatus = _safetyStatus;
    if (_safetyStatus.toLowerCase().contains('unsafe')) {
      normalizedSafetyStatus = 'Unsafe';
    } else if (_safetyStatus.toLowerCase().contains('safe')) {
      normalizedSafetyStatus = 'Safe';
    }

    // ✅ NEW: Create full SafetyCard object with adminModified field
    final fullCard = SafetyCard(
      id: widget.card.id,
      uuid: widget.card.uuid,
      keyRiskConditionId: _krcId,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      time: timeStr,
      raisedById: _raisedById,
      department: _department,
      siteId: _siteId,
      locationId: _locationId,
      safetyStatus: normalizedSafetyStatus,
      observation: _observation,
      actionTaken: _actionTaken,
      status: _cardStatus,
      personResponsibleId: _personResponsibleId,
      imageData: null,
      imageListBase64: null,
      adminModified: _isAnonymous ? true : null, // ✅ NEW: Set adminModified based on isAnonymous
    );

    print('Calling syncService.updateCard...');

    try {
      await syncService.updateCard(fullCard, newImages: _newImageBytesList);
      print('✔ Card updated successfully');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safety card updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      print('✗ Error updating card: $e');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating card: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
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
                isMobile ? 'Edit Record' : 'Health and Safety Management Panel',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            actions: [
              if (!isMobile)
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
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
                                  'Edit Safety Record',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  icon: const Icon(Icons.close),
                                  label: const Text(''),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ] else ...[
                            const Text(
                              'Edit Safety Record',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          _buildProgressIndicator(isMobile),
                          SizedBox(height: isMobile ? 24 : 32),
                          
                          if (_currentPanel == 0) _buildPanel0(isMobile),
                          if (_currentPanel == 1) _buildPanel1(isMobile),
                          if (_currentPanel == 2) _buildPanel2(isMobile),
                          
                          SizedBox(height: isMobile ? 24 : 32),
                          
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
                color: isActive ? AppColors.surface : Colors.grey[600],
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
    ));
  }

  Widget _buildProgressLine(int index) {
    final isActive = _currentPanel > index;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: isActive ? AppColors.textPrimary : Colors.grey[300],
    );
  }

  // Panel 0: Key Risk Condition with icon grid
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
                if (_currentPanel == 0) ...[
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
            
            // Grid of KRC icons
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
                    // Auto-navigate to Location panel
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
                          ? AppColors.primary.withOpacity(0.05)
                          : Colors.white,
                    ),
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                        child: krc.icon.startsWith('http')
                            ? Image.network(
                                krc.icon,
                                fit: BoxFit.contain, // Ensure aspect ratio is maintained
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
                            color: AppColors.textPrimary,
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

  // Panel 1: Site, Location, Department, Date & Time
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
                    color: AppColors.textPrimary,
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
                      color: const Color(0xFFFFF4ED),
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
                            child: (krc.icon.startsWith('http://') || krc.icon.startsWith('https://'))
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
                            color: const Color(0xFFFF6B35),
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
                                  color: const Color(0xFF6B7280),
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
            
            // Ded uplicate sites to prevent dropdown error
            Builder(
              builder: (context) {
                final uniqueSites = <Site>[];
                final seenIds = <int>{};
                for (var site in sites) {
                  if (!seenIds.contains(site.id)) {
                    seenIds.add(site.id);
                    uniqueSites.add(site);
                  }
                }
                
                return _dropdown<int>(
                  'Site *',
                  _siteId,
                  uniqueSites
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ))
                      .toList(),
                  (v) async {
                    if (v != null) {
                      print('Site changed to: $v');
                      
                      // Find the site UUID from the helper results to fetch locations
                      final sites = await _sitesF;
                      final site = sites.firstWhere((s) => s.id == v, orElse: () => sites.first);
                      
                      setState(() {
                        _siteId = v;
                        _locationId = 0; // Clear location when site changes
                        _locations = []; // Clear locations list
                      });
                      
                      // Load new locations
                      final newLocations = await LocationHelper.fetchBySite(site.uuid);
                      print('Loaded ${newLocations.length} locations for site $v');
                      
                      setState(() {
                        _locations = newLocations;
                        // Auto-select first location if available
                        if (_locations.isNotEmpty) {
                          _locationId = _locations.first.id;
                        }
                      });
                    }
                  },
                );
              },
            ),
            SizedBox(height: isMobile ? 16 : 20),
            
            // Location dropdown with key to force rebuild
            Builder(
              key: ValueKey('location_dropdown_$_siteId'),
              builder: (context) {
                return _dropdown<int>(
                  'Location *',
                  _locationId,
                  _locations
                      .map((l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.name),
                          ))
                      .toList(),
                  (v) {
                    print('Location changed to: $v');
                    setState(() => _locationId = v ?? _locationId);
                  },
                );
              },
            ),
            SizedBox(height: isMobile ? 16 : 20),
            
            // Department field ABOVE Raised By
            _text(
              'Department *',
              (v) => _department = v ?? _department,
              initial: _department,
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
                              ? AppColors.textPrimary
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
                                    ? AppColors.textPrimary
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
                                        ? AppColors.textPrimary
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
                                ? AppColors.textPrimary
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
                        
                        // For admin users, show dropdown with AppUser IDs that map to User IDs
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
                                    // Find matching user by name
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

  // Update the Panel 2 section to prevent editing Closed cards
  Widget _buildPanel2(bool isMobile) {
    // Check if card is closed - should not allow editing
    if (widget.card.status == 'Closed' && !UserSession.isAdmin) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'This card is closed and cannot be edited',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }
    
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
          (v) => _observation = v ?? _observation,
          hint: 'Describe what you observed in detail...',
          initial: _observation,
        ),
        SizedBox(height: isMobile ? 16 : 20),
        
        _textArea(
          'Action Taken *',
          (v) => _actionTaken = v ?? _actionTaken,
          hint: 'What immediate action was taken?',
          initial: _actionTaken,
        ),
        SizedBox(height: isMobile ? 16 : 20),
        
        // Person Responsible - only for admins
        if (UserSession.isAdmin) ...[
          FutureBuilder<List<UserLite>>(
            future: _usersF,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final users = snapshot.data!;
              return _dropdown<int>(
                'Person Responsible',
                _personResponsibleId,
                users
                    .map((u) => DropdownMenuItem(
                          value: u.id,
                          child: Text(u.name),
                        ))
                    .toList(),
                (v) => setState(() => _personResponsibleId = v),
              );
            },
          ),
          SizedBox(height: isMobile ? 16 : 20),
        ],

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
        
        // Card Status - only for admins
        if (UserSession.isAdmin) ...[
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Card Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Close Card checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _cardStatus == 'Closed',
                      onChanged: (bool? value) {
                        setState(() {
                          // Toggle between 'Closed' and the original non-Closed status
                          if (value == true) {
                            _cardStatus = 'Closed';
                          } else {
                            // When unchecking, return to Open or Submitted (whichever it was before)
                            _cardStatus = widget.card.status == 'Closed' ? 'Open' : widget.card.status;
                          }
                        });
                      },
                      activeColor: const Color(0xFF16A34A),
                    ),
                    const Expanded(
                      child: Text(
                        'Close the Card',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
        ],
        
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
    bool showError, // Add this parameter
  ) {
    final isSelected = _safetyStatus == value;
    
    return InkWell(
      onTap: () => setState(() {
        _safetyStatus = value;
        _safetyStatusError = false; // Clear error on selection
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
                  backgroundColor: AppColors.primary,
                ),
                onPressed: _nextPanel,
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
                  backgroundColor: AppColors.primary,
                ),
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Update Record'),
              ),
            ),
          if (_currentPanel > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: _previousPanel,
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
            onPressed: _previousPanel,
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
            onPressed: _nextPanel,
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
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Update Record'),
          ),
      ],
    );
  }

  Widget _text(
    String label,
    FormFieldSetter<String?> onSaved, {
    String? initial,
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
    );
  }

  Widget _textArea(
    String label,
    FormFieldSetter<String?> onSaved, {
    String? hint,
    String? initial,
  }) {
    return TextFormField(
      initialValue: initial,
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