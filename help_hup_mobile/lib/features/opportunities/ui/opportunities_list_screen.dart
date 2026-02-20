import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/opportunities_provider.dart';
import '../provider/opportunity_detail_provider.dart';
import '../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';

class OpportunitiesListScreen extends StatefulWidget {
  const OpportunitiesListScreen({super.key});

  @override
  State<OpportunitiesListScreen> createState() =>
      _OpportunitiesListScreenState();
}

class _OpportunitiesListScreenState extends State<OpportunitiesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpportunitiesProvider>().search();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Oportunidades',
          style: TextStyle(
              color: Color(0xFF18181B), fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) =>
                  context.read<OpportunitiesProvider>().search(query: value),
              decoration: InputDecoration(
                hintText: 'Buscar oportunidades…',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF52525B)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<OpportunitiesProvider>().search();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                ),
              ),
            ),
          ),

          // Lista
          Expanded(
            child: Consumer<OpportunitiesProvider>(
              builder: (_, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF10B77F)),
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

                if (provider.opportunities.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron oportunidades.',
                      style: TextStyle(color: Color(0xFF52525B)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: provider.opportunities.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OpportunityCard(
                        opportunity: provider.opportunities[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (_) => OpportunityDetailProvider(),
                                child: OpportunityDetailScreen(
                                  opportunityId:
                                      provider.opportunities[index].id,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
