import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import 'package:vinyl_collection_app_gruppo_16/services/database_service.dart';
import 'package:vinyl_collection_app_gruppo_16/models/section.dart';
import 'package:vinyl_collection_app_gruppo_16/models/vinyl.dart';

import 'package:vinyl_collection_app_gruppo_16/utils/grafico.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/drop_down.dart';



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
        body:SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Padding(padding: const EdgeInsets.all(10), 
                    child:SizedBox(
                      width: 200,
                      height: 200,
                      child: GraficoATorta(generiColori),
                    ),),
                    SizedBox(
                      width: 150,
                      height: 200,
                    child:ListView(
                      children: [
                        const Text(
                          "Generi Musicali",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...AppConstants.defaultGenres.map((genere) => ListTile(
                              title: Text(genere),
                              leading: Icon(Icons.music_note),
                              iconColor: generiColori[genere] ?? Colors.grey,
                            )),
                      ],
                    ),
                    ),
                  ],
                ),
               Padding(padding: EdgeInsets.all(30),
               child: Text("Andamento crescita della collezione",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
               ),
                DropDownMenu(),
               SizedBox(
                  width: 700,
                  height: 500,
                  child: Consumer<ChangeNotifierDropDown>(
                    builder: (context, notifier, child) {
                      return GraficoALinee(
                        anno: notifier.year,
                      );
                    },
                  ),
                ),  
                SizedBox(
                   width: 700,
                  height: 500,
                  child: Ultime5Vinili(),
                )
              ],
            ),
          ),
        ),
      ),
      );
  }
}



class Ultime5Vinili extends StatelessWidget {
  const Ultime5Vinili({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Vinyl>>(
      future: DatabaseService().getRecentVinyls(limit:5),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator( color: Colors.blue,));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Errore nel caricamento dei dati'));
        }

        final List<dynamic> vinili = snapshot.data!;
        return buildSection(
          'Ultimi 5 Vinili Aggiunti',
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