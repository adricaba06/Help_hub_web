import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/opportunity_response.dart';

class OpportunityCard extends StatelessWidget {
  final OpportunityResponse opportunity;
  final VoidCallback? onTap;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMM y', 'es');
    final dateRange =
        '${formatter.format(opportunity.dateFrom)} — ${formatter.format(opportunity.dateTo)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE4E4E7)),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: opportunity.isOpen
                          ? const Color(0xFF10B77F)
                          : const Color(0xFFA1A1AA),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      opportunity.isOpen ? 'ABIERTA' : 'CERRADA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFFA1A1AA), size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                opportunity.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Color(0xFF52525B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      opportunity.city,
                      style: const TextStyle(
                          color: Color(0xFF52525B), fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: Color(0xFF52525B)),
                  const SizedBox(width: 4),
                  Text(
                    dateRange,
                    style: const TextStyle(
                        color: Color(0xFF52525B), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
