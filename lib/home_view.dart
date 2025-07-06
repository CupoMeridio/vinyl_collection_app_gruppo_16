import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import dei servizi e schermate necessari
import 'services/vinyl_provider.dart';
import 'screens/add_edit_vinyl_screen.dart';
import 'utils/constants.dart';
import "../models/section.dart";

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
                      buildSection("Aggiunti di Recente",
                      "Nessun vinile aggiunto", 
                      "Inizia aggiungendo il tuo primo vinile alla collezione!", 
                      Icons.schedule, 
                      Icons.album, 
                      "/listaVinili_view", 
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
                        null, // Nessuna navigazione
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
                        null, // Nessuna navigazione
                        Provider.of<VinylProvider>(context).randomVinyls,
                        context,
                      ),
                      SizedBox(height: AppConstants.spacingLarge),

                      // === STATS: Statistiche rapide ===
                      _buildQuickStatsSection(context),
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
        GestureDetector(
          onTap:() => Navigator.pushNamed(context, '/profile_view'),
          child: 
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Icon(
              Icons.account_circle,
              color: AppConstants.primaryColor,
              size: 32,
            ),
          ),
        ),
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
  
}

