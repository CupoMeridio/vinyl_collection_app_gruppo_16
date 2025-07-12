// Modello per rappresentare una canzone in un vinile
// Contiene le informazioni di ogni traccia musicale

class Song {
  // ID univoco della canzone (auto-incrementale nel database)
  // Nullable perché viene assegnato dal database alla creazione
  int? id;

//ID DEL VINILE (foreign key)
  final int vinylId;
  
  // Titolo della canzone
  String titolo;
  
  // Artista della canzone (può essere diverso dall'artista del vinile)
  String artista;
  
  // Anno della canzone (convertito da String a int per coerenza)
  int anno;
  
  // Numero della traccia nell'album (opzionale)
  int? trackNumber;
  
  // Durata della canzone in formato MM:SS (opzionale)
  String? duration;

  // Costruttore della classe Song
  Song({
    this.id,
    required this.vinylId,
    required this.titolo,
    required this.artista,
    required this.anno,
    this.trackNumber,
    this.duration,
  });

  // Factory constructor per creare Song da Map del database
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      vinylId: map['vinylId'] as int, 
      titolo: map['titolo'],
      artista: map['artista'],
      anno: map['anno'],
      trackNumber: map['trackNumber'],
      duration: map['duration'],
    );
  }

  // Metodo per convertire Song in Map per il database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vinylId': vinylId, 
      'titolo': titolo,
      'artista': artista,
      'anno': anno,
      'trackNumber': trackNumber,
      'duration': duration,
    };
  }

  // Metodo per creare una copia della canzone con alcune modifiche
  Song copyWith({
    int? id,
    int? vinylId,
    String? titolo,
    String? artista,
    int? anno,
    int? trackNumber,
    String? duration,
  }) {
    return Song(
      id: id ?? this.id,
      vinylId: vinylId ?? this.vinylId, 
      titolo: titolo ?? this.titolo,
      artista: artista ?? this.artista,
      anno: anno ?? this.anno,
      trackNumber: trackNumber ?? this.trackNumber,
      duration: duration ?? this.duration,
    );
  }

  // Override del metodo toString per debug
  @override
  String toString() {
    return 'Song{id: $id, vinylId: $vinylId, titolo: $titolo, artista: $artista, anno: $anno}';
  }
}