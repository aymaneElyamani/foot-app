import 'package:app010/models/competition.dart';

class TeamRef {
  const TeamRef({required this.id, required this.name, required this.crest});

  final int id;
  final String name;
  final String crest;

  factory TeamRef.fromMap(Map<String, dynamic> map) {
    return TeamRef(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: (map['name'] as String?) ?? '',
      crest: (map['crest'] as String?) ?? '',
    );
  }
}

class ScoreTime {
  const ScoreTime({required this.home, required this.away});

  final int? home;
  final int? away;

  factory ScoreTime.fromMap(Map<String, dynamic> map) {
    int? asInt(dynamic v) => (v as num?)?.toInt();

    return ScoreTime(home: asInt(map['home']), away: asInt(map['away']));
  }
}

class Score {
  const Score({
    required this.winner,
    required this.duration,
    required this.fullTime,
    required this.halfTime,
  });

  final String winner;
  final String duration;
  final ScoreTime fullTime;
  final ScoreTime halfTime;

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      winner: (map['winner'] as String?) ?? '',
      duration: (map['duration'] as String?) ?? '',
      fullTime: ScoreTime.fromMap(
        (map['fullTime'] as Map<String, dynamic>?) ?? const {},
      ),
      halfTime: ScoreTime.fromMap(
        (map['halfTime'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class FootballMatch {
  const FootballMatch({
    required this.id,
    required this.utcDate,
    required this.status,
    required this.matchday,
    required this.stage,
    required this.group,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
    required this.competition,
    required this.venue,
  });

  final int id;
  final DateTime? utcDate;
  final String status;
  final int? matchday;
  final String stage;
  final String group;
  final TeamRef homeTeam;
  final TeamRef awayTeam;
  final Score score;
  final Competition competition;
  final String venue;

  factory FootballMatch.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value is! String || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    return FootballMatch(
      id: (map['id'] as num?)?.toInt() ?? 0,
      utcDate: parseDate(map['utcDate']),
      status: (map['status'] as String?) ?? '',
      matchday: (map['matchday'] as num?)?.toInt(),
      stage: (map['stage'] as String?) ?? '',
      group: (map['group'] as String?) ?? '',
      homeTeam: TeamRef.fromMap(
        (map['homeTeam'] as Map<String, dynamic>?) ?? const {},
      ),
      awayTeam: TeamRef.fromMap(
        (map['awayTeam'] as Map<String, dynamic>?) ?? const {},
      ),
      score: Score.fromMap((map['score'] as Map<String, dynamic>?) ?? const {}),
      competition: Competition.fromMap(
        (map['competition'] as Map<String, dynamic>?) ?? const {},
      ),
      venue: (map['venue'] as String?) ?? '',
    );
  }
}

class CompetitionMatchesResponse {
  const CompetitionMatchesResponse({
    required this.competition,
    required this.matches,
  });

  final Competition competition;
  final List<FootballMatch> matches;

  factory CompetitionMatchesResponse.fromMap(Map<String, dynamic> map) {
    final matches = (map['matches'] as List?) ?? const [];
    return CompetitionMatchesResponse(
      competition: Competition.fromMap(
        (map['competition'] as Map<String, dynamic>?) ?? const {},
      ),
      matches: matches
          .whereType<Map<String, dynamic>>()
          .map(FootballMatch.fromMap)
          .toList(growable: false),
    );
  }
}

class TeamSummary {
  const TeamSummary({
    required this.id,
    required this.name,
    required this.shortName,
    required this.crest,
  });

  final int id;
  final String name;
  final String shortName;
  final String crest;

  factory TeamSummary.fromMap(Map<String, dynamic> map) {
    return TeamSummary(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: (map['name'] as String?) ?? '',
      shortName: (map['shortName'] as String?) ?? '',
      crest: (map['crest'] as String?) ?? '',
    );
  }
}

class TeamsResponse {
  const TeamsResponse({required this.count, required this.teams});

  final int count;
  final List<TeamSummary> teams;

  factory TeamsResponse.fromMap(Map<String, dynamic> map) {
    final teams = (map['teams'] as List?) ?? const [];
    return TeamsResponse(
      count: (map['count'] as num?)?.toInt() ?? 0,
      teams: teams
          .whereType<Map<String, dynamic>>()
          .map(TeamSummary.fromMap)
          .toList(growable: false),
    );
  }
}

class TeamDetails {
  const TeamDetails({
    required this.id,
    required this.name,
    required this.shortName,
    required this.crest,
    required this.website,
    required this.venue,
    required this.founded,
  });

  final int id;
  final String name;
  final String shortName;
  final String crest;
  final String website;
  final String venue;
  final int? founded;

  factory TeamDetails.fromMap(Map<String, dynamic> map) {
    return TeamDetails(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: (map['name'] as String?) ?? '',
      shortName: (map['shortName'] as String?) ?? '',
      crest: (map['crest'] as String?) ?? '',
      website: (map['website'] as String?) ?? '',
      venue: (map['venue'] as String?) ?? '',
      founded: (map['founded'] as num?)?.toInt(),
    );
  }
}
