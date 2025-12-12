// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'dart:convert';
// import 'dart:async';

// import 'package:safety_card_web/data/app_database.dart';

// class ImageService {
//   static const String baseUrl = 'https://clickpad.cloud/api/SafetyCardImages';
  
//   // Timeout configurations
//   static const Duration uploadTimeout = Duration(seconds: 60);
//   static const Duration downloadTimeout = Duration(seconds: 30);
  
//   /// Upload images for a safety card using multipart/form-data
//   /// Uses 'files' field name to match your mobile app API
//   static Future<bool> uploadImages(String cardUuid, List<Uint8List> images) async {
//     try {
//       print('📤 Uploading ${images.length} images for card: $cardUuid');
      
//       final uri = Uri.parse('$baseUrl/$cardUuid');
//       final request = http.MultipartRequest('POST', uri);
      
//       // Add each image as a multipart file
//       for (int i = 0; i < images.length; i++) {
//         final image = images[i];
//         print('Image ${i + 1} size: ${image.length} bytes');

//         if (image.isEmpty) {
//           print('⚠️ Warning: Image ${i + 1} is empty!');
//           continue;
//         }
        
//         // Determine content type (default to JPEG for safety cards)
//         final contentType = MediaType('image', 'jpeg');
        
//         // Create multipart file from bytes
//         final multipartFile = http.MultipartFile.fromBytes(
//           'files',  // ✅ Match your mobile app - uses 'files' not 'file'
//           image,
//           filename: 'safety_card_image_${i + 1}.jpg',
//           contentType: contentType,
//         );
        
//         request.files.add(multipartFile);
//         print('Added image ${i + 1} to request with filename: safety_card_image_${i + 1}.jpg');
//       }
      
//       print('Sending request to: $uri');
//       print('Total files in request: ${request.files.length}');
      
//       // Send the request with timeout
//       final streamedResponse = await request.send().timeout(
//         uploadTimeout,
//         onTimeout: () {
//           throw TimeoutException('Image upload timed out after ${uploadTimeout.inSeconds} seconds');
//         },
//       );
      
//       // Get the response
//       final response = await http.Response.fromStream(streamedResponse);
      
//       print('Upload response status: ${response.statusCode}');
//       print('Upload response body: ${response.body}');
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print('✅ Successfully uploaded all ${images.length} images');
//         return true;
//       } else {
//         print('❌ Failed to upload images: ${response.statusCode} - ${response.body}');
//         return false;
//       }
//     } catch (e, stackTrace) {
//       print('❌ Error uploading images: $e');
//       print('Stack trace: $stackTrace');
//       return false;
//     }
//   }

//   Future<void> _uploadCardImages(SafetyCard card) async {
//     try {
//       final images = <Uint8List>[];
      
//       // Add primary image if exists
//       if (card.imageData != null) {
//         images.add(card.imageData!);
//       }
      
//       // ✅ FIXED: Properly decode base64 strings from imageListBase64
//       if (card.imageListBase64 != null && card.imageListBase64!.isNotEmpty) {
//         final imageStrings = card.imageListBase64!.split('|||');
//         for (var imgStr in imageStrings) {
//           if (imgStr.isNotEmpty) {
//             try {
//               // ✅ Decode base64 string properly
//               images.add(base64Decode(imgStr));
//             } catch (e) {
//               print('⚠️ Failed to decode image from base64: $e');
//             }
//           }
//         }
//       }
      
//       if (images.isNotEmpty) {
//         print('📤 Uploading ${images.length} images for card ${card.uuid}');
//         final uploaded = await ImageService.uploadImages(card.uuid, images);
//         if (uploaded) {
//           print('✅ Images uploaded successfully for card ${card.uuid}');
//         } else {
//           print('⚠️ Failed to upload some images for card ${card.uuid}');
//         }
//       }
//     } catch (e) {
//       print('❌ Error uploading images for card ${card.uuid}: $e');
//     }
//   }
  
//   /// Download all images for a safety card
//   static Future<List<Uint8List>> downloadImages(String cardUuid) async {
//     try {
//       print('📥 Downloading images for card: $cardUuid');
      
//       final uri = Uri.parse('$baseUrl/by-plant/$cardUuid');
//       final response = await http.get(uri).timeout(
//         downloadTimeout,
//         onTimeout: () {
//           throw TimeoutException('Get images request timed out');
//         },
//       );
      
