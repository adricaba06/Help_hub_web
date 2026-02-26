import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/models/application_response.dart';
import '../../../core/services/application_service.dart';
import '../bloc/opportunity_applications_bloc.dart';

/// Section used inside organization opportunity list cards in manager mode.
///
/// It creates its own [OpportunityApplicationsBloc] and immediately requests
/// the first page of applications. The widget displays a simple loading/error
/// UI and then a list of applications with buttons to change status.
class OpportunityApplicationsSection extends StatelessWidget {
  final int opportunityId;

  const OpportunityApplicationsSection({
    Key? key,
    required this.opportunityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OpportunityApplicationsBloc>(
      create: (_) => OpportunityApplicationsBloc(
        applicationService: ApplicationService(),
        opportunityId: opportunityId,
      )..add(LoadOpportunityApplications()),
      child: const _ApplicationsContent(),
    );
  }
}

class _ApplicationsContent extends StatelessWidget {
  const _ApplicationsContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OpportunityApplicationsBloc,
        OpportunityApplicationsState>(
      listener: (context, state) {
        if (state is OpportunityApplicationsError) {
          final msg = state.message.replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
          // after showing error, request fresh list to avoid stuck error page
          context
              .read<OpportunityApplicationsBloc>()
              .add(LoadOpportunityApplications());
        }
      },
      builder: (context, state) {
        if (state is OpportunityApplicationsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OpportunityApplicationsError) {
          // error UI is handled by listener so just show nothing
          return const SizedBox.shrink();
        }

        if (state is OpportunityApplicationsLoaded) {
          final apps = state.applications;
          if (apps.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('Sin solicitudes')),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final application = apps[index];
              return _ManagerApplicationCard(
                application: application,
                isUpdating: state.isUpdating && state.updatingId == application.id,
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: apps.length,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ManagerApplicationCard extends StatelessWidget {
  final ApplicationResponse application;
  final bool isUpdating;

  const _ManagerApplicationCard({
    Key? key,
    required this.application,
    this.isUpdating = false,
  }) : super(key: key);

  void _changeStatus(BuildContext context, String newStatus) {
    context.read<OpportunityApplicationsBloc>().add(
          ChangeApplicationStatus(
            applicationId: application.id,
            newStatus: newStatus,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = application.applicationDate == null
        ? 'sin fecha'
        : DateFormat('dd MMM', 'es').format(application.applicationDate!);
    final status = application.status.trim().toUpperCase();
    final isPending = status == 'PENDING';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            application.userName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text('Enviado: $dateText', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(application.motivationText),
          const SizedBox(height: 8),
          if (isPending)
            if (isUpdating)
              const Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _changeStatus(context, 'ACCEPTED'),
                      child: const Text('Aceptar'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _changeStatus(context, 'REJECTED'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Rechazar'),
                    ),
                  ),
                ],
              )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status == 'ACCEPTED'
                    ? const Color(0x1910B77F)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status == 'ACCEPTED' ? 'ACEPTADA' : 'RECHAZADA',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: status == 'ACCEPTED'
                      ? const Color(0xFF10B77F)
                      : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
