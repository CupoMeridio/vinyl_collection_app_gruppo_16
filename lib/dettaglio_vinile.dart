import 'package:flutter/material.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import 'models/song_.dart';
import 'models/vinyl.dart';
import 'dart:io';
import '../services/vinyl_provider.dart';
import 'package:provider/provider.dart';
import '../screens/add_edit_vinyl_screen.dart';

class ViewDisco extends StatefulWidget {
  final Vinyl vinile;
  final VoidCallback? onVinylUpdated;
  const ViewDisco({super.key, required this.vinile, this.onVinylUpdated});

  @override
  State<ViewDisco> createState() => _ViewDiscoState();
}

class _ViewDiscoState extends State<ViewDisco> {
  late Vinyl currentVinyl;

  @override
  void initState() {
    super.initState();
    currentVinyl = widget.vinile;
  }

  Future<void> _refreshVinyl() async {
    final provider = Provider.of<VinylProvider>(context, listen: false);
    // Ricarica tutti i vinili per aggiornare la cache
    await provider.loadVinyls();
    // Cerca il vinile aggiornato nella cache
    final updatedVinyl = provider.getVinylById(widget.vinile.id!);
    if (updatedVinyl != null && mounted) {
      setState(() {
        currentVinyl = updatedVinyl;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Note:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Text(
            notes,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentVinyl.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 150,
            height: 150,
            child: currentVinyl.imagePath != null
                ? Image.file(
                    File(currentVinyl.imagePath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.album, color: AppConstants.primaryColor.withValues(alpha: 0.5), size: 60),
                  ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow("Artista", currentVinyl.artist),
                const SizedBox(height: 8),
                _buildInfoRow("Anno", currentVinyl.year.toString()),
                const SizedBox(height: 8),
                _buildInfoRow("Genere", currentVinyl.genre),
                const SizedBox(height: 8),
                _buildInfoRow("Casa Discografica", currentVinyl.label),
                const SizedBox(height: 8),
                _buildInfoRow("Condizioni", currentVinyl.condition),
                const SizedBox(height: 8),
                _buildInfoRow("Data Aggiunta", currentVinyl.dateAdded.toLocal().toString().split(' ')[0]),
                if (currentVinyl.notes != null && currentVinyl.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildNotesSection(currentVinyl.notes!),
                ],
              ],
            ),
          ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final result = await navigator.push(
                          MaterialPageRoute(
                            builder: (context) => AddEditVinylScreen(
                              vinyl: currentVinyl,
                            ),
                          ),
                        );
                        // REFRESH: Ricarica dati se vinile modificato con successo
                        if (result == true && mounted) {
                          await _refreshVinyl();
                          // Chiama il callback per aggiornare anche la schermata padre
                          if (widget.onVinylUpdated != null) {
                            widget.onVinylUpdated!();
                          }
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Vinile modificato con successo!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }

                      },
                        child: Text("Modifica", style: TextStyle(
                              fontSize: 20,
                              color: AppConstants.primaryColor)
                              )
                    ),

                    Divider(),

                    GestureDetector(
                      onTap: () async {
                        if (!mounted) return;
                        // Salva i riferimenti al context prima delle operazioni async
                        final provider = Provider.of<VinylProvider>(context, listen: false);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        
                        final confirm = await showDialog<bool>(
                          context: context, 
                          builder: (context) => AlertDialog(
                            title: Text("Conferma eliminazione"),
                            content: Text("Sei sicuro di voler eliminare questo vinile?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Annulla'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Elimina', style: TextStyle(color: Colors.red)),
                              ),
                            ]
                          )
                        );
                        if (confirm == true && mounted) {
                            // logica di eliminazione
                            final success = await provider.deleteVinyl(currentVinyl.id!);
                            if (success && mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Vinile eliminato!'))
                              );
                              navigator.pop(); // Torna indietro dopo l'eliminazione
                            } else if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Errore durante l\'eliminazione'))
                              );
                            }
                        }
                      },
                      child: Text("Elimina", style: TextStyle(
                            fontSize: 20,
                            color: Colors.red)
                            ) 
                    )
                    ,
                  ],
              ),
            ),      
        ],
      ),
    );
  }
}


abstract class ListItem {
  Widget buildTopPart(BuildContext context);
  Widget buildBottomPart(BuildContext context);
}

class CanzoniItem implements ListItem {
  final Song canzone;
  CanzoniItem(this.canzone);

  @override
  Widget buildTopPart(BuildContext context) => Text(canzone.titolo);

  @override
  Widget buildBottomPart(BuildContext context) =>
      Text('Artista: ${canzone.artista} \nAnno: ${canzone.anno}');
}


class SchermataDettaglio extends StatefulWidget {
  final List<ListItem> items;
  final Vinyl vinile;
  const SchermataDettaglio({super.key, required this.items, required this.vinile});

  @override
  State<SchermataDettaglio> createState() => _SchermataDettaglioState();
}

class _SchermataDettaglioState extends State<SchermataDettaglio> {
  late Vinyl currentVinyl;
  late List<ListItem> currentItems;

  @override
  void initState() {
    super.initState();
    currentVinyl = widget.vinile;
    currentItems = widget.items;
  }

  Future<void> _refreshVinylAndSongs() async {
    final provider = Provider.of<VinylProvider>(context, listen: false);
    // Ricarica tutti i vinili per aggiornare la cache
    await provider.loadVinyls();
    // Cerca il vinile aggiornato nella cache
    final updatedVinyl = provider.getVinylById(widget.vinile.id!);
    if (updatedVinyl != null && mounted) {
      // Crea la lista aggiornata di CanzoniItem dalle canzoni del vinile
      List<CanzoniItem> songItems = [];
      if (updatedVinyl.song != null && updatedVinyl.song!.isNotEmpty) {
        songItems = updatedVinyl.song!.map((song) => CanzoniItem(song)).toList();
      }
      setState(() {
        currentVinyl = updatedVinyl;
        currentItems = songItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          leading: IconButton( 
            icon: Icon(Icons.arrow_back),
            onPressed:(){
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
          title: const Text('Dettaglio Vinile'),
          foregroundColor: Colors.white,
          backgroundColor: AppConstants.primaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ViewDisco(
                vinile: currentVinyl,
                onVinylUpdated: _refreshVinylAndSongs,
              ),
              // Sezione Canzoni
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Canzoni',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (currentItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.music_off,
                              size: 48,
                              color: Colors.grey.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nessuna canzone aggiunta',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Le canzoni di questo vinile non sono state ancora inserite',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentItems.length,
                        itemBuilder: (context, index) {
                          final ListItem item = currentItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.music_note,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                              title: item.buildTopPart(context),
                              subtitle: item.buildBottomPart(context),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
