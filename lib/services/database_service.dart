// === IMPORTAZIONI NECESSARIE ===
// sqflite: Plugin Flutter per database SQLite locale
import 'package:sqflite/sqflite.dart';
// sqflite_common_ffi: Supporto per desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// sqflite_common_ffi_web: Supporto specifico per web
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// path: Utility per manipolare percorsi di file in modo cross-platform
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/vinyl.dart';
import '../models/song_.dart';
import '../models/category.dart' as models;
import '../utils/constants.dart';

// === SERVIZIO DATABASE ===
// Gestisce tutte le operazioni di database per l'app Vinyl Collection
// Implementa il pattern Singleton per garantire una sola istanza del database
// MOTIVO SINGLETON: Evita connessioni multiple e conflitti di accesso al database
class DatabaseService {
  // Istanza singleton del servizio database (static = condivisa tra tutte le istanze)
  static final DatabaseService _instance = DatabaseService._internal();
  
  // Flag per evitare di impostare il factory più volte
  static bool _factoryInitialized = false;
  
  // Factory constructor: restituisce sempre la stessa istanza invece di crearne una nuova
  // MOTIVO: Garantisce che ci sia sempre una sola connessione al database
  factory DatabaseService() => _instance;
  
  // Constructor privato per il pattern Singleton
  // MOTIVO: Impedisce la creazione diretta di istanze dall'esterno
  DatabaseService._internal();

  // Istanza del database SQLite (nullable fino all'inizializzazione)
  // MOTIVO STATIC: Condivisa tra tutte le istanze della classe
  static Database? _database;

  // Getter asincrono per ottenere l'istanza del database
  // ASYNC: Necessario perché l'inizializzazione del database è un'operazione I/O
  // AWAIT: Aspetta che l'operazione di inizializzazione sia completata
  Future<Database> get database async {
    // Lazy initialization: inizializza solo quando necessario
    if (_database != null) return _database!;
    // AWAIT: Aspetta che l'inizializzazione sia completata prima di continuare
    _database = await _initDatabase();
    return _database!;
  }
  
  // Metodo per gestire le migrazioni del database
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrazione dalla versione 1 alla 2: aggiunge il campo isDefault
      await db.execute('ALTER TABLE ${AppConstants.categoryTable} ADD COLUMN isDefault INTEGER NOT NULL DEFAULT 0');
      
      // Marca le categorie predefinite esistenti come default
      for (String genre in AppConstants.defaultGenres) {
        await db.execute(
          'UPDATE ${AppConstants.categoryTable} SET isDefault = 1 WHERE name = ?',
          [genre]
        );
      }
      
