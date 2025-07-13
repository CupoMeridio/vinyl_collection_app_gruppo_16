import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/section.dart';
import '../models/vinyl.dart';

import '../utils/grafico.dart';
import '../utils/drop_down.dart';
import '../services/vinyl_provider.dart';



class AnalisiView extends StatelessWidget{
  const AnalisiView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context) => ChangeNotifierDropDown(),
      child: const Analisi(),
    );
  }
}


class Analisi extends StatelessWidget {
  const Analisi({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Analisi Vinile'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: Column(
              children: [
                const TotaleVinili(),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Se la larghezza è troppo stretta, usa layout verticale
                    if (constraints.maxWidth < 400) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: 180,
                              height: 180,
                              child: GraficoATorta(AppConstants.genreColors),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                             child: SizedBox(
                               width: 280,
                               height: 200,
                              child: Consumer<VinylProvider>(
                                builder: (context, provider, child) {
                                  if (provider.isLoading) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  
                                  final generi = provider.genreDistribution.keys.toList();
                                  
                                  if (generi.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.music_note,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Nessun genere',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Aggiungi vinili per\nvedere i generi',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  return ListView(
                                    children: [
                                      const Center(
                                        child: Text(
                                          "Generi Musicali",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppConstants.primaryColor
                                          ),
                                        ),
                                      ),
                                      ...generi.map((genere) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.music_note, 
                                                    size: 18,
                                                    color: AppConstants.getGenreColor(genere),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    genere,
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ))
                                    ],
                                    
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      );
                    } else {
                      // Layout orizzontale per schermi più larghi
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: 180,
                              height: 180,
                              child: GraficoATorta(AppConstants.genreColors),
                            ),
                          ),
                          Flexible(
                            child: SizedBox(
                              width: 150,
                              height: 180,
                              child: Consumer<VinylProvider>(
                                builder: (context, provider, child) {
                                  if (provider.isLoading) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  
                                  final generi = provider.genreDistribution.keys.toList();
                                  
                                  if (generi.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.music_note,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Nessun genere',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Aggiungi vinili per\nvedere i generi',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  return ListView(
                                    children: [
                                      const Text(
                                        "Generi Musicali",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.primaryColor
                                        ),
                                      ),
                                      ...generi.map((genere) => ListTile(
                                            dense: true,
                                            title: Text(genere, style: const TextStyle(fontSize: 13)),
                                            leading: Icon(Icons.music_note, size: 18),
                                            iconColor: AppConstants.getGenreColor(genere),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                          )),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Andamento crescita della collezione",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const DropDownMenu(),
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Consumer<ChangeNotifierDropDown>(
                    builder: (context, notifier, child) {
                      return GraficoALinee(
                        anno: notifier.year,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: const ViniliPiuVecchi(),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class TotaleVinili extends StatefulWidget {
  const TotaleVinili({super.key});

  @override
  State<TotaleVinili> createState() => _TotaleViniliState();

}

class _TotaleViniliState extends State<TotaleVinili> {
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
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text("Totale vinili: ${Provider.of<VinylProvider>(context).totalVinyls}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                ],);
  }
}



class ViniliPiuVecchi extends StatelessWidget {
  const ViniliPiuVecchi({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VinylProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        // Ottieni i 5 vinili più vecchi dal provider
        final allVinyls = List<Vinyl>.from(provider.vinyls);
        allVinyls.sort((a, b) => a.year.compareTo(b.year));
        final oldestVinyls = allVinyls.take(5).toList();

        return buildSection(
          'I 5 Vinili più Vecchi',
          'Nessun vinile aggiunto di recente',
          'Aggiungi un vinile per vederlo qui',
          Icons.album,
          Icons.music_note,
          null, // No navigation for this section
          oldestVinyls,
          context,
        );
      },
    );
  }
}