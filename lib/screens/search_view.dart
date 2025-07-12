import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import '../services/vinyl_provider.dart';
import '../models/vinyl.dart';
import 'dart:io';

class SearchView extends StatefulWidget {
  final String? initialFilter;
  final String? sortBy;
  final bool? showFavoritesOnly;
  final String? title;
  
  const SearchView({
    super.key,
    this.initialFilter,
    this.sortBy,
    this.showFavoritesOnly,
    this.title,
  });
  
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  String _selectedGenre = 'Tutti';
  String _selectedCondition = 'Tutte';
  int? _selectedYear;
  bool _showFavoritesOnly = false;
  String _sortBy = 'title';
  bool _sortAscending = true;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    
    // Inizializza i filtri locali in base ai parametri
    if (widget.initialFilter != null) {
      _selectedGenre = widget.initialFilter!;
    }
    if (widget.showFavoritesOnly == true) {
      _showFavoritesOnly = true;
    }
    if (widget.sortBy != null) {
      _sortBy = widget.sortBy!;
    }
    
    // Applica filtri iniziali se specificati
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  void _applyFilters() {
    final provider = Provider.of<VinylProvider>(context, listen: false);
    
    // Applica filtri combinati usando i nuovi metodi
    provider.applyAdvancedFilters(
      genre: _selectedGenre,
      year: _selectedYear,
      favoritesOnly: _showFavoritesOnly,
      sortBy: _sortBy,
      condition: _selectedCondition != "Tutte" ? _selectedCondition : null,
      ascending: _sortAscending,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Cerca vinili'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              key: Key('search_field'),
              decoration: InputDecoration(
                hintText: 'Cerca vinili...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                Provider.of<VinylProvider>(context, listen: false).searchVinyls(value);
              },
            ),
          ),
          if (_showFilters) _buildFiltersSection(),
          Expanded(
            child: Consumer<VinylProvider>(
              builder: (context, provider, child) {
                final vinyls = _getFilteredVinyls(provider);
                
                if (vinyls.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nessun vinile trovato',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Prova a modificare i criteri di ricerca',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vinyls.length,
                  itemBuilder: (context, index) {
                    final vinyl = vinyls[index];
                    return _buildVinylCard(vinyl);
                  },
                );
              },
            ),
          ),
        ],
      ),
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

  List<dynamic> _getFilteredVinyls(VinylProvider provider) {
    // Controlla prima il filtro locale per i preferiti
    if (_showFavoritesOnly || widget.showFavoritesOnly == true) {
      return provider.favoriteVinyls;
    }
    
    if (widget.sortBy == 'recent') {
      return provider.recentVinyls;
    }
    
    if (widget.sortBy == 'random') {
      return provider.randomVinyls;
    }
    
    return provider.filteredVinyls;
  }
  
  Widget _buildFiltersSection() {
    return Consumer<VinylProvider>(
      builder: (context, provider, child) {
        final genres = ['Tutti', ...provider.genreDistribution.keys];
        final years = provider.vinyls.map((v) => v.year).toSet().toList()..sort((a, b) => b.compareTo(a));
        final conditions = ["Tutte", ...provider.conditionDistribution.keys];

        return Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtri Avanzati',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // Filtro Genere
              Row(
                children: [
                  Icon(Icons.library_music, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('Genere:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      key: Key('genre_filter_dropdown'),
                      value: _selectedGenre,
                      isExpanded: true,
                      items: genres.map((genre) {
                        return DropdownMenuItem(
                          value: genre,
                          child: Text(genre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGenre = value!;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Filtro Anno
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('Anno:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int?>(
                      key: Key('year_filter_dropdown'),
                      value: _selectedYear,
                      isExpanded: true,
                      hint: Text('Tutti gli anni'),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Tutti gli anni'),
                        ),
                        ...years.map((year) {
                          return DropdownMenuItem<int?>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              //Filtro per condizione del vinile
              Row(
                children: [
                  Icon(Icons.album, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('Condizione:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      key: Key('condition_filter_dropdown'),
                      value: _selectedCondition,
                      isExpanded: true,
                      items: conditions.map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCondition = value!;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Filtro Preferiti
              CheckboxListTile(
                key: Key('favorites_filter_checkbox'),
                title: Text('Solo Preferiti', style: TextStyle(fontSize: 14)),
                value: _showFavoritesOnly,
                onChanged: (value) {
                  setState(() {
                    _showFavoritesOnly = value!;
                  });
                  _applyFilters();
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              
              // Ordinamento
              Row(
                children: [
                  Icon(Icons.sort, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('Ordina per:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      key: Key('sort_filter_dropdown'),
                      value: _sortBy,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: 'title', child: Text('Titolo')),
                        DropdownMenuItem(value: 'artist', child: Text('Artista')),
                        DropdownMenuItem(value: 'year', child: Text('Anno')),
                        DropdownMenuItem(value: 'recent', child: Text('Recenti')),
                        DropdownMenuItem(value: 'random', child: Text('Casuale')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Ordine crescente/decrescente
              if (_sortBy != 'random')
                Row(
                  children: [
                    Icon(Icons.swap_vert, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text('Ordine:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text('Crescente', style: TextStyle(fontSize: 14)),
                              value: true,
                              groupValue: _sortAscending,
                              onChanged: (value) {
                                setState(() {
                                  _sortAscending = value!;
                                });
                                _applyFilters();
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text('Decrescente', style: TextStyle(fontSize: 14)),
                              value: false,
                              groupValue: _sortAscending,
                              onChanged: (value) {
                                setState(() {
                                  _sortAscending = value!;
                                });
                                _applyFilters();
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              
              // Pulsante Reset
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final provider = Provider.of<VinylProvider>(context, listen: false);
                    provider.resetFilters();
                    setState(() {
                      _selectedGenre = 'Tutti';
                      _selectedYear = null;
                      _showFavoritesOnly = false;
                      _selectedCondition = 'Tutte';
                      _sortBy = 'title';
                      _sortAscending = true;
                    });
                  },
                  icon: Icon(Icons.clear_all),
                  label: Text('Reset Filtri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}