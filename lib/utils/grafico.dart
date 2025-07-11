
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vinyl_collection_app_gruppo_16/services/database_service.dart';
import 'package:vinyl_collection_app_gruppo_16/models/vinyl.dart';


class GraficoATorta extends StatelessWidget {
    final Map<String, Color> generiColori;
    final DatabaseService db = DatabaseService();

    GraficoATorta(
    this.generiColori, {super.key}
  );


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        db.getGenreDistribution(),
        db.getTotalVinylCount(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator( color: Colors.blue,));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Errore nel caricamento dei dati'));
        }

        final Map<String, int> generiDistribution = snapshot.data![0] as Map<String, int>;
        final int totaleVinili = snapshot.data![1] as int;
        final List<String> generi = generiDistribution.keys.toList();
        List<DatiGrafico> dati = [];

        for (var genere in generi) {
          final int count = generiDistribution[genere] ?? 0;
          final double value = totaleVinili > 0 ? count / totaleVinili : 0.0;
          dati.add(DatiGrafico(
            value: value*100,
            color: generiColori[genere] ?? Colors.grey,
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


class GraficoALinee extends StatelessWidget {
  final DatabaseService db = DatabaseService();
  late final String anno; // Anno di default per il grafico

  GraficoALinee({super.key, String? anno}) {
    this.anno = anno ?? DateTime.now().year.toString();
  }


  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<Map<int, Map<int, List<Vinyl>>>>(
      future: db.getVinylsByYearAndMonth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Errore nel caricamento dei dati'));
        }
        final Map<int, Map<int, List<Vinyl>>> distribuzionePerAnno =
            snapshot.data as Map<int, Map<int, List<Vinyl>>>;
        // You can use snapshot.data here to build your chart with real data
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
                          return Text('Gen');
                        case 2:
                          return Text('Feb');
                        case 3:
                          return Text('Mar');
                        case 4:
                          return Text('Apr');
                        case 5:
                          return Text('Mag');
                        case 6:
                          return Text('Giu');
                        case 7:
                          return Text('Lug');
                        case 8:
                          return Text('Ago');
                        case 9:
                          return Text('Set');
                        case 10:
                          return Text('Ott');
                        case 11:
                          return Text('Nov');
                        case 12:
                          return Text('Dic');
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                  axisNameWidget: Text(
                    'Mesi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
