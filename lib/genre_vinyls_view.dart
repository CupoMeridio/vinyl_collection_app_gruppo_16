import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import 'services/vinyl_provider.dart';
import 'models/vinyl.dart';
import 'dart:io';

class GenreVinylsView extends StatefulWidget {
  final String genre;
  
  const GenreVinylsView({super.key, required this.genre});

  @override
  State<GenreVinylsView> createState() => _GenreVinylsViewState();
}

class _GenreVinylsViewState extends State<GenreVinylsView> {
  List<Vinyl> _genreVinyls = [];
  bool _isLoading = true;
  String _sortBy = 'dateAdded'; // dateAdded, title, artist, year
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadGenreVinyls();
  }

  Future<void> _loadGenreVinyls() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<VinylProvider>(context, listen: false);
      await provider.loadVinyls();
      
      final allVinyls = provider.vinyls;
      final filteredVinyls = allVinyls
          .where((vinyl) => vinyl.genre == widget.genre)
          .toList();
      
      setState(() {
        _genreVinyls = filteredVinyls;
        _isLoading = false;
      });
      
      _sortVinyls();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel caricamento dei vinili: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sortVinyls() {
    setState(() {
      _genreVinyls.sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'title':
            comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
            break;
          case 'artist':
            comparison = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
            break;
          case 'year':
            comparison = a.year.compareTo(b.year);
            break;
          case 'dateAdded':
          default:
            comparison = a.dateAdded.compareTo(b.dateAdded);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ordina per:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Data aggiunta', 'dateAdded', Icons.schedule),
              _buildSortOption('Titolo', 'title', Icons.title),
              _buildSortOption('Artista', 'artist', Icons.person),
              _buildSortOption('Anno', 'year', Icons.calendar_today),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Ordine: '),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Crescente'),
                    selected: _sortAscending,
                    onSelected: (selected) {
                      setState(() {
                        _sortAscending = true;
                      });
                      _sortVinyls();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Decrescente'),
                    selected: !_sortAscending,
                    onSelected: (selected) {
                      setState(() {
                        _sortAscending = false;
                      });
                      _sortVinyls();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: _sortBy == value ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        _sortVinyls();
        Navigator.pop(context);
      },
    );
  }

  Color _getGenreColor(String genre) {
    const genreColors = {
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
    return genreColors[genre] ?? Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    final genreColor = _getGenreColor(widget.genre);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.genre} (${_genreVinyls.length})'),
        backgroundColor: genreColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Ordina',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGenreVinyls,
            tooltip: 'Aggiorna',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadGenreVinyls,
              child: _buildVinylsList(),
            ),
    );
  }

  Widget _buildVinylsList() {
    if (_genreVinyls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun vinile trovato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Non ci sono vinili di genere ${widget.genre}',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _genreVinyls.length,
      itemBuilder: (context, index) {
        final vinyl = _genreVinyls[index];
        return _buildVinylCard(vinyl);
      },
    );
  }

  Widget _buildVinylCard(Vinyl vinyl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/DettaglioVinile',
            arguments: vinyl,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Immagine copertina
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppConstants.primaryColor.withValues(alpha: 26),
                ),
                child: vinyl.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(vinyl.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 16),
              // Informazioni vinile
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vinyl.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vinyl.artist,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vinyl.year.toString(),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.business,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vinyl.label,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(vinyl.condition).withValues(alpha: 26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getConditionColor(vinyl.condition).withValues(alpha: 77),
                            ),
                          ),
                          child: Text(
                            vinyl.condition,
                            style: TextStyle(
                              color: _getConditionColor(vinyl.condition),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (vinyl.isFavorite)
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.album,
        color: AppConstants.primaryColor.withValues(alpha: 128),
        size: 32,
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Nuovo':
        return Colors.green;
      case 'Ottimo':
        return Colors.lightGreen;
      case 'Buono':
        return Colors.orange;
      case 'Discreto':
        return Colors.deepOrange;
      case 'Da restaurare':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}