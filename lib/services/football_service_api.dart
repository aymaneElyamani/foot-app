import 'dart:convert';

import 'package:app010/env_config.dart';
import 'package:app010/models/competition.dart';
import 'package:app010/models/match_models.dart';
import 'package:app010/models/standings_models.dart';
import 'package:http/http.dart' as http;

class FootballDataApiService {
  FootballDataApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => {
    'X-Auth-Token': Env.apiKey,
    'Accept': 'application/json',
  };

  Uri _endpoint(String path, [Map<String, String>? query]) {
    final base = Uri.parse(Env.baseUrl);
    final resolved = base.resolve(path);
    return resolved.replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> _getJsonObject(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(uri, headers: headers ?? _headers);
    if (response.statusCode != 200) {
      throw Exception('Request failed: HTTP ${response.statusCode}');
    }
    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response type');
    }
    return decoded;
  }
  Future<List<Competition>> getCompetitions() async {
    final uri = _endpoint('competitions');
    final jsonObj = await _getJsonObject(uri);

    final competitions = (jsonObj['competitions'] as List?) ?? const [];
    return competitions
        .whereType<Map<String, dynamic>>()
        .map(Competition.fromMap)
        .toList(growable: false);
  }

  Future<CompetitionMatchesResponse> getCompetitionMatches({
    required String competitionCode,
    int? matchday,
  }) async {
    final query = <String, String>{};
    if (matchday != null) query['matchday'] = matchday.toString();

    final uri = _endpoint(
      'competitions/$competitionCode/matches',
      query.isEmpty ? null : query,
    );
    final jsonObj = await _getJsonObject(uri);
    return CompetitionMatchesResponse.fromMap(jsonObj);
  }

  Future<FootballMatch> getMatch({required int matchId}) async {
    final uri = _endpoint('matches/$matchId');
    final jsonObj = await _getJsonObject(uri);
    final match = (jsonObj['match'] as Map<String, dynamic>?) ?? const {};
    return FootballMatch.fromMap(match);
  }

  Future<StandingsResponse> getStandings({
    required String competitionCode,
    int? season,
    int? matchday,
  }) async {
    final query = <String, String>{};
    if (season != null) query['season'] = season.toString();
    if (matchday != null) query['matchday'] = matchday.toString();

    final uri = _endpoint(
      'competitions/$competitionCode/standings',
      query.isEmpty ? null : query,
    );
    final jsonObj = await _getJsonObject(uri);
    return StandingsResponse.fromMap(jsonObj);
  }

  Future<TeamsResponse> getTeams({int limit = 50, int offset = 0}) async {
    final uri = _endpoint('teams', {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    final jsonObj = await _getJsonObject(uri);
    return TeamsResponse.fromMap(jsonObj);
  }

  Future<TeamDetails> getTeam({required int teamId}) async {
    final uri = _endpoint('teams/$teamId');
    final jsonObj = await _getJsonObject(uri);
    return TeamDetails.fromMap(jsonObj);
  }

  void dispose() {
    _client.close();
  }
}
