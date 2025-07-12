// === PATTERN ARCHITETTURALE: DEPENDENCY INJECTION + STATE MANAGEMENT ===
//
// MOTIVAZIONE: Questo file implementa il pattern "Dependency Injection" a livello root
// per fornire il VinylProvider a tutta l'applicazione attraverso l'albero dei widget.
//
// VANTAGGI DEL PATTERN PROVIDER A LIVELLO ROOT:
// 1. SINGLE SOURCE OF TRUTH: Un'unica istanza del provider per tutta l'app
// 2. AUTOMATIC DISPOSAL: Flutter gestisce automaticamente il cleanup del provider
// 3. PERFORMANCE: Evita ricreazioni multiple del provider
// 4. ACCESSIBILITY: Tutti i widget figli possono accedere al provider
// 5. TESTABILITY: Facilita l'injection di mock provider nei test
//
// PATTERN IMPLEMENTATI:
// - Dependency Injection Pattern: Provider iniettato a livello root
// - Observer Pattern: ChangeNotifierProvider per notifiche automatiche
// - Singleton Pattern: Una sola istanza di VinylProvider per l'intera app
// - Factory Pattern: create() function per istanziazione lazy del provider

// Import delle librerie Flutter necessarie per l'interfaccia utente
// CORE FRAMEWORK: Widgets, Material Design, rendering engine
import 'package:flutter/material.dart';

// Import del package Provider per la gestione dello stato dell'applicazione
// STATE MANAGEMENT: Implementa pattern Observer per reattività UI
// DEPENDENCY: provider ^6.0.0 (gestione stato reattiva)
import 'package:provider/provider.dart';

// Import del nostro provider personalizzato per la gestione dei dati dei vinili
// BUSINESS LOGIC: Centralizza logica applicativa e stato globale
import 'services/vinyl_provider.dart';

// Import delle costanti dell'applicazione (colori, dimensioni, stringhe)
// DESIGN SYSTEM: Centralizza valori di design per consistenza UI
import 'utils/constants.dart';

// Import della schermata principale con navigazione
import 'screens/schermata_principale.dart';

// === ENTRY POINT: BOOTSTRAP DELL'APPLICAZIONE ===
// PATTERN: Application Bootstrap con configurazione centralizzata
// MOTIVAZIONE: Punto di ingresso unico per inizializzazione e configurazione
void main() {
  // FRAMEWORK INITIALIZATION: Avvia il framework Flutter
  // WIDGET TREE: Costruisce l'albero dei widget partendo da VinylCollectionApp
  runApp(const VinylCollectionApp());
}

// === ROOT WIDGET: CONFIGURAZIONE ARCHITETTURALE ===
// PATTERN: Root Configuration Widget
// MOTIVAZIONE: Centralizza configurazione tema, provider e routing
// PERFORMANCE: StatelessWidget per evitare rebuild inutili del root
class VinylCollectionApp extends StatelessWidget {
  // IMMUTABILITY: Costruttore const per ottimizzazioni compile-time
  // PERFORMANCE: Permette a Flutter di riutilizzare l'istanza del widget
  const VinylCollectionApp({super.key});

  // === UI BUILDER: COSTRUZIONE ALBERO WIDGET ===
  // PATTERN: Builder Pattern per costruzione incrementale UI
  @override
  Widget build(BuildContext context) {
    // === DEPENDENCY INJECTION LAYER ===
    // PATTERN: Provider Pattern per Dependency Injection
    // SCOPE: Application-wide scope per stato globale
    // LIFECYCLE: Provider gestito automaticamente da Flutter
    return ChangeNotifierProvider(
      // === FACTORY PATTERN: LAZY INITIALIZATION ===
      // PATTERN: Factory Method per creazione controllata istanze
      // LAZY LOADING: Provider creato solo quando necessario
      // CASCADE OPERATOR: ..initialize() per chiamata fluent
      create: (context) => VinylProvider()..initialize(),
      
      // === MATERIAL APP: CONFIGURAZIONE FRAMEWORK ===
      // PATTERN: Configuration Object per setup applicazione
      child: MaterialApp(
        // === METADATA CONFIGURATION ===
        // APP IDENTITY: Identificazione applicazione per sistema operativo
        title: AppConstants.appName,
        
        // === DEVELOPMENT CONFIGURATION ===
        // DEBUG OPTIMIZATION: Rimuove banner debug in development
        // PRODUCTION: Automaticamente false in release build
        debugShowCheckedModeBanner: false,
        
        // === DESIGN SYSTEM: THEME CONFIGURATION ===
        // PATTERN: Theme Configuration Pattern
        // MOTIVAZIONE: Centralizza stili per consistenza UI globale
        theme: ThemeData(
          // === COLOR SYSTEM: MATERIAL DESIGN 3 ===
          // LEGACY SUPPORT: primarySwatch per compatibilità Material 2
          primarySwatch: Colors.deepPurple,
          
          // CUSTOM BRANDING: Colore primario personalizzato
          primaryColor: AppConstants.primaryColor,
          
          // === DYNAMIC COLOR SCHEME ===
          // PATTERN: Seed-based Color Generation
          // ALGORITHM: Genera palette completa da colore seed
          // ACCESSIBILITY: Contrasti automatici per accessibilità
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            brightness: Brightness.light, // Light theme configuration
          ),
          
          // === COMPONENT THEMES: DESIGN TOKENS ===
          // PATTERN: Component-specific Theme Configuration
          
          // APP BAR THEME: Configurazione barre superiori
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white, // Testo e icone
            elevation: 0, // Flat design - no shadow
          ),
          
          // CARD THEME: Configurazione componenti card
          cardTheme: CardThemeData(
            elevation: AppConstants.cardElevation, // Material elevation
            // SHAPE: Bordi arrotondati per design moderno
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          
          // INPUT THEME: Configurazione campi di input
          inputDecorationTheme: InputDecorationTheme(
            // BORDER STYLE: Outline border per chiarezza visiva
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            filled: true, // Background fill per migliore leggibilità
            fillColor: Colors.grey[50], // Subtle background color
          ),
          
          // BUTTON THEME: Configurazione pulsanti elevati
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              // SHAPE: Consistenza con altri componenti
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              // PADDING: Touch target optimization per usabilità
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
            ),
          ),
        ),
        