//       if (response.statusCode == 404) {
//         print('ℹ️ No images found for card: $cardUuid');
//         return [];
//       }
      
//       if (response.statusCode == 200) {
//         final responseBody = response.body;
        
//         if (responseBody.isEmpty || responseBody == '[]') {
//           print('ℹ️ Empty image list for card: $cardUuid');
//           return [];
//         }
        
//         final List<dynamic> imagesJson = json.decode(responseBody);
//         print('📷 Found ${imagesJson.length} image URLs');
        
//         // ✅ Return empty list - we'll use URLs directly in UI instead
//         print('ℹ️ Returning image metadata for URL-based rendering');
//         return [];
//       }
      
//       return [];
//     } catch (e, stackTrace) {
//       print('❌ Error downloading images: $e');
//       return [];
//     }
//   }

//   /// NEW METHOD: Get image URLs instead of downloading
//   static Future<List<String>> getImageUrls(String cardUuid) async {
//     try {
//       final uri = Uri.parse('$baseUrl/by-plant/$cardUuid');
//       final response = await http.get(uri).timeout(downloadTimeout);
      
//       if (response.statusCode == 200) {
//         final List<dynamic> imagesJson = json.decode(response.body);
//         return imagesJson
//             .map((img) => img['url'] as String)
//             .where((url) => url.isNotEmpty)
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       print('❌ Error getting image URLs: $e');
//       return [];
//     }
//   }


//   /// Download a specific image by ID
//   static Future<Uint8List?> downloadImageById(String imageId) async {
//     try {
//       print('📥 Downloading image: $imageId');
      
//       final uri = Uri.parse('$baseUrl/$imageId');
//       final response = await http.get(uri).timeout(
//         downloadTimeout,
//         onTimeout: () {
//           throw TimeoutException('Get image request timed out after ${downloadTimeout.inSeconds} seconds');
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final imageJson = json.decode(response.body);
//         final imageUrl = imageJson['url'] as String?;
        
//         if (imageUrl != null && imageUrl.isNotEmpty) {
//           print('📥 Downloading image from URL: $imageUrl');
//           final imageResponse = await http.get(Uri.parse(imageUrl)).timeout(
//             downloadTimeout,
//             onTimeout: () {
//               throw TimeoutException('Image download timed out');
//             },
//           );
          
//           if (imageResponse.statusCode == 200) {
//             print('✅ Downloaded image successfully');
//             return imageResponse.bodyBytes;
//           }
//         }
//       }
      
//       print('⚠️ Image not found or error: ${response.statusCode}');
//       return null;
//     } catch (e) {
//       print('❌ Error downloading image: $e');
//       return null;
//     }
//   }
  
//   /// Delete all images for a card
//   static Future<bool> deleteImagesForCard(String cardUuid) async {
//     try {
//       print('🗑️ Deleting images for card: $cardUuid');
      
//       // First get all images
//       final uri = Uri.parse('$baseUrl/by-plant/$cardUuid');
//       final response = await http.delete(uri).timeout(
//         downloadTimeout,
//         onTimeout: () {
//           throw TimeoutException('Delete images request timed out');
//         },
//       );
//       print('Delete response status: ${response.statusCode}');
//       print('Delete response body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404) {
//         final List<dynamic> imagesJson = json.decode(response.body);
        
//         // Delete each image
//         for (var imageData in imagesJson) {
//           final imageId = imageData['id']?.toString();
//           if (imageId != null) {
//             final deleteUri = Uri.parse('https://clickpad.cloud/api/SafetyCardImages/$cardUuid');
//             await http.delete(deleteUri).timeout(
//               downloadTimeout,
//               onTimeout: () {
//                 throw TimeoutException('Delete image request timed out');
//               },
//             );
//             print('Deleted image: $imageId');
//           }
//         }
        
//         print('✅ Deleted all images for card: $cardUuid');
//         return true;
//       } else if (response.statusCode == 404) {
//         // No images to delete
//         print('ℹ️ No images to delete for card: $cardUuid');
//         return true;
//       }
      
//       return true;
//     } catch (e) {
//       print('❌ Error deleting images: $e');
//       return false;
//     }
//   }
  
