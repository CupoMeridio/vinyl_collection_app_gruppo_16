import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import 'package:vinyl_collection_app_gruppo_16/services/database_service.dart';
import 'package:vinyl_collection_app_gruppo_16/models/section.dart';
import 'package:vinyl_collection_app_gruppo_16/models/vinyl.dart';

import 'package:vinyl_collection_app_gruppo_16/utils/grafico.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/drop_down.dart';
import 'services/vinyl_provider.dart';



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

  static const Map<String, Color> generiColori = {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Analisi Vinile'),
        ),
        body: SingleChildScrollView(
          physics: const  ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: Column(
              children: [
                const TotaleVinili(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: GraficoATorta(generiColori),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      height: 180,
                      child: FutureBuilder<Map<String, int>>(
                        future: DatabaseService().getGenreDistribution(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(child: Text('Errore caricamento'));
                          }
                          
                          final generi = snapshot.data!.keys.toList();
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
                                    iconColor: generiColori[genere] ?? Colors.grey,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                  )),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
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
    return FutureBuilder<List<Vinyl>>(
      future: DatabaseService().getOldestVinyls(limit:5),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator( color: Colors.blue,));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Errore nel caricamento dei dati'));
        }

        final List<dynamic> vinili = snapshot.data!;
        return buildSection(
          'I 5 Vinili più Vecchi',
          'Nessun vinile aggiunto di recente',
          'Aggiungi un vinile per vederlo qui',
          Icons.album,
          Icons.music_note,
          null, // No navigation for this section
          vinili.cast<Vinyl>(), // Cast to List<Vinyl>
          context,
        );
        //Widget buildSection(String title, String missingPhrase, String missingSubtitle, IconData mainIcon, IconData emptyIcon, String? navigation, List<Vinyl> list, BuildContext context)
      },
    );
  }
}