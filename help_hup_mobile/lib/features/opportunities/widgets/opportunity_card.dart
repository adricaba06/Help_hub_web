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
    // Por ahora mostramos 0 ocupadas, cuando se agregue la info real se actualizará
    final occupied = 0;
    return '$occupied/${opportunity.seats} ocupadas';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge de estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: opportunity.isOpen
                    ? const Color(0xFF10B77F)
                    : const Color(0xFFA1A1AA),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                opportunity.isOpen ? 'ABIERTA' : 'CERRADA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Título
            Text(
              opportunity.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 12),
            
            // Ciudad
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF52525B),
                ),
                const SizedBox(width: 4),
                Text(
                  opportunity.city,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF52525B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Fechas
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF52525B),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateRange(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF52525B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Plazas con barra de progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso de plazas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF52525B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0, // Por ahora 0, se actualizará con datos reales
                          backgroundColor: const Color(0xFFE4E4E7),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B77F),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