// //   /// Delete a single image by ID
// //   static Future<bool> deleteImage(String imageId) async {
// //     try {
// //       final uri = Uri.parse('$baseUrl/$imageId');
// //       final response = await http.delete(uri).timeout(
// //         downloadTimeout,
// //         onTimeout: () {
// //           throw TimeoutException('Delete image request timed out');
// //         },
// //       );
      
// //       if (response.statusCode == 200 || response.statusCode == 204) {
// //         print('✅ Deleted image: $imageId');
// //         return true;
// //       } else {
// //         print('❌ Failed to delete image: ${response.statusCode}');
// //         return false;
// //       }
// //     } catch (e) {
// //       print('❌ Error deleting image: $e');
// //       return false;
// //     }
// //   }
// // }
// /// Delete a single image by ID
// static Future<bool> deleteImage(String imageId) async {
//   try {
//     print('🗑️ Deleting single image: $imageId');
    
//     // ✅ Use the correct single image delete endpoint
//     final uri = Uri.parse('https://clickpad.cloud/api/SafetyCardImages/$imageId');
    
//     final response = await http.delete(uri).timeout(
//       downloadTimeout,
//       onTimeout: () {
//         throw TimeoutException('Delete image request timed out');
//       },
//     );
    
//     print('Delete response status: ${response.statusCode}');
    
//     if (response.statusCode == 200 || response.statusCode == 204) {
//       print('✅ Successfully deleted image: $imageId');
//       return true;
//     } else {
//       print('❌ Failed to delete image: ${response.statusCode}');
//       return false;
//     }
//   } catch (e) {
//     print('❌ Error deleting image: $e');
//     return false;
//   }
// }

// /// NEW METHOD: Extract image ID from URL
// static String? extractImageIdFromUrl(String imageUrl) {
//   try {
//     // Assuming URL format: https://clickpad.cloud/api/SafetyCardImages/{id}
//     // or https://storage.../images/{id}.jpg
//     final uri = Uri.parse(imageUrl);
//     final segments = uri.pathSegments;
    
//     if (segments.isNotEmpty) {
//       // Get last segment and remove query parameters and file extension
//       final lastSegment = segments.last.split('?').first.split('.').first;
//       return lastSegment;
//     }
//   } catch (e) {
//     print('❌ Error extracting image ID from URL: $e');
//   }
//   return null;
// }
// }
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:async';

import 'package:safety_card_web/data/app_database.dart';

class ImageService {
  static const String baseUrl = 'https://clickpad.cloud/api/SafetyCardImages';
  
  // Timeout configurations
  static const Duration uploadTimeout = Duration(seconds: 60);
  static const Duration downloadTimeout = Duration(seconds: 30);
  
