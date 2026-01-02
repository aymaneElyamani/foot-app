import 'package:app010/models/competition.dart';
import 'package:app010/screens/equipe_classement.dart';
import 'package:app010/screens/matchs.dart';
import 'package:app010/services/football_service_api.dart';
import 'package:app010/widgets/async_state_views.dart';
import 'package:app010/widgets/app_drawer.dart';
import 'package:app010/colors.dart' as app_colors;
import 'package:flutter/material.dart';

class CompetitionsPage extends StatefulWidget {
  final Function(int)? onPageChange;

  const CompetitionsPage({super.key, this.onPageChange});

  @override
  State<CompetitionsPage> createState() => _CompetitionsPageState();
}

class _CompetitionsPageState extends State<CompetitionsPage> {
  final _service = FootballDataApiService();

  late Future<List<Competition>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _service.getCompetitions();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _service.getCompetitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);
    final showDrawer = widget.onPageChange != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compétitions'),
        leading: showDrawer
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
      ),
      drawer: showDrawer
          ? AppDrawer(onPageSelected: widget.onPageChange!)
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher une compétition (nom, code, pays)…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Competition>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView(
                    message: 'Chargement des compétitions…',
                  );
                }
                if (snapshot.hasError) {
                  return ErrorView(error: snapshot.error!, onRetry: _reload);
                }

                final data = snapshot.data ?? const <Competition>[];
                final filtered = data
                    .where((c) {
                      final hay =
                          '${c.name} ${c.code} ${c.area.name} ${c.area.code}'
                              .toLowerCase();
                      return _query.isEmpty || hay.contains(_query);
                    })
                    .toList(growable: false);

                if (filtered.isEmpty) {
                  return const EmptyView(
                    message: 'Aucune compétition trouvée.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = filtered[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                c.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                '${c.area.name} • ${c.type}'.trim(),
                              ),
                              trailing: c.code.isEmpty
                                  ? null
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        color: primary.withValues(alpha: 0.06),
                                      ),
                                      child: Text(
                                        c.code,
                                        style: TextStyle(color: primary),
                                      ),
                                    ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: c.code.isEmpty
                                        ? null
                                        : () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => MatchsPage(
                                                  initialCompetitionCode:
                                                      c.code,
                                                ),
                                              ),
                                            );
                                          },
                                    icon: const Icon(Icons.sports_soccer),
                                    label: const Text('Matchs'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: c.code.isEmpty
                                        ? null
                                        : () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ClassementPage(
                                                  initialCompetitionCode:
                                                      c.code,
                                                ),
                                              ),
                                            );
                                          },
                                    icon: const Icon(Icons.leaderboard),
                                    label: const Text('Classement'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
