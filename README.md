# 🎵 Vinyl Collection App - Documentazione Tecnica

**Gruppo 16 - Mobile Programming**  
*Università degli studi di Salerno*  
*Anno Accademico: 2024/2025*

---

## 📋 Indice

1. [Panoramica del Progetto](#panoramica-del-progetto)
2. [Architettura e Design Pattern](#architettura-e-design-pattern)
3. [Modelli Dati](#modelli-dati)
4. [Funzionalità Implementate](#funzionalità-implementate)
5. [Tecnologie Utilizzate](#tecnologie-utilizzate)
6. [Struttura del Progetto](#struttura-del-progetto)
7. [Database Design](#database-design)
8. [Interfaccia Utente](#interfaccia-utente)
9. [Testing e Qualità](#testing-e-qualità)
10. [Team di Sviluppo](#team-di-sviluppo)

---

## 🎯 Panoramica del Progetto

### Descrizione
Vinyl Collection App è un'applicazione mobile sviluppata in Flutter che permette agli utenti di gestire e catalogare la propria collezione di dischi in vinile. L'app offre funzionalità complete per l'aggiunta, modifica, ricerca e analisi dei vinili, con un'interfaccia moderna e intuitiva.

### Obiettivi
- **Catalogazione Completa**: Gestione dettagliata di ogni vinile con metadati completi
- **Ricerca Avanzata**: Sistema di filtri e ricerca testuale multi-campo
- **Analisi Statistica**: Visualizzazione di grafici e statistiche della collezione
- **Usabilità**: Interfaccia responsive e user-friendly
- **Performance**: Ottimizzazioni per collezioni di grandi dimensioni

---

## 🏗️ Architettura e Design Pattern

### Pattern Architetturali Implementati

#### 1. **Provider Pattern (State Management)**
```dart
// Gestione centralizzata dello stato
ChangeNotifierProvider(
  create: (context) => VinylProvider()..initialize(),
  child: MaterialApp(...)
)
```
- **Scopo**: Single Source of Truth per lo stato globale
- **Vantaggi**: Reattività UI, separazione business logic, testabilità

#### 2. **Singleton Pattern (Database Service)**
```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
}
```
- **Scopo**: Unica istanza database per tutta l'applicazione
- **Vantaggi**: Evita connessioni duplicate, centralizza gestione stato

#### 3. **Repository Pattern**
- **Scopo**: Astrazione layer di persistenza
- **Implementazione**: `DatabaseService` aggrega operazioni CRUD
- **Vantaggi**: Isolamento logica persistenza, facilità testing

#### 4. **Observer Pattern**
- **Scopo**: Aggiornamenti automatici UI
- **Implementazione**: `ChangeNotifier` + `Consumer` widgets
- **Vantaggi**: Reattività interfaccia, performance ottimizzate

#### 5. **Factory Pattern**
- **Scopo**: Creazione oggetti da dati database
- **Implementazione**: `fromMap()` constructors nei modelli
- **Vantaggi**: Parsing sicuro, validazione dati

### Strategie Avanzate

#### Dual Counting Strategy
```dart
// Cache veloce per UI
int vinylCount; // Aggiornato in tempo reale

// Source of Truth per accuratezza
Future<Map<String, int>> getGenreDistribution() {
  // Query aggregata GROUP BY COUNT
}
```

#### Lazy Initialization
```dart
Future<Database> get database async {
  if (_database != null) return _database!;
  _database = await _initDatabase();
  return _database!;
}
```

---

## 📊 Modelli Dati

### Vinyl (Modello Principale)
```dart
class Vinyl {
  int? id;
  String title;           // Titolo album
  String artist;          // Artista
  int year;              // Anno pubblicazione
  String genre;          // Genere musicale
  String label;          // Casa discografica
  String condition;      // Condizione fisica
  bool isFavorite;       // Flag preferito
  String? imagePath;     // Percorso immagine
  DateTime dateAdded;    // Data aggiunta
  String? notes;         // Note personali
  List<Song>? song;      // Lista canzoni
}
```

### Category (Generi Musicali)
```dart
class Category {
  int? id;
  String name;           // Nome categoria
  String? description;   // Descrizione
  int vinylCount;        // Contatore vinili
  DateTime dateCreated;  // Data creazione
  bool isDefault;        // Flag categoria predefinita
}
```

### Song (Tracce Audio)
```dart
class Song {
  int? id;
  int? vinylId;          // Foreign key
  String titolo;         // Titolo canzone
  String artista;        // Artista
  int anno;             // Anno
  int? trackNumber;     // Numero traccia
  String? duration;     // Durata
}
```

---

## ⚡ Funzionalità Implementate

### 🏠 Dashboard Principale
- **Vinili Recenti**: Ultimi 5 vinili aggiunti
- **Preferiti**: Collezione vinili marcati come favoriti
- **Consigliati**: Selezione casuale per scoperta
- **Statistiche Rapide**: Contatori e metriche
- **Accesso Categorie**: Navigazione per genere

### 🔍 Ricerca e Filtri
- **Ricerca Testuale**: Multi-campo (titolo, artista, etichetta)
- **Filtri Avanzati**:
  - Genere musicale
  - Anno di pubblicazione
  - Condizione del vinile
  - Solo preferiti
- **Ordinamento**: Per titolo, artista, anno, data aggiunta
- **Risultati Real-time**: Aggiornamento istantaneo

### 📈 Analisi e Statistiche
- **Grafico a Torta**: Distribuzione per genere
- **Grafico Temporale**: Crescita collezione nel tempo
- **Top Lists**: Vinili più vecchi, più recenti
- **Metriche**: Totali, percentuali, trend

### ➕ Gestione Vinili
- **CRUD Completo**: Create, Read, Update, Delete
- **Upload Immagini**: Copertine con anteprima
- **Gestione Tracklist**: Aggiunta canzoni complete
- **Validazione Dati**: Controlli input e consistenza

### 🏷️ Gestione Categorie
- **Categorie Predefinite**: 15 generi musicali standard
- **Categorie Custom**: Creazione generi personalizzati
- **Contatori Automatici**: Aggiornamento in tempo reale
- **Protezione Sistema**: Categorie predefinite non eliminabili

---

## 🛠️ Tecnologie Utilizzate

### Framework e Linguaggi
- **Flutter 3.8+**: Framework UI cross-platform
- **Dart**: Linguaggio di programmazione
- **Material Design 3**: Design system Google

### Database e Persistenza
- **SQLite**: Database locale embedded
- **sqflite**: Plugin Flutter per SQLite
- **sqflite_common_ffi**: Supporto desktop/web

### State Management
- **Provider 6.1+**: Gestione stato reattiva
- **ChangeNotifier**: Pattern Observer

### UI e Visualizzazione
- **fl_chart 0.65+**: Libreria grafici interattivi
- **image_picker 1.0+**: Selezione immagini

### Supporto Multi-piattaforma
- **Android**: Supporto nativo
- **iOS**: Supporto nativo
- **Web**: Tramite sqflite_common_ffi_web

---

## 📁 Struttura del Progetto

```
lib/
├── main.dart                    # Entry point applicazione
├── models/                      # Modelli dati
│   ├── vinyl.dart              # Modello vinile
│   ├── category.dart           # Modello categoria
│   ├── song_.dart              # Modello canzone
│   └── section.dart            # Modello sezione UI
├── services/                    # Business logic
│   ├── database_service.dart   # Servizio database
│   └── vinyl_provider.dart     # Provider stato globale
├── screens/                     # Schermate UI
│   ├── schermata_principale.dart
│   ├── home_view.dart
│   ├── search_view.dart
│   ├── analisi_view.dart
│   ├── add_edit_vinyl_screen.dart
│   ├── dettaglio_vinile.dart
│   ├── categorie_view.dart
│   └── genre_vinyls_view.dart
└── utils/                       # Utilità e costanti
    ├── constants.dart          # Costanti applicazione
    ├── grafico.dart           # Widget grafici
    ├── drop_down.dart         # Widget dropdown
    └── schermo_adattivo.dart  # Responsive design
```

---

## 🗄️ Database Design

### Schema Tabelle

#### Tabella `vinili`
```sql
CREATE TABLE vinili (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  artist TEXT NOT NULL,
  year INTEGER NOT NULL,
  genre TEXT NOT NULL,
  label TEXT NOT NULL,
  condition TEXT NOT NULL,
  isFavorite INTEGER NOT NULL DEFAULT 0,
  imagePath TEXT,
  dateAdded TEXT NOT NULL,
  notes TEXT
);
```

#### Tabella `categorie`
```sql
CREATE TABLE categorie (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  vinylCount INTEGER NOT NULL DEFAULT 0,
  isDefault INTEGER NOT NULL DEFAULT 0,
  dateCreated TEXT NOT NULL
);
```

#### Tabella `songs`
```sql
CREATE TABLE songs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vinylId INTEGER NOT NULL,
  titolo TEXT NOT NULL,
  artista TEXT NOT NULL,
  anno INTEGER NOT NULL,
  trackNumber INTEGER,
  duration TEXT,
  FOREIGN KEY (vinylId) REFERENCES vinili (id) ON DELETE CASCADE
);
```

### Relazioni
- **Vinyl ↔ Category**: Relazione 1:N (un genere, molti vinili)
- **Vinyl ↔ Song**: Relazione 1:N (un vinile, molte canzoni)
- **Integrità Referenziale**: CASCADE DELETE per canzoni

---

## 🎨 Interfaccia Utente

### Navigazione
- **Bottom Navigation**: 3 tab principali (Home, Ricerca, Analisi)
- **Floating Action Button**: Aggiunta rapida vinili
- **Navigation Routes**: Sistema routing nominato

### Responsive Design
- **Mobile First**: Ottimizzato per smartphone
- **Tablet Support**: Layout adattivo
- **Desktop Ready**: Supporto schermi grandi

### Componenti Riutilizzabili
- **VinylCard**: Card vinile standardizzata
- **StatCard**: Card statistiche
- **FilterChip**: Chip filtri
- **CustomChart**: Grafici personalizzati

---

## 🧪 Testing e Qualità

### Attributi di Qualità

#### Manutenibilità
- **Separazione Concerns**: Architettura a layer
- **Documentazione**: Commenti estensivi nel codice
- **Naming Convention**: Nomenclatura consistente
- **Code Organization**: Struttura modulare

#### Scalabilità
- **Database Ottimizzato**: Indici e query efficienti
- **Lazy Loading**: Caricamento dati on-demand
- **Pagination**: Supporto liste grandi
- **Memory Management**: Gestione memoria ottimizzata

#### Usabilità
- **Interfaccia Intuitiva**: Design user-centered
- **Feedback Visivo**: Loading states, animazioni
- **Error Handling**: Gestione errori graceful
- **Accessibility**: Supporto screen reader

#### Performance
- **Database Indexing**: Query ottimizzate
- **Widget Optimization**: Rebuild minimizzati
- **Image Caching**: Cache immagini locale
- **Async Operations**: Operazioni non bloccanti

---

## 👥 Team di Sviluppo

**Gruppo 16 - Mobile Programming**

- [Angela Monti](https://github.com/MontiAngela)
- [Vittorio Postiglione](https://github.com/CupoMeridio)
- [Mattia Sanzari](https://github.com/Mattia-Sanzari)
- [Sharon Schiavano](https://github.com/sharon-schiavano)
- [Valerio Volzone](https://github.com/valioh1)

---

## 📚 Riferimenti e Risorse

### Documentazione Tecnica
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [fl_chart Documentation](https://pub.dev/packages/fl_chart)

### Design Guidelines
- [Material Design 3](https://m3.material.io/)
- [Flutter Design Patterns](https://flutterdesignpatterns.com/)

### Best Practices
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

---
