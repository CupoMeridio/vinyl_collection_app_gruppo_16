import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import '../services/vinyl_provider.dart';
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
  int? _selectedYear;
  bool _showFavoritesOnly = false;
  String _sortBy = 'title';
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
    
    // Applica filtri combinati
    provider.applyAdvancedFilters(
      genre: _selectedGenre != 'Tutti' ? _selectedGenre : null,
      year: _selectedYear,
      favoritesOnly: _showFavoritesOnly,
      sortBy: _sortBy,
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
                  itemCount: vinyls.length,
                  itemBuilder: (context, index) {
                    final vinyl = vinyls[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          '/DettaglioVinile', 
                          arguments: vinyl);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: vinyl.imagePath != null
                                    ? Image.file(
                                        File(vinyl.imagePath!),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                        child: Icon(Icons.album, color: AppConstants.primaryColor.withValues(alpha: 0.5)),
                                      ),
                              ),
                              const SizedBox(width: 16),
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
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Artista: ${vinyl.artist}',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Anno: ${vinyl.year}',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  List<dynamic> _getFilteredVinyls(VinylProvider provider) {
    if (widget.showFavoritesOnly == true) {
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
        final genres = ['Tutti', ...provider.genreDistribution.keys.toList()];
        final years = provider.vinyls.map((v) => v.year).toSet().toList()..sort((a, b) => b.compareTo(a));
        
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
              
              // Filtro Preferiti e Ordinamento
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
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
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
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
                  ),
                ],
              ),
              
              // Pulsante Reset
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedGenre = 'Tutti';
                      _selectedYear = null;
                      _showFavoritesOnly = false;
                      _sortBy = 'title';
                    });
                    _applyFilters();
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
