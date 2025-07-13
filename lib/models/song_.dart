class Song {
  int? id;
  int? vinylId;
  String titolo;
  String artista;
  int anno;
  int? trackNumber;
  String? duration;

  Song(this.titolo, this.artista, this.anno, {
    this.id,
    this.vinylId,
    this.trackNumber,
    this.duration,
  });

  // Metodo per convertire in Map per il database
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

  // Metodo per creare Song da Map del database
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      map['titolo'] ?? '',
      map['artista'] ?? '',
      map['anno'] ?? 0,
      id: map['id'],
      vinylId: map['vinylId'],
      trackNumber: map['trackNumber'],
      duration: map['duration'],
    );
  }
}
