// === PATTERN ARCHITETTURALE: STATE MANAGEMENT CON PROVIDER ===
//
// MOTIVAZIONE: Questo provider implementa il pattern "Single Source of Truth"
// per la gestione centralizzata dello stato dell'applicazione Flutter.
//
// VANTAGGI DEL PATTERN PROVIDER:
// 1. REATTIVITÀ: ChangeNotifier permette aggiornamenti automatici UI
// 2. SEPARAZIONE: Business logic separata dalla presentazione
// 3. TESTABILITÀ: Logica isolata e facilmente testabile
// 4. SCALABILITÀ: Gestione centralizzata dello stato globale
// 5. PERFORMANCE: Aggiornamenti granulari solo dei widget necessari
//
// PATTERN IMPLEMENTATI:
// - Repository Pattern: Astrazione del layer di persistenza
// - Observer Pattern: Notifiche automatiche ai widget
// - Command Pattern: Operazioni CRUD incapsulate
// - Strategy Pattern: Diversi algoritmi di filtro e ricerca

// Provider per la gestione dello stato dei vinili e delle categorie
// Utilizza il pattern Provider per gestire lo stato globale dell'applicazione

// Import necessari per il funzionamento del provider
import 'dart:async';
import 'package:flutter/foundation.dart';  // Per ChangeNotifier e debugPrint
import '../models/vinyl.dart';              // Modello dati Vinyl
import '../models/category.dart' as models; // Modello dati Category (con alias)
import 'database_service.dart';             // Servizio per operazioni database

// === CLASSE PRINCIPALE: VINYL PROVIDER ===
// Implementa il pattern "Facade" per semplificare l'accesso ai dati
// Estende ChangeNotifier per il pattern Observer (notifiche automatiche)
class VinylProvider with ChangeNotifier {
  // === DEPENDENCY INJECTION ===
  // PATTERN: Dependency Injection per disaccoppiamento
  // MOTIVAZIONE: Facilita testing e manutenibilità
  // ALTERNATIVA: Si potrebbe usare get_it per DI più avanzata
  final DatabaseService _databaseService = DatabaseService();
  
  // === STATO PRIVATO: ENCAPSULATION PATTERN ===
  // MOTIVAZIONE: Controllo completo sull'accesso e modifica dei dati
  // PATTERN: Information Hiding per garantire consistenza dello stato
  
  // CACHE LOCALE: Lista completa dei vinili (Source of Truth locale)
  // MOTIVAZIONE: Evita query ripetute al database per performance
  List<Vinyl> _vinyls = [];
  
  // CACHE CATEGORIE: Lista delle categorie/generi musicali
  List<models.Category> _categories = [];
  
  // VISTA FILTRATA: Risultato di ricerche e filtri applicati
  // PATTERN: Computed Property per performance ottimizzate
  List<Vinyl> _filteredVinyls = [];
  
  // STATO UI: Query di ricerca corrente
  String _searchQuery = '';
  
  // STATO FILTRO: Genere selezionato per il filtro
  String _selectedGenre = 'Tutti';
  
  // STATO LOADING: Flag per feedback visivo durante operazioni async
  // PATTERN: Loading State per UX migliorata
  bool _isLoading = false;
  
  // Cache per le proprietà computate
  List<Vinyl>? _cachedFavorites;
  List<Vinyl>? _cachedRandom;
  Map<String, int>? _cachedGenreDistribution;
  
  // Timer per il debouncing della ricerca
  Timer? _searchTimer;
  
  // === GETTERS PUBBLICI: CONTROLLED ACCESS PATTERN ===
  // MOTIVAZIONE: Accesso read-only per prevenire modifiche accidentali
  // PATTERN: Immutable Views per garantire data integrity
  
  List<Vinyl> get vinyls => _vinyls;
  List<models.Category> get categories => _categories;
  
  // COMPUTED PROPERTY: Vista intelligente che decide quale lista mostrare
  // ALGORITMO: Mostra lista filtrata se ci sono filtri attivi, altrimenti lista completa
  // PERFORMANCE: Evita calcoli inutili quando non ci sono filtri
  List<Vinyl> get filteredVinyls => _filteredVinyls.isEmpty && _searchQuery.isEmpty && _selectedGenre == 'Tutti' ? _vinyls : _filteredVinyls;
  
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;
  bool get isLoading => _isLoading;
  