  /// Upload images for a safety card using multipart/form-data
  static Future<bool> uploadImages(String cardUuid, List<Uint8List> images) async {
    try {
      print('📤 Uploading ${images.length} images for card: $cardUuid');
      
      final uri = Uri.parse('$baseUrl/$cardUuid');
      final request = http.MultipartRequest('POST', uri);
      
      // Add each image as a multipart file
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        print('Image ${i + 1} size: ${image.length} bytes');

        if (image.isEmpty) {
          print('⚠️ Warning: Image ${i + 1} is empty!');
          continue;
        }
        
        final contentType = MediaType('image', 'jpeg');
        
        final multipartFile = http.MultipartFile.fromBytes(
          'files',
          image,
          filename: 'safety_card_image_${i + 1}.jpg',
          contentType: contentType,
        );
        
        request.files.add(multipartFile);
        print('Added image ${i + 1} to request with filename: safety_card_image_${i + 1}.jpg');
      }
      
      print('Sending request to: $uri');
      print('Total files in request: ${request.files.length}');
      
      final streamedResponse = await request.send().timeout(
        uploadTimeout,
        onTimeout: () {
          throw TimeoutException('Image upload timed out after ${uploadTimeout.inSeconds} seconds');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Successfully uploaded all ${images.length} images');
        return true;
      } else {
        print('❌ Failed to upload images: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Error uploading images: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get image URLs instead of downloading
  static Future<List<String>> getImageUrls(String cardUuid) async {
    try {
      final uri = Uri.parse('$baseUrl/by-plant/$cardUuid');
      final response = await http.get(uri).timeout(downloadTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> imagesJson = json.decode(response.body);
        return imagesJson
            .map((img) => img['url'] as String)
            .where((url) => url.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting image URLs: $e');
      return [];
    }
  }

  /// Download a specific image by ID
  static Future<Uint8List?> downloadImageById(String imageId) async {
    try {
      print('📥 Downloading image: $imageId');
      
      final uri = Uri.parse('$baseUrl/$imageId');
      final response = await http.get(uri).timeout(
        downloadTimeout,
        onTimeout: () {
          throw TimeoutException('Get image request timed out after ${downloadTimeout.inSeconds} seconds');
        },
      );
      
      if (response.statusCode == 200) {
        final imageJson = json.decode(response.body);
        final imageUrl = imageJson['url'] as String?;
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          print('📥 Downloading image from URL: $imageUrl');
          final imageResponse = await http.get(Uri.parse(imageUrl)).timeout(
            downloadTimeout,
            onTimeout: () {
              throw TimeoutException('Image download timed out');
            },
          );
          
          if (imageResponse.statusCode == 200) {
            print('✅ Downloaded image successfully');
            return imageResponse.bodyBytes;
          }
        }
      }
      
      print('⚠️ Image not found or error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error downloading image: $e');
      return null;
    }
  }
  
  /// Delete all images for a card using the bulk delete endpoint
  static Future<bool> deleteImagesForCard(String cardUuid) async {
    try {
      print('🗑️ Deleting all images for card: $cardUuid');
      
      // ✅ Use the correct bulk delete endpoint
      final uri = Uri.parse('$baseUrl/by-plant/$cardUuid');
      
      final response = await http.delete(uri).timeout(
        downloadTimeout,
        onTimeout: () {
          throw TimeoutException('Delete images request timed out');
        },
      );
      
      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404) {
        // 200/204 = success, 404 = no images to delete (also success)
        print('✅ Successfully deleted all images for card: $cardUuid');
        return true;
      } else {
        print('⚠️ Unexpected response when deleting images: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting images: $e');
      return false;
    }
  }
  
  /// Delete a single image by ID
  static Future<bool> deleteImage(String imageId) async {
    try {
      print('🗑️ Deleting single image: $imageId');
      
      // ✅ Use the correct single image delete endpoint
      final uri = Uri.parse('$baseUrl/$imageId');
      
      final response = await http.delete(uri).timeout(
        downloadTimeout,
        onTimeout: () {
          throw TimeoutException('Delete image request timed out');
        },
      );
      
      print('Delete response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully deleted image: $imageId');
        return true;
      } else {
        print('❌ Failed to delete image: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// ✅ NEW: Extract image ID from URL
  static String? extractImageIdFromUrl(String imageUrl) {
    try {
      // Handle different URL formats:
      // 1. https://clickpad.cloud/api/SafetyCardImages/{id}
      // 2. https://storage.../images/{id}.jpg
      // 3. https://cdn.../uploads/{id}?query=params
      
      final uri = Uri.parse(imageUrl);
      
      // Try to extract from path segments
      if (uri.pathSegments.isNotEmpty) {
        // Get last segment and remove query parameters and file extension
        String lastSegment = uri.pathSegments.last;
        
        // Remove query parameters
        lastSegment = lastSegment.split('?').first;
        
        // Remove file extension
        lastSegment = lastSegment.split('.').first;
        
        // If it looks like a valid ID, return it
        if (lastSegment.isNotEmpty) {
          print('✅ Extracted image ID: $lastSegment from URL: $imageUrl');
          return lastSegment;
        }
      }
      
      print('⚠️ Could not extract image ID from URL: $imageUrl');
    } catch (e) {
      print('❌ Error extracting image ID from URL: $e');
    }
    return null;
  }

  /// ✅ NEW: Get full image details including ID
  static Future<List<Map<String, String>>> getImageDetails(String cardUuid) async {
    try {
      final uri = Uri.parse('$baseUrl/by-plant/$cardUuid');
      final response = await http.get(uri).timeout(downloadTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> imagesJson = json.decode(response.body);
        return imagesJson.map((img) {
          return {
            'id': img['id']?.toString() ?? '',
            'url': img['url']?.toString() ?? '',
          };
        }).where((img) => img['id']!.isNotEmpty && img['url']!.isNotEmpty)
        .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting image details: $e');
      return [];
    }
  }
}