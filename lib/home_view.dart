import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import dei servizi e schermate necessari
import 'services/vinyl_provider.dart';
import 'screens/add_edit_vinyl_screen.dart';
import 'utils/constants.dart';
import "../models/section.dart";
import 'search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // === HEADER: Intestazione app ===
              buildHeader(),
              SizedBox(height: AppConstants.spacingLarge),
              
              // === CONTENT: Contenuto principale scrollabile ===
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // === RECENT VINYLS: Vinili recenti ===
                      buildSection("Vinili Recenti",
                      "Nessun vinile aggiunto", 
                      "Inizia aggiungendo il tuo primo vinile alla collezione!", 
                      Icons.schedule, 
                      Icons.album, 
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchView(
                              sortBy: 'recent',
                              title: 'Vinili Recenti',
                            ),
                          ),
                        );
                      }, 
                      (Provider.of<VinylProvider>(context).recentVinyls), 
                      context),
                      SizedBox(height: AppConstants.spacingLarge),
                      
                      // === FAVORITE VINYLS: Vinili preferiti ===
                      buildSection(
                        "I Tuoi Preferiti",
                        "Nessun preferito",
                        "Marca i tuoi vinili preferiti per vederli qui!",
                        Icons.favorite,
                        Icons.favorite_border,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchView(
                                showFavoritesOnly: true,
                                title: 'I Tuoi Preferiti',
                              ),
                            ),
                          );
                        },
                        Provider.of<VinylProvider>(context).favoriteVinyls,
                        context,
                      ),
                      SizedBox(height: AppConstants.spacingLarge),
                      
                      // === RANDOM VINYLS: Vinili casuali consigliati ===
                      buildSection(
                        "Vinili Consigliati",
                        "Nessun vinile consigliato",
                        "Aggiungi vinili alla tua collezione per ricevere consigli!",
                        Icons.recommend,
                        Icons.recommend,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchView(
                                sortBy: 'random',
                                title: 'Vinili Consigliati',
                              ),
                            ),
                          );
                        },
                        Provider.of<VinylProvider>(context).randomVinyls,
                        context,
                      ),
                      SizedBox(height: AppConstants.spacingLarge),

                      // === STATS: Statistiche rapide ===
                      _buildQuickStatsSection(context),
                      SizedBox(height: AppConstants.spacingLarge),
                      
                      // === CATEGORIES: Accesso rapido alle categorie ===
                      _buildCategoriesSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // NAVIGATION: Naviga alla schermata aggiunta vinile
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditVinylScreen(),
            ),
          );
          
          // REFRESH: Ricarica dati se vinile aggiunto con successo
          if (result == true && mounted) {
            // Il provider si aggiorna automaticamente tramite notifyListeners
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Vinile aggiunto alla collezione!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        backgroundColor: AppConstants.primaryColor,
        tooltip: 'Aggiungi nuovo vinile',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  // === HEADER: Widget intestazione ===
  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'La tua collezione di vinili',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
// Icona profilo rimossa
      ],
    );
  }

  
  // === QUICK STATS SECTION: Sezione statistiche rapide ===
  Widget _buildQuickStatsSection(BuildContext context) {
    return Consumer<VinylProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            buildSectionHeader(
              'Statistiche Rapide',
              Icons.analytics,
            ),
            SizedBox(height: AppConstants.spacingMedium),
            
            Row(
              children: [
                Expanded(
                  child: buildStatCard(
                    'Totale Vinili',
                    provider.totalVinyls.toString(),
                    Icons.album,
                    AppConstants.primaryColor,
                  ),
                ),
                SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: buildStatCard(
                    'Preferiti',
                    provider.favoriteCount.toString(),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  
  // === CATEGORIES SECTION: Sezione accesso categorie ===
  Widget _buildCategoriesSection(BuildContext context) {
    return Consumer<VinylProvider>(
      builder: (context, provider, child) {
        final genreDistribution = provider.genreDistribution;
        final topGenres = genreDistribution.entries
            .where((entry) => entry.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(4).toList();
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildSectionHeader(
                  'Categorie Musicali',
                  Icons.library_music,
                ),
                TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/categorie');
                        },
                        icon: Icon(Icons.arrow_forward),
                        label: Text('Vedi tutte'),
                      ),
              ],
            ),
            SizedBox(height: AppConstants.spacingMedium),
            
            if (topGenres.isEmpty)
              SizedBox(
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_music,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                      SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        'Nessuna categoria',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Aggiungi vinili per vedere le categorie',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.spacingMedium,
                  mainAxisSpacing: AppConstants.spacingMedium,
                  childAspectRatio: 2.5,
                ),
                itemCount: topGenres.length,
                itemBuilder: (context, index) {
                  final genre = topGenres[index];
                  return _buildGenreCard(genre.key, genre.value);
                },
              ),
          ],
        );
      },
    );
  }
  
  // === GENRE CARD: Widget per singola categoria ===
  Widget _buildGenreCard(String genre, int count) {
    final genreColors = {
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
    
    final color = genreColors[genre] ?? Colors.indigo;
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/GenreVinyls',
          arguments: genre,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 26),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.music_note,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      genre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      count == 1 ? '$count vinile' : '$count vinili',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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
  
}

