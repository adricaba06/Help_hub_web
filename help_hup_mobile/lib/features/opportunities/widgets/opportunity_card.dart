import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/opportunity_response.dart';

class OpportunityCard extends StatelessWidget {
  final OpportunityResponse opportunity;

  const OpportunityCard({
    super.key,
    required this.opportunity,
  });

  String _formatDateRange() {
    final formatter = DateFormat('d MMM', 'es');
    final from = formatter.format(opportunity.dateFrom);
    final to = formatter.format(opportunity.dateTo);
    return '$from - $to';
  }

  String _formatProgress() {
    // Por ahora mostramos 15 ocupadas de ejemplo
    final occupied = 15;
    return '$occupied/${opportunity.seats} ocupadas';
  }

  String _getOrganizationName() {
    // Organizaciones ficticias basadas en el título
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
    // Imágenes de placeholder basadas en el tipo de oportunidad
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
          // Imagen con badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFE4E4E7),
                  child: Icon(
                    Icons.volunteer_activism,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              // Badge de estado
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
              // Botón favorito
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Color(0xFF52525B)),
                    iconSize: 20,
                    onPressed: () {},
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
                // Organización
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
                
                // Título
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
                
                // Ciudad y fechas
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
                
                // Progreso de plazas
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
                        value: 15 / opportunity.seats,
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
