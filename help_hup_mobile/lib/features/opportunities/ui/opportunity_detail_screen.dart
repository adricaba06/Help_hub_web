import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/opportunity_detail_provider.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final int opportunityId;

  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpportunityDetailProvider>().load(widget.opportunityId);
    });
  }

  Future<void> _showApplyDialog(int opportunityId) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    final provider = context.read<OpportunityDetailProvider>();
    final detail = provider.detail;
    final opp = detail?.opportunity;
    final dialogDateFormat = DateFormat('d MMM y', 'es');

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Enviar solicitud'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (opp != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8F7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE4E4E7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opp.city.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF10B77F),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opp.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dialogDateFormat.format(opp.dateFrom)} - ${dialogDateFormat.format(opp.dateTo)}',
                            style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 12,
                            ),
                          ),
                          if (detail != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Plazas: ${detail.acceptedCount}/${opp.seats} ocupadas · Libres: ${detail.seatsLeft}',
                              style: const TextStyle(
                                color: Color(0xFF52525B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: controller,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Motivación',
                      hintText: 'Cuéntanos por qué quieres participar…',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final txt = (v ?? '').trim();
                      if (txt.isEmpty) return 'La motivación es obligatoria';
                      if (txt.length < 10) return 'Mínimo 10 caracteres';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            Consumer<OpportunityDetailProvider>(
              builder: (_, p, __) {
                return FilledButton(
                  onPressed: p.applying
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          final ok = await provider.apply(
                            opportunityId,
                            controller.text,
                          );

                          if (ok) {
                            Navigator.pop(context, true);
                          } else {
                            // El dialog se mantiene abierto y el error se maneja fuera.
                          }
                        },
                  child: p.applying
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar'),
                );
              },
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada ✅')),
      );
    } else {
      final err = provider.applyError;
      if (err != null && mounted) {
        var msg = 'Error al enviar solicitud';

        if (err.contains('NO_TOKEN') || err.contains('UNAUTHORIZED')) {
          msg = 'Tienes que iniciar sesión';
        } else if (err.contains('FORBIDDEN')) {
          msg = 'No tienes permisos (rol incorrecto)';
        } else if (err.contains('CONFLICT')) {
          msg = 'Ya has aplicado a esta oportunidad o no está disponible';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detalle de oportunidad',
          style: TextStyle(
              color: Color(0xFF18181B), fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF52525B)),
      ),
      body: Consumer<OpportunityDetailProvider>(
        builder: (_, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF10B77F)),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF52525B)),
                ),
              ),
            );
          }

          final detail = provider.detail;
          if (detail == null) {
            return const Center(child: Text('Sin datos.'));
          }

          final opp = detail.opportunity;
          final formatter = DateFormat('d MMM y', 'es');
          final dateRange =
              '${formatter.format(opp.dateFrom)} - ${formatter.format(opp.dateTo)}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Estado
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: opp.isOpen
                          ? const Color(0xFF10B77F)
                          : const Color(0xFFA1A1AA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      opp.isOpen ? 'ABIERTA' : 'CERRADA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Título
                Text(
                  opp.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 12),

                _rowIconText(Icons.location_on_outlined, opp.city),
                const SizedBox(height: 8),
                _rowIconText(Icons.calendar_today_outlined, dateRange),
                const SizedBox(height: 16),
                _infoBox(detail.acceptedCount, detail.seatsLeft, opp.seats),

                const SizedBox(height: 20),

                // Botón solicitar (voluntario que puede aplicar)
                if (detail.canApply)
                  ElevatedButton(
                    onPressed: () => _showApplyDialog(widget.opportunityId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B77F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Aplicar'),
                  ),

                // Ver solicitud propia (ya aplicó)
                if (detail.hasApplied &&
                    detail.myApplicationId != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'TODO: Ver solicitud #${detail.myApplicationId} (feat-015)')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B77F),
                      side: const BorderSide(color: Color(0xFF10B77F)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Ver mi solicitud'),
                  ),
                ],

                // Editar / Eliminar (manager/admin)
                if (detail.canEdit || detail.canDelete) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (detail.canEdit)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('TODO: Editar (manager)')),
                              );
                            },
                            child: const Text('Editar'),
                          ),
                        ),
                      if (detail.canEdit && detail.canDelete)
                        const SizedBox(width: 10),
                      if (detail.canDelete)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('TODO: Eliminar (manager)')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Eliminar'),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _rowIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF52525B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(color: Color(0xFF52525B), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _infoBox(int accepted, int left, int totalSeats) {
    final value = totalSeats == 0
        ? 0.0
        : (accepted / totalSeats).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plazas',
            style: TextStyle(
                color: Color(0xFF18181B), fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Aceptadas: $accepted',
                  style: const TextStyle(color: Color(0xFF52525B))),
              Text('Libres: $left',
                  style: const TextStyle(color: Color(0xFF52525B))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: const Color(0xFFE4E4E7),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF10B77F)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$accepted/$totalSeats ocupadas',
            style: const TextStyle(
                color: Color(0xFF10B77F), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
