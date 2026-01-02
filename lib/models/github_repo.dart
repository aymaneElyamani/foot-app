class MyGitHubRepo {
  MyGitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.htmlUrl,
    required this.description,
    required this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.updatedAt,
    required this.ownerLogin,
    required this.ownerAvatarUrl,
  });

  final int id;
  final String name;
  final String fullName;
  final String htmlUrl;
  final String description;
  final String language;
  final int stargazersCount;
  final int forksCount;
  final DateTime? updatedAt;
  final String ownerLogin;
  final String ownerAvatarUrl;

  factory MyGitHubRepo.fromMap(Map<String, dynamic> map) {
    final owner = (map['owner'] as Map<String, dynamic>?) ?? const {};

    DateTime? parseDate(dynamic value) {
      if (value is! String || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    return MyGitHubRepo(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: (map['name'] as String?) ?? '',
      fullName: (map['full_name'] as String?) ?? '',
      htmlUrl: (map['html_url'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      language: (map['language'] as String?) ?? '',
      stargazersCount: (map['stargazers_count'] as num?)?.toInt() ?? 0,
      forksCount: (map['forks_count'] as num?)?.toInt() ?? 0,
      updatedAt: parseDate(map['updated_at']),
      ownerLogin: (owner['login'] as String?) ?? '',
      ownerAvatarUrl: (owner['avatar_url'] as String?) ?? '',
    );
  }
}
