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
  const ViewDisco({super.key, required this.vinile});

  @override
  State<ViewDisco> createState() => _ViewDiscoState();
}

class _ViewDiscoState extends State<ViewDisco> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Ensure column only takes necessary space
        children: [
          Text(
            widget.vinile.title, // Use actual data from vinile
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4.0),
          SizedBox(
            width: 200,
            height: 200,
            child: widget.vinile.imagePath != null
                                ? Image.file(
                                    File(widget.vinile.imagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                    child: Icon(Icons.album, color: AppConstants.primaryColor.withValues(alpha: 0.5), size: 100),
                                  ), // Cover the box while maintaining aspect ratio
            ),

          
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Titolo: "),
                    Text(widget.vinile.title, 
                    style: Theme.of(context).textTheme.headlineSmall
                    )
                  ] 
                ),
                Divider(), // inizio nuovo elemento 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Artista: "),
                    Text(widget.vinile.artist, 
                    style: Theme.of(context).textTheme.bodyMedium
                    )
                  ] 
                ), // fine elemento
                Divider(), // linea divisoria
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Anno: "),
                    Text(widget.vinile.year.toString(), 
                    style: Theme.of(context).textTheme.bodyMedium
                    )
                  ] 
                ), // fine elemento
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Genere: "),
                    Text(widget.vinile.genre, 
                    style: Theme.of(context).textTheme.bodyMedium
                    )
                  ] 
                ), // fine elemento
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Casa Discografica: "),
                    Text(widget.vinile.label, 
                    style: Theme.of(context).textTheme.bodyMedium
                    )
                  ] 
                ), // fine elemento
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Artista: "),
                    Text(widget.vinile.artist, 
                    style: Theme.of(context).textTheme.bodyMedium
                    )
                  ] 
                ), // fine elemento
                Divider(),
                if (widget.vinile.notes != null && widget.vinile.notes!.isNotEmpty)
                  ...[ Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Note Personali: "),
                      Text(widget.vinile.notes!, 
                      style: Theme.of(context).textTheme.bodyMedium
                      )
                    ] 
                  ), 
                Divider(),
                  ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Condizioni: "),
                    Text(widget.vinile.condition, 
                    style: Theme.of(context).textTheme.bodyMedium
                    )
                  ] 
                ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Data Di Aggiunta: "),
                      Text(widget.vinile.dateAdded.toLocal().toString().split(' ')[0], 
                      style: Theme.of(context).textTheme.bodyMedium
                      )
                    ] 
                  ),// fine elemento
                  
              ]
            )
          ),

              const SizedBox(height: 40),
              Padding(padding: EdgeInsets.symmetric(horizontal: 50),
              child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (!mounted) return;
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final result = await navigator.push(
                          MaterialPageRoute(
                            builder: (context) => AddEditVinylScreen(vinyl: widget.vinile),
                          ),
                        );
                        
                        // REFRESH: Ricarica dati se vinile aggiunto con successo
                        if (result == true && mounted) {
                          // Il provider si aggiorna automaticamente tramite notifyListeners
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
                            final success = await provider.deleteVinyl(widget.vinile.id!);
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


class SchermataDettaglio extends StatelessWidget {
  final List<ListItem> items;
  final Vinyl vinile;
  const SchermataDettaglio({super.key, required this.items, required this.vinile});

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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ViewDisco(vinile: vinile),
            Expanded(
              // Expanded ensures ListView.builder gets a bounded height
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final ListItem item = items[index];

                  return ListTile(
                    leading: Icon(Icons.music_note),
                    title: item.buildTopPart(context),
                    subtitle: item.buildBottomPart(context),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }
}
