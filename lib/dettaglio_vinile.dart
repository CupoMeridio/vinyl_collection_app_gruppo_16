import 'package:flutter/material.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import 'models/song_.dart';
import 'models/vinyl.dart';
import 'dart:io';

class ViewDisco extends StatelessWidget {
  final Vinyl vinile;
  const ViewDisco({super.key, required this.vinile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Ensure column only takes necessary space
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: vinile.imagePath != null
                                ? Image.file(
                                    File(vinile.imagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                    child: Icon(Icons.album, color: AppConstants.primaryColor.withValues(alpha: 0.5), size: 100),
                                  ), // Cover the box while maintaining aspect ratio
            ),

          Text(
            vinile.title, // Use actual data from vinile
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4.0),
          Text(
            vinile.artist, // Use actual data from vinile
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Anno: ${vinile.year}'),
          const SizedBox(height: 4.0),
          Text(
            'Genere: ${vinile.genre}'),
          const SizedBox(height: 4.0),
          Text(
            'Casa Discografica: ${vinile.label}'),
          const SizedBox(height: 4.0),
          if(vinile.notes != null && vinile.notes!.isNotEmpty)
          ...[
          Text(
            'Note Personali: ${vinile.notes}'),
          const SizedBox(height: 4.0)
          ],
          Text(
            'Condizioni: ${vinile.condition}'),
          const SizedBox(height: 4.0),
          Text(
            'Data di aggiunta: ${vinile.dateAdded.toLocal().toString().split(' ')[0]}'), // Format date to show only the date part
          const SizedBox(height: 4.0)
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
    return MaterialApp(
      title: 'Dettaglio Vinile',
      home: Scaffold(
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
      ),
    );
  }
}
