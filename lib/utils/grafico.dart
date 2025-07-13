
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_collection_app_gruppo_16/services/vinyl_provider.dart';
import 'package:vinyl_collection_app_gruppo_16/models/vinyl.dart';


class GraficoATorta extends StatelessWidget {
    final Map<String, Color> generiColori;

    const GraficoATorta(
    this.generiColori, {super.key}
  );


  @override
  Widget build(BuildContext context) {
    return Consumer<VinylProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        final Map<String, int> generiDistribution = provider.genreDistribution;
        final int totaleVinili = provider.totalVinyls;
        final List<String> generi = generiDistribution.keys.toList();
        
        // Gestione stato vuoto quando non ci sono vinili
        if (totaleVinili == 0 || generi.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Nessun dato disponibile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aggiungi dei vinili per vedere\nla distribuzione per genere',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        List<DatiGrafico> dati = [];

        for (var genere in generi) {
          final int count = generiDistribution[genere] ?? 0;
          final double value = totaleVinili > 0 ? count / totaleVinili : 0.0;
          dati.add(DatiGrafico(
            value: value*100,
            color: generiColori[genere] ?? Color.fromRGBO(genere.hashCode.abs() % 256,genere.length * 20 % 256, (genere.codeUnitAt(0) * 3) % 256, 0.5),
            title: genere,
          ));
        }

        return PieChart(
          PieChartData(
            sections: dati
                .map((e) => PieChartSectionData(
                      value: e.value,
                      color: e.color,
                      title: '${e.value.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ))
                .toList(),
            centerSpaceRadius: 50,
          ),
        );
      },
    );
  }
}

class ScritteRuotate extends StatelessWidget {
  final String text;
  const ScritteRuotate({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -90 * (3.1415926535 / 180),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
class GraficoALinee extends StatelessWidget {
  late final String anno; // Anno di default per il grafico

  GraficoALinee({super.key, String? anno}) {
    this.anno = anno ?? DateTime.now().year.toString();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<VinylProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        
        final Map<int, Map<int, List<Vinyl>>> distribuzionePerAnno = provider.vinylsByYearAndMonth;
        
        // Verifica se ci sono dati per l'anno selezionato
        final Map<int, List<Vinyl>>? datiAnno = distribuzionePerAnno[int.parse(anno)];
        bool hasData = false;
        
        if (datiAnno != null) {
          for (var mese in datiAnno.values) {
            if (mese.isNotEmpty) {
              hasData = true;
              break;
            }
          }
        }
        
        // Gestione stato vuoto quando non ci sono dati per l'anno
        if (!hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Nessun dato per il $anno',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Non ci sono vinili aggiunti\nnell\'anno selezionato',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, bottom: 70),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                  axisNameWidget: Text(
                    'Numero di Vinili',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 1:
                          return ScritteRuotate(text: 'Gen');
                        case 2:
                          return ScritteRuotate(text: 'Feb');
                        case 3:
                          return ScritteRuotate(text: 'Mar');
                        case 4:
                          return ScritteRuotate(text: 'Apr');
                        case 5:
                          return ScritteRuotate(text:'Mag');
                        case 6:
                          return ScritteRuotate(text:'Giu');
                        case 7:
                          return ScritteRuotate(text:'Lug'); 
                        case 8:
                          return ScritteRuotate(text:'Ago');
                        case 9:
                          return ScritteRuotate(text:'Set');
                        case 10:
                          return ScritteRuotate(text:'Ott');
                        case 11:
                          return ScritteRuotate(text:'Nov');
                        case 12:
                          return ScritteRuotate(text:'Dic');
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  show: true,
                  spots: [
                    FlSpot(1, distribuzionePerAnno[int.parse(anno)]?[1]?.length.toDouble() ?? 0),
                    FlSpot(2, distribuzionePerAnno[int.parse(anno)]?[2]?.length.toDouble() ?? 0),
                    FlSpot(3, distribuzionePerAnno[int.parse(anno)]?[3]?.length.toDouble() ?? 0),
                    FlSpot(4, distribuzionePerAnno[int.parse(anno)]?[4]?.length.toDouble() ?? 0),
                    FlSpot(5, distribuzionePerAnno[int.parse(anno)]?[5]?.length.toDouble() ?? 0 ),
                    FlSpot(6, distribuzionePerAnno[int.parse(anno)]?[6]?.length.toDouble() ?? 0 ),
                    FlSpot(7, distribuzionePerAnno[int.parse(anno)]?[7]?.length.toDouble() ?? 0),
                    FlSpot(8, distribuzionePerAnno[int.parse(anno)]?[8]?.length.toDouble() ?? 0),
                    FlSpot(9, distribuzionePerAnno[int.parse(anno)]?[9]?.length.toDouble() ?? 0),
                    FlSpot(10, distribuzionePerAnno[int.parse(anno)]?[10]?.length.toDouble() ?? 0),
                    FlSpot(11, distribuzionePerAnno[int.parse(anno)]?[11]?.length.toDouble() ?? 0),
                    FlSpot(12, distribuzionePerAnno[int.parse(anno)]?[12]?.length.toDouble() ?? 0),
                  ],
                  isCurved: false,
                  barWidth: 3,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                  preventCurveOverShooting: true,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withAlpha((0.3 * 255).toInt()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class DatiGrafico{

  final double value;
  final Color color;
  final String title;
  DatiGrafico({required this.value, required this.color, required this.title});
  // Constructor to initialize the properties
}