import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/opportunity_response.dart';

class OpportunityCard extends StatelessWidget {
  final OpportunityResponse opportunity;
  final bool showFavoriteButton;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final VoidCallback? onFavoriteTap;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.isFavoriteLoading = false,
    this.onFavoriteTap,
  });

  String _formatDateRange() {
    final formatter = DateFormat('d MMM', 'es');
    final from = formatter.format(opportunity.dateFrom);
    final to = formatter.format(opportunity.dateTo);
    return '$from - $to';
  }

  String _formatProgress() {
    final occupied = 0;
    return '$occupied/${opportunity.seats} ocupadas';
  }

  String _getOrganizationName() {
    if (opportunity.title.toLowerCase().contains('alimento') ||
        opportunity.title.toLowerCase().contains('comida') ||
        opportunity.title.toLowerCase().contains('reparto')) {
      return 'CRUZ ROJA';
    } else if (opportunity.title.toLowerCase().contains('escolar') ||
        opportunity.title.toLowerCase().contains('apoy') ||
        opportunity.title.toLowerCase().contains('educación')) {
      return 'EDUCATODOS';
    }
    return 'VOLUNTARIADO';
  }

  Color _getOrganizationColor() {
    final org = _getOrganizationName();
    if (org == 'CRUZ ROJA') return const Color(0xFFDC2626);
    if (org == 'EDUCATODOS') return const Color(0xFF2563EB);
    return const Color(0xFF10B77F);
  }

  String _getImageForOpportunity() {
    if (opportunity.title.toLowerCase().contains('alimento') ||
        opportunity.title.toLowerCase().contains('comida')) {
      return 'https://images.unsplash.com/photo-1593113646773-028c64a8f1b8?w=400&h=300&fit=crop';
    } else if (opportunity.title.toLowerCase().contains('escolar') ||
        opportunity.title.toLowerCase().contains('apoy')) {
      return 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400&h=300&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=400&h=300&fit=crop';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  _getImageForOpportunity(),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFFE4E4E7),
                      child: Icon(
                        Icons.volunteer_activism,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFFE4E4E7),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B77F),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: opportunity.isOpen
                        ? const Color(0xFF10B77F)
                        : const Color(0xFFA1A1AA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    opportunity.isOpen ? 'ABIERTA' : 'CERRADA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              if (showFavoriteButton)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      onPressed:
                          isFavoriteLoading || onFavoriteTap == null
                              ? null
                              : onFavoriteTap,
                      icon:
                          isFavoriteLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                              : Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF71717A),
                              ),
                      tooltip:
                          isFavorite
                              ? 'Quitar de favoritos'
                              : 'Agregar a favoritos',
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 14,
                      color: _getOrganizationColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getOrganizationName(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getOrganizationColor(),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  opportunity.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18181B),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF71717A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${opportunity.city}, Centro',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFF71717A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progreso de plazas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF71717A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatProgress(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B77F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0,
                        backgroundColor: const Color(0xFFE4E4E7),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B77F),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
