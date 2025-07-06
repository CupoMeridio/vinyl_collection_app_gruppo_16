import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import '../services/vinyl_provider.dart';
import 'dart:io';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerca vinili'),
      ),
      body: Column(
        children: [
          Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Cerca...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            Provider.of<VinylProvider>(context, listen: false).searchVinyls(value);
          },
        ),
      ),
      Expanded(
          child: Consumer<VinylProvider>(
            builder: (context, provider, child) {
              final vinyls = provider.filteredVinyls;
              return ListView.builder(
                itemCount: vinyls.length,
                itemBuilder: (context, index) {
                  final vinyl = vinyls[index];
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/DettaglioVinile', 
                        arguments: vinyl);
                    },
                    child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: vinyl.imagePath != null
                                ? Image.file(
                                    File(vinyl.imagePath!),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                    child: Icon(Icons.album, color: AppConstants.primaryColor.withValues(alpha: 0.5)),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // Testo a destra
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vinyl.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Artista: ${vinyl.artist}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Anno: ${vinyl.year}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ),
                  )
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
  }
}
