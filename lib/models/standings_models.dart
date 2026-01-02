import 'package:app010/models/match_models.dart';

class StandingRow {
  const StandingRow({
    required this.position,
    required this.team,
    required this.playedGames,
    required this.won,
    required this.draw,
    required this.lost,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  final int position;
  final TeamRef team;
  final int playedGames;
  final int won;
  final int draw;
  final int lost;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  factory StandingRow.fromMap(Map<String, dynamic> map) {
    return StandingRow(
      position: (map['position'] as num?)?.toInt() ?? 0,
      team: TeamRef.fromMap((map['team'] as Map<String, dynamic>?) ?? const {}),
      playedGames: (map['playedGames'] as num?)?.toInt() ?? 0,
      won: (map['won'] as num?)?.toInt() ?? 0,
      draw: (map['draw'] as num?)?.toInt() ?? 0,
      lost: (map['lost'] as num?)?.toInt() ?? 0,
      points: (map['points'] as num?)?.toInt() ?? 0,
      goalsFor: (map['goalsFor'] as num?)?.toInt() ?? 0,
      goalsAgainst: (map['goalsAgainst'] as num?)?.toInt() ?? 0,
      goalDifference: (map['goalDifference'] as num?)?.toInt() ?? 0,
    );
  }
}

class StandingsTable {
  const StandingsTable({
    required this.type,
    required this.stage,
    required this.group,
    required this.table,
  });

  final String type;
  final String stage;
  final String group;
  final List<StandingRow> table;

  factory StandingsTable.fromMap(Map<String, dynamic> map) {
    final table = (map['table'] as List?) ?? const [];
    return StandingsTable(
      type: (map['type'] as String?) ?? '',
      stage: (map['stage'] as String?) ?? '',
      group: (map['group'] as String?) ?? '',
      table: table
          .whereType<Map<String, dynamic>>()
          .map(StandingRow.fromMap)
          .toList(growable: false),
    );
  }
}

class StandingsResponse {
  const StandingsResponse({required this.standings});

  final List<StandingsTable> standings;

  factory StandingsResponse.fromMap(Map<String, dynamic> map) {
    final standings = (map['standings'] as List?) ?? const [];
    return StandingsResponse(
      standings: standings
          .whereType<Map<String, dynamic>>()
          .map(StandingsTable.fromMap)
          .toList(growable: false),
    );
  }

  StandingsTable? get totalTable {
    for (final s in standings) {
      if (s.type.toUpperCase() == 'TOTAL') return s;
    }
    return standings.isEmpty ? null : standings.first;
  }
}