        // === INITIAL ROUTE: NAVIGATION BOOTSTRAP ===
        // PATTERN: Initial Screen Pattern
        // UX: Splash screen per perceived performance
        home: const SplashScreen(),
      ),
    );
  }
}

// === SPLASH SCREEN: LOADING & INITIALIZATION ===
// PATTERN: Splash Screen Pattern per UX ottimizzata
// MOTIVAZIONE: Maschera tempo di inizializzazione e migliora perceived performance
// LIFECYCLE: StatefulWidget per gestione navigazione temporizzata
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// === SPLASH STATE: LIFECYCLE MANAGEMENT ===
// PATTERN: State Management per operazioni asincrone
class _SplashScreenState extends State<SplashScreen> {
  // === INITIALIZATION HOOK ===
  // LIFECYCLE: Chiamato una sola volta alla creazione del widget
  // TIMING: Ideale per setup iniziale e operazioni one-time
  @override
  void initState() {
    super.initState(); // REQUIRED: Chiamata al parent per corretto lifecycle
    _navigateToHome(); // ASYNC: Avvia timer navigazione
  }

  // === NAVIGATION STRATEGY: DELAYED TRANSITION ===
  // PATTERN: Timed Navigation Pattern
  // UX: Permette visualizzazione logo e caricamento perceived
  // ERROR HANDLING: Verifica mounted state per prevenire memory leaks
  _navigateToHome() async {
    // DELAY: Simula caricamento e permette visualizzazione splash
    // TIMING: 2 secondi ottimali per branding senza frustrazione utente
    await Future.delayed(const Duration(seconds: 2));
    
    // SAFETY CHECK: Verifica che widget sia ancora nell'albero
    // MEMORY LEAK PREVENTION: Evita navigazione su widget dismesso
    if (mounted) {
      // NAVIGATION: Sostituzione completa dello stack
      // PATTERN: Replace Navigation per prevenire back alla splash
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SchermataP()),
      );
    }
  }

  // === SPLASH UI: BRANDING & LOADING ===
  // PATTERN: Centered Loading UI Pattern
  // DESIGN: Branding prominente con feedback di caricamento
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BRANDING: Background con colore primario per impatto visivo
      backgroundColor: AppConstants.primaryColor,
      
      // LAYOUT: Centrato per focus su branding
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // === BRAND ICON: VISUAL IDENTITY ===
            // ICONOGRAPHY: Album icon per immediate riconoscimento app
            Icon(
              Icons.album, // Material Design icon semanticamente appropriata
              size: 100, // Large size per impatto visivo
              color: Colors.white, // High contrast su background primario
            ),
            
            // SPACING: Consistent spacing usando design tokens
            SizedBox(height: AppConstants.spacingMedium),
            
            // === BRAND NAME: TYPOGRAPHY HIERARCHY ===
            // PRIMARY TEXT: Nome app con massima prominenza
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28, // Large font per hierarchy
                fontWeight: FontWeight.bold, // Bold per emphasis
                color: Colors.white, // High contrast
              ),
            ),
            
            SizedBox(height: AppConstants.spacingSmall),
            
            // === TAGLINE: SECONDARY INFORMATION ===
            // DESCRIPTIVE TEXT: Chiarisce purpose dell'app
            Text(
              'La tua collezione di vinili',
              style: TextStyle(
                fontSize: 16, // Smaller font per hierarchy
                color: Colors.white70, // Reduced opacity per secondary info
              ),
            ),
            
            SizedBox(height: AppConstants.spacingLarge),
            
            // === LOADING INDICATOR: USER FEEDBACK ===
            // PROGRESS: Indica attività in corso
            // UX: Rassicura utente che app sta caricando
            CircularProgressIndicator(
              color: Colors.white, // Consistent con color scheme
            ),
          ],
        ),
      ),
    );
  }
}

// === NOTA: HOME SCREEN RIMOSSA ===
// La HomeScreen placeholder è stata sostituita con SchermataP
// che include la navigazione completa con HomeView, SearchView e AnalisiView