      // Inserisce eventuali categorie predefinite mancanti
      for (String genre in AppConstants.defaultGenres) {
        final existing = await db.query(
          AppConstants.categoryTable,
          where: 'name = ?',
          whereArgs: [genre],
        );
        
        if (existing.isEmpty) {
          await db.insert(AppConstants.categoryTable, {
            'name': genre,
            'description': 'Genere musicale $genre',
            'vinylCount': 0,
            'isDefault': 1,
            'dateCreated': DateTime.now().toIso8601String(),
          });
        }
      }
    }
  }

  // Metodo privato per inizializzare il database
  // ASYNC: Le operazioni di file system sono asincrone per non bloccare l'UI
  Future<Database> _initDatabase() async {
    // Inizializza il database factory per web/desktop se necessario (solo una volta)
    if (kIsWeb && !_factoryInitialized) {
      // Per il web, usa sqflite_common_ffi_web
      databaseFactory = databaseFactoryFfiWeb;
      _factoryInitialized = true;
    }
    
    // JOIN: Combina il percorso della directory database con il nome del file
    // MOTIVO JOIN: Gestisce automaticamente i separatori di percorso (/ o \) per ogni OS
    // AWAIT: getDatabasesPath() è asincrono perché accede al file system
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    
    // AWAIT: openDatabase è asincrono perché crea/apre file dal disco
    // onCreate: Callback chiamato solo alla prima creazione del database
    // onUpgrade: Callback chiamato quando la versione del database aumenta
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDatabase, // Funzione per creare la struttura iniziale
      onUpgrade: _upgradeDatabase, // Funzione per migrazioni del database
    );
  }

  // Metodo per creare la struttura del database
  // ASYNC: Necessario perché le operazioni SQL sono asincrone
  // CALLBACK: Viene chiamato automaticamente da SQLite solo alla prima creazione
  Future<void> _createDatabase(Database db, int version) async {
    // === CREAZIONE TABELLA VINILI ===
    // AWAIT: Aspetta che l'operazione SQL sia completata prima di continuare
    // EXECUTE: Esegue comandi SQL DDL (Data Definition Language)
    await db.execute('''
      CREATE TABLE ${AppConstants.vinylTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID univoco auto-incrementale
        title TEXT NOT NULL,                   -- Titolo dell'album (NOT NULL = obbligatorio)
        artist TEXT NOT NULL,                  -- Nome dell'artista
        year INTEGER NOT NULL,                 -- Anno di pubblicazione
        genre TEXT NOT NULL,                   -- Genere musicale
        label TEXT NOT NULL,                   -- Casa discografica
        condition TEXT NOT NULL,               -- Condizione del vinile
        isFavorite INTEGER NOT NULL DEFAULT 0, -- Flag preferito (0=false, 1=true)
        imagePath TEXT,                        -- Percorso immagine (nullable)
        dateAdded TEXT NOT NULL,               -- Data aggiunta (formato ISO 8601)
        notes TEXT                             -- Note aggiuntive (nullable)
      )
    ''');

    // === CREAZIONE TABELLA CATEGORIE ===
    // UNIQUE: Impedisce duplicati nel campo 'name'
    // DEFAULT: Valore predefinito se non specificato
    await db.execute('''
      CREATE TABLE ${AppConstants.categoryTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID univoco auto-incrementale
        name TEXT NOT NULL UNIQUE,             -- Nome categoria (deve essere unico)
        description TEXT,                       -- Descrizione opzionale
        vinylCount INTEGER NOT NULL DEFAULT 0, -- Contatore vinili nella categoria
        isDefault INTEGER NOT NULL DEFAULT 0,  -- Flag categoria predefinita (0=false, 1=true)
        dateCreated TEXT NOT NULL              -- Data creazione categoria
      )
    ''');

    // === CREAZIONE TABELLA CANZONI ===
    // FOREIGN KEY: Collega ogni canzone a un vinile specifico
    // ON DELETE CASCADE: Elimina automaticamente le canzoni quando si elimina un vinile
    await db.execute('''
      CREATE TABLE ${AppConstants.songsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID univoco auto-incrementale
        vinylId INTEGER NOT NULL,              -- ID del vinile a cui appartiene la canzone
        titolo TEXT NOT NULL,                  -- Titolo della canzone
        artista TEXT NOT NULL,                 -- Artista della canzone
        anno INTEGER NOT NULL,                 -- Anno della canzone
        trackNumber INTEGER,                   -- Numero della traccia nell'album
        duration TEXT,                         -- Durata della canzone (formato MM:SS)
        FOREIGN KEY (vinylId) REFERENCES ${AppConstants.vinylTable} (id) ON DELETE CASCADE
      )
    ''');

    // === INSERIMENTO DATI INIZIALI ===
    // Popola il database con categorie predefinite
    // FOR LOOP: Itera attraverso i generi predefiniti
    for (String genre in AppConstants.defaultGenres) {
      // AWAIT: Aspetta che ogni inserimento sia completato
      // INSERT: Operazione SQL DML (Data Manipulation Language)
      await db.insert(AppConstants.categoryTable, {
        'name': genre,
        'description': 'Genere musicale $genre',
        'vinylCount': 0,
        'isDefault': 1,  // Marca come categoria predefinita
        // ISO 8601: Standard internazionale per date/orari
        'dateCreated': DateTime.now().toIso8601String(),
      });
    }
  }

  // === OPERAZIONI CRUD PER VINILI ===
  
  // Inserisce un nuovo vinile nel database
  // ASYNC: Operazione I/O che non deve bloccare l'UI
  // RETURN: ID del record inserito (auto-generato dal database)
  Future<int> insertVinyl(Vinyl vinyl) async {
    // AWAIT: Aspetta che il database sia pronto
    final db = await database;
    
    // TRANSAZIONE: Garantisce che vinile e canzoni vengano inseriti insieme
    int vinylId = 0;
    await db.transaction((txn) async {
      // INSERT: Converte l'oggetto Vinyl in Map per SQLite
      vinylId = await txn.insert(AppConstants.vinylTable, vinyl.toMap());
      
      // Inserisce le canzoni se presenti
      if (vinyl.song != null && vinyl.song!.isNotEmpty) {
        for (Song song in vinyl.song!) {
          Map<String, dynamic> songMap = song.toMap();
          songMap['vinylId'] = vinylId;
          await txn.insert(AppConstants.songsTable, songMap);
        }
      }
    });
    
    // Aggiorna il contatore della categoria (operazione atomica)
    await _updateCategoryCount(vinyl.genre, 1);
    return vinylId;
  }

  // Recupera tutti i vinili ordinati per data di aggiunta
  // ASYNC: Query al database è operazione asincrona
  // RETURN: Lista di oggetti Vinyl con canzoni caricate
  Future<List<Vinyl>> getAllVinyls() async {
    final db = await database;
    // QUERY: Operazione SQL SELECT con ordinamento
    // ORDER BY DESC: Più recenti prima (ordine decrescente)
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.vinylTable,
      orderBy: 'dateAdded DESC',
    );
    
    // CARICAMENTO LAZY: Carica le canzoni per ogni vinile
    List<Vinyl> vinyls = [];
    for (var map in maps) {
      Vinyl vinyl = Vinyl.fromMap(map);
      // Carica le canzoni associate se il vinile ha un ID
      if (vinyl.id != null) {
        vinyl.song = await getSongsByVinylId(vinyl.id!);
      }
      vinyls.add(vinyl);
    }
    return vinyls;
  }

  // Trova un vinile specifico tramite ID
  // NULLABLE RETURN: Può restituire null se non trovato
  Future<Vinyl?> getVinylById(int id) async {
    final db = await database;
    // WHERE CLAUSE: Filtra per ID specifico
    // PLACEHOLDER (?): Previene SQL injection attacks
    // WHERE ARGS: Valori sicuri per i placeholder
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.vinylTable,
      where: 'id = ?',        // Condizione SQL sicura
      whereArgs: [id],        // Valore del placeholder
    );
    // Controlla se è stato trovato almeno un risultato
    if (maps.isNotEmpty) {
      Vinyl vinyl = Vinyl.fromMap(maps.first);
      // Carica le canzoni associate al vinile
      vinyl.song = await getSongsByVinylId(id);
      return vinyl;
    }
    return null; // Nessun vinile trovato con quell'ID
  }

  // Recupera i vinili più recenti con limite configurabile
  // PARAMETRO OPZIONALE: limit ha valore predefinito di 5
  // LIMIT: Restringe il numero di risultati per performance
  Future<List<Vinyl>> getRecentVinyls({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.vinylTable,
      orderBy: 'dateAdded DESC', // Più recenti prima
      limit: limit,              // Limita risultati per efficienza
    );
    return List.generate(maps.length, (i) => Vinyl.fromMap(maps[i]));
  }

  // Recupera solo i vinili marcati come preferiti
  // WHERE: Filtra per campo booleano (1 = true, 0 = false)
  Future<List<Vinyl>> getFavoriteVinyls() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.vinylTable,
      where: 'isFavorite = ?',   // Filtra solo i preferiti
      whereArgs: [1],            // 1 = true in SQLite
      orderBy: 'dateAdded DESC', // Più recenti prima
    );
    return List.generate(maps.length, (i) => Vinyl.fromMap(maps[i]));
  }

  // Ricerca testuale nei campi principali del vinile
  // LIKE: Operatore SQL per ricerca parziale (case-insensitive)
  // OR: Cerca in più campi contemporaneamente
  // %: Wildcard che significa "qualsiasi carattere"
  Future<List<Vinyl>> searchVinyls(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.vinylTable,
      // OR: Cerca in titolo, artista o etichetta
      where: 'title LIKE ? OR artist LIKE ? OR label LIKE ?',
      // %query%: Trova la query ovunque nei campi di vinyl
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'dateAdded DESC',
    );
    return List.generate(maps.length, (i) => Vinyl.fromMap(maps[i]));
  }

  // Filtra vinili per genere musicale specifico
  // EXACT MATCH: Ricerca esatta (non parziale come LIKE)
  Future<List<Vinyl>> getVinylsByGenre(String genre) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.vinylTable,
      where: 'genre = ?',        // Corrispondenza esatta
      whereArgs: [genre],        // Genere specifico
      orderBy: 'dateAdded DESC',
    );
    return List.generate(maps.length, (i) => Vinyl.fromMap(maps[i]));
  }

  // Aggiorna un vinile esistente nel database
  // UPDATE: Modifica record esistente mantenendo lo stesso ID
  Future<void> updateVinyl(Vinyl vinyl) async {
    final db = await database;
    
    // TRANSAZIONE: Garantisce che vinile e canzoni vengano aggiornati insieme
    await db.transaction((txn) async {
      // UPDATE: Sostituisce tutti i campi del record
      await txn.update(
        AppConstants.vinylTable,
        vinyl.toMap(),           // Nuovi valori da salvare
        where: 'id = ?',         // Condizione per trovare il record
        whereArgs: [vinyl.id],   // ID del vinile da aggiornare
      );
      
      // Aggiorna le canzoni: elimina le vecchie e inserisce le nuove
      if (vinyl.id != null) {
        // Elimina tutte le canzoni esistenti per questo vinile
        await txn.delete(
          AppConstants.songsTable,
          where: 'vinylId = ?',
          whereArgs: [vinyl.id],
        );
        
        // Inserisce le nuove canzoni se presenti
        if (vinyl.song != null && vinyl.song!.isNotEmpty) {
          for (Song song in vinyl.song!) {
            Map<String, dynamic> songMap = song.toMap();
            songMap['vinylId'] = vinyl.id;
            await txn.insert(AppConstants.songsTable, songMap);
          }
        }
      }
    });
  }

  // Elimina un vinile dal database
  // TRANSAZIONE LOGICA: Prima legge, poi elimina, infine aggiorna contatori
  Future<void> deleteVinyl(int id) async {
    final db = await database;
    // STEP 1: Recupera il vinile per conoscere il genere
    // MOTIVO: Serve per aggiornare il contatore della categoria
    final vinyl = await getVinylById(id);
    if (vinyl != null) {
      // STEP 2: Elimina il record dal database
      await db.delete(
        AppConstants.vinylTable,
        where: 'id = ?',       // Identifica il record da eliminare
        whereArgs: [id],       // ID del vinile
      );
      // STEP 3: Decrementa il contatore della categoria
      // -1: Sottrae uno dal conteggio
      await _updateCategoryCount(vinyl.genre, -1);
    }
  }

  // === OPERAZIONI CRUD PER CATEGORIE ===

  // === PATTERN ARCHITETTURALE: DUAL COUNTING STRATEGY ===
  // 
  // MOTIVAZIONE: Questo sistema implementa una strategia ibrida per il conteggio
  // dei vinili per categoria, utilizzando due approcci complementari:
  //
  // 1. CONTATORE MANTENUTO (vinylCount nella tabella categories):
  //    - PRO: Velocità estrema per operazioni frequenti (O(1))
  //    - PRO: Ideale per interfacce utente responsive
  //    - CONTRO: Rischio di inconsistenza in caso di errori/crash
  //    - USO: Visualizzazione categorie, dashboard, operazioni CRUD
  //
  // 2. CONTEGGIO DINAMICO (getGenreDistribution con GROUP BY COUNT):
  //    - PRO: Sempre accurato (source of truth)
  //    - PRO: Auto-correttivo, non può diventare inconsistente
  //    - CONTRO: Più lento per grandi dataset (O(n))
  //    - USO: Report, statistiche, verifiche di integrità
  //
  // PATTERN: "Cache + Source of Truth"
  // - Cache (contatore): Veloce ma potenzialmente inconsistente
  // - Source of Truth (conteggio): Lento ma sempre corretto
  // - Strategia: Usa cache per performance, source of truth per accuratezza

  // Metodo privato per aggiornare il contatore di vinili per categoria
  // PARTE 1 DELLA STRATEGIA IBRIDA: Mantiene cache veloce (vinylCount)
  // RAW UPDATE: Query SQL personalizzata per operazioni aritmetiche
  // ATOMIC OPERATION: Incremento/decremento sicuro anche con accessi concorrenti
  // MOTIVAZIONE: Permette visualizzazione istantanea delle categorie senza query complesse
  Future<void> _updateCategoryCount(String categoryName, int delta) async {
    final db = await database;
    // RAW UPDATE: Permette operazioni aritmetiche direttamente in SQL
    // vinylCount + delta: Somma algebrica (delta può essere +1 o -1)
    // VANTAGGIO: Operazione atomica che previene race conditions
    await db.rawUpdate(
      'UPDATE ${AppConstants.categoryTable} SET vinylCount = vinylCount + ? WHERE name = ?',
      [delta, categoryName], // delta: +1 per aggiunta, -1 per rimozione
    );
  }

  // === METODI STATISTICI ===
  
  // Conta il numero totale di vinili nella collezione
  // RAW QUERY: Query SQL personalizzata per funzioni aggregate
  // COUNT(*): Funzione SQL che conta tutte le righe
  Future<int> getTotalVinylCount() async {
    final db = await database;
    // RAW QUERY: Permette di usare funzioni SQL avanzate
    // COUNT(*): Conta tutti i record nella tabella
    // AS count: Alias per il risultato della funzione
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.vinylTable}');
    // FIRST: Prende il primo (e unico) risultato
    // AS INT: Cast esplicito per type safety
    return result.first['count'] as int;
  }

  // PARTE 2 DELLA STRATEGIA IBRIDA: Source of Truth per conteggio accurato
  // Calcola la distribuzione dei vinili per genere musicale
  // MOTIVAZIONE: Questo metodo fornisce il conteggio REALE e ACCURATO,
  // utilizzato per verifiche di integrità e report statistici dettagliati
  // GROUP BY: Raggruppa i record per campo specifico
  // COUNT: Conta i record in ogni gruppo
  // Ottiene la distribuzione dei generi basata sui conteggi reali dei vinili
  // e include tutte le categorie dal database (anche quelle senza vinili)
  Future<Map<String, int>> getGenreDistribution() async {
    final db = await database;
    
    // 1. Ottieni conteggi dai vinili esistenti
    final List<Map<String, dynamic>> vinylResult = await db.rawQuery(
      'SELECT genre, COUNT(*) as count FROM ${AppConstants.vinylTable} GROUP BY genre ORDER BY count DESC'
    );
    
    // Converte il risultato SQL in Map Dart
    Map<String, int> distribution = {};
    for (var row in vinylResult) {
      distribution[row['genre']] = row['count'];
    }
    
    // 2. Aggiungi tutte le categorie dal database (predefinite e personalizzate)
    final List<Map<String, dynamic>> categoryResult = await db.query(
      AppConstants.categoryTable,
      columns: ['name']
    );
    
    // Aggiungi categorie con conteggio 0 se non già presenti
    for (var row in categoryResult) {
      final categoryName = row['name'] as String;
      if (!distribution.containsKey(categoryName)) {
        distribution[categoryName] = 0;
      }
    }
    
    return distribution;
  }
  
  // Recupera tutte le categorie dal database
  Future<List<models.Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.categoryTable,
      orderBy: 'isDefault DESC, name ASC', // Prima le predefinite, poi alfabetico
    );
    return List.generate(maps.length, (i) => models.Category.fromMap(maps[i]));
  }
  
  // Recupera solo le categorie predefinite
  Future<List<models.Category>> getDefaultCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.categoryTable,
      where: 'isDefault = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => models.Category.fromMap(maps[i]));
  }
  
  // Recupera solo le categorie personalizzate
  Future<List<models.Category>> getCustomCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.categoryTable,
      where: 'isDefault = ?',
      whereArgs: [0],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => models.Category.fromMap(maps[i]));
  }

  // Recupera i vinili più vecchi per anno di pubblicazione
  // ORDER BY ASC: Ordine crescente (più vecchi prima)
  Future<List<Vinyl>> getOldestVinyls({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.vinylTable,
      orderBy: 'year ASC',   // Ordina per anno crescente
      limit: limit,          // Limita i risultati
    );
    return List.generate(maps.length, (i) => Vinyl.fromMap(maps[i]));
  }

  // === RAGGRUPPAMENTO TEMPORALE: ANALISI CRONOLOGICA ===
  // 
  // Raggruppa i vinili per anno e mese di aggiunta alla collezione
  // STRUTTURA DATI: Map<Anno, Map<Mese, List<Vinyl>>>
  // MOTIVAZIONE: Permette analisi temporali dettagliate e visualizzazioni cronologiche
  // PATTERN: Nested Map per raggruppamento gerarchico
  // 
  // VANTAGGI:
  // - Accesso O(1) per anno specifico
  // - Accesso O(1) per mese specifico dentro un anno
  // - Struttura naturale per grafici temporali
  // - Facilita calcoli di crescita mensile/annuale
  // 
  // UTILIZZO:
  // - Grafici di crescita della collezione nel tempo
  // - Analisi stagionalità degli acquisti
  // - Report mensili/annuali
  // - Timeline interattive
  Future<Map<int, Map<int, List<Vinyl>>>> getVinylsByYearAndMonth() async {
    final db = await database;
    
    // QUERY: Recupera tutti i vinili ordinati per data di aggiunta
    // ORDER BY: Cronologico crescente per costruzione logica della timeline
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.vinylTable,
      orderBy: 'dateAdded ASC', // Dal più vecchio al più recente
    );
    
    // INIZIALIZZAZIONE: Struttura dati nested per raggruppamento
    // OUTER MAP: Anno -> Inner Map
    // INNER MAP: Mese -> Lista Vinili
    Map<int, Map<int, List<Vinyl>>> groupedVinyls = {};
    
    // PROCESSING: Itera attraverso ogni vinile per raggruppamento
    for (var map in maps) {
      // CONVERSION: Converte Map SQL in oggetto Vinyl tipizzato
      Vinyl vinyl = Vinyl.fromMap(map);
      
      // PARSING: Estrae anno e mese dalla data di aggiunta
      // NOTA: vinyl.dateAdded è già un DateTime (convertito in fromMap)
      // EXTRACT: Estrae componenti temporali dall'oggetto DateTime
      int year = vinyl.dateAdded.year;   // Estrae anno (es: 2024)
      int month = vinyl.dateAdded.month; // Estrae mese (1-12)
      
      // NESTED INITIALIZATION: Crea strutture se non esistono
      // PATTERN: Lazy initialization per evitare null pointer
      
      // LEVEL 1: Inizializza Map per l'anno se non esiste
      if (!groupedVinyls.containsKey(year)) {
        groupedVinyls[year] = <int, List<Vinyl>>{};
      }
      
      // LEVEL 2: Inizializza List per il mese se non esiste
      if (!groupedVinyls[year]!.containsKey(month)) {
        groupedVinyls[year]![month] = <Vinyl>[];
      }
      
      // INSERTION: Aggiunge il vinile alla lista appropriata
      // APPEND: Mantiene ordine cronologico all'interno del mese
      groupedVinyls[year]![month]!.add(vinyl);
    }
    
    return groupedVinyls;
  }
  
  // === METODI HELPER PER ANALISI TEMPORALE ===
  
  // Conta i vinili aggiunti per ogni mese di un anno specifico
  // UTILITY: Semplifica l'accesso ai conteggi mensili
  // RETURN: Map<Mese, Conteggio> per un anno specifico
  Future<Map<int, int>> getMonthlyCountForYear(int year) async {
    final groupedVinyls = await getVinylsByYearAndMonth();
    Map<int, int> monthlyCount = {};
    
    // INITIALIZATION: Inizializza tutti i mesi a 0
    // MOTIVO: Garantisce che tutti i mesi siano rappresentati anche se vuoti
    for (int month = 1; month <= 12; month++) {
      monthlyCount[month] = 0;
    }
    
    // COUNTING: Conta i vinili per ogni mese dell'anno specificato
    if (groupedVinyls.containsKey(year)) {
      groupedVinyls[year]!.forEach((month, vinyls) {
        monthlyCount[month] = vinyls.length;
      });
    }
    
    return monthlyCount;
  }
  
  // Conta i vinili aggiunti per ogni anno
  // AGGREGATION: Somma tutti i mesi per ottenere totale annuale
  // RETURN: Map<Anno, Conteggio> per tutti gli anni
  Future<Map<int, int>> getYearlyCount() async {
    final groupedVinyls = await getVinylsByYearAndMonth();
    Map<int, int> yearlyCount = {};
    
    // AGGREGATION: Somma i vinili di tutti i mesi per ogni anno
    groupedVinyls.forEach((year, monthsMap) {
      int totalForYear = 0;
      monthsMap.forEach((month, vinyls) {
        totalForYear += vinyls.length;
      });
      yearlyCount[year] = totalForYear;
    });
    
    return yearlyCount;
  }
  
  // Recupera i vinili di un mese specifico
  // DIRECT ACCESS: Accesso diretto a un sottoinsieme temporale
  // PARAMETERS: Anno e mese specifici
  // RETURN: Lista vinili per il periodo specificato
  Future<List<Vinyl>> getVinylsForMonth(int year, int month) async {
    final groupedVinyls = await getVinylsByYearAndMonth();
    
    // SAFE ACCESS: Verifica esistenza prima dell'accesso
    if (groupedVinyls.containsKey(year) && 
        groupedVinyls[year]!.containsKey(month)) {
      return groupedVinyls[year]![month]!;
    }
    
    // EMPTY RESULT: Restituisce lista vuota se non trovato
    return <Vinyl>[];
  }

  // === OPERAZIONI CRUD PER CANZONI ===
  
  // Inserisce una nuova canzone associata a un vinile
  // FOREIGN KEY: vinylId deve esistere nella tabella vinili
  Future<int> insertSong(Song song, int vinylId) async {
    final db = await database;
    // Crea una mappa con i dati della canzone includendo vinylId
    Map<String, dynamic> songMap = song.toMap();
    songMap['vinylId'] = vinylId;
    
    return await db.insert(AppConstants.songsTable, songMap);
  }
  
  // Recupera tutte le canzoni di un vinile specifico
  // JOIN: Collega le tabelle vinili e canzoni tramite foreign key
  Future<List<Song>> getSongsByVinylId(int vinylId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'vinylId = ?',
      whereArgs: [vinylId],
      orderBy: 'trackNumber ASC', // Ordina per numero di traccia
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }
  
  // Aggiorna una canzone esistente
  Future<void> updateSong(Song song) async {
    final db = await database;
    await db.update(
      AppConstants.songsTable,
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }
  
  // Elimina una canzone specifica
  Future<void> deleteSong(int songId) async {
    final db = await database;
    await db.delete(
      AppConstants.songsTable,
      where: 'id = ?',
      whereArgs: [songId],
    );
  }
  
  // Elimina tutte le canzoni di un vinile
  // UTILIZZATO: Quando si elimina un vinile o si vuole rimuovere tutte le tracce
  Future<void> deleteSongsByVinylId(int vinylId) async {
    final db = await database;
    await db.delete(
      AppConstants.songsTable,
      where: 'vinylId = ?',
      whereArgs: [vinylId],
    );
  }
  
  // Inserisce multiple canzoni per un vinile in una transazione
  // TRANSAZIONE: Garantisce che tutte le canzoni vengano inserite o nessuna
  Future<void> insertSongsForVinyl(List<Song> songs, int vinylId) async {
    final db = await database;
    await db.transaction((txn) async {
      for (Song song in songs) {
        Map<String, dynamic> songMap = song.toMap();
        songMap['vinylId'] = vinylId;
        await txn.insert(AppConstants.songsTable, songMap);
      }
    });
  }

  // === OPERAZIONI CRUD AGGIUNTIVE PER CATEGORIE ===
  
  // Inserisce una nuova categoria nel database
  Future<int> insertCategory(models.Category category) async {
    final db = await database;
    return await db.insert(AppConstants.categoryTable, category.toMap());
  }
  
  // Aggiorna una categoria esistente
  Future<void> updateCategory(models.Category category) async {
    final db = await database;
    await db.update(
      AppConstants.categoryTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }
  
  // Elimina una categoria
  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete(
      AppConstants.categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Recupera una categoria per nome
  Future<models.Category?> getCategoryByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.categoryTable,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return models.Category.fromMap(maps.first);
    }
    return null;
  }

  // Chiude la connessione al database
  // CLEANUP: Libera le risorse quando l'app viene chiusa
  // IMPORTANTE: Chiamare sempre per evitare memory leaks
  Future<void> close() async {
    final db = await database;
    // CLOSE: Chiude la connessione e libera le risorse
    await db.close();
  }
}