import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import dei servizi e schermate necessari
import '../services/vinyl_provider.dart';
import '../utils/constants.dart';
import "../models/section.dart";
import 'search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}


class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Inizializza il provider all'avvio della schermata
    Future.microtask(() {
      if (mounted) {
        Provider.of<VinylProvider>(context, listen: false).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // === HEADER: Intestazione app ===
            buildHeader(),
            SizedBox(height: AppConstants.spacingLarge),
            
            // === CONTENT: Contenuto principale scrollabile ===
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
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
                    //provider.recentVinyls,
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
                      //provider.favoriteVinyls,
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
                      //provider.randomVinyls,
                      Provider.of<VinylProvider>(context).randomVinyls,
                      context,
                    ),
                    SizedBox(height: AppConstants.spacingLarge),

                    // === STATS: Statistiche rapide ===
                    _buildQuickStatsSection(context),
                    SizedBox(height: AppConstants.spacingLarge),
                    
                    // === CATEGORIES: Accesso rapido alle categorie ===
                    _buildCategoriesSection(context),
                    
                    // === BOTTOM PADDING: Spazio extra per la navigation bar ===
                    SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: buildSectionHeader(
                    'Categorie Musicali',
                    Icons.library_music,
                  ),
                ),
                Flexible(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/categorie');
                    },
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Vedi tutte'),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingMedium),
            
            if (topGenres.isEmpty)
              buildEmptyState(
                'Nessuna categoria',
                'Aggiungi vinili per vedere le categorie',
                Icons.library_music,
              )
            else
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  itemCount: topGenres.length,
                  separatorBuilder: (context, index) => 
                      SizedBox(width: AppConstants.spacingMedium),
                  itemBuilder: (context, index) {
                    final genre = topGenres[index];
                    return _buildGenreCard(genre.key, genre.value);
                  },
                ),
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
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.music_note,
                  color: color,
                  size: 28,
                ),
              ),
              SizedBox(height: AppConstants.spacingSmall),
              Text(
                genre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2),
              Text(
                count == 1 ? '$count vinile' : '$count vinili',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  } 
}