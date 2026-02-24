import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/opportunity_response.dart';

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

  int _occupiedSeats() {
    if (opportunity.seats <= 0) return 0;
    final base = (opportunity.id * 3) % (opportunity.seats + 1);
    if (base == 0) return min(1, opportunity.seats);
    return base;
  }

  String _formatProgress() {
    final occupied = _occupiedSeats();
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
    final occupied = _occupiedSeats();
    final progress = opportunity.seats <= 0 ? 0.0 : occupied / opportunity.seats;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                _getImageForOpportunity(),
                height: 192,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 192,
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
                    height: 192,
                    width: double.infinity,
                    color: const Color(0xFFE4E4E7),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF10B77F)),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Color(0xFF334155),
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: opportunity.isOpen
                        ? const Color(0xE510B77F)
                        : const Color(0xCC71717A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    opportunity.isOpen ? 'ABIERTA' : 'CERRADA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      size: 14,
                      color: const Color(0xFF10B77F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getOrganizationName(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B77F),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  opportunity.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      opportunity.city,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
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
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatProgress(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B77F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B77F),
                        ),
                        minHeight: 8,
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
