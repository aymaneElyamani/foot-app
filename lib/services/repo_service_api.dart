import 'dart:convert';

import 'package:app010/models/github_repo.dart';
import 'package:http/http.dart' as http;

class GitHubServiceApi {
  static const String _baseUrl = 'https://api.github.com';

  Future<List<MyGitHubRepo>> getUserRepos({required String username}) async {
    final url = Uri.parse('$_baseUrl/users/$username/repos');

    final response = await http.get(
      url,
      headers: {
        // GitHub recommends setting this header.
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load repos: HTTP ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final list = (decoded as List).cast<Map<String, dynamic>>();

    return list.map(MyGitHubRepo.fromMap).toList();
  }
}
