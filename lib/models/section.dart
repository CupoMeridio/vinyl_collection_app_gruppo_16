import 'package:flutter/material.dart';
import 'package:vinyl_collection_app_gruppo_16/models/vinyl.dart';
import '../utils/constants.dart';
import '../services/vinyl_provider.dart';

import 'package:provider/provider.dart';
import 'dart:io';

Widget buildEmptyState(String title, String subtitle, IconData icon) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.grey[400],
              size: 48,
            ),
            SizedBox(height: AppConstants.spacingSmall),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

// intestazione della sezione (icona, titolo)
Widget buildSectionHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 24,
            ),
            SizedBox(width: AppConstants.spacingSmall),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

Widget buildFavoriteVinylsSection(BuildContext context) {
    return Consumer<VinylProvider>(
      builder: (context, provider, child) {
        final favoriteVinyls = provider.favoriteVinyls;
        
        return Column(
          children: [
            buildSectionHeader(
              'I Tuoi Preferiti',
              Icons.favorite,
            ),
            SizedBox(height: AppConstants.spacingMedium),
            
            if (favoriteVinyls.isEmpty)
              buildEmptyState(
                'Nessun preferito',
                'Marca i tuoi vinili preferiti per vederli qui!',
                Icons.favorite_border,
              )
            else
              SizedBox(
                height: 165,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  itemCount: favoriteVinyls.length,
                  separatorBuilder: (context, index) => 
                      SizedBox(width: AppConstants.spacingMedium),
                  itemBuilder: (context, index) {
                    final vinyl = favoriteVinyls[index];
                    return buildVinylCard(vinyl, context);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

// immagine segnaposto per i vinili senza copertina
Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.album,
        color: AppConstants.primaryColor.withValues(alpha: 0.5),
        size: 40,
      ),
    );
  }

// widget per visualizzare un vinile, con o senza copertina
Widget buildVinylCard(Vinyl vinyl, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // NAVIGATION: Naviga alla schermata dettaglio vinile
        await Navigator.pushNamed(
          context,
          '/DettaglioVinile',
          arguments: vinyl,
        );
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immagine con copertina
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: vinyl.imagePath != null
              // da un bordo rettangolare al vinile
                  ? ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.borderRadius),
                      ),
                      child: Image.file(
                        File(vinyl.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                    // immagine senza copertina
                  : _buildImagePlaceholder(),
            ),
            
            // INFO: Informazioni vinile
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vinyl.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      vinyl.artist,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vinyl.year.toString(),
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (vinyl.isFavorite)
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 12,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// card per le statistiche
Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          SizedBox(height: AppConstants.spacingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

Widget buildSection(String title, String missingPhrase, String missingSubtitle, IconData mainIcon, IconData emptyIcon, dynamic navigation, List<Vinyl> list, BuildContext context) {
    return Consumer<VinylProvider>(
      builder: (context, provider, child) {
        return Column(
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                Expanded(
                  child: buildSectionHeader(title, mainIcon),
                ),
                if (navigation != null)
                  Flexible(
                    child: TextButton.icon(
                      onPressed: () {
                        if (navigation is String) {
                          Navigator.pushNamed(context, navigation);
                        } else if (navigation is Function) {
                          navigation();
                        }
                      },
                      icon: Icon(Icons.arrow_forward),
                      label: Text('Vedi tutti'),
                    ),
                  ),
                    ],
                  ),
                SizedBox(height: AppConstants.spacingMedium),

                if (list.isEmpty)
                  buildEmptyState(missingPhrase, missingSubtitle, emptyIcon)
                  else
                    SizedBox(
                      height: 165,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        itemCount: list.length,
                        separatorBuilder: (context, index) => 
                            SizedBox(width: AppConstants.spacingMedium),
                        itemBuilder: (context, index) {
                          final vinyl = list[index];
                          return buildVinylCard(vinyl, context);
                        }
                      ),
                    ),
                ],
          );
      },
    );
}
