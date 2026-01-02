import 'package:app010/models/competition.dart';
import 'package:app010/models/match_models.dart';
import 'package:app010/screens/match_details_page.dart';
import 'package:app010/services/football_service_api.dart';
import 'package:app010/widgets/async_state_views.dart';
import 'package:app010/widgets/app_drawer.dart';
import 'package:app010/colors.dart' as app_colors;
import 'package:flutter/material.dart';

class MatchsPage extends StatefulWidget {
  final String? initialCompetitionCode;
  final Function(int)? onPageChange;

  const MatchsPage({super.key, this.initialCompetitionCode, this.onPageChange});

  @override
  State<MatchsPage> createState() => _MatchsPageState();
}

class _MatchsPageState extends State<MatchsPage> {
  final _service = FootballDataApiService();

  late Future<List<Competition>> _competitionsFuture;
  Future<CompetitionMatchesResponse>? _matchesFuture;

  String? _competitionCode;
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

  void _loadMatches() {
    final code = _competitionCode;
    if (code == null || code.isEmpty) return;
    setState(() {
      _matchesFuture = _service.getCompetitionMatches(
        competitionCode: code,
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
      if (_matchesFuture == null && _competitionCode != null) {
        _matchesFuture = _service.getCompetitionMatches(
          competitionCode: _competitionCode!,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownMenu<String>(
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
                    setState(() {
                      _competitionCode = v;
                    });
                    _loadMatches();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _matchday?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Journée (matchday) – optionnel',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    final parsed = int.tryParse(v.trim());
                    setState(() => _matchday = parsed);
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _loadMatches,
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
    final showDrawer = widget.onPageChange != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matchs'),
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
                child: FutureBuilder<CompetitionMatchesResponse>(
                  future: _matchesFuture,
                  builder: (context, matchesSnapshot) {
                    if (_matchesFuture == null) {
                      return const EmptyView(
                        message:
                            'Choisissez une ligue pour afficher les matchs.',
                      );
                    }
                    if (matchesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LoadingView(
                        message: 'Chargement des matchs…',
                      );
                    }
                    if (matchesSnapshot.hasError) {
                      return ErrorView(
                        error: matchesSnapshot.error!,
                        onRetry: _loadMatches,
                      );
                    }

                    final response = matchesSnapshot.data;
                    final matches =
                        response?.matches ?? const <FootballMatch>[];
                    if (matches.isEmpty) {
                      return const EmptyView(
                        message: 'Aucun match trouvé pour ces filtres.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: matches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final m = matches[index];
                        final local = m.utcDate?.toLocal();
                        final dateText = local == null
                            ? ''
                            : '${local.day.toString().padLeft(2, '0')}/'
                                  '${local.month.toString().padLeft(2, '0')}/'
                                  '${local.year} '
                                  '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
                        final score =
                            (m.score.fullTime.home == null ||
                                m.score.fullTime.away == null)
                            ? '—'
                            : '${m.score.fullTime.home} - ${m.score.fullTime.away}';

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MatchDetailsPage(matchId: m.id),
                              ),
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          m.competition.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelLarge,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (m.matchday != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            color: primary.withValues(
                                              alpha: 0.06,
                                            ),
                                          ),
                                          child: Text(
                                            'J${m.matchday}',
                                            style: TextStyle(color: primary),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      '${m.homeTeam.name}  •  $score  •  ${m.awayTeam.name}',
                                    ),
                                    subtitle: Text(
                                      [
                                        if (dateText.isNotEmpty) dateText,
                                        if (m.status.isNotEmpty) m.status,
                                      ].join('  •  '),
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                  ),
                                ],
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
