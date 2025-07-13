// Schermata per aggiungere o modificare un vinile
// Implementa un form completo con validazione e gestione immagini

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/schermo_adattivo.dart';
import 'dart:io';

// Import dei modelli e servizi necessari
import '../models/vinyl.dart';
import '../models/song_.dart';
import '../services/vinyl_provider.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';


// === SCHERMATA AGGIUNTA/MODIFICA VINILE ===
// PATTERN: Form Validation Strategy per input sicuri
// ARCHITECTURE: Stateful Widget per gestione stato form
// UX: Interfaccia intuitiva con feedback visivo
class AddEditVinylScreen extends StatefulWidget {
  // Vinile da modificare (null per aggiunta nuovo)
  final Vinyl? vinyl;

  const AddEditVinylScreen({super.key, this.vinyl});

  @override
  State<AddEditVinylScreen> createState() => _AddEditVinylScreenState();
}

class _AddEditVinylScreenState extends State<AddEditVinylScreen> {
  // === FORM MANAGEMENT ===
  // PATTERN: Form Key per validazione centralizzata
  final _formKey = GlobalKey<FormState>();

  // === CONTROLLERS PER INPUT FIELDS ===
  // MEMORY MANAGEMENT: Controllori per gestire input utente
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _yearController;
  late TextEditingController _labelController;
  late TextEditingController _notesController;

  // === STATO FORM ===
  // DROPDOWN VALUES: Valori selezionati per dropdown
  String _selectedGenre =
      'Rock'; // Valore di default, verrà aggiornato da _loadAvailableGenres
  String _selectedCondition = AppConstants.vinylConditions.first;
  bool _isFavorite = false;

  // === GENRE MANAGEMENT ===
  // Lista completa di generi (predefiniti + personalizzati)
  List<String> _availableGenres = [];
  final DatabaseService _databaseService = DatabaseService();

  // === IMAGE MANAGEMENT ===
  // PATTERN: File Strategy per gestione immagini
  File? _selectedImage;
  String? _existingImagePath;
  Uint8List? _selectedImageBytes; // Bytes dell'immagine per Flutter Web
  final ImagePicker _imagePicker = ImagePicker();

  // === LOADING STATE ===
  // UX: Indicatore di caricamento per operazioni async
  bool _isLoading = false;

  // === CONTROLLERS PER CANZONI ===
  // Liste di controllori per gestire dinamicamente i campi delle canzoni
  final List<TextEditingController> _songTitleControllers = [];
  final List<TextEditingController> _songArtistControllers = [];
  final List<TextEditingController> _songYearControllers = [];
  final List<TextEditingController> _songTrackNumberControllers = [];
  final List<TextEditingController> _songDurationControllers = [];

