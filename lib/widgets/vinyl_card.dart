import 'dart:io';
import 'package:flutter/material.dart';
import '../models/vinyl.dart';
import '../utils/constants.dart';

enum VinylCardType {
  horizontal, // Layout orizzontale per liste (search, genre)
  verticalCompact, // Layout verticale compatto per home
}

class VinylCard extends StatelessWidget {
  final Vinyl vinyl;
  final VinylCardType type;
  final VoidCallback? onTap;

  const VinylCard({
    super.key,
    required this.vinyl,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case VinylCardType.horizontal:
        return _buildHorizontalCard(context);
      case VinylCardType.verticalCompact:
        return _buildVerticalCompactCard(context);
    }
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => _navigateToDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Immagine copertina
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppConstants.primaryColor.withValues(alpha: 26),
                ),
                child: vinyl.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(vinyl.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 16),
              // Informazioni vinile
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vinyl.artist,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vinyl.year.toString(),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.business,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vinyl.label,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Tag condizione
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(vinyl.condition),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vinyl.condition,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tag genere musicale
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.getGenreColor(vinyl.genre),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vinyl.genre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (vinyl.isFavorite)
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalCompactCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _navigateToDetail(context),
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

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.album,
        color: AppConstants.primaryColor.withValues(alpha: 128),
        size: type == VinylCardType.verticalCompact ? 40 : 32,
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Nuovo':
        return Colors.green[700]!;
      case 'Ottimo':
        return Colors.green[600]!;
      case 'Buono':
        return Colors.orange[700]!;
      case 'Discreto':
        return Colors.deepOrange[700]!;
      case 'Da restaurare':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/DettaglioVinile',
      arguments: vinyl,
    );
  }
}