import 'package:flutter/material.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import 'services/database_service.dart';
import 'models/category.dart' as models;

class CategorieView extends StatefulWidget {
  const CategorieView({super.key});

  @override
  State<CategorieView> createState() => _CategorieViewState();
}

class _CategorieViewState extends State<CategorieView> {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, int> _genreDistribution = {};
  bool _isLoading = true;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGenreDistribution();
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _loadGenreDistribution() async {
    try {
      final distribution = await _databaseService.getGenreDistribution();
      setState(() {
        _genreDistribution = distribution;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel caricamento delle categorie: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aggiungi Nuova Categoria'),
          content: TextField(
            controller: _newCategoryController,
            decoration: const InputDecoration(
              labelText: 'Nome categoria',
              hintText: 'Es: Indie Rock',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _newCategoryController.clear();
              },
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                final categoryName = _newCategoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  await _addNewCategory(categoryName);
                  if (mounted) {
                    Navigator.of(context).pop();
                    _newCategoryController.clear();
                  }
                }
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewCategory(String categoryName) async {
    try {
      final category = models.Category(name: categoryName);
      await _databaseService.insertCategory(category);
      
      // Ricarica la distribuzione per includere la nuova categoria
      await _loadGenreDistribution();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoria "$categoryName" aggiunta con successo'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nell\'aggiunta della categoria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToGenreVinyls(String genre) {
    Navigator.pushNamed(
      context,
      '/GenreVinyls',
      arguments: genre,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorie Musicali'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
            tooltip: 'Aggiungi categoria',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGenreDistribution,
            tooltip: 'Aggiorna',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadGenreDistribution,
              child: _buildCategoriesList(),
            ),
    );
  }

  Widget _buildCategoriesList() {
    if (_genreDistribution.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nessuna categoria trovata',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aggiungi dei vinili per vedere le categorie',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi Categoria'),
            ),
          ],
        ),
      );
    }

    // Combina le categorie predefinite con quelle dal database
    final allGenres = <String>{};
    allGenres.addAll(AppConstants.defaultGenres);
    allGenres.addAll(_genreDistribution.keys);
    
    final sortedGenres = allGenres.toList()
      ..sort((a, b) {
        final countA = _genreDistribution[a] ?? 0;
        final countB = _genreDistribution[b] ?? 0;
        if (countA != countB) {
          return countB.compareTo(countA); // Ordina per numero di vinili (decrescente)
        }
        return a.compareTo(b); // Poi alfabeticamente
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedGenres.length,
      itemBuilder: (context, index) {
        final genre = sortedGenres[index];
        final count = _genreDistribution[genre] ?? 0;
        final color = _getGenreColor(genre);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(
                Icons.music_note,
                color: color,
              ),
            ),
            title: Text(
              genre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              count == 1 ? '$count vinile' : '$count vinili',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            trailing: count > 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  )
                : Icon(
                    Icons.add,
                    color: Colors.grey[400],
                  ),
            onTap: count > 0 ? () => _navigateToGenreVinyls(genre) : null,
            enabled: count > 0,
          ),
        );
      },
    );
  }
}