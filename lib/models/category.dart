// Modello per le categorie/generi musicali
// Rappresenta una categoria che raggruppa vinili dello stesso genere

// Classe che definisce la struttura dati per le categorie musicali
class Category {
  // ID univoco della categoria (auto-incrementale nel database)
  // Nullable perché viene assegnato dal database alla creazione
  int? id;
  
  // Nome della categoria (es: "Rock", "Jazz", "Classical")
  // Campo obbligatorio e unico
  String name;
  
  // Descrizione opzionale della categoria
  // Può contenere dettagli aggiuntivi sul genere
  String? description;
  
  // Contatore dei vinili appartenenti a questa categoria
  // Aggiornato automaticamente quando si aggiungono/rimuovono vinili
  int vinylCount;
  
  // Data di creazione della categoria
  // Utilizzata per ordinamento e statistiche
  DateTime dateCreated;
  
  // Flag per indicare se è una categoria predefinita del sistema
  // I generi predefiniti non possono essere eliminati dall'utente
  bool isDefault;

  // Costruttore della classe Category
  // Solo 'name' è obbligatorio, gli altri parametri hanno valori di default
  Category({
    this.id,                    // ID assegnato dal database
    required this.name,         // Nome obbligatorio
    this.description,           // Descrizione opzionale
    this.vinylCount = 0,        // Inizia con 0 vinili
    this.isDefault = false,     // Di default non è una categoria predefinita
    DateTime? dateCreated,      // Data opzionale
  }) : dateCreated = dateCreated ?? DateTime.now(); // Se non fornita, usa data corrente

  // Factory constructor per creare Category da Map del database
  // Utilizzato quando si leggono dati dal database SQLite
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],                              // ID dal database
      name: map['name'],                          // Nome dal database
      description: map['description'],            // Descrizione dal database
      vinylCount: map['vinylCount'] ?? 0,         // Contatore con fallback a 0
      isDefault: (map['isDefault'] ?? 0) == 1,    // Converte da INTEGER a bool
      dateCreated: DateTime.parse(map['dateCreated']), // Parsing della data ISO
    );
  }

  // Metodo per convertire Category in Map per il database
  // Utilizzato quando si salvano dati nel database SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,                                   // ID (può essere null per nuovi record)
      'name': name,                               // Nome della categoria
      'description': description,                 // Descrizione (può essere null)
      'vinylCount': vinylCount,                   // Contatore vinili
      'isDefault': isDefault ? 1 : 0,             // Converte bool a INTEGER per SQLite
      'dateCreated': dateCreated.toIso8601String(), // Data in formato ISO string
    };
  }

  // Metodo per creare una copia della categoria con alcune modifiche
  // Utile per aggiornamenti immutabili dello stato
  Category copyWith({
    int? id,                    // Nuovo ID (opzionale)
    String? name,               // Nuovo nome (opzionale)
    String? description,        // Nuova descrizione (opzionale)
    int? vinylCount,            // Nuovo contatore vinili (opzionale)
    bool? isDefault,            // Nuovo flag predefinito (opzionale)
    DateTime? dateCreated,      // Nuova data creazione (opzionale)
  }) {
    return Category(
      id: id ?? this.id,                           // Usa nuovo ID o mantieni quello esistente
      name: name ?? this.name,                     // Usa nuovo nome o mantieni quello esistente
      description: description ?? this.description, // Usa nuova descrizione o mantieni quella esistente
      vinylCount: vinylCount ?? this.vinylCount,   // Usa nuovo contatore o mantieni quello esistente
      isDefault: isDefault ?? this.isDefault,     // Usa nuovo flag o mantieni quello esistente
      dateCreated: dateCreated ?? this.dateCreated, // Usa nuova data o mantieni quella esistente
    );
  }

  // Override del metodo toString per debug e logging
  // Mostra le informazioni principali della categoria
  @override
  String toString() {
    return 'Category{id: $id, name: $name, vinylCount: $vinylCount}';
  }

  // Override dell'operatore di uguaglianza
  // Due categorie sono uguali se hanno lo stesso nome
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;      // Stesso oggetto in memoria
    return other is Category && other.name == name; // Stesso nome
  }

  // Override di hashCode per coerenza con operator==
  // Utilizza l'hash del nome per identificare univocamente la categoria
  @override
  int get hashCode => name.hashCode;
}