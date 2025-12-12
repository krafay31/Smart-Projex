// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/app_database.dart';
import '../main.dart';
import 'image_service.dart';

class SyncService {
  static const String _baseApiUrl = 'https://clickpad.cloud/api/safety-cards';
  static const String _filterApiUrl = 'https://clickpad.cloud/api/safety-cards/filter';
  
  static String _getCardsUrl({int pageNumber = 1, int pageSize = 500}) {
    final email = UserSession.userEmail ?? '';
    final isAdmin = UserSession.isAdmin;
    return '$_baseApiUrl?email=$email&isAdmin=$isAdmin&deviceType=0&pageNumber=$pageNumber&pageSize=$pageSize';
  }

  static String _getCardUrl(String uuid) {
    return '$_baseApiUrl/$uuid';
  }
  
  // Singleton pattern
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _periodicSyncTimer;
  bool _isOnline = false;
  
  // Track sync status for UI updates
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// Initialize connectivity monitoring
  void initialize() {
    print('Initializing SyncService...');
    
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      print('Connectivity changed: $result');
      
      final isConnected = result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.mobile;
      
      if (isConnected) {
        print('Connected to internet, triggering sync');
        _isOnline = true;
        syncSitesAndLocations();
      } else {
        print('No internet connection detected');
        _isOnline = false;
        _syncStatusController.add(SyncStatus.offline);
      }
    });
    
    _checkInitialConnectivity();
    
    // Periodic sync every 30 minutes
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) {
        print('Periodic sync triggered');
        syncSitesAndLocations();
      },
    );
  }

  /// Check initial connectivity on startup
  Future<void> _checkInitialConnectivity() async {
    try {
      print('Checking initial connectivity...');
      final result = await _connectivity.checkConnectivity();
      print('Initial connectivity result: $result');
      
      final isConnected = result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.mobile;
      
      _isOnline = isConnected;
      
      if (isConnected) {
        print('Initial connectivity check: Online - triggering sync');
        Future.delayed(const Duration(milliseconds: 500), () async {
          await syncSitesAndLocations();
        });
      } else {
        print('Initial connectivity check: Offline');
        _syncStatusController.add(SyncStatus.offline);
      }
    } catch (e) {
      print('Error checking initial connectivity: $e');
      _isOnline = false;
      _syncStatusController.add(SyncStatus.offline);
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
  }

  /// Check if device is online by pinging the API
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasNetworkConnection = connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.ethernet ||
          connectivityResult == ConnectivityResult.mobile;
      
      if (!hasNetworkConnection) {
        print('No network connection available');
        return false;
      }
      
      print('Network connection available');
      return true;
      
    } catch (e) {
      print('isOnline check failed with error: $e');
      return false;
    }
  }