  // Lista temporanea di oggetti Song per mantenere gli ID delle canzoni esistenti
  final List<Song> _songsToSave = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadAvailableGenres();
    _loadExistingData();
  }

  // === INITIALIZATION: Setup controllori ===
  // PATTERN: Lazy Initialization per performance
  void _initializeControllers() {
    _titleController = TextEditingController();
    _artistController = TextEditingController();
    _yearController = TextEditingController();
    _labelController = TextEditingController();
    _notesController = TextEditingController();
  }

  // === GENRE LOADING: Caricamento generi disponibili ===
  Future<void> _loadAvailableGenres() async {
    try {
      // Ottieni tutte le categorie dal database (predefinite + personalizzate)
      final categories = await _databaseService.getAllCategories();

      // Estrai i nomi delle categorie
      _availableGenres = categories.map((category) => category.name).toList();

      setState(() {
        // Assicurati che il genere selezionato sia nella lista
        if (!_availableGenres.contains(_selectedGenre)) {
          if (_availableGenres.isNotEmpty) {
            _selectedGenre = _availableGenres.first;
          }
        }
      });
    } catch (e) {
      debugPrint('Errore nel caricamento dei generi: $e');
      // Fallback a generi di base in caso di errore
      setState(() {
        _availableGenres = ['Rock', 'Pop', 'Jazz', 'Blues', 'Classical'];
        if (!_availableGenres.contains(_selectedGenre)) {
          _selectedGenre = _availableGenres.first;
        }
      });
    }
  }

  // === DATA LOADING: Carica dati esistenti per modifica ===
  // CONDITIONAL LOGIC: Popola form solo se in modalità modifica
  void _loadExistingData() {
    if (widget.vinyl != null) {
      final vinyl = widget.vinyl!;
      _titleController.text = vinyl.title;
      _artistController.text = vinyl.artist;
      _yearController.text = vinyl.year.toString();
      _labelController.text = vinyl.label;
      _notesController.text = vinyl.notes ?? '';

      // GENRE HANDLING: Gestione genere con controllo disponibilità
      if (_availableGenres.contains(vinyl.genre)) {
        _selectedGenre = vinyl.genre;
      } else {
        // Se il genere non è nella lista, aggiungilo
        _availableGenres.add(vinyl.genre);
        _availableGenres.sort();
        _selectedGenre = vinyl.genre;
      }

      _selectedCondition = vinyl.condition;
      _isFavorite = vinyl.isFavorite;
      _existingImagePath = vinyl.imagePath;

      // === CARICA CANZONI ESISTENTI ===
      if (vinyl.song != null && vinyl.song!.isNotEmpty) {
        for (var song in vinyl.song!) {
          _songsToSave.add(
            song,
          ); // Aggiungi la canzone all'elenco da salvare per mantenere l'ID
          _songTitleControllers.add(TextEditingController(text: song.titolo));
          _songArtistControllers.add(TextEditingController(text: song.artista));
          _songYearControllers.add(
            TextEditingController(text: song.anno.toString()),
          );
          _songTrackNumberControllers.add(
            TextEditingController(text: song.trackNumber?.toString() ?? ''),
          );
          _songDurationControllers.add(
            TextEditingController(text: song.duration ?? ''),
          );
        }
      }
    }
    // Non aggiungere automaticamente una canzone per i nuovi vinili
  }

  @override
  void dispose() {
    // MEMORY MANAGEMENT: Cleanup controllori per evitare memory leaks
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addSongField() {
    setState(() {
      _songTitleControllers.add(TextEditingController());
      // Pre-compila artista e anno con quelli del vinile come default
      _songArtistControllers.add(
        TextEditingController(text: _artistController.text),
      );
      _songYearControllers.add(
        TextEditingController(text: _yearController.text),
      );
      _songTrackNumberControllers.add(
        TextEditingController(
          text: (_songTrackNumberControllers.length + 1).toString(),
        ),
      );
      _songDurationControllers.add(TextEditingController());
     
      _songsToSave.add(
        Song(
          '',
          _artistController.text,
          int.tryParse(_yearController.text) ?? DateTime.now().year,
          id: null, //  null per le nuove canzoni
          vinylId:
              widget.vinyl?.id ??
              0, // Placeholder, sarà corretto al salvataggio nel DB
        ),
      );
    });
  }

  void _removeSongField(int index) {
    setState(() {
      _songTitleControllers[index].dispose();
      _songArtistControllers[index].dispose();
      _songYearControllers[index].dispose();
      _songTrackNumberControllers[index].dispose();
      _songDurationControllers[index].dispose();

      _songTitleControllers.removeAt(index);
      _songArtistControllers.removeAt(index);
      _songYearControllers.removeAt(index);
      _songTrackNumberControllers.removeAt(index);
      _songDurationControllers.removeAt(index);
      _songsToSave.removeAt(index); 
    });
  }

  // === IMAGE SELECTION: Gestione selezione immagine ===
  // PATTERN: Strategy Pattern per diverse sorgenti immagine
  Future<void> _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // OPTIMIZATION: Riduce dimensione per performance
        maxHeight: 800,
        imageQuality: 85, // COMPRESSION: Bilancia qualità e dimensione
      );

      if (image != null) {
        if (kIsWeb) {
          // Su web, leggi i bytes dell'immagine
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImage = null; // Non usare File su web
          });
        } else {
          // Su mobile, usa File normalmente
          setState(() {
            _selectedImage = File(image.path);
            _selectedImageBytes = null;
          });
        }
      }
    } catch (e) {
      // ERROR HANDLING: Gestione errori selezione immagine
      _showErrorSnackBar('Errore nella selezione dell\'immagine: $e');
    }
  }

  // === CAMERA SELECTION: Gestione selezione da fotocamera ===
  Future<void> _selectImageFromCamera() async {
    try {
      // Su web, la fotocamera non è sempre disponibile
      if (kIsWeb) {
        _showErrorSnackBar('Fotocamera non disponibile su web. Usa galleria o URL.');
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // Su web, leggi i bytes dell'immagine
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImage = null; // Non usare File su web
          });
        } else {
          // Su mobile, usa File normalmente
          setState(() {
            _selectedImage = File(image.path);
            _selectedImageBytes = null;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Errore nell\'acquisizione dalla fotocamera: $e');
    }
  }



  // === IMAGE SOURCE SELECTION: Mostra opzioni selezione immagine ===
  Future<void> _showImageSourceSelection() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galleria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImage();
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Fotocamera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _selectImageFromCamera();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // === FORM VALIDATION: Validazione campi obbligatori ===
  // PATTERN: Validation Strategy per input sicuri
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName è obbligatorio';
    }
    return null;
  }

  // === YEAR VALIDATION: Validazione specifica per anno ===
  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Anno è obbligatorio';
    }

    final year = int.tryParse(value);
    if (year == null) {
      return 'Inserisci un anno valido';
    }

    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      return 'Anno deve essere tra 1900 e $currentYear';
    }

    return null;
  }

  // === SAVE OPERATION: Salvataggio vinile ===
  // PATTERN: Command Pattern per operazioni CRUD
  // ASYNC: Operazione asincrona con feedback UX
  Future<void> _saveVinyl() async {
    if (!_formKey.currentState!.validate()) {
      return; // EARLY RETURN: Esce se validazione fallisce
    }

    // Valida i titoli delle canzoni solo se ci sono canzoni aggiunte
    for (int i = 0; i < _songTitleControllers.length; i++) {
      if (_songTitleControllers[i].text.trim().isEmpty) {
        _showErrorSnackBar(
          'Il titolo della canzone ${i + 1} non può essere vuoto.',
        );
        return; // Impedisce il salvataggio se una canzone ha titolo vuoto
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Costruisci la lista di canzoni finali dai controller
      List<Song> finalSongs = [];
      for (int i = 0; i < _songTitleControllers.length; i++) {
        finalSongs.add(
          Song(
            _songTitleControllers[i].text.trim(),
            _songArtistControllers[i].text.trim(),
            int.tryParse(_songYearControllers[i].text.trim()) ?? 0,
            id: _songsToSave[i]
                .id, // Mantiene l'ID se esistente per l'aggiornamento
            vinylId:
                widget.vinyl?.id ??
                0, // Placeholder, sarà assegnato al salvataggio nel DB
            trackNumber: int.tryParse(
              _songTrackNumberControllers[i].text.trim(),
            ),
            duration: _songDurationControllers[i].text.trim().isEmpty
                ? null
                : _songDurationControllers[i].text.trim(),
          ),
        );
      }
      // BUSINESS LOGIC: Crea oggetto Vinyl dai dati form
      final vinyl = Vinyl(
        id: widget.vinyl?.id, // Mantiene ID per modifica, null per nuovo
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        genre: _selectedGenre,
        label: _labelController.text.trim(),
        condition: _selectedCondition,
        isFavorite: _isFavorite,
        imagePath: _selectedImageBytes != null 
            ? 'web_image_${DateTime.now().millisecondsSinceEpoch}' 
            : (_selectedImage?.path ?? _existingImagePath),
        dateAdded: widget.vinyl?.dateAdded ?? DateTime.now(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        song: finalSongs,
      );

      // PROVIDER PATTERN: Delega operazione al provider
      final provider = Provider.of<VinylProvider>(context, listen: false);
      bool success;

      if (widget.vinyl == null) {
        // OPERATION: Aggiunta nuovo vinile
        success = await provider.addVinyl(vinyl);
      } else {
        // OPERATION: Modifica vinile esistente
        success = await provider.updateVinyl(vinyl);
        widget.vinyl?.artist = vinyl.artist; // Aggiorna artista
        widget.vinyl?.title = vinyl.title; // Aggiorna titolo
        widget.vinyl?.year = vinyl.year; // Aggiorna anno
        widget.vinyl?.genre = vinyl.genre; // Aggiorna genere
        widget.vinyl?.label = vinyl.label; // Aggiorna etichetta
        widget.vinyl?.condition = vinyl.condition; // Aggiorna condizione
        widget.vinyl?.isFavorite = vinyl.isFavorite; // Aggiorna preferito
        widget.vinyl?.imagePath = vinyl.imagePath; // Aggiorna immagine
        widget.vinyl?.notes = vinyl.notes; // Aggiorna note
        widget.vinyl?.dateAdded = vinyl.dateAdded; // Aggiorna data aggiunta
        // NOTA: Non è necessario aggiornare l'ID, viene mantenuto quello esistente
      }

      if (success) {
        // SUCCESS FEEDBACK: Notifica successo e torna indietro
        _showSuccessSnackBar(
          widget.vinyl == null
              ? 'Vinile aggiunto con successo!'
              : 'Vinile modificato con successo!',
        );
        if (mounted) {
          Navigator.of(context).pop(true); // Ritorna true per indicare successo
        }
      } else {
        // ERROR FEEDBACK: Notifica errore
        _showErrorSnackBar('Errore nel salvataggio del vinile');
      }
    } catch (e) {
      // EXCEPTION HANDLING: Gestione errori imprevisti
      _showErrorSnackBar('Errore imprevisto: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // === UI FEEDBACK: Metodi per notifiche utente ===
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === APP BAR: Titolo dinamico basato su modalità ===
      appBar: AppBar(
        title: Text(
          widget.vinyl == null ? 'Aggiungi Vinile' : 'Modifica Vinile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConstants.cardElevation,
        // ACTION: Pulsante salva in app bar
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveVinyl,
              tooltip: 'Salva vinile',
            ),
        ],
      ),

      // === BODY: Form principale ===
      body: _isLoading
          ? Center(
              // LOADING STATE: Indicatore di caricamento
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppConstants.primaryColor),
                  SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    'Salvataggio in corso...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              // SCROLLABLE: Form scrollabile per schermi piccoli
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // === IMAGE SECTION: Gestione immagine copertina ===
                    _buildImageSection(),
                    SizedBox(height: AppConstants.spacingLarge),

                    // === BASIC INFO: Informazioni base ===
                    _buildBasicInfoSection(),
                    SizedBox(height: AppConstants.spacingLarge),

                    // === DETAILS: Dettagli aggiuntivi ===
                    _buildDetailsSection(),
                    SizedBox(height: AppConstants.spacingLarge),

                    // === SONGS SECTION: Sezione per la gestione delle canzoni ===
                    _buildSongsSection(),
                    const SizedBox(
                      height: AppConstants.paddingLarge,
                    ), // Usare le costanti
                    // === NOTES: Note opzionali ===
                    _buildNotesSection(),
                    SizedBox(height: AppConstants.spacingLarge),

                    // === SAVE BUTTON: Pulsante salva principale ===
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // === IMAGE SECTION: Widget per gestione immagine ===
  Widget _buildImageSection() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Text(
              'Immagine Copertina',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            SizedBox(height: AppConstants.spacingMedium),

            // IMAGE DISPLAY: Mostra immagine selezionata o placeholder
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.grey[100],
              ),
              child: _selectedImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                    )
                  : _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : _existingImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      child: Image.file(
                        File(_existingImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                  : _buildImagePlaceholder(),
            ),

            SizedBox(height: AppConstants.spacingMedium),

            // IMAGE ACTIONS: Pulsanti per gestione immagine
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _showImageSourceSelection,
                  icon: Icon(Icons.add_photo_alternate),
                  label: Text('Aggiungi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_selectedImage != null || _selectedImageBytes != null || _existingImagePath != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _selectedImageBytes = null;
                        _existingImagePath = null;
                      });
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Rimuovi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === IMAGE PLACEHOLDER: Widget placeholder per immagine ===
  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.album, size: 64, color: Colors.grey[400]),
        SizedBox(height: AppConstants.spacingSmall),
        Text(
          'Nessuna immagine',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  // === BASIC INFO SECTION: Campi informazioni base ===
  Widget _buildBasicInfoSection() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informazioni Base',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            SizedBox(height: AppConstants.spacingMedium),

            // TITLE FIELD: Campo titolo
            TextFormField(
              key: Key('vinyl_title_field'),
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titolo *',
                hintText: 'Inserisci il titolo dell\'album',
                prefixIcon: Icon(Icons.album),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              validator: (value) => _validateRequired(value, 'Titolo'),
              textCapitalization: TextCapitalization.words,
              autofillHints: [AutofillHints.name],
            ),

            SizedBox(height: AppConstants.spacingMedium),

            // ARTIST FIELD: Campo artista
            TextFormField(
              key: Key('vinyl_artist_field'),
              controller: _artistController,
              decoration: InputDecoration(
                labelText: 'Artista *',
                hintText: 'Inserisci il nome dell\'artista',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              validator: (value) => _validateRequired(value, 'Artista'),
              textCapitalization: TextCapitalization.words,
              autofillHints: [AutofillHints.givenName],
            ),

            SizedBox(height: AppConstants.spacingMedium),

            // YEAR AND LABEL: Layout responsivo per anno e etichetta
            context.isMobile
                ? Column(
                    children: [
                      // YEAR FIELD: Campo anno (su riga separata per mobile)
                      TextFormField(
                        key: Key('vinyl_year_field'),
                        controller: _yearController,
                        decoration: InputDecoration(
                          labelText: 'Anno *',
                          hintText: 'es. 1975',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        validator: _validateYear,
                        keyboardType: TextInputType.number,
                        autofillHints: [AutofillHints.birthdayYear],
                      ),
                      
                      SizedBox(height: AppConstants.spacingMedium),
                      
                      // LABEL FIELD: Campo etichetta (su riga separata per mobile)
                      TextFormField(
                        key: Key('vinyl_label_field'),
                        controller: _labelController,
                        decoration: InputDecoration(
                          labelText: 'Etichetta *',
                          hintText: 'es. EMI, Sony',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        validator: (value) => _validateRequired(value, 'Etichetta'),
                        textCapitalization: TextCapitalization.words,
                        autofillHints: [AutofillHints.organizationName],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // YEAR FIELD: Campo anno (in riga per tablet/desktop)
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          key: Key('vinyl_year_field'),
                          controller: _yearController,
                          decoration: InputDecoration(
                            labelText: 'Anno *',
                            hintText: 'es. 1975',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                          ),
                          validator: _validateYear,
                          keyboardType: TextInputType.number,
                          autofillHints: [AutofillHints.birthdayYear],
                        ),
                      ),

                      SizedBox(width: AppConstants.spacingMedium),

                      // LABEL FIELD: Campo etichetta (in riga per tablet/desktop)
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          key: Key('vinyl_label_field'),
                          controller: _labelController,
                          decoration: InputDecoration(
                            labelText: 'Etichetta *',
                            hintText: 'es. EMI, Sony',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                          ),
                          validator: (value) => _validateRequired(value, 'Etichetta'),
                          textCapitalization: TextCapitalization.words,
                          autofillHints: [AutofillHints.organizationName],
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // === DETAILS SECTION: Sezione dettagli ===
  Widget _buildDetailsSection() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dettagli',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            SizedBox(height: AppConstants.spacingMedium),

            // GENRE DROPDOWN: Selezione genere
            DropdownButtonFormField<String>(
              key: Key('vinyl_genre_field'),
              value: _selectedGenre,
              decoration: InputDecoration(
                labelText: 'Genere',
                prefixIcon: Icon(Icons.music_note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              items: _availableGenres.map((genre) {
                return DropdownMenuItem(value: genre, child: Text(genre));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGenre = value!;
                });
              },
            ),

            SizedBox(height: AppConstants.spacingMedium),

            // CONDITION DROPDOWN: Selezione condizione
            DropdownButtonFormField<String>(
              key: Key('vinyl_condition_field'),
              value: _selectedCondition,
              decoration: InputDecoration(
                labelText: 'Condizione',
                prefixIcon: Icon(Icons.star),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              items: AppConstants.vinylConditions.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value!;
                });
              },
            ),

            SizedBox(height: AppConstants.spacingMedium),

            // FAVORITE SWITCH: Toggle preferito
            SwitchListTile(
              title: Text(
                'Aggiungi ai preferiti',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('Marca questo vinile come preferito'),
              value: _isFavorite,
              onChanged: (value) {
                setState(() {
                  _isFavorite = value;
                });
              },
              activeColor: AppConstants.primaryColor,
              secondary: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === SONGS SECTION: Widget per la gestione delle canzoni ===
  Widget _buildSongsSection() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Canzoni (opzionale)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            if (_songTitleControllers.isEmpty)
              // Mostra messaggio quando non ci sono canzoni
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.music_note_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Nessuna canzone aggiunta',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Aggiungi le canzoni del vinile per tenere traccia della tracklist',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap:
                    true, // Importante per ListView annidati in SingleChildScrollView
                physics:
                    const NeverScrollableScrollPhysics(), // Per disabilitare lo scroll del ListView
                itemCount: _songTitleControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.paddingMedium,
                    ),
                    child: Card(
                      // Wrap each song in a Card for better visual separation
                      margin: EdgeInsets.zero,
                      elevation:
                          AppConstants.cardElevation /
                          2, // Meno elevazione delle card principali
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Canzone ${index + 1}',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                // Ora è sempre possibile rimuovere le canzoni
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeSongField(index),
                                ),
                              ],
                            ),
                          TextFormField(
                            controller: _songTitleControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Titolo Canzone',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Inserisci un titolo per la canzone';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          TextFormField(
                            controller: _songArtistControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Artista Canzone (opzionale)',
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _songYearControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Anno Canzone (opzionale)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingSmall),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      _songTrackNumberControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Traccia # (opzionale)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingSmall),
                              Expanded(
                                child: TextFormField(
                                  controller: _songDurationControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Durata (MM:SS) (opzionale)',
                                  ),
                                  keyboardType: TextInputType.datetime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Center(
              child: OutlinedButton.icon(
                onPressed: _addSongField,
                icon: const Icon(Icons.add, color: AppConstants.accentColor),
                label: Text(
                  'Aggiungi Canzone',
                  style: TextStyle(color: AppConstants.accentColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppConstants.accentColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === NOTES SECTION: Sezione note ===
  Widget _buildNotesSection() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note Personali',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            SizedBox(height: AppConstants.spacingMedium),

            // NOTES FIELD: Campo note multilinea
            TextFormField(
              key: Key('vinyl_notes_field'),
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Note (opzionale)',
                hintText:
                    'Aggiungi note personali, ricordi o dettagli tecnici...',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                alignLabelWithHint: true,
                counterText: '${_notesController.text.length}/500',
              ),
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              autofillHints: [AutofillHints.addressCityAndState],
              onChanged: (value) {
                setState(() {}); // Aggiorna il counter
              },
            ),
          ],
        ),
      ),
    );
  }

  // === SAVE BUTTON: Pulsante salva principale ===
  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _saveVinyl,
      icon: Icon(widget.vinyl == null ? Icons.add : Icons.save, size: 24),
      label: Text(
        widget.vinyl == null ? 'Aggiungi Vinile' : 'Salva Modifiche',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
          horizontal: AppConstants.paddingLarge,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        elevation: AppConstants.cardElevation,
      ),
    );
  }
}
