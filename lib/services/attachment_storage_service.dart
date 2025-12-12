import 'dart:convert';
import 'dart:indexed_db' as idb;
import 'dart:html' as html;

/// Service to store and retrieve attachments using browser's IndexedDB
class AttachmentStorageService {
  static const String _dbName = 'signoff_attachments';
  static const String _storeName = 'attachments';
  static const int _dbVersion = 1;

  // Singleton
  static final AttachmentStorageService _instance = AttachmentStorageService._internal();
  factory AttachmentStorageService() => _instance;
  AttachmentStorageService._internal();

  idb.Database? _db;

  /// Initialize the IndexedDB database
  Future<void> init() async {
    if (_db != null) return; // Already initialized

    try {
      final window = html.window;
      if (window.indexedDB == null) {
        print('⚠️ IndexedDB not supported in this browser');
        return;
      }

      _db = await window.indexedDB!.open(_dbName, version: _dbVersion,
        onUpgradeNeeded: (e) {
          final db = e.target.result as idb.Database;
          if (!db.objectStoreNames!.contains(_storeName)) {
            db.createObjectStore(_storeName, keyPath: 'cardId');
          }
        }
      );
      
      print('✅ AttachmentStorage initialized');
    } catch (e) {
      print('⚠️ Error initializing AttachmentStorage: $e');
    }
  }

  /// Save attachments for a SignOff card
  Future<void> saveAttachments(String cardId, List<Map<String, dynamic>> attachments) async {
    await init();
    if (_db == null) return;

    try {
      final transaction = _db!.transaction(_storeName, 'readwrite');
      final store = transaction.objectStore(_storeName);
      
      final data = {
        'cardId': cardId,
        'attachments': json.encode(attachments),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await store.put(data);
      print('📎 Saved ${attachments.length} attachments for card $cardId to IndexedDB');
    } catch (e) {
      print('⚠️ Error saving attachments: $e');
    }
  }

  /// Retrieve attachments for a SignOff card
  Future<List<Map<String, dynamic>>> getAttachments(String cardId) async {
    await init();
    if (_db == null) return [];

    try {
      final transaction = _db!.transaction(_storeName, 'readonly');
      final store = transaction.objectStore(_storeName);
      final result = await store.getObject(cardId);
      
      if (result != null && result is Map) {
        final attachmentsJson = result['attachments'] as String?;
        if (attachmentsJson != null && attachmentsJson.isNotEmpty) {
          final decoded = json.decode(attachmentsJson);
          if (decoded is List) {
            print('📎 Retrieved ${decoded.length} attachments for card $cardId from IndexedDB');
            return List<Map<String, dynamic>>.from(decoded);
          }
        }
      }
      
      return [];
    } catch (e) {
      print('⚠️ Error retrieving attachments: $e');
      return [];
    }
  }

  /// Delete attachments for a SignOff card
  Future<void> deleteAttachments(String cardId) async {
    await init();
    if (_db == null) return;

    try {
      final transaction = _db!.transaction(_storeName, 'readwrite');
      final store = transaction.objectStore(_storeName);
      await store.delete(cardId);
      print('🗑️ Deleted attachments for card $cardId');
    } catch (e) {
      print('⚠️ Error deleting attachments: $e');
    }
  }

  /// Clear all stored attachments
  Future<void> clearAll() async {
    await init();
    if (_db == null) return;

    try {
      final transaction = _db!.transaction(_storeName, 'readwrite');
      final store = transaction.objectStore(_storeName);
      await store.clear();
      print('🗑️ Cleared all attachments from IndexedDB');
    } catch (e) {
      print('⚠️ Error clearing attachments: $e');
    }
  }
}
