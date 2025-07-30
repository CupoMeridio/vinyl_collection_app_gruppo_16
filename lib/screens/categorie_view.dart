import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/vinyl_provider.dart';
import '../models/category.dart' as models;
import '../utils/constants.dart';

class CategorieView extends StatefulWidget {
  const CategorieView({super.key});

  @override
  State<CategorieView> createState() => _CategorieViewState();
}

class _CategorieViewState extends State<CategorieView> {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, int> _genreDistribution = {};
  List<models.Category> _allCategories = [];
  bool _isLoading = true;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGenreDistribution();
    
    // Ascolta i cambiamenti del VinylProvider per aggiornare la distribuzione
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<VinylProvider>(context, listen: false);
      provider.addListener(_onVinylProviderChanged);
    });
  }
  
  @override
  void dispose() {
    // Rimuovi il listener quando il widget viene distrutto
    final provider = Provider.of<VinylProvider>(context, listen: false);
    provider.removeListener(_onVinylProviderChanged);
    _newCategoryController.dispose();
    super.dispose();
  }
  
  void _onVinylProviderChanged() {
    // Ricarica la distribuzione quando cambiano i vinili
    _loadGenreDistribution();
  }



  Future<void> _loadGenreDistribution() async {
    try {
      final distribution = await _databaseService.getGenreDistribution();
      final categories = await _databaseService.getAllCategories();
      setState(() {
        _genreDistribution = distribution;
        _allCategories = categories;
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
                  final navigator = Navigator.of(context);
                  await _addNewCategory(categoryName);
                  if (mounted) {
                    navigator.pop();
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
      // Verifica se esiste già una categoria con lo stesso nome (case-insensitive)
      final existingCategory = await _databaseService.getCategoryByName(categoryName);
      
      if (existingCategory != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La categoria "${existingCategory.name}" esiste già'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
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

  Future<void> _deleteCategory(models.Category category) async {
    // Verifica che sia una categoria personalizzata
    if (category.isDefault) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Non è possibile eliminare le categorie predefinite'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Verifica se ci sono vinili associati a questa categoria
    final vinylCount = _genreDistribution[category.name] ?? 0;
    if (vinylCount > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossibile eliminare "${category.name}": contiene $vinylCount vinili'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      await _databaseService.deleteCategory(category.id!);
      
      // Ricarica la distribuzione per rimuovere la categoria eliminata
      await _loadGenreDistribution();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoria "${category.name}" eliminata con successo'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nell\'eliminazione della categoria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(models.Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: Text('Sei sicuro di voler eliminare la categoria "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategory(category);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToGenreVinyls(String genre) {
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/GenreVinyls',
      arguments: genre,
    );
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
    // Ordina le categorie: prima per numero di vinili (decrescente), poi alfabeticamente
    final sortedCategories = List<models.Category>.from(_allCategories)
      ..sort((a, b) {
        final countA = _genreDistribution[a.name] ?? 0;
        final countB = _genreDistribution[b.name] ?? 0;
        if (countA != countB) {
          return countB.compareTo(countA); // Ordina per numero di vinili (decrescente)
        }
        return a.name.compareTo(b.name); // Poi alfabeticamente
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final count = _genreDistribution[category.name] ?? 0;
        final color = AppConstants.getGenreColor(category.name);
        final canDelete = !category.isDefault && count == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 51), // 0.2 * 255 = 51
              child: Icon(
                Icons.music_note,
                color: color,
              ),
            ),
            title: Text(
              category.name,
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (category.isDefault) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Predefinita',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (canDelete) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteConfirmationDialog(category),
                    color: Colors.red[400],
                    iconSize: 20,
                    tooltip: 'Elimina categoria',
                  ),
                ],
              ],
            ),
            onTap: () => _navigateToGenreVinyls(category.name),
            enabled: true,
          ),
        );
      },
    );
  }
}