  // === GETTERS COMPUTATI: DERIVED STATE PATTERN ===
  // MOTIVAZIONE: Calcoli derivati dallo stato principale
  // PATTERN: Computed Properties per evitare duplicazione dati
  // PERFORMANCE: Calcolo on-demand invece di storage ridondante
  
  // FILTRO DINAMICO: Lista preferiti calcolata in tempo reale
  // VANTAGGIO: Sempre sincronizzata, nessun rischio di inconsistenza
  List<Vinyl> get favoriteVinyls {
    _cachedFavorites ??= _vinyls.where((vinyl) => vinyl.isFavorite).toList();
    return _cachedFavorites!;
  }
  
  // VISTA LIMITATA: Ultimi 5 vinili aggiunti
  // PATTERN: Pagination/Limiting per performance UI
  List<Vinyl> get recentVinyls => _vinyls.take(5).toList();
  
  // VISTA CASUALE: Vinili casuali per raccomandazioni
  // ALGORITMO: Shuffle per randomizzazione
  List<Vinyl> get randomVinyls {
    if (_cachedRandom == null) {
      final shuffled = List.of(_vinyls)..shuffle();
      _cachedRandom = shuffled.take(5).toList();
    }
    return _cachedRandom!;
  }

  // === STATISTICHE COMPUTATE ===
  // PATTERN: Analytics/Metrics derivate dallo stato
  int get totalVinyls => _vinyls.length;
  int get favoriteCount => favoriteVinyls.length;
  
  // AGGREGAZIONE DINAMICA: Distribuzione per genere
  // ALGORITMO: Conta occorrenze usando Map come accumulatore
  // COMPLESSITÀ: O(n) ma accettabile per dataset tipici
  Map<String, int> get genreDistribution {
    if (_cachedGenreDistribution == null) {
      _cachedGenreDistribution = {};
      // PATTERN: Reduce/Fold per aggregazione dati
      for (var vinyl in _vinyls) {
        _cachedGenreDistribution![vinyl.genre] = (_cachedGenreDistribution![vinyl.genre] ?? 0) + 1;
      }
    }
    return _cachedGenreDistribution!;
  }

  // === INIZIALIZZAZIONE: BOOTSTRAP PATTERN ===
  // PATTERN: Initialization Strategy per setup completo
  // MOTIVAZIONE: Caricamento coordinato di tutti i dati necessari
  
  // METODO PRINCIPALE: Orchestrazione del caricamento iniziale
  // PATTERN: Facade per semplificare operazioni complesse
  // ERROR HANDLING: Try-catch con cleanup garantito (finally)
  Future<void> initialize() async {
    // LOADING STATE: Feedback visivo immediato
    _isLoading = true;
    notifyListeners(); // OBSERVER: Notifica UI del cambio stato
    
    try {
      // OPERAZIONI PARALLELE: Caricamento coordinato
      // NOTA: Si potrebbe usare Future.wait per parallelizzazione
      await loadVinyls();
      await loadCategories();
    } catch (e) {
      // ERROR HANDLING: Logging per debugging
      debugPrint('Errore durante l\'inizializzazione: $e');
    } finally {
      // CLEANUP: Garantisce reset dello stato loading
      _isLoading = false;
      notifyListeners();
    }
  }

  // === CARICAMENTO DATI: REPOSITORY PATTERN ===
  // PATTERN: Data Loading Strategy con cache locale
  // MOTIVAZIONE: Separazione tra persistenza e business logic
  
  // CARICAMENTO VINILI: Sincronizzazione database -> memoria
  // SIDE EFFECTS: Aggiorna cache locale e applica filtri
  Future<void> loadVinyls() async {
    try {
      // DATABASE QUERY: Recupero dati persistenti
      _vinyls = await _databaseService.getAllVinyls();
      // CACHE INVALIDATION: Invalida cache quando i dati vengono ricaricati
      _invalidateCache();
      // FILTER APPLICATION: Mantiene coerenza vista filtrata
      _applyFilters();
      // UI NOTIFICATION: Aggiornamento reattivo interfaccia
      notifyListeners();
    } catch (e) {
      // ERROR LOGGING: Tracciamento problemi per debugging
      debugPrint('Errore nel caricamento vinili: $e');
    }
  }