Future<FilteredCardsResult> fetchFilteredCards({
  int pageNumber = 1,
  int pageSize = 50,
  DateTime? dateFrom,
  DateTime? dateTo,
  String? keyRiskConditionHexId,
  String? siteUuid,
  String? locationUuid,
  String? raisedByName,
  String? cardStatus,
  String? safetyStatus,
  // 🆕 REMOVED: sortBy and sortAscending parameters
}) async {
  try {
    if (!await isOnline()) {
      print('❌ Device is offline, cannot fetch filtered cards');
      return FilteredCardsResult(
        cards: [],
        totalCount: 0,
        totalPages: 0,
        currentPage: pageNumber,
      );
    }

    print('📥 Fetching filtered cards from server...');
    print('   - Page: $pageNumber, Size: $pageSize');
    
    final requestBody = <String, dynamic>{
      'email': UserSession.userEmail ?? '',
      'isAdmin': UserSession.isAdmin,
      'deviceType': 0,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    
    // Only add filters if they have actual values
    if (dateFrom != null && dateFrom.millisecondsSinceEpoch > 0) {
      requestBody['dateFrom'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      requestBody['dateTo'] = dateTo.toIso8601String();
    }
    if (keyRiskConditionHexId != null && keyRiskConditionHexId.isNotEmpty) {
      requestBody['keyRiskCondition'] = keyRiskConditionHexId;
    }
    if (siteUuid != null && siteUuid.isNotEmpty) {
      requestBody['siteId'] = siteUuid;
    }
    if (locationUuid != null && locationUuid.isNotEmpty) {
      requestBody['locationId'] = locationUuid;
    }
    if (raisedByName != null && raisedByName.isNotEmpty) {
      requestBody['raisedBy'] = raisedByName;
    }
    if (cardStatus != null && cardStatus.isNotEmpty) {
      requestBody['cardStatus'] = cardStatus;
    }
    if (safetyStatus != null && safetyStatus.isNotEmpty) {
      requestBody['safetyStatus'] = safetyStatus;
    }
    // 🆕 REMOVED: sortBy and sortAscending from requestBody

    print('Request body: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse(_filterApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    ).timeout(const Duration(seconds: 60));

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      
      if (data is Map && data.containsKey('data')) {
        final listData = data['data'] as List;
        final pageCards = listData.cast<Map<String, dynamic>>();
        
        final totalPages = data['totalPages'] ?? 1;
        final totalCount = data['totalCount'] ?? pageCards.length;
        
        print('Filtered cards: ${pageCards.length} cards (total: $totalCount, pages: $totalPages)');
        
        // ✅ FIXED: Return fresh server data directly, not local DB cards
        // Convert API cards to SafetyCard objects on-the-fly
        final freshCards = <SafetyCard>[];
        for (var apiCard in pageCards) {
          try {
            final cardUuid = apiCard['id']?.toString() ?? '';
            
            // ✅ Check if card exists locally by UUID
            final existingCard = await (db.select(db.safetyCards)
              ..where((c) => c.uuid.equals(cardUuid))).getSingleOrNull();
            
            SafetyCard card;
            if (existingCard == null) {
              // Create new card in local DB
              final companion = await _apiCardToCompanion(apiCard);
              final id = await db.createSafetyCard(companion);
              card = (await db.safetyCardById(id))!;
              // print('Created new card locally: $cardUuid'); // Removed for security
            } else {
              // ✅ Update existing card using its ID
              final companion = await _apiCardToCompanion(apiCard);
              await (db.update(db.safetyCards)..where((c) => c.id.equals(existingCard.id)))
                .write(companion);
              card = (await db.safetyCardById(existingCard.id))!;
              // print('Updated existing card: $cardUuid'); // Removed for security
            }
            
            freshCards.add(card);
          } catch (e) {
            print('Error processing card: $e');
          }
        }
        
        return FilteredCardsResult(
          cards: freshCards,  // ✅ Return fresh server data
          totalCount: totalCount,
          totalPages: totalPages,
          currentPage: pageNumber,
        );
      }
    }
    
    print('Failed to fetch filtered cards: ${response.statusCode}');
    return FilteredCardsResult(
      cards: [],
      totalCount: 0,
      totalPages: 0,
      currentPage: pageNumber,
    );
    
  } catch (e) {
    print('Error fetching filtered cards: $e');
    return FilteredCardsResult(
      cards: [],
      totalCount: 0,
      totalPages: 0,
      currentPage: pageNumber,
    );
  }
}


  /// Sync all pending changes - NOW WITH PROGRESSIVE PAGE LOADING AND ALL TABLES
  Future<SyncResult> syncAll({int? specificPage, int pageSize = 50}) async {
    if (_isSyncing) {
      print('Sync already in progress, skipping');
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    print('');
    print('=== COMPREHENSIVE SYNC STARTED ${specificPage != null ? "(Page $specificPage)" : "(All Tables)"} ===');
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    int created = 0, updated = 0, deleted = 0, failed = 0;

    try {
      if (!_isOnline) {
        print('Device is offline (cached status), aborting sync');
        _syncStatusController.add(SyncStatus.offline);
        return SyncResult(success: false, message: 'Device is offline');
      }

      print('Device online, proceeding with comprehensive sync');

      // ✅ NEW: Step 1 - Sync Sites
      print('📥 Step 1: Syncing Sites from API...');
      try {
        final sitesData = await fetchSitesFromApi();
        await db.syncSitesFromApi(sitesData);
        print('✅ Synced ${sitesData.length} sites');
      } catch (e) {
        print('⚠️ Failed to sync sites: $e');
      }

      // ✅ NEW: Step 2 - Sync Locations
      print('📥 Step 2: Syncing Locations from API...');
      try {
        final locationsData = await fetchLocationsFromApi();
        await db.syncLocationsFromApi(locationsData);
        print('✅ Synced ${locationsData.length} locations');
      } catch (e) {
        print('⚠️ Failed to sync locations: $e');
      }

      // ✅ NEW: Step 3 - Sync Key Risk Conditions
      print('📥 Step 3: Syncing Key Risk Conditions from API...');
      try {
        final krcData = await fetchKrcFromApi();
        await db.syncKrcFromApi(krcData);
        print('✅ Synced ${krcData.length} Key Risk Conditions');
      } catch (e) {
        print('⚠️ Failed to sync KRC: $e');
      }

      // ✅ NEW: Step 4 - Sync Users
      print('📥 Step 4: Syncing Users from API...');
      try {
        final usersData = await fetchUsersFromApi();
        await db.syncUsersFromApi(usersData);
        print('✅ Synced ${usersData.length} users');
      } catch (e) {
        print('⚠️ Failed to sync users: $e');
      }

      // Step 5: Fetching safety cards from API...
      print('📥 Step 5: Syncing Safety Cards from API...');
      List<Map<String, dynamic>> apiCards;
      
      if (specificPage != null) {
        print('📥 Fetching page $specificPage (pageSize: $pageSize)...');
        apiCards = await _fetchPageFromApi(specificPage, pageSize);
        print('Fetched ${apiCards.length} cards from page $specificPage');
      } else {
        print('📥 Fetching all cards...');
        apiCards = await _fetchAllFromApi();
        print('Fetched ${apiCards.length} cards from API');
      }
      
      final apiCardMap = <String, Map<String, dynamic>>{};
      final apiCardUuids = <String>{};
      for (var card in apiCards) {
        final uuid = card['id']?.toString();
        if (uuid != null) {
          apiCardMap[uuid] = card;
          apiCardUuids.add(uuid);
        }
      }

      print('Step 6: Getting local cards...');
      final localCards = await db.allSafetyCards();
      print('Found ${localCards.length} local cards');
      
      final localCardMap = <String, SafetyCard>{};
      for (var card in localCards) {
        localCardMap[card.uuid] = card;
      }

      if (specificPage == null) {
        print('Step 7: Removing cards deleted from server...');
        final cardsToDeleteLocally = <SafetyCard>[];
        
        for (var localCard in localCards) {
          if (!apiCardUuids.contains(localCard.uuid)) {
            cardsToDeleteLocally.add(localCard);
          }
        }
        
        for (var card in cardsToDeleteLocally) {
          try {
            await db.deleteCard(card.id);
            deleted++;
            print('Deleted card ${card.id} (UUID: ${card.uuid}) from local DB');
          } catch (e) {
            failed++;
            print('Failed to delete card ${card.id}: $e');
          }
        }
      } else {
        print('Step 7: Skipping deletion check (page-specific sync)');
      }

      print('Step 8: Refreshing local cards list...');
      final updatedLocalCards = await db.allSafetyCards();
      final updatedLocalCardMap = <String, SafetyCard>{};
      for (var card in updatedLocalCards) {
        updatedLocalCardMap[card.uuid] = card;
      }
      print('Now have ${updatedLocalCards.length} local cards');

      if (specificPage == null) {
        print('Step 9: Syncing remaining local cards to API...');
        
        final cardsToCreate = <SafetyCard>[];
        final cardsToUpdate = <SafetyCard>[];
        
        for (var localCard in updatedLocalCards) {
          if (apiCardUuids.contains(localCard.uuid)) {
            cardsToUpdate.add(localCard);
          } else {
            cardsToCreate.add(localCard);
          }
        }
        
        if (cardsToCreate.isNotEmpty) {
          print('Creating ${cardsToCreate.length} new cards on server...');
          for (var card in cardsToCreate) {
            try {
              await _batchCreateCardsToApi([card]);
              created++;
              await _uploadCardImages(card);
            } catch (e) {
              failed++;
              print('Failed to create card ${card.id}: $e');
            }
          }
        }
        
        if (cardsToUpdate.isNotEmpty) {
          print('Updating ${cardsToUpdate.length} existing cards on server...');
          for (var card in cardsToUpdate) {
            try {
              await _updateCardToApi(card);
              updated++;
              await _uploadCardImages(card);
            } catch (e) {
              failed++;
              print('Failed to update card ${card.id}: $e');
            }
          }
        }
      } else {
        print('Step 9: Skipping local-to-server sync (page-specific sync)');
      }

      print('Step 10: Pulling cards from server...');
      for (var apiCard in apiCards) {
        final apiUuid = apiCard['id']?.toString();
        if (apiUuid != null) {
          final existingCard = updatedLocalCardMap[apiUuid];
          
          if (existingCard == null) {
            // Card doesn't exist locally, create it
            try {
              await _createCardFromApi(apiCard);
              created++;
              print('Pulled new card (UUID: $apiUuid) from server');
            } catch (e) {
              failed++;
              print('Failed to pull card (UUID: $apiUuid) from server: $e');
            }
          } else {
            // ✅ FIXED: Card exists locally, UPDATE it with server data
            try {
              final companion = await _apiCardToCompanion(apiCard);
              // ✅ Use update() with existing card ID instead of insertOnConflictUpdate
              await (db.update(db.safetyCards)..where((c) => c.id.equals(existingCard.id)))
                .write(companion);
              updated++;
              print('Updated existing card (UUID: $apiUuid) with server data');
            } catch (e) {
              failed++;
              print('Failed to update card (UUID: $apiUuid) from server: $e');
            }
          }
        }
      }

      _lastSyncTime = DateTime.now();
      _syncStatusController.add(SyncStatus.synced);
      
      final message = specificPage != null
          ? 'Page $specificPage synced: $created new cards loaded'
          : 'All tables synced successfully - Sites, Locations, KRC, Users, and $created new cards';
      print('');
      print('$message');
      print('=== COMPREHENSIVE SYNC COMPLETED ===');
      print('');
      
      return SyncResult(
        success: true,
        message: message,
        created: created,
        updated: updated,
        deleted: deleted,
        failed: failed,
      );
    } catch (e, stackTrace) {
      print('');
      print('Sync error: $e');
      print('Stack trace: $stackTrace');
      print('=== SYNC FAILED ===');
      print('');
      
      _syncStatusController.add(SyncStatus.error);
      return SyncResult(success: false, message: 'Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPageFromApi(int pageNumber, int pageSize) async {
    try {
      print('📥 Fetching page $pageNumber (size: $pageSize) from API...');
      
      final response = await http.get(
        Uri.parse(_getCardsUrl(pageNumber: pageNumber, pageSize: pageSize)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        if (data is Map && data.containsKey('data')) {
          final listData = data['data'] as List;
          final pageCards = listData.cast<Map<String, dynamic>>();
          
          final totalPages = data['totalPages'] ?? 1;
          final totalCount = data['totalCount'] ?? pageCards.length;
          
          print('✅ Page $pageNumber: ${pageCards.length} cards (total in db: $totalCount, total pages: $totalPages)');
          
          return pageCards;
        } else {
          print('❌ Unexpected response format for page $pageNumber');
          return [];
        }
      } else {
        print('❌ HTTP Error on page $pageNumber: ${response.statusCode}');
        throw Exception('Failed to fetch page: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ _fetchPageFromApi error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Create a safety card (offline-first)
  Future<int> createCard(SafetyCardsCompanion card) async {
    final id = await db.createSafetyCard(card);
    print('Created card locally with id: $id');
    
    if (_isOnline && await isOnline()) {
      try {
        final savedCard = await db.safetyCardById(id);
        if (savedCard != null) {
          await _batchCreateCardsToApi([savedCard]);
          print('Synced new card immediately');
          
          final images = <Uint8List>[];
          
          if (savedCard.imageListBase64 != null && savedCard.imageListBase64!.isNotEmpty) {
            final imageStrings = savedCard.imageListBase64!.split('|||');
            for (var imgStr in imageStrings) {
              if (imgStr.isNotEmpty) {
                try {
                  images.add(base64Decode(imgStr));
                } catch (e) {
                  print('⚠️ Failed to decode image: $e');
                }
              }
            }
          }
                    
          if (images.isNotEmpty) {
            await ImageService.uploadImages(savedCard.uuid, images);
          }
        }
      } catch (e) {
        print('Failed to sync new card immediately: $e');
      }
    }
    
    return id;
  }

  /// Update a safety card (offline-first)
  Future<void> updateCard(SafetyCard card, {List<Uint8List>? newImages}) async {
    await db.updateSafetyCard(card);
    print('Updated card locally: ${card.id}');
    
    if (_isOnline && await isOnline()) {
      try {
        await _updateCardToApi(card, isEdited: true);
        print('Synced updated card immediately');
        
        // ✅ ONLY upload NEW images (don't delete or re-upload existing ones)
        if (newImages != null && newImages.isNotEmpty) {
          print('📤 Uploading ${newImages.length} new images');
          await ImageService.uploadImages(card.uuid, newImages);
        } else {
          print('📌 No new images to upload');
        }
      } catch (e) {
        print('Failed to sync updated card immediately: $e');
      }
    }
  }

  /// Delete a safety card (offline-first)
  Future<void> deleteCard(int id) async {
    final card = await db.safetyCardById(id);
    final cardUuid = card?.uuid;
    
    await db.deleteCard(id);
    print('Deleted card locally: $id');
    
    if (cardUuid != null && _isOnline && await isOnline()) {
      try {
        await ImageService.deleteImagesForCard(cardUuid);
        await _deleteCardFromApi(cardUuid);
        print('Synced deletion immediately');
      } catch (e) {
        print('Failed to sync deletion immediately: $e');
      }
    }
  }

  Future<void> closeCard(int id) async {
    final card = await db.safetyCardById(id);
    if (card == null) {
      print('Card not found: $id');
      return;
    }
    
    await db.closeCard(id);
    print('Closed card locally: $id');
    
    if (_isOnline && await isOnline()) {
      try {
        final updatedCard = await db.safetyCardById(id);
        if (updatedCard != null) {
          await _updateCardToApi(updatedCard);
          print('Synced closed card immediately');
        }
      } catch (e) {
        print('Failed to sync closed card immediately: $e');
      }
    }
  }

  Future<void> submitCard(int id) async {
    final card = await db.safetyCardById(id);
    if (card == null) {
      print('Card not found: $id');
      return;
    }
    
    await db.submitCard(id);
    print('Submitted card locally: $id');
    
    if (_isOnline && await isOnline()) {
      try {
        final updatedCard = await db.safetyCardById(id);
        if (updatedCard != null) {
          await _updateCardToApi(updatedCard);
          print('Synced submitted card immediately');
        }
      } catch (e) {
        print('Failed to sync submitted card immediately: $e');
      }
    }
  }

  /// Reopen a safety card (offline-first)
  Future<void> reopenCard(int id) async {
    final card = await db.safetyCardById(id);
    if (card == null) {
      print('Card not found: $id');
      return;
    }
    
    await db.reopenCard(id);
    print('Reopened card locally: $id');
    
    if (_isOnline && await isOnline()) {
      try {
        final updatedCard = await db.safetyCardById(id);
        if (updatedCard != null) {
          await _updateCardToApi(updatedCard);
          print('Synced reopened card immediately');
        }
      } catch (e) {
        print('Failed to sync reopened card immediately: $e');
      }
    }
  }

  // Private API methods
  
  Future<List<Map<String, dynamic>>> _fetchAllFromApi() async {
    try {
      print('📥 Fetching all cards with pagination for ${UserSession.userEmail} (Admin: ${UserSession.isAdmin})');
      
      List<Map<String, dynamic>> allCards = [];
      int currentPage = 1;
      int totalPages = 1;
      
      do {
        print('📄 Fetching page $currentPage of $totalPages...');
        
        final response = await http.get(
          Uri.parse(_getCardsUrl(pageNumber: currentPage, pageSize: 500)),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          
          if (data is Map && data.containsKey('data')) {
            final listData = data['data'] as List;
            final pageCards = listData.cast<Map<String, dynamic>>();
            allCards.addAll(pageCards);
            
            totalPages = data['totalPages'] ?? 1;
            final totalCount = data['totalCount'] ?? allCards.length;
            
            print('✅ Page $currentPage: ${pageCards.length} cards (total: ${allCards.length}/$totalCount)');
            
            currentPage++;
          } else {
            print('❌ Unexpected response format on page $currentPage');
            break;
          }
        } else {
          print('❌ HTTP Error on page $currentPage: ${response.statusCode}');
          throw Exception('Failed to fetch cards: ${response.statusCode}');
        }
      } while (currentPage <= totalPages);
      
      print('✅ Sync complete: Fetched all ${allCards.length} cards across ${totalPages} pages');
      return allCards;
      
    } catch (e) {
      print('_fetchAllFromApi error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Fetch all sites from API
  Future<List<Map<String, dynamic>>> fetchSitesFromApi() async {
    try {
      print('Fetching sites from API...');
      final response = await http.get(
        Uri.parse('https://clickpad.cloud/api/safety-sites'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Fetched ${data.length} sites from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch sites: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchSitesFromApi error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Fetch all locations from API
  Future<List<Map<String, dynamic>>> fetchLocationsFromApi() async {
    try {
      print('Fetching locations from API...');
      final response = await http.get(
        Uri.parse('https://clickpad.cloud/api/safety-locations'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Fetched ${data.length} locations from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch locations: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchLocationsFromApi error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Fetch locations by site UUID
  Future<List<Map<String, dynamic>>> fetchLocationsBySiteFromApi(String siteUuid) async {
    try {
      print('Fetching locations for site $siteUuid from API...');
      final response = await http.get(
        Uri.parse('https://clickpad.cloud/api/safety-locations/safety-site/$siteUuid'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Fetched ${data.length} locations for site $siteUuid from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch locations for site: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchLocationsBySiteFromApi error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// ✅ NEW: Fetch a single safety card by UUID from server
  Future<SafetyCard?> fetchCardByUuid(String uuid) async {
    try {
      print('📥 Fetching card by UUID from server: $uuid');
      
      if (!await isOnline()) {
        print('❌ Device is offline, cannot fetch card');
        return null;
      }
      
      final url = _getCardUrl(uuid);
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiCard = json.decode(response.body);
        print('✅ Fetched card from server: ${apiCard['id']}');
        
        // Convert API card to SafetyCardsCompanion and save to local DB
        final companion = await _apiCardToCompanion(apiCard);
        
        // Check if card exists locally
        final existingCard = await (db.select(db.safetyCards)
          ..where((c) => c.uuid.equals(uuid))).getSingleOrNull();
        
        if (existingCard == null) {
          // Create new card
          final id = await db.createSafetyCard(companion);
          final newCard = await db.safetyCardById(id);
          return newCard;
        } else {
          // ✅ Update existing card with fresh data using its ID
          await (db.update(db.safetyCards)..where((c) => c.id.equals(existingCard.id)))
            .write(companion);
          final updatedCard = await db.safetyCardById(existingCard.id);
          return updatedCard;
        }
      } else if (response.statusCode == 404) {
        print('⚠️ Card not found on server: $uuid');
        return null;
      } else {
        throw Exception('Failed to fetch card: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching card by UUID: $e');
      return null;
    }
  }

  /// ✅ NEW: Fetch all Key Risk Conditions from API
  Future<List<Map<String, dynamic>>> fetchKrcFromApi() async {
    try {
      print('📥 Fetching Key Risk Conditions from API...');
      final response = await http.get(
        Uri.parse('https://clickpad.cloud/api/safety-key-risk-conditions'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Fetched ${data.length} Key Risk Conditions from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch KRC: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ fetchKrcFromApi error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// ✅ NEW: Fetch all users from API
  Future<List<Map<String, dynamic>>> fetchUsersFromApi() async {
    try {
      print('📥 Fetching users from API...');
      final response = await http.get(
        Uri.parse('https://clickpad.cloud/api/safety-users'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Fetched ${data.length} users from API');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ fetchUsersFromApi error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Batch create multiple cards - API expects array
  Future<void> _batchCreateCardsToApi(List<SafetyCard> cards) async {
    print('Creating ${cards.length} cards individually to API...');
    
    for (var card in cards) {
      try {
        final cardJson = await _safetyCardToJson(card, isEdited: false);
        
        print('Sending card ${card.id} to API');
        print('Request body: ${json.encode(cardJson)}');
        
        final response = await http.post(
          Uri.parse('https://clickpad.cloud/api/safety-cards'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(cardJson),
        ).timeout(const Duration(seconds: 60));

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to create card: ${response.statusCode} - ${response.body}');
        }
        
        print('Successfully created card ${card.id}');
      } catch (e) {
        print('Failed to create card ${card.id}: $e');
        rethrow;
      }
    }
  }

  /// Update a card to API - Send as single object using card UUID
  Future<void> _updateCardToApi(SafetyCard card, {bool isEdited = false}) async {
    try {
      print('=== UPDATE CARD TO API ===');
      print('Card ID: ${card.id}');
      print('Card UUID: ${card.uuid}');
      print('Site ID: ${card.siteId}');
      print('Location ID: ${card.locationId}');
      print('Status: ${card.status}');
      print('Safety Status: ${card.safetyStatus}');
      print('Is User Edit: $isEdited');
      
      final body = await _safetyCardToJson(card, isEdited: isEdited);
      
      final url = _getCardUrl(card.uuid);
      print('PUT URL: $url');
      print('Request body: ${json.encode(body)}');
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update card: ${response.statusCode} - ${response.body}');
      }
      
      print('✓ Successfully updated card ${card.id} (UUID: ${card.uuid})');
    } catch (e, stackTrace) {
      print('✘ Error updating card to API:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sync sites and locations from API
  Future<void> syncSitesAndLocations() async {
    try {
      print('🔄 Syncing sites and locations...');
      
      // Fetch sites
      final sitesData = await fetchSitesFromApi();
      await db.syncSitesFromApi(sitesData);
      
      // Fetch all locations
      final locationsData = await fetchLocationsFromApi();
      await db.syncLocationsFromApi(locationsData);
      
      print('✅ Sites and locations synced successfully');
    } catch (e) {
      print('❌ Error syncing sites and locations: $e');
    }
  }

  /// Delete card from API - Use UUID
  Future<void> _deleteCardFromApi(String uuid) async {
    print('Deleting card UUID: $uuid from API');
    
    final response = await http.delete(
      Uri.parse(_getCardUrl(uuid)),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 60));

    print('Response status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete card: ${response.statusCode}');
    }
    
    print('Successfully deleted card');
  }

  /// Helper method to upload images for a card
  Future<void> _uploadCardImages(SafetyCard card) async {
    try {
      final images = <Uint8List>[];
      
      if (card.imageListBase64 != null && card.imageListBase64!.isNotEmpty) {
        final imageStrings = card.imageListBase64!.split('|||');
        for (var imgStr in imageStrings) {
          if (imgStr.isNotEmpty) {
            try {
              images.add(base64Decode(imgStr));
            } catch (e) {
              print('⚠️ Failed to decode image: $e');
            }
          }
        }
      }
      
      if (images.isNotEmpty) {
        print('📤 Uploading ${images.length} images for card ${card.uuid}');
        // ✅ REMOVED: Don't delete images first, just upload
        final uploaded = await ImageService.uploadImages(card.uuid, images);
        if (uploaded) {
          print('✅ Images uploaded successfully for card ${card.uuid}');
        } else {
          print('⚠️ Failed to upload some images for card ${card.uuid}');
        }
      }
    } catch (e) {
      print('❌ Error uploading images for card ${card.uuid}: $e');
    }
  }

  Future<void> _createCardFromApi(Map<String, dynamic> apiCard) async {
    final companion = await _apiCardToCompanion(apiCard);
    await db.createSafetyCard(companion);
  }

// Conversion methods
  
Future<Map<String, dynamic>> _safetyCardToJson(SafetyCard card, {bool isEdited = false}) async { 
  
  print("Edited status : $isEdited, adminModified: ${card.adminModified}");
  
  final site = await db.allSites().then((sites) => 
    sites.firstWhere((s) => s.id == card.siteId, orElse: () => sites.first)
  );
  final location = await db.allLocations().then((locs) => 
    locs.firstWhere((l) => l.id == card.locationId, orElse: () => locs.first)
  );
  
  final krc = await db.allKrc().then((krcs) =>
    krcs.firstWhere((k) => k.id == card.keyRiskConditionId, orElse: () => krcs.first)
  );
  
  final currentUserEmail = UserSession.userEmail ?? 'unknown@example.com';
  
  final raisedByUser = await db.allUsers().then((users) {
    final user = users.firstWhere(
      (u) => u.id == card.raisedById, 
      orElse: () => users.first
    );
    print('🔍 Card raisedById: ${card.raisedById} -> User: ${user.name}');
    return user;
  });
  
  final allAppUsers = await db.select(db.appUsers).get();
  final raisedByAppUser = allAppUsers.firstWhere(
    (u) => u.name.trim().toLowerCase() == raisedByUser.name.trim().toLowerCase(),
    orElse: () => allAppUsers.first,
  );
  final raisedByEmail = raisedByAppUser.email;
  
  print('📧 RaisedBy: ${raisedByUser.name} -> Email: $raisedByEmail');
  
  String? personResponsibleName;
  if (card.personResponsibleId != null) {
    final responsibleUser = await db.allUsers().then((users) =>
      users.firstWhere((u) => u.id == card.personResponsibleId, orElse: () => users.first)
    );
    personResponsibleName = responsibleUser.name;
  }
  
  final now = DateTime.now();
  final formattedNow = '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}T'
      '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}:'
      '${now.second.toString().padLeft(2, '0')}';
  
  String formattedTime = card.time;
  if (card.time.split(':').length == 2) {
    formattedTime = card.time;
  }
  
  String normalizedSafetyStatus = card.safetyStatus;
  if (card.safetyStatus.toLowerCase().contains('unsafe')) {
    normalizedSafetyStatus = 'Unsafe';
  } else if (card.safetyStatus.toLowerCase().contains('safe')) {
    normalizedSafetyStatus = 'Safe';
  }
  
  final projectNo = DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase();
  
  final cardDateTime = DateTime.parse(card.date);
  final timeParts = card.time.split(':');
  final createdDateTime = DateTime(
    cardDateTime.year,
    cardDateTime.month,
    cardDateTime.day,
    int.parse(timeParts[0]),
    int.parse(timeParts[1]),
  );
  
  final createdAt = '${createdDateTime.year.toString().padLeft(4, '0')}-'
      '${createdDateTime.month.toString().padLeft(2, '0')}-'
      '${createdDateTime.day.toString().padLeft(2, '0')}T'
      '${createdDateTime.hour.toString().padLeft(2, '0')}:'
      '${createdDateTime.minute.toString().padLeft(2, '0')}:'
      '${createdDateTime.second.toString().padLeft(2, '0')}';
  
  print('📤 Syncing card with raisedBy: ${raisedByUser.name} (ID: ${card.raisedById})');
  
  String finalEditedBy;
  String finalEditedAt;
  
  if (isEdited) {
    finalEditedBy = currentUserEmail;
    finalEditedAt = formattedNow;
    print('✏️ Active edit - Setting editedBy: $currentUserEmail, editedAt: $formattedNow');
  } else {
    try {
      print('🔍 Fetching existing card data from API for UUID: ${card.uuid}');
      final response = await http.get(
        Uri.parse(_getCardUrl(card.uuid)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 120));
      
      if (response.statusCode == 200) {
        final existingCard = json.decode(response.body);
        finalEditedBy = existingCard['editedBy'] ?? raisedByEmail;
        finalEditedAt = existingCard['editedAt'] ?? createdAt;
        print('✅ Preserved existing editedBy: $finalEditedBy, editedAt: $finalEditedAt');
      } else {
        print('⚠️ Could not fetch existing card (${response.statusCode}), defaulting to creator');
        finalEditedBy = raisedByEmail;
        finalEditedAt = createdAt;
      }
    } catch (e) {
      print('⚠️ Error fetching existing card data: $e, defaulting to creator');
      finalEditedBy = raisedByEmail;
      finalEditedAt = createdAt;
    }
  }
  
  print('📧 Final values - createdBy: $raisedByEmail, editedBy: $finalEditedBy');
  
  return {
    'id': card.uuid,
    'keyRiskCondition': krc.hexId,
    'projectNo': projectNo,
    'cardDate': '${card.date}T00:00:00',
    'cardTime': formattedTime,
    'raisedBy': raisedByUser.name,
    'department': card.department,
    'siteId': site.uuid,
    'locationId': location.uuid,
    'safetyStatus': normalizedSafetyStatus,
    'observation': card.observation,
    'actionTaken': card.actionTaken,
    'reportStatus': card.status,
    'personResponsible': personResponsibleName,
    'createdAt': createdAt,
    'createdBy': raisedByEmail,
    'createdLocation': '0.0, 0.0',
    'editedAt': isEdited ? formattedNow : finalEditedAt,
    'editedBy': isEdited ? currentUserEmail : finalEditedBy,
    'editedLocation': '0.0, 0.0',
    'filePath': null,
    'adminModified': card.adminModified, // ✅ Send adminModified from card object
  };
}


  Future<SafetyCardsCompanion> _apiCardToCompanion(Map<String, dynamic> apiCard) async {
    final dateStr = apiCard['cardDate']?.toString().split('T')[0] ?? 
                  DateTime.now().toString().split(' ')[0];
    
    final siteUuid = apiCard['siteId']?.toString();
    final locationUuid = apiCard['locationId']?.toString();
    
    final sites = await db.allSites();
    final site = sites.firstWhere(
      (s) => s.uuid == siteUuid,
      orElse: () => sites.first,
    );
    
    final locations = await db.allLocations();
    final location = locations.firstWhere(
      (l) => l.uuid == locationUuid,
      orElse: () => locations.first,
    );
    
    String timeStr = apiCard['cardTime'] ?? '00:00:00';
    final timeParts = timeStr.split(':');
    if (timeParts.length == 2) {
      timeStr = '$timeStr:00';
    }

    // ðŸ†• FIXED: Map keyRiskCondition hex ID correctly
    final krcHexId = apiCard['keyRiskCondition']?.toString();
    int krcId = 1;
    
    if (krcHexId != null && krcHexId.isNotEmpty) {
      final krcs = await db.allKrc();
      final matchedKrc = krcs.firstWhere(
        (k) => k.hexId.toUpperCase() == krcHexId.toUpperCase(), // Case-insensitive match
        orElse: () {
          print('âš ï¸ KRC not found for hexId: $krcHexId, using first KRC');
          return krcs.first;
        },
      );
      krcId = matchedKrc.id;
      print('âœ… Mapped keyRiskCondition "$krcHexId" to KRC ID: $krcId (${matchedKrc.name})');
    } else {
      print('âš ï¸ No keyRiskCondition in API response, using default KRC');
    }
    
    final raisedByName = apiCard['raisedBy']?.toString();
    int raisedById = 1;
    
    if (raisedByName != null && raisedByName.isNotEmpty) {
      final users = await db.allUsers();
      final matchedUser = users.firstWhere(
        (u) => u.name.toLowerCase() == raisedByName.toLowerCase(),
        orElse: () => users.first,
      );
      raisedById = matchedUser.id;
    }
    
    final personResponsibleName = apiCard['personResponsible']?.toString();
    int? personResponsibleId;
    
    if (personResponsibleName != null && personResponsibleName.isNotEmpty) {
      final users = await db.allUsers();
      final matchedUser = users.firstWhere(
        (u) => u.name.toLowerCase() == personResponsibleName.toLowerCase(),
        orElse: () => users.first,
      );
      personResponsibleId = matchedUser.id;
    }
    
    final uuid = apiCard['id']?.toString() ?? const Uuid().v4();
    final status = apiCard['reportStatus']?.toString() ?? 'Open';

    final adminModified = apiCard['adminModified'] as bool?;

    return SafetyCardsCompanion.insert(
      uuid: uuid,
      keyRiskConditionId: krcId,
      date: dateStr,
      time: timeStr,
      raisedById: raisedById,
      department: apiCard['department'] ?? 'Unknown',
      siteId: site.id,
      locationId: location.id,
      safetyStatus: apiCard['safetyStatus'] ?? 'Unknown',
      observation: apiCard['observation'] ?? '',
      actionTaken: apiCard['actionTaken'] ?? '',
      status: Value(status),
      personResponsibleId: Value(personResponsibleId),
      adminModified: Value(adminModified), // ✅ NEW: Include adminModified from API
    );
  }

Future<DashboardResult> fetchDashboard({
  int pageNumber = 1,
  int pageSize = 50,
  DateTime? dateFrom,
  DateTime? dateTo,
  String? keyRiskConditionHexId,
  String? siteUuid,
  String? locationUuid,
  String? raisedByName,
  String? cardStatus,
  String? safetyStatus,
}) async {
  try {
    if (!await isOnline()) {
      print('❌ Device is offline, cannot fetch dashboard');
      return DashboardResult(
        cards: [],
        totalCount: 0,
        totalPages: 0,
        currentPage: pageNumber,
        safetyCardCount: 0,
        topKeyRiskConditions: [],
        recordsPerWeek: [],
        safeUnsafe: {},
        cardStatusDistribution: {},
      );
    }

    print('🔥 Fetching dashboard data from server...');
    print('   - Page: $pageNumber, Size: $pageSize');
    
    final requestBody = <String, dynamic>{
      'email': UserSession.userEmail ?? '',
      'isAdmin': UserSession.isAdmin,
      'deviceType': 0,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    
    // Only add filters if they have actual values
    if (dateFrom != null && dateFrom.millisecondsSinceEpoch > 0) {
      requestBody['dateFrom'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      requestBody['dateTo'] = dateTo.toIso8601String();
    }
    if (keyRiskConditionHexId != null && keyRiskConditionHexId.isNotEmpty) {
      requestBody['keyRiskCondition'] = keyRiskConditionHexId;
    }
    if (siteUuid != null && siteUuid.isNotEmpty) {
      requestBody['siteId'] = siteUuid;
    }
    if (locationUuid != null && locationUuid.isNotEmpty) {
      requestBody['locationId'] = locationUuid;
    }
    if (raisedByName != null && raisedByName.isNotEmpty) {
      requestBody['raisedBy'] = raisedByName;
    }
    if (cardStatus != null && cardStatus.isNotEmpty) {
      requestBody['cardStatus'] = cardStatus;
    }
    if (safetyStatus != null && safetyStatus.isNotEmpty) {
      requestBody['safetyStatus'] = safetyStatus;
    }

    print('Request body: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse('https://clickpad.cloud/api/safety-cards/dashboard'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    ).timeout(const Duration(seconds: 60));

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      
      // Extract pagination data
      final pagination = data['pagination'] as Map<String, dynamic>;
      final listData = pagination['data'] as List;
      final pageCards = listData.cast<Map<String, dynamic>>();
      
      final totalPages = pagination['totalPages'] ?? 1;
      final totalCount = pagination['totalCount'] ?? pageCards.length;
      
      print('Dashboard data: ${pageCards.length} cards (total: $totalCount, pages: $totalPages)');
      
      // Convert API cards to SafetyCard objects and save to local DB
      final freshCards = <SafetyCard>[];
      for (var apiCard in pageCards) {
        try {
          final cardUuid = apiCard['id']?.toString() ?? '';
          
          // Check if card exists locally by UUID
          final existingCard = await (db.select(db.safetyCards)
            ..where((c) => c.uuid.equals(cardUuid))).getSingleOrNull();
          
          SafetyCard card;
          if (existingCard == null) {
            // Create new card in local DB
            final companion = await _apiCardToCompanion(apiCard);
            final id = await db.createSafetyCard(companion);
            card = (await db.safetyCardById(id))!;
          } else {
            // Update existing card using its ID
            final companion = await _apiCardToCompanion(apiCard);
            await (db.update(db.safetyCards)..where((c) => c.id.equals(existingCard.id)))
              .write(companion);
            card = (await db.safetyCardById(existingCard.id))!;
          }
          
          freshCards.add(card);
        } catch (e) {
          print('Error processing card: $e');
        }
      }
      
      return DashboardResult(
        cards: freshCards,
        totalCount: totalCount,
        totalPages: totalPages,
        currentPage: pageNumber,
        safetyCardCount: data['safetyCardCount'] ?? totalCount,
        topKeyRiskConditions: (data['topKeyRiskConditions'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        recordsPerWeek: (data['recordsPerWeek'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        safeUnsafe: (data['safeUnsafe'] as Map<String, dynamic>?) ?? {},
        cardStatusDistribution: (data['cardStatusDistribution'] as Map<String, dynamic>?) ?? {},
      );
    }
    
    print('Failed to fetch dashboard: ${response.statusCode}');
    return DashboardResult(
      cards: [],
      totalCount: 0,
      totalPages: 0,
      currentPage: pageNumber,
      safetyCardCount: 0,
      topKeyRiskConditions: [],
      recordsPerWeek: [],
      safeUnsafe: {},
      cardStatusDistribution: {},
    );
    
  } catch (e) {
    print('Error fetching dashboard: $e');
    return DashboardResult(
      cards: [],
      totalCount: 0,
      totalPages: 0,
      currentPage: pageNumber,
      safetyCardCount: 0,
      topKeyRiskConditions: [],
      recordsPerWeek: [],
      safeUnsafe: {},
      cardStatusDistribution: {},
    );
  }
}



  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;
  bool get isCurrentlyOnline => _isOnline;
}

class DashboardResult {
  final List<SafetyCard> cards;
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int safetyCardCount;
  final List<Map<String, dynamic>> topKeyRiskConditions;
  final List<Map<String, dynamic>> recordsPerWeek;
  final Map<String, dynamic> safeUnsafe;
  final Map<String, dynamic> cardStatusDistribution;

  DashboardResult({
    required this.cards,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.safetyCardCount,
    required this.topKeyRiskConditions,
    required this.recordsPerWeek,
    required this.safeUnsafe,
    required this.cardStatusDistribution,
  });
}


class SyncResult {
  final bool success;
  final String message;
  final int created;
  final int updated;
  final int deleted;
  final int failed;

  SyncResult({
    required this.success,
    required this.message,
    this.created = 0,
    this.updated = 0,
    this.deleted = 0,
    this.failed = 0,
  });
}

// 🆕 NEW: Result class for filtered cards
class FilteredCardsResult {
  final List<SafetyCard> cards;
  final int totalCount;
  final int totalPages;
  final int currentPage;

  FilteredCardsResult({
    required this.cards,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
  });
}

enum SyncStatus {
  idle,
  syncing,
  synced,
  offline,
  error,
}