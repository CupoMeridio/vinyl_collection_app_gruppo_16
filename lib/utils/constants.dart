// Costanti dell'applicazione Vinyl Collection
// Centralizza tutti i valori utilizzati nell'app per facilità di manutenzione

// Import di Material Design per utilizzare il tipo Color
import 'package:flutter/material.dart';

// Classe che contiene tutte le costanti dell'applicazione
// Utilizza static const per valori immutabili e ottimizzazioni di memoria
class AppConstants {
  // === COLORI DEL TEMA ===
  // Colore primario dell'app: blu Material Design
  static const Color primaryColor = Color(0xFF1976D2);
  // Colore di accento: arancione per elementi di evidenziazione
  static const Color accentColor = Color(0xFFFF5722);
  // Colore di sfondo: grigio molto chiaro per le schermate
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  // === DIMENSIONI GENERALI ===
  // Padding standard utilizzato in tutta l'app
  static const double defaultPadding = 16.0;
  // Elevazione (ombra) delle card per effetto Material Design
  static const double cardElevation = 4.0;
  // Raggio dei bordi arrotondati per card, pulsanti e campi input
  static const double borderRadius = 8.0;
  
  // === PADDING SPECIFICI ===
  // Padding piccolo per elementi compatti
  static const double paddingSmall = 8.0;
  // Padding medio per la maggior parte degli elementi
  static const double paddingMedium = 16.0;
  // Padding grande per sezioni importanti
  static const double paddingLarge = 24.0;
  
  // === SPAZIATURE TRA ELEMENTI ===
  // Spazio piccolo tra elementi correlati
  static const double spacingSmall = 8.0;
  // Spazio medio tra sezioni
  static const double spacingMedium = 16.0;
  // Spazio grande tra sezioni principali
  static const double spacingLarge = 24.0;
  
  // === STRINGHE DELL'APPLICAZIONE ===
  // Nome dell'applicazione mostrato nell'interfaccia
  static const String appName = 'Vinyl Collection';
  // Nome del file database SQLite
  static const String databaseName = 'vinyl_collection.db';
  // Versione del database per gestire migrazioni future
  static const int databaseVersion = 2;
  
  // === TABELLE DEL DATABASE ===
  // Nome della tabella principale che contiene i dati dei vinili
  static const String vinylTable = 'vinili';
  // Nome della tabella che contiene le categorie/generi musicali
  static const String categoryTable = 'categorie';
  // Nome della tabella che contiene le canzoni dei vinili
  static const String songsTable = 'songs';
  
  // === CONDIZIONI DEI VINILI ===
  // Lista predefinita delle possibili condizioni di conservazione
  // Ordinata dalla migliore alla peggiore condizione
  static const List<String> vinylConditions = [
    'Nuovo',        // Vinile mai utilizzato, perfetto
    'Ottimo',       // Vinile usato pochissimo, quasi perfetto
    'Buono',        // Vinile usato ma in buone condizioni
    'Discreto',     // Vinile con segni di usura ma funzionante
    'Da restaurare' // Vinile danneggiato che necessita riparazione
  ];
  
  // Generi musicali predefiniti
  static const List<String> defaultGenres = [
    'Rock',
    'Pop',
    'Jazz',
    'Blues',
    'Classical',
    'Electronic',
    'Hip Hop',
    'Country',
    'Folk',
    'Reggae',
    'Punk',
    'Metal',
    'R&B',
    'Soul',
    'Funk'
  ];
  
  // === COLORI DEI GENERI MUSICALI ===
  // Mappa che associa ogni genere musicale a un colore specifico
  // Utilizzata per la visualizzazione coerente dei generi nell'interfaccia
  static const Map<String, Color> genreColors = {
    'Rock': Colors.red,
    'Pop': Colors.blue,
    'Jazz': Colors.green,
    'Blues': Colors.brown,
    'Classical': Colors.purple,
    'Electronic': Colors.cyan,
    'Hip Hop': Colors.orange,
    'Country': Colors.lime,
    'Folk': Colors.teal,
    'Reggae': Colors.lightGreen,
    'Punk': Colors.pink,
    'Metal': Colors.grey,
    'R&B': Colors.deepPurple,
    'Soul': Colors.amber,
    'Funk': Colors.deepOrange,
  };
  
  // Metodo helper per ottenere il colore di un genere
  // Restituisce un colore di default se il genere non è trovato
  static Color getGenreColor(String genre) {
    return genreColors[genre] ?? Colors.indigo;
  }
}