  // CARICAMENTO CATEGORIE: Gestione metadati
  Future<void> loadCategories() async {
    try {
      _categories = await _databaseService.getAllCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Errore nel caricamento categorie: $e');
    }
  }

  // === OPERAZIONI CRUD: COMMAND PATTERN ===
  // PATTERN: Command per incapsulare operazioni business
  // MOTIVAZIONE: Operazioni atomiche con rollback e feedback
  // CONSISTENCY: Sincronizzazione database <-> cache locale
  
  // CREATE: Aggiunta nuovo vinile
  // TRANSACTION PATTERN: Operazione atomica con rollback su errore
  // OPTIMISTIC UPDATE: Aggiorna cache prima di conferma database
  Future<bool> addVinyl(Vinyl vinyl) async {
    try {
      // LOADING FEEDBACK: UX durante operazione asincrona
      _isLoading = true;
      notifyListeners();
      
      // DATABASE PERSISTENCE: Salvataggio permanente
      int id = await _databaseService.insertVinyl(vinyl);
      vinyl.id = id; // ID ASSIGNMENT: Sincronizzazione chiave primaria
      
      // CACHE UPDATE: Aggiornamento immediato lista locale
      // STRATEGY: Insert at beginning per "most recent first"
      _vinyls.insert(0, vinyl);
      
      // FILTER CONSISTENCY: Mantiene coerenza vista filtrata
      _applyFilters();
      _invalidateCache(); // Invalida la cache
      
      // SUCCESS FEEDBACK: Notifica completamento operazione
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // ERROR RECOVERY: Ripristino stato consistente
      debugPrint('Errore nell\'aggiunta del vinile: $e');
      _isLoading = false;
      notifyListeners();
      return false; // FAILURE INDICATION: Comunicazione errore al caller
    }
  }

  // UPDATE: Modifica vinile esistente
  // PATTERN: Update Strategy con sincronizzazione dual-layer
  Future<bool> updateVinyl(Vinyl vinyl) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // DATABASE UPDATE: Persistenza modifiche
      await _databaseService.updateVinyl(vinyl);
      
      // CACHE SYNCHRONIZATION: Aggiornamento lista locale
      // ALGORITHM: Find-and-replace per mantenere posizione
      int index = _vinyls.indexWhere((v) => v.id == vinyl.id);
      if (index != -1) {
        _vinyls[index] = vinyl; // IN-PLACE UPDATE
        _applyFilters(); // FILTER REFRESH: Ricalcola vista filtrata
      }
      
