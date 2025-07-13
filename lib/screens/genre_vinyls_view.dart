import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/vinyl_provider.dart';
import '../models/vinyl.dart';
import 'dart:io';

class GenreVinylsView extends StatefulWidget {
  final String genre;
  
  const GenreVinylsView({super.key, required this.genre});

  @override
  State<GenreVinylsView> createState() => _GenreVinylsViewState();
}

class _GenreVinylsViewState extends State<GenreVinylsView> {
  String _sortBy = 'dateAdded'; // dateAdded, title, artist, year
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadGenreVinyls();
  }

  Future<void> _loadGenreVinyls() async {
    try {
      final provider = Provider.of<VinylProvider>(context, listen: false);
      await provider.loadVinyls();
    } catch (e) {
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

  List<Vinyl> _getGenreVinyls(VinylProvider provider) {
    final filteredVinyls = provider.vinyls
        .where((vinyl) => vinyl.genre == widget.genre)
        .toList();
    
    // Applica ordinamento
    filteredVinyls.sort((a, b) {
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
    
    return filteredVinyls;
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
        Navigator.pop(context);
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final genreColor = AppConstants.getGenreColor(widget.genre);
    
    return Scaffold(
      appBar: AppBar(
        title: Consumer<VinylProvider>(
          builder: (context, provider, child) {
            final genreVinyls = _getGenreVinyls(provider);
            return Text('${widget.genre} (${genreVinyls.length})');
          },
        ),
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
      body: Consumer<VinylProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _loadGenreVinyls,
            child: _buildVinylsList(provider),
          );
        },
      ),
    );
  }

  Widget _buildVinylsList(VinylProvider provider) {
    final genreVinyls = _getGenreVinyls(provider);
    
    if (genreVinyls.isEmpty) {
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
      itemCount: genreVinyls.length,
      itemBuilder: (context, index) {
        final vinyl = genreVinyls[index];
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
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(vinyl.condition),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vinyl.condition,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
        return Colors.green[700]!;
      case 'Ottimo':
        return Colors.green[600]!;
      case 'Buono':
        return Colors.orange[700]!;
      case 'Discreto':
        return Colors.deepOrange[700]!;
      case 'Da restaurare':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}