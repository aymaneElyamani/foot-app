import 'package:app010/models/competition.dart';
import 'package:app010/models/standings_models.dart';
import 'package:app010/services/football_service_api.dart';
import 'package:app010/widgets/async_state_views.dart';
import 'package:app010/colors.dart' as app_colors;
import 'package:flutter/material.dart';

class ClassementPage extends StatefulWidget {
  const ClassementPage({super.key, this.initialCompetitionCode});

  final String? initialCompetitionCode;

  @override
  State<ClassementPage> createState() => _ClassementPageState();
}

class _ClassementPageState extends State<ClassementPage> {
  final _service = FootballDataApiService();

  late Future<List<Competition>> _competitionsFuture;
  Future<StandingsResponse>? _standingsFuture;

  String? _competitionCode;
  int? _season;
  int? _matchday;

  @override
  void initState() {
    super.initState();
    _competitionsFuture = _service.getCompetitions();
    _competitionCode = widget.initialCompetitionCode;
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _loadStandings() {
    final code = _competitionCode;
    if (code == null || code.isEmpty) return;
    setState(() {
      _standingsFuture = _service.getStandings(
        competitionCode: code,
        season: _season,
        matchday: _matchday,
      );
    });
  }

  Widget _buildFilters(List<Competition> competitions) {
    final items = competitions
        .where((c) => c.code.isNotEmpty)
        .toList(growable: false);

    if (_competitionCode == null || _competitionCode!.isEmpty) {
      _competitionCode =
          widget.initialCompetitionCode ??
          (items.isEmpty ? null : items.first.code);
      if (_standingsFuture == null && _competitionCode != null) {
        _standingsFuture = _service.getStandings(
          competitionCode: _competitionCode!,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          DropdownMenu<String>(
            label: const Text('Ligue'),
            initialSelection: _competitionCode,
            dropdownMenuEntries: items
                .map(
                  (c) => DropdownMenuEntry(
                    value: c.code,
                    label: '${c.name} (${c.code})',
                  ),
                )
                .toList(growable: false),
            onSelected: (v) {
              if (v == null) return;
              setState(() => _competitionCode = v);
              _loadStandings();
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _season?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Saison (ex: 2023) – optionnel',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      setState(() => _season = int.tryParse(v.trim())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _matchday?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Journée – optionnel',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      setState(() => _matchday = int.tryParse(v.trim())),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _loadStandings,
                icon: const Icon(Icons.filter_alt),
                label: const Text('Filtrer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);

    return Scaffold(
      appBar: AppBar(title: const Text('Classement')),
      body: FutureBuilder<List<Competition>>(
        future: _competitionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(message: 'Chargement des ligues…');
          }
          if (snapshot.hasError) {
            return ErrorView(
              error: snapshot.error!,
              onRetry: () {
                setState(() {
                  _competitionsFuture = _service.getCompetitions();
                });
              },
            );
          }

          final competitions = snapshot.data ?? const <Competition>[];
          if (competitions.isEmpty) {
            return const EmptyView(message: 'Aucune compétition disponible.');
          }

          return Column(
            children: [
              _buildFilters(competitions),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<StandingsResponse>(
                  future: _standingsFuture,
                  builder: (context, standingsSnapshot) {
                    if (_standingsFuture == null) {
                      return const EmptyView(
                        message:
                            'Choisissez une ligue pour afficher le classement.',
                      );
                    }
                    if (standingsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LoadingView(
                        message: 'Chargement du classement…',
                      );
                    }
                    if (standingsSnapshot.hasError) {
                      return ErrorView(
                        error: standingsSnapshot.error!,
                        onRetry: _loadStandings,
                      );
                    }

                    final standings = standingsSnapshot.data;
                    final table = standings?.totalTable;
                    final rows = table?.table ?? const [];

                    if (rows.isEmpty) {
                      return const EmptyView(
                        message: 'Aucune donnée de classement disponible.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final r = rows[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                r.position.toString(),
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            title: Text(
                              r.team.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'W ${r.won}  •  D ${r.draw}  •  L ${r.lost}',
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: primary.withValues(alpha: 0.06),
                              ),
                              child: Text(
                                '${r.points} pts',
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