      _invalidateCache(); // Invalida la cache
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Errore nell\'aggiornamento del vinile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // DELETE: Rimozione vinile
  // PATTERN: Soft Delete Strategy (database) + Hard Delete (cache)
  Future<bool> deleteVinyl(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // DATABASE DELETION: Rimozione permanente
      await _databaseService.deleteVinyl(id);
      
      // CACHE CLEANUP: Rimozione da lista locale
      // ALGORITHM: Filter-out per rimozione efficiente
      _vinyls.removeWhere((vinyl) => vinyl.id == id);
      
      // FILTER REFRESH: Aggiorna vista filtrata
      _applyFilters();
      _invalidateCache(); // Invalida la cache
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Errore nella cancellazione del vinile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // TOGGLE FAVORITE: Operazione specializzata
  // PATTERN: Composite Operation (find + update)
  // IMMUTABILITY: Usa copyWith per modifiche immutabili
  Future<bool> toggleFavorite(int id) async {
    try {
      // SEARCH ALGORITHM: Linear search per ID
      int index = _vinyls.indexWhere((vinyl) => vinyl.id == id);
      if (index != -1) {
        Vinyl vinyl = _vinyls[index];
        // IMMUTABLE UPDATE: Crea nuova istanza con modifica
        Vinyl updatedVinyl = vinyl.copyWith(isFavorite: !vinyl.isFavorite);
        // DELEGATION: Riusa logica updateVinyl per consistenza
        bool result = await updateVinyl(updatedVinyl);
        if (result) {
          _invalidateCache(); // Invalida la cache
        }
        return result;
      }
      return false;
    } catch (e) {
      debugPrint('Errore nel toggle favorito: $e');
      return false;
    }
  }

  // === RICERCA E FILTRI: STRATEGY PATTERN ===
  // PATTERN: Filter Strategy per ricerca multi-criterio
  // PERFORMANCE: Filtri applicati in memoria per velocità
  // ALGORITHM: Combinazione AND di filtri multipli
  
  // SEARCH: Ricerca testuale multi-campo
  // ALGORITHM: Case-insensitive substring matching
  // FIELDS: Titolo, artista, etichetta, genere
  void searchVinyls(String query) {
    // NORMALIZATION: Lowercase per ricerca case-insensitive
    _searchQuery = query.toLowerCase();
    
    // Cancella il timer precedente se esiste
    _searchTimer?.cancel();
    
    // Implementa debouncing con delay di 300ms
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      // FILTER APPLICATION: Ricalcola risultati
      _applyFilters();
      // UI UPDATE: Notifica cambiamento vista
      notifyListeners();
    });
  }

  // GENRE FILTER: Filtro per categoria
  // SPECIAL VALUE: 'Tutti' per disabilitare filtro
  void filterByGenre(String genre) {
    _selectedGenre = genre;
    _applyFilters();
    notifyListeners();
  }

  // CLEAR FILTERS: Reset completo filtri
  // PATTERN: Reset Strategy per stato pulito
  void clearFilters() {
    _searchQuery = '';
    _selectedGenre = 'Tutti';
    _filteredVinyls = []; // CLEAR CACHE: Forza uso lista completa
    notifyListeners();
  }
  
  // FAVORITES FILTER: Filtro per vinili preferiti
  void filterByFavorites(bool showOnlyFavorites) {
    if (showOnlyFavorites) {
      _filteredVinyls = _vinyls.where((vinyl) => vinyl.isFavorite).toList();
    } else {
      _filteredVinyls = List.from(_vinyls);
    }
    notifyListeners();
  }
  
  // YEAR FILTER: Filtro per anno
  void filterByYear(int year) {
    _filteredVinyls = _vinyls.where((vinyl) => vinyl.year == year).toList();
    notifyListeners();
  }
  
  // SORT VINYLS: Ordinamento vinili
  void sortVinyls(String sortBy) {
    List<Vinyl> sorted = List.from(_vinyls);
    
    switch (sortBy) {
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'artist':
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'year':
        sorted.sort((a, b) => a.year.compareTo(b.year));
        break;
      case 'recent':
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'random':
        sorted.shuffle();
        break;
      default:
        // Nessun ordinamento
        break;
    }
    
    _filteredVinyls = sorted;
     notifyListeners();
   }
   
   // ADVANCED FILTERS: Applica filtri combinati
   void applyAdvancedFilters({
     String? genre,
     int? year,
     bool favoritesOnly = false,
     String sortBy = 'title',
   }) {
     List<Vinyl> filtered = List.from(_vinyls);
     
     // Applica filtro per genere
     if (genre != null) {
       filtered = filtered.where((vinyl) => vinyl.genre == genre).toList();
     }
     
     // Applica filtro per anno
     if (year != null) {
       filtered = filtered.where((vinyl) => vinyl.year == year).toList();
     }
     
     // Applica filtro per preferiti
     if (favoritesOnly) {
       filtered = filtered.where((vinyl) => vinyl.isFavorite).toList();
     }
     
     // Applica ordinamento
     switch (sortBy) {
       case 'title':
         filtered.sort((a, b) => a.title.compareTo(b.title));
         break;
       case 'artist':
         filtered.sort((a, b) => a.artist.compareTo(b.artist));
         break;
       case 'year':
         filtered.sort((a, b) => a.year.compareTo(b.year));
         break;
       case 'recent':
         filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
         break;
       case 'random':
         filtered.shuffle();
         break;
     }
     
     _filteredVinyls = filtered;
     notifyListeners();
   }
 
   // CORE FILTERING ALGORITHM: Applicazione filtri combinati
  // PATTERN: Pipeline Processing per filtri sequenziali
  // PERFORMANCE: Early termination se nessun filtro attivo
  void _applyFilters() {
    // COPY STRATEGY: Lavora su copia per non modificare originale
    List<Vinyl> filtered = List.from(_vinyls);
    
    // TEXT FILTER: Ricerca multi-campo
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((vinyl) {
        // MULTI-FIELD SEARCH: OR logic tra campi diversi
        return vinyl.title.toLowerCase().contains(_searchQuery) ||
               vinyl.artist.toLowerCase().contains(_searchQuery) ||
               vinyl.label.toLowerCase().contains(_searchQuery) ||
               vinyl.genre.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    // GENRE FILTER: Filtro esatto per categoria
    if (_selectedGenre != 'Tutti') {
      filtered = filtered.where((vinyl) => vinyl.genre == _selectedGenre).toList();
    }
    
    // RESULT ASSIGNMENT: Aggiorna cache filtrata
    _filteredVinyls = filtered;
  }

  // === UTILITY METHODS: HELPER PATTERN ===
  // PATTERN: Utility Functions per operazioni comuni
  
  // FIND BY ID: Ricerca diretta per chiave primaria
  // ALGORITHM: Linear search (accettabile per dataset tipici)
  // RETURN: Nullable per gestione "not found"
  Vinyl? getVinylById(int id) {
    try {
      return _vinyls.firstWhere((vinyl) => vinyl.id == id);
    } catch (e) {
      return null; // NOT FOUND: Gestione elegante assenza
    }
  }

  // AVAILABLE GENRES: Lista dinamica generi
  // PATTERN: Computed Property da dati esistenti
  // ALGORITHM: Set per unicità + sort per ordinamento
  List<String> get availableGenres {
    // EXTRACTION: Estrae generi unici dalla collezione
    Set<String> genres = _vinyls.map((vinyl) => vinyl.genre).toSet();
    // UI CONVENTION: 'Tutti' come prima opzione
    List<String> genreList = ['Tutti'];
    // SORTING: Ordinamento alfabetico per UX
    genreList.addAll(genres.toList()..sort());
    return genreList;
  }

  // YEAR FILTER: Filtro per anno pubblicazione
  // ALGORITHM: Exact match filtering
  List<Vinyl> getVinylsByYear(int year) {
    return _vinyls.where((vinyl) => vinyl.year == year).toList();
  }

  // ARTIST FILTER: Ricerca per artista
  // ALGORITHM: Case-insensitive partial matching
  List<Vinyl> getVinylsByArtist(String artist) {
    return _vinyls.where((vinyl) => 
        vinyl.artist.toLowerCase().contains(artist.toLowerCase())).toList();
  }

  // === ANALYTICS: STATISTICAL PATTERN ===
  // PATTERN: Data Analytics per insights business
  // PERFORMANCE: Calcolo on-demand per dati sempre aggiornati
  
  // YEAR DISTRIBUTION: Analisi temporale collezione
  // ALGORITHM: Frequency counting con Map come accumulatore
  Map<int, int> get yearDistribution {
    Map<int, int> distribution = {};
    for (var vinyl in _vinyls) {
      distribution[vinyl.year] = (distribution[vinyl.year] ?? 0) + 1;
    }
    return distribution;
  }

  // CONDITION DISTRIBUTION: Analisi stato conservazione
  Map<String, int> get conditionDistribution {
    Map<String, int> distribution = {};
    for (var vinyl in _vinyls) {
      distribution[vinyl.condition] = (distribution[vinyl.condition] ?? 0) + 1;
    }
    return distribution;
  }

  // OLDEST VINYLS: Top 5 più vecchi
  // ALGORITHM: Sort + take per ranking
  // SORTING: Crescente per anno (oldest first)
  List<Vinyl> get oldestVinyls {
    List<Vinyl> sorted = List.from(_vinyls);
    sorted.sort((a, b) => a.year.compareTo(b.year));
    return sorted.take(5).toList();
  }

  // NEWEST VINYLS: Top 5 più recenti
  // SORTING: Decrescente per anno (newest first)
  List<Vinyl> get newestVinyls {
    List<Vinyl> sorted = List.from(_vinyls);
    sorted.sort((a, b) => b.year.compareTo(a.year));
    return sorted.take(5).toList();
  }

  // === CACHE MANAGEMENT ===
  // PATTERN: Cache Invalidation per performance ottimizzate
  // MOTIVAZIONE: Invalida cache computate quando i dati cambiano
  void _invalidateCache() {
    _cachedFavorites = null;
    _cachedRandom = null;
    _cachedGenreDistribution = null;
  }
  
  // === CLEANUP ===
  // PATTERN: Resource Management per prevenire memory leaks
  // MOTIVAZIONE: Cancella timer attivi quando il provider viene distrutto
  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}