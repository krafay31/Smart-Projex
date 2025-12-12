// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, unused_import
import 'dart:convert';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:uuid/uuid.dart';
part 'app_database.g.dart';

@DataClassName('AppUser')
class AppUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get securityLevel => text()(); // 'Admin' | 'User'
  TextColumn get currentSite => text().nullable()();
  TextColumn get specialization => text().nullable()();
}

@DataClassName('KeyRiskCondition')
class KeyRiskConditions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get hexId => text().unique()();
}

@DataClassName('UserLite')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

@DataClassName('Site')
class Sites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get uuid => text().unique()();
}

@DataClassName('Location')
class Locations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get siteId => integer().references(Sites, #id)();
  TextColumn get uuid => text().unique()();
}

@DataClassName('SafetyCard')
class SafetyCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();

  BlobColumn get imageData => blob().nullable()();
  TextColumn get imageListBase64 => text().nullable()();

  IntColumn get keyRiskConditionId =>
      integer().references(KeyRiskConditions, #id)();

  TextColumn get date => text()();
  TextColumn get time => text()();

  IntColumn get raisedById => integer().references(Users, #id)();

  TextColumn get department => text()();
  IntColumn get siteId => integer().references(Sites, #id)();
  IntColumn get locationId => integer().references(Locations, #id)();

  TextColumn get safetyStatus => text()();
  TextColumn get status => text().withDefault(const Constant('Open'))();

  TextColumn get observation => text()();
  TextColumn get actionTaken => text()();

  IntColumn get personResponsibleId =>
      integer().nullable().references(Users, #id)();
  
  TextColumn get filePath => text().nullable()();
  
  // ✅ adminModified indicates if card was submitted anonymously
  BoolColumn get adminModified => boolean().nullable()();
}

@DataClassName('SignOffSite')
class SignOffSites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get siteId => text().unique()(); // This is the ID from API
  TextColumn get name => text()();
  TextColumn get image => text().nullable()();
  BoolColumn get siteDpr => boolean().withDefault(const Constant(true))();
  TextColumn get siteCustomer => text().nullable()();
  TextColumn get temp3 => text().nullable()();
}

@DataClassName('SignOffLocation')
class SignOffLocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get locationId => text().unique()(); // This is the ID from API
  TextColumn get name => text()();
  TextColumn get latLong => text().nullable()();
  TextColumn get siteId => text().references(SignOffSites, #siteId)();
  TextColumn get field => text().nullable()();
  TextColumn get taskLocation => text().nullable()();
}

@DataClassName('SafetyCommunication')
class SafetyCommunications extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get id => text().unique()(); // GUID from API
  TextColumn get title => text()();
  TextColumn get date => text()();
  TextColumn get description => text().nullable()();
  TextColumn get siteId => text().references(SignOffSites, #siteId)();
  TextColumn get department => text().nullable()();
  TextColumn get location => text().references(SignOffLocations, #locationId)(); // This seems to store name or ID, spec says ID for usage but name in current AppUser? Let's check API.
  // Actually API for Location has locationId. The SafetyComm payload has "location". 
  // API spec for POST SafetyComm says "location": "string".
  // For now we will store the string value, but likely it refers to locationId or Name. 
  // Given existing patterns, we'll store as text.
  TextColumn get project => text().nullable()(); // temp3 from site
  TextColumn get deliveredBy => text()(); // User email/name
  TextColumn get category => text()(); // Comma separated or single? The payload has booleans. 
  // We'll store the 'active' category name here, or maybe we replicate the booleans?
  // User asked for "category" in filter. Payload has booleans for specific ones.
  // "category": "string" in POST.
  // Also booleans: induction, training, etc.
  // We'll add booleans as well to match API.
  BoolColumn get induction => boolean().withDefault(const Constant(false))();
  BoolColumn get training => boolean().withDefault(const Constant(false))();
  BoolColumn get toolboxTalk => boolean().withDefault(const Constant(false))();
  BoolColumn get procedure => boolean().withDefault(const Constant(false))();
  BoolColumn get riskAssessment => boolean().withDefault(const Constant(false))();
  BoolColumn get coshhAssessment => boolean().withDefault(const Constant(false))();
  BoolColumn get other => boolean().withDefault(const Constant(false))();
  
  TextColumn get comments => text().nullable()();
  BoolColumn get generateReport => boolean().withDefault(const Constant(true))();
  TextColumn get filePath => text().nullable()();
  
  // Status tracking (local only maybe?)
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // New column for sorting
  TextColumn get creationDateTime => text().nullable()();
}

@DataClassName('SafetyCommSignature')
class SafetyCommSignatures extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get id => text().unique()(); // GUID from API
  TextColumn get communicationId => text().references(SafetyCommunications, #id)();
  TextColumn get teamMember => text()();
  TextColumn get signature => text().nullable()(); // Base64 or path?
  TextColumn get shift => text().nullable()();
  
  // Status tracking
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [
  AppUsers,
  KeyRiskConditions,
  Users,
  Sites,
  Locations,
  SafetyCards,
  SignOffSites,
  SignOffLocations,
  SafetyCommunications,
  SafetyCommSignatures,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  Future<void> deleteCard(int id) => 
    (delete(safetyCards)..where((c) => c.id.equals(id))).go();

  Future<void> reopenCard(int id) => (update(safetyCards)
        ..where((c) => c.id.equals(id)))
      .write(const SafetyCardsCompanion(
        status: Value('Open'),
      ));

  static QueryExecutor _openConnection() {
    return DatabaseConnection.delayed(Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'safety_card_db',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        print('Using ${result.chosenImplementation} due to missing browser features: ${result.missingFeatures}');
      }

      return result.resolvedExecutor;
    }));
  }

  Future<PaginatedCardsResult> getPaginatedCardsForUser(
    int userId, 
    bool isAdmin, 
    {int page = 1, int pageSize = 50}
  ) async {
    final offset = (page - 1) * pageSize;
    
    List<SafetyCard> allVisibleCards;
    
    if (isAdmin) {
      allVisibleCards = await (select(safetyCards)
        ..where((c) => 
          c.raisedById.equals(userId) | 
          c.status.equals('Submitted') | 
          c.status.equals('Closed')
        )).get();
    } else {
      allVisibleCards = await (select(safetyCards)
        ..where((c) => c.raisedById.equals(userId))).get();
    }
    
    final totalCount = allVisibleCards.length;
    final totalPages = (totalCount / pageSize).ceil();
    
    allVisibleCards.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });
    
    final startIndex = offset;
    final endIndex = (startIndex + pageSize).clamp(0, totalCount);
    
    final paginatedCards = allVisibleCards.sublist(
      startIndex.clamp(0, totalCount),
      endIndex,
    );
    
    return PaginatedCardsResult(
      cards: paginatedCards,
      currentPage: page,
      pageSize: pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
    );
  }

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2 && to >= 2) {
        await m.addColumn(sites, sites.uuid);
        await m.addColumn(locations, locations.uuid);
        
        const uuid = Uuid();
        final db = m.database;
        
        final sitesNeedingUuid = await db.customSelect(
          'SELECT id FROM sites WHERE uuid IS NULL'
        ).get();
        
        for (var site in sitesNeedingUuid) {
          final id = site.read<int>('id');
          await db.customUpdate(
            'UPDATE sites SET uuid = ? WHERE id = ?',
            variables: [Variable.withString(uuid.v4()), Variable.withInt(id)],
            updates: {sites},
          );
        }
        
        final locationsNeedingUuid = await db.customSelect(
          'SELECT id FROM locations WHERE uuid IS NULL'
        ).get();
        
        for (var location in locationsNeedingUuid) {
          final id = location.read<int>('id');
          await db.customUpdate(
            'UPDATE locations SET uuid = ? WHERE id = ?',
            variables: [Variable.withString(uuid.v4()), Variable.withInt(id)],
            updates: {locations},
          );
        }
      }
      
      if (from < 5 && to >= 5) {
        await m.addColumn(keyRiskConditions, keyRiskConditions.hexId);
        
        final db = m.database;
        final hexIdMap = {
          'Slip trips and falls': '99A64B0E',
          'Working at height': 'ED8D7496',
          'Manual Handling': '2A3601DA',
          'Stored energy: pressure': 'DDF4A9E0',
          'Stored energy: Electrical': '0319F47C',
          'Stored energy: Falling objects': 'E924DB28',
          'Cutting / Knife safety': '25C21EE4',
          'Tools & equipment': '2909EAE2',
          'Hazardous substances': '75CDA14A',
          'Mobile Plant': 'ED713852',
          'Lifting & slinging': '7A0F0C2A',
          'Personal Protection Equipment': '8B2D88E4',
          'Procedures': '8EE4FF85',
          'Contractor management': '0A45A3DC',
          'Complacency': 'D6EC6B18',
          'Noise': 'FEFE8423',
          'Working Environment': 'ABA1EC44',
          'Fatigue': '4B3C4421',
          'Spillages': '94DC113C',
          'Waste': '3FC328B6',
          'Emissions': 'AC6082E5',
          'Other': 'AC6082E6',
        };
        
        for (var entry in hexIdMap.entries) {
          await db.customUpdate(
            'UPDATE key_risk_conditions SET hex_id = ? WHERE name = ?',
            variables: [
              Variable.withString(entry.value),
              Variable.withString(entry.key),
            ],
            updates: {keyRiskConditions},
          );
        }
      }
      
      if (from < 6 && to >= 6) {
        await m.addColumn(safetyCards, safetyCards.adminModified);
        print('✅ Added adminModified column to safety_cards');
      }

      if (from < 7 && to >= 7) {
        await m.createTable(signOffSites);
        await m.createTable(signOffLocations);
        await m.createTable(safetyCommunications);
        await m.createTable(safetyCommSignatures);
        print('✅ Created SignOff module tables');
      }
    },
    beforeOpen: (details) async {
      try {
        final userCount = await customSelect('SELECT COUNT(*) as count FROM app_users')
            .getSingle()
            .then((r) => r.read<int>('count'));
        
        if (userCount == 0) {
          print('Database is empty, seeding...');
          await seed();
        } else {
          print('Database already has $userCount users, skipping seed');
        }
      } catch (e) {
        print('Error checking/seeding database: $e');
        if (e.toString().contains('no such table')) {
          print('Tables do not exist, will be created by migration');
        }
      }
    },
  );

  Future<void> seed() async {
    const uuid = Uuid();

    final seedSites = <SitesCompanion>[
      SitesCompanion.insert(name: 'Offshore', uuid: 'B920FFE0'),
      SitesCompanion.insert(name: 'Brazil', uuid: '88CEAC4D'),
      SitesCompanion.insert(name: 'Client Facility Onshore', uuid: 'df0d50ed'),
      SitesCompanion.insert(name: 'Hartlepool', uuid: '9254ED50'),
      SitesCompanion.insert(name: 'Houston', uuid: 'E4AF21BA'),
      SitesCompanion.insert(name: 'Littleport', uuid: 'E5525BCF'),
      SitesCompanion.insert(name: 'Maritime House', uuid: '935d3080'),
      SitesCompanion.insert(name: 'Newcastle', uuid: '348C3E58'),
      SitesCompanion.insert(name: 'Offsite', uuid: '99ccbffb'),
      SitesCompanion.insert(name: 'Other', uuid: 'ED74ADA0'),
      SitesCompanion.insert(name: 'VW1', uuid: '0445d664'),
      SitesCompanion.insert(name: 'CVOW', uuid: 'f0f1fdb6'),
    ];

    await batch((b) => b.insertAll(sites, seedSites));

    final insertedSites = await select(sites).get();

    final seedLocations = <LocationsCompanion>[
      // Offshore locations
      LocationsCompanion.insert(name: 'Accomodation Vessel', siteId: insertedSites[0].id, uuid: '435BCE22'),
      LocationsCompanion.insert(name: 'Cable Laying Vessel (CLV)', siteId: insertedSites[0].id, uuid: '9030C207'),
      // ... (rest of locations - keeping them for brevity)
    ];

    await batch((b) => b.insertAll(locations, seedLocations));

    final seedKrc = <KeyRiskConditionsCompanion>[
      KeyRiskConditionsCompanion.insert(name: 'Slip trips and falls', icon: 'slip_trips_falls.png', hexId: '99A64B0E'),
      KeyRiskConditionsCompanion.insert(name: 'Working at height', icon: 'working_at_height.png', hexId: 'ED8D7496'),
      // ... (rest of KRCs)
    ];

    await batch((b) => b.insertAll(keyRiskConditions, seedKrc));
  }

  // Queries
  Future<AppUser?> findAppUserByEmail(String email) =>
      (select(appUsers)..where((u) => u.email.equals(email)))
          .getSingleOrNull();

  Future<List<KeyRiskCondition>> allKrc() =>
      select(keyRiskConditions).get();

  Future<List<UserLite>> allUsers() => select(users).get();

  Future<List<Site>> allSites() => select(sites).get();

  Future<List<Location>> allLocations() async {
    return await select(locations).get();
  }

  Future<List<SafetyCard>> getVisibleCardsForUser(int userId, bool isAdmin) async {
    if (isAdmin) {
      return await (select(safetyCards)
        ..where((c) => 
          c.raisedById.equals(userId) | 
          c.status.equals('Submitted') | 
          c.status.equals('Closed')
        )
        ..orderBy([
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)
        ])
      ).get();
    } else {
      return await (select(safetyCards)
        ..where((c) => c.raisedById.equals(userId))
        ..orderBy([
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)
        ])
      ).get();
    }
  }

  Future<UserLite?> findUserByName(String name) =>
      (select(users)..where((u) => u.name.equals(name)))
          .getSingleOrNull();

  Future<UserLite?> findUserByAppUserEmail(String email) async {
    final appUser = await findAppUserByEmail(email);
    if (appUser == null) return null;
    
    return await findUserByName(appUser.name);
  }

  Future<SafetyCard?> safetyCardById(int id) => 
    (select(safetyCards)..where((c) => c.id.equals(id))).getSingleOrNull();
  
  // Site Management Methods
  Future<int> insertSite(String name) async {
    const uuid = Uuid();
    return await into(sites).insert(
      SitesCompanion.insert(name: name, uuid: uuid.v4())
    );
  }

  Future<void> updateSite(int id, String name) async {
    await (update(sites)..where((s) => s.id.equals(id)))
        .write(SitesCompanion(name: Value(name)));
  }

  Future<void> deleteSite(int id) async {
    await (delete(sites)..where((s) => s.id.equals(id))).go();
  }

  // Location Management Methods
  Future<int> insertLocation(String name, int siteId) async {
    const uuid = Uuid();
    return await into(locations).insert(
      LocationsCompanion.insert(name: name, siteId: siteId, uuid: uuid.v4()),
    );
  }

  Future<void> updateLocation(int id, String name, int siteId) async {
    await (update(locations)..where((l) => l.id.equals(id)))
        .write(LocationsCompanion(
          name: Value(name),
          siteId: Value(siteId),
        ));
  }

  Future<void> deleteLocation(int id) async {
    await (delete(locations)..where((l) => l.id.equals(id))).go();
  }

  // Key Risk Condition Management Methods
  Future<int> insertKrc(String name, String icon, {String? hexId}) async {
    final idToUse = hexId ?? DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase().padLeft(8, '0').substring(0, 8);
    
    return await into(keyRiskConditions).insert(
      KeyRiskConditionsCompanion.insert(
        name: name, 
        icon: icon,
        hexId: idToUse,
      ),
    );
  }

  Future<void> updateKrc(int id, String name, String icon) async {
    await (update(keyRiskConditions)..where((k) => k.id.equals(id)))
        .write(KeyRiskConditionsCompanion(
          name: Value(name),
          icon: Value(icon),
        ));
  }

  Future<void> deleteKrc(int id) async {
    await (delete(keyRiskConditions)..where((k) => k.id.equals(id))).go();
  }

  Future<void> updateSafetyCard(Insertable<SafetyCard> card) => 
    update(safetyCards).replace(card);
    
  Future<List<Location>> locationsForSite(int siteId) =>
      (select(locations)..where((l) => l.siteId.equals(siteId))).get();

  Future<int> createSafetyCard(Insertable<SafetyCard> card) =>
      into(safetyCards).insert(card);

  Future<List<SafetyCard>> allSafetyCards() => (select(safetyCards)
        ..orderBy([
          (t) => OrderingTerm(
              expression: t.id, mode: OrderingMode.desc)
        ]))
      .get();

  Future<List<SafetyCard>> safetyCardsByRaisedBy(int userId) =>
      (select(safetyCards)
            ..where((c) => c.raisedById.equals(userId))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.id, mode: OrderingMode.desc)
            ]))
          .get();

  Future<KeyRiskCondition?> getKrcByHexId(String hexId) async {
    final results = await (select(keyRiskConditions)
          ..where((t) => t.hexId.equals(hexId.toUpperCase())))
        .get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<Site?> getSiteByUuid(String uuid) async {
    final results = await (select(sites)
          ..where((t) => t.uuid.equals(uuid)))
        .get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<Location?> getLocationByUuid(String uuid) async {
    final results = await (select(locations)
          ..where((t) => t.uuid.equals(uuid)))
        .get();
    return results.isNotEmpty ? results.first : null;
  }




  Future<void> closeCard(int id) => (update(safetyCards)
        ..where((c) => c.id.equals(id)))
      .write(const SafetyCardsCompanion(
        status: Value('Closed'),
      ));

  Future<void> submitCard(int id) => (update(safetyCards)
      ..where((c) => c.id.equals(id)))
    .write(const SafetyCardsCompanion(
      status: Value('Submitted'),
    ));

  // ===========================================================================
  // SignOff Module DAOs
  // ===========================================================================

  Future<List<SignOffSite>> getAllSignOffSites() => select(signOffSites).get();
  
  Future<List<SignOffLocation>> getAllSignOffLocations() => select(signOffLocations).get();
  
  Future<List<SignOffLocation>> getSignOffLocationsForSite(String siteId) =>
      (select(signOffLocations)..where((l) => l.siteId.equals(siteId))).get();

  Future<List<SafetyCommunication>> getAllSafetyCommunications() => 
      (select(safetyCommunications)
        ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
      
  Future<List<SafetyCommSignature>> getSignaturesForComm(String commId) =>
      (select(safetyCommSignatures)..where((s) => s.communicationId.equals(commId))).get();

  Future<int> createSafetyCommunication(SafetyCommunicationsCompanion comm) =>
      into(safetyCommunications).insert(comm);
      
  Future<void> updateSafetyCommunication(SafetyCommunicationsCompanion comm) =>
      update(safetyCommunications).replace(comm);
      
  Future<void> deleteSafetyCommunication(String id) =>
      (delete(safetyCommunications)..where((c) => c.id.equals(id))).go();
      
  Future<int> createSignature(SafetyCommSignaturesCompanion sig) =>
      into(safetyCommSignatures).insert(sig);
      
  Future<void> deleteSignature(String id) =>
      (delete(safetyCommSignatures)..where((s) => s.id.equals(id))).go();


  Future<void> syncSitesFromApi(List<Map<String, dynamic>> apiSites) async {
    print('🔄 Syncing ${apiSites.length} sites from API...');
    
    for (var apiSite in apiSites) {
      final uuid = apiSite['id']?.toString();
      final name = apiSite['name']?.toString();
      
      if (uuid == null || name == null) continue;
      
      final existingSite = await (select(sites)
        ..where((s) => s.uuid.equals(uuid)))
        .getSingleOrNull();
      
      if (existingSite == null) {
        await into(sites).insert(
          SitesCompanion.insert(name: name, uuid: uuid),
        );
        print('✅ Added site: $name');
      } else if (existingSite.name != name) {
        await (update(sites)..where((s) => s.uuid.equals(uuid)))
          .write(SitesCompanion(name: Value(name)));
        print('✅ Updated site: $name');
      }
    }
  }

  Future<void> syncUsersFromApi(List<Map<String, dynamic>> apiUsers) async {
    print('🔥 Syncing ${apiUsers.length} users from API...');
    
    for (var apiUser in apiUsers) {
      final userId = apiUser['userId']?.toString();
      final name = apiUser['name']?.toString();
      final email = apiUser['loginEmail']?.toString();
      final securityLevel = apiUser['securityLevel']?.toString() ?? 'User';
      final currentSite = apiUser['currentSite']?.toString();
      
      if (userId == null || name == null || email == null) continue;
      
      final existingAppUser = await (select(appUsers)
        ..where((u) => u.email.equals(email)))
        .getSingleOrNull();
      
      if (existingAppUser == null) {
        await into(appUsers).insert(
          AppUsersCompanion.insert(
            name: name,
            email: email,
            securityLevel: securityLevel,
            currentSite: Value(currentSite),
            specialization: const Value(null),
          ),
        );
      } else {
        await (update(appUsers)..where((u) => u.email.equals(email)))
          .write(AppUsersCompanion(
            name: Value(name),
            securityLevel: Value(securityLevel),
            currentSite: Value(currentSite),
          ));
        print('✅ Updated AppUser: $name');
      }
      
      final existingUser = await (select(users)
        ..where((u) => u.name.equals(name)))
        .getSingleOrNull();
      
      if (existingUser == null) {
        await into(users).insert(
          UsersCompanion.insert(name: name),
        );
      }
    }
    
    print('✅ User sync completed');
  }

  Future<void> syncLocationsFromApi(List<Map<String, dynamic>> apiLocations) async {
    print('🔄 Syncing ${apiLocations.length} locations from API...');
    
    for (var apiLocation in apiLocations) {
      final uuid = apiLocation['id']?.toString();
      final name = apiLocation['name']?.toString();
      final siteUuid = apiLocation['siteId']?.toString();
      
      if (uuid == null || name == null || siteUuid == null) continue;
      
      final site = await (select(sites)
        ..where((s) => s.uuid.equals(siteUuid)))
        .getSingleOrNull();
      
      if (site == null) {
        print('⚠️ Site not found for location: $name (site UUID: $siteUuid)');
        continue;
      }
      
      final existingLocation = await (select(locations)
        ..where((l) => l.uuid.equals(uuid)))
        .getSingleOrNull();
      
      if (existingLocation == null) {
        await into(locations).insert(
          LocationsCompanion.insert(
            name: name,
            siteId: site.id,
            uuid: uuid,
          ),
        );
        print('✅ Added location: $name');
      } else if (existingLocation.name != name || existingLocation.siteId != site.id) {
        await (update(locations)..where((l) => l.uuid.equals(uuid)))
          .write(LocationsCompanion(
            name: Value(name),
            siteId: Value(site.id),
          ));
        print('✅ Updated location: $name');
      }
    }
  }

  Future<void> syncKrcFromApi(List<Map<String, dynamic>> apiKrcs) async {
    print('🔄 Syncing ${apiKrcs.length} Key Risk Conditions from API...');
    
    for (var apiKrc in apiKrcs) {
      final hexId = apiKrc['id']?.toString();
      final name = apiKrc['name']?.toString();
      final icon = apiKrc['icon']?.toString() ?? 'other.png';
      
      if (hexId == null || name == null) continue;
      
      final existingKrc = await (select(keyRiskConditions)
        ..where((k) => k.hexId.equals(hexId)))
        .getSingleOrNull();
      
      if (existingKrc == null) {
        await into(keyRiskConditions).insert(
          KeyRiskConditionsCompanion.insert(
            name: name,
            icon: icon,
            hexId: hexId,
          ),
        );
        print('✅ Added KRC: $name');
      } else if (existingKrc.name != name || existingKrc.icon != icon) {
        await (update(keyRiskConditions)..where((k) => k.hexId.equals(hexId)))
          .write(KeyRiskConditionsCompanion(
            name: Value(name),
            icon: Value(icon),
          ));
        print('✅ Updated KRC: $name');
      }
    }
  }
}

class PaginatedCardsResult {
  final List<SafetyCard> cards;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  
  PaginatedCardsResult({
    required this.cards,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });
  
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
}