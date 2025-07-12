// Modello per rappresentare un vinile nella collezione

// Contiene tutte le informazioni necessarie per catalogare un disco in vinile

import 'song_.dart';

// Classe che definisce la struttura dati per i vinili
class Vinyl {
  // ID univoco del vinile (auto-incrementale nel database)
  // Nullable perché viene assegnato dal database alla creazione
  int? id;
  
  // Titolo dell'album o del singolo
  // Campo obbligatorio per identificare il disco
  String title;
  
  // Nome dell'artista o del gruppo musicale
  // Campo obbligatorio per l'identificazione
  String artist;
  
  // Anno di pubblicazione del vinile
  // Utilizzato per ordinamento cronologico e ricerche
  int year;
  
  // Genere musicale del vinile
  // Collegato alle categorie per organizzazione
  String genre;
  
  // Casa discografica che ha pubblicato il vinile
  // Informazione importante per collezionisti
  String label;
  
  // Condizione fisica del vinile
  // Deve corrispondere a uno dei valori in AppConstants.vinylConditions
  String condition;
  
  // Flag per indicare se il vinile è tra i preferiti
  // Utilizzato per filtri e visualizzazioni speciali
  bool isFavorite;
  
  // Percorso dell'immagine di copertina (opzionale)
  // Può essere un file locale o un URL
  String? imagePath;
  
  // Data di aggiunta alla collezione
  // Utilizzata per ordinamento e statistiche
  DateTime dateAdded;
  
  // Note personali sul vinile (opzionali)
  // Spazio per commenti, ricordi, dettagli tecnici
  String? notes;

  // Canzoni contenute nel disco
 List<Song>? song;

  // Costruttore della classe Vinyl
  // I campi principali sono obbligatori, altri hanno valori di default
  Vinyl({
    this.id,                        // ID assegnato dal database
    required this.title,            // Titolo obbligatorio
    required this.artist,           // Artista obbligatorio
    required this.year,             // Anno obbligatorio
    required this.genre,            // Genere obbligatorio
    required this.label,            // Etichetta obbligatoria
    required this.condition,        // Condizione obbligatoria
    this.isFavorite = false,        // Default: non è un preferito
    this.imagePath,                 // Immagine opzionale
    DateTime? dateAdded,            // Data opzionale
    this.notes,                     // Note opzionali
    this.song,                      // Lista di Canzoni opzionali
  }) : dateAdded = dateAdded ?? DateTime.now(); // Se non fornita, usa data corrente

  // Factory constructor per creare Vinyl da Map del database
  // Utilizzato quando si leggono dati dal database SQLite
  factory Vinyl.fromMap(Map<String, dynamic> map) {
    return Vinyl(
      id: map['id'],                              // ID dal database
      title: map['title'],                        // Titolo dal database
      artist: map['artist'],                      // Artista dal database
      year: map['year'],                          // Anno dal database
      genre: map['genre'],                        // Genere dal database
      label: map['label'],                        // Etichetta dal database
      condition: map['condition'],                // Condizione dal database
      isFavorite: map['isFavorite'] == 1,         // Conversione da int a bool (SQLite)
      imagePath: map['imagePath'],                // Percorso immagine dal database
      dateAdded: DateTime.parse(map['dateAdded']), // Parsing della data ISO
      notes: map['notes'],                        // Note dal database
    );
  }

  // Metodo per convertire Vinyl in Map per il database
  // Utilizzato quando si salvano dati nel database SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,                                   // ID (può essere null per nuovi record)
      'title': title,                             // Titolo dell'album
      'artist': artist,                           // Nome dell'artista
      'year': year,                               // Anno di pubblicazione
      'genre': genre,                             // Genere musicale
      'label': label,                             // Casa discografica
      'condition': condition,                     // Condizione fisica
      'isFavorite': isFavorite ? 1 : 0,          // Conversione da bool a int (SQLite)
      'imagePath': imagePath,                     // Percorso immagine (può essere null)
      'dateAdded': dateAdded.toIso8601String(),   // Data in formato ISO string
      'notes': notes,                             // Note personali (può essere null)
    };
  }

  // Metodo per creare una copia del vinile con alcune modifiche
  // Utile per aggiornamenti immutabili dello stato
  Vinyl copyWith({
    int? id,                    // Nuovo ID (opzionale)
    String? title,              // Nuovo titolo (opzionale)
    String? artist,             // Nuovo artista (opzionale)
    int? year,                  // Nuovo anno (opzionale)
    String? genre,              // Nuovo genere (opzionale)
    String? label,              // Nuova etichetta (opzionale)
    String? condition,          // Nuova condizione (opzionale)
    bool? isFavorite,           // Nuovo stato preferito (opzionale)
    String? imagePath,          // Nuovo percorso immagine (opzionale)
    DateTime? dateAdded,        // Nuova data aggiunta (opzionale)
    String? notes,              // Nuove note (opzionale)
  }) {
    return Vinyl(
      id: id ?? this.id,                           // Usa nuovo ID o mantieni quello esistente
      title: title ?? this.title,                 // Usa nuovo titolo o mantieni quello esistente
      artist: artist ?? this.artist,              // Usa nuovo artista o mantieni quello esistente
      year: year ?? this.year,                    // Usa nuovo anno o mantieni quello esistente
      genre: genre ?? this.genre,                 // Usa nuovo genere o mantieni quello esistente
      label: label ?? this.label,                 // Usa nuova etichetta o mantieni quella esistente
      condition: condition ?? this.condition,     // Usa nuova condizione o mantieni quella esistente
      isFavorite: isFavorite ?? this.isFavorite,  // Usa nuovo stato o mantieni quello esistente
      imagePath: imagePath ?? this.imagePath,     // Usa nuovo percorso o mantieni quello esistente
      dateAdded: dateAdded ?? this.dateAdded,     // Usa nuova data o mantieni quella esistente
      notes: notes ?? this.notes,                 // Usa nuove note o mantieni quelle esistenti
    );
  }

  // Override del metodo toString per debug e logging
  // Mostra le informazioni principali del vinile
  @override
  String toString() {
    return 'Vinyl{id: $id, title: $title, artist: $artist, year: $year}';
  }
}