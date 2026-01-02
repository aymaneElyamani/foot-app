import 'package:app010/models/match_models.dart';
import 'package:app010/services/football_service_api.dart';
import 'package:app010/widgets/async_state_views.dart';
import 'package:app010/colors.dart' as app_colors;
import 'package:flutter/material.dart';

class MatchDetailsPage extends StatefulWidget {
  const MatchDetailsPage({super.key, required this.matchId});

  final int matchId;

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final _service = FootballDataApiService();
  late Future<FootballMatch> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMatch(matchId: widget.matchId);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _service.getMatch(matchId: widget.matchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);

    return Scaffold(
      appBar: AppBar(title: const Text('Détails du match')),
      body: FutureBuilder<FootballMatch>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(message: 'Chargement des détails…');
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!, onRetry: _reload);
          }

          final m = snapshot.data;
          if (m == null) {
            return const EmptyView(message: 'Aucun détail disponible.');
          }

          final dateText = m.utcDate == null
              ? '—'
              : '${m.utcDate!.toLocal().day.toString().padLeft(2, '0')}/'
                    '${m.utcDate!.toLocal().month.toString().padLeft(2, '0')}/'
                    '${m.utcDate!.toLocal().year} '
                    '${m.utcDate!.toLocal().hour.toString().padLeft(2, '0')}:${m.utcDate!.toLocal().minute.toString().padLeft(2, '0')}';

          final scoreFT =
              (m.score.fullTime.home == null || m.score.fullTime.away == null)
              ? '—'
              : '${m.score.fullTime.home} - ${m.score.fullTime.away}';

          final scoreHT =
              (m.score.halfTime.home == null || m.score.halfTime.away == null)
              ? '—'
              : '${m.score.halfTime.home} - ${m.score.halfTime.away}';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.competition.name,
                              style: Theme.of(context).textTheme.titleMedium,
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
                                borderRadius: BorderRadius.circular(999),
                                color: primary.withValues(alpha: 0.06),
                              ),
                              child: Text(
                                'J${m.matchday}',
                                style: TextStyle(color: primary),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.homeTeam.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            scoreFT,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Expanded(
                            child: Text(
                              m.awayTeam.name,
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Statut',
                              value: m.status.isEmpty ? '—' : m.status,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(label: 'Mi-temps', value: scoreHT),
                            const SizedBox(height: 8),
                            _InfoRow(label: 'Date', value: dateText),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Stade',
                              value: m.venue.isEmpty ? '—' : m.venue